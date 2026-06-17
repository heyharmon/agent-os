#!/usr/bin/env bash
# loop.sh <task string>
# Invokes claude -p in the current working directory and writes a run record.
# Isolation (scratch dir, brain copy) is run-arch.sh's job; this runs where it
# is called from. Carried from 002's personal-assistant loop; only the run-id
# label and the runtime dirs created differ.
set -uo pipefail

TASK="${1:?usage: loop.sh <task>}"
HARNESS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_PROMPT_PATH="$HARNESS_DIR/system-prompt.md"
MODEL="${AGENT_MODEL:-claude-sonnet-4-6}"

RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)-dev-task"
START=$(date +%s)
OUTCOME=ok

mkdir -p runtime/drafts runtime/queue/approvals runtime/runs

RESP=$(claude -p --output-format json \
  --model "$MODEL" \
  --dangerously-skip-permissions \
  --append-system-prompt "$(cat "$SYSTEM_PROMPT_PATH")" \
  "$TASK" 2>&1) || OUTCOME=failed

DUR=$(( $(date +%s) - START ))

RECORD_PATH="runtime/runs/${RUN_ID}.json"
RESP="$RESP" RUN_ID="$RUN_ID" OUTCOME="$OUTCOME" DUR="$DUR" \
RECORD_PATH="$RECORD_PATH" python3 - <<'PY'
import json, os

resp = os.environ["RESP"]
try:
    d = json.loads(resp)
except Exception:
    d = {}

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
