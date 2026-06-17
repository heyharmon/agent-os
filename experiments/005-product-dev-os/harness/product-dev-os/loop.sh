#!/usr/bin/env bash
# loop.sh <role> <task string>
# Invokes claude -p in the current working directory (the scratch brain) with
# the system prompt for <role> and writes a run record under runtime/runs/.
# Isolation (scratch dir, brain copy) is run-arch.sh's job; this runs where it
# is called from. Carried from 003's loop.sh; the only change is that the
# system prompt is selected by <role> so one harness drives every arm's agents
# (single, ingestor, planner, builder, validator). Every agent's cost lands in
# the same runtime/runs/ so the arm's total agent cost is the sum across roles.
set -uo pipefail

ROLE="${1:?usage: loop.sh <role> <task>}"
TASK="${2:?usage: loop.sh <role> <task>}"
HARNESS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_PROMPT_PATH="$HARNESS_DIR/prompts/${ROLE}.md"
[ -f "$SYSTEM_PROMPT_PATH" ] || { echo "no system prompt for role '$ROLE' at $SYSTEM_PROMPT_PATH" >&2; exit 1; }
MODEL="${AGENT_MODEL:-claude-sonnet-4-6}"
# Wall-clock cap on every claude -p call (seconds). Portable timeout via perl
# alarm since macOS has no coreutils `timeout`. A hung/over-budget call is killed
# and recorded as a failed run (OUTCOME=failed); run-arch.sh still snapshots and
# scores, so a timeout becomes a failed trial, not a hang. Mechanical rig fix.
AGENT_TIMEOUT="${AGENT_TIMEOUT:-600}"
run_with_timeout() {
  perl -e '
    my $t = shift @ARGV;
    my $pid = fork();
    if ($pid == 0) { exec @ARGV or exit 127; }
    local $SIG{ALRM} = sub { kill "TERM", $pid; sleep 3; kill "KILL", $pid; exit 124; };
    alarm $t;
    waitpid($pid, 0);
    exit($? >> 8);
  ' "$@"
}

RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)-${ROLE}-$RANDOM"
START=$(date +%s)
OUTCOME=ok

mkdir -p runtime/drafts runtime/plans runtime/handoffs runtime/reports \
  runtime/issues runtime/queue/approvals runtime/runs

# stdin from /dev/null: stops claude's "no stdin data received in 3s" warning
# from being interleaved into the captured stdout and corrupting the JSON
# envelope (which zeroed out provider cost/tokens under concurrent load).
RESP=$(run_with_timeout "$AGENT_TIMEOUT" claude -p --output-format json \
  --model "$MODEL" \
  --dangerously-skip-permissions \
  --append-system-prompt "$(cat "$SYSTEM_PROMPT_PATH")" \
  "$TASK" </dev/null 2>&1) || OUTCOME=failed

DUR=$(( $(date +%s) - START ))

RECORD_PATH="runtime/runs/${RUN_ID}.json"
RESP="$RESP" RUN_ID="$RUN_ID" ROLE="$ROLE" OUTCOME="$OUTCOME" DUR="$DUR" \
RECORD_PATH="$RECORD_PATH" python3 - <<'PY'
import json, os

resp = os.environ["RESP"]
def _parse(s):
    try:
        return json.loads(s)
    except Exception:
        pass
    # Defensive: strip any leading non-JSON noise (e.g. a stderr warning that
    # leaked into the capture) and parse the first balanced JSON object.
    i = s.find("{")
    if i >= 0:
        try:
            return json.loads(s[i:])
        except Exception:
            import re as _re
            m = _re.search(r"\{.*\}", s, _re.DOTALL)
            if m:
                try:
                    return json.loads(m.group(0))
                except Exception:
                    pass
    return {}
d = _parse(resp)

usage = d.get("usage", {}) if isinstance(d, dict) else {}

def g(obj, key, default=None):
    if isinstance(obj, dict):
        return obj.get(key, default)
    return default

def n(x):
    return x if isinstance(x, (int, float)) else 0

uncached = n(g(usage, "input_tokens"))
cache_read = n(g(usage, "cache_read_input_tokens"))
cache_creation = n(g(usage, "cache_creation_input_tokens"))
input_total = uncached + cache_read + cache_creation

cost = g(d, "total_cost_usd")
rec = {
    "run_id": os.environ["RUN_ID"],
    "role": os.environ["ROLE"],
    "trigger": "task",
    "duration_s": int(os.environ["DUR"]),
    "outcome": os.environ["OUTCOME"],
    "tokens_in": input_total,
    "tokens_in_uncached": uncached,
    "tokens_cache_read": cache_read,
    "tokens_cache_creation": cache_creation,
    "tokens_out": g(usage, "output_tokens"),
    "cost_usd": (round(cost, 6) if isinstance(cost, (int, float)) else None),
    "num_turns": g(d, "num_turns"),
    "result": g(d, "result"),
    "session_id": g(d, "session_id"),
    "is_error": g(d, "is_error"),
}
with open(os.environ["RECORD_PATH"], "w") as f:
    json.dump(rec, f, indent=2)
print(os.environ["RECORD_PATH"])
PY

printf '%s' "$RESP" > "runtime/runs/${RUN_ID}.raw.json"
