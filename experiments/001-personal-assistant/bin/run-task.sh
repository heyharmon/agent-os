#!/usr/bin/env bash
# run-task.sh <task_id>
# Runs one benchmark task TRIALS times (default 3), each in its own hermetic
# scratch brain OUTSIDE the git repo (so the agent-under-test does not inherit
# the repo's root CLAUDE.md), snapshots each trial under
# runtime/evals/<task_id>/trial-<k>/after/, scores each trial, then aggregates.
#
# Env:
#   TRIALS       number of trials (default 3). TRIALS=1 keeps the single-trial layout.
#   AGENT_MODEL  agent-under-test model (default in loop.sh: claude-sonnet-4-6).
#   JUDGE_MODEL  judge model (default in score.py: claude-sonnet-4-6).
#   GATE         OFF by default. GATE=1 enables the H-16 checked harness gate:
#                after the agent runs, bin/gate.py checks the write/escalation
#                contract; on a violation the harness does ONE corrective
#                re-prompt (re-invokes the agent in the SAME scratch brain with a
#                correction naming the broken rule), then re-checks. The
#                corrective pass is real spend and is counted into the agent run
#                records; a gate.json per trial records what fired and whether
#                the correction resolved it. With GATE unset, behavior is exactly
#                as before (no gate, no re-prompt).
set -uo pipefail

TASK_ID="${1:?usage: run-task.sh <task_id>}"
TRIALS="${TRIALS:-3}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Read the task trigger from tasks.yaml.
TRIGGER=$(TASK_ID="$TASK_ID" EXP_DIR="$EXP_DIR" python3 - <<'PY'
import os, sys
exp = os.environ["EXP_DIR"]
tid = os.environ["TASK_ID"]
path = os.path.join(exp, "tasks", "tasks.yaml")
trigger = None
cur = None
for line in open(path):
    s = line.rstrip("\n")
    st = s.strip()
    if st.startswith("- id:"):
        cur = st.split(":", 1)[1].strip()
    elif st.startswith("trigger:") and cur == tid:
        v = st.split(":", 1)[1].strip()
        if v and v[0] in "\"'" and v[-1] == v[0]:
            v = v[1:-1]
        trigger = v
        break
if trigger is None:
    sys.stderr.write(f"no trigger for task {tid}\n")
    sys.exit(1)
print(trigger)
PY
) || exit 1

EVAL_DIR="$EXP_DIR/runtime/evals/$TASK_ID"
# Clear prior trial dirs for this task so aggregation is clean.
rm -rf "$EVAL_DIR"
mkdir -p "$EVAL_DIR"

for k in $(seq 1 "$TRIALS"); do
  echo "=== task $TASK_ID trial $k/$TRIALS ==="

  # 1. Scratch dir OUTSIDE the repo.
  SCRATCH=$(mktemp -d "${TMPDIR:-/tmp}/pa-${TASK_ID}-t${k}-XXXXXX")
  mkdir -p "$SCRATCH/brain/knowledge" "$SCRATCH/brain/world" \
    "$SCRATCH/brain/bin" "$SCRATCH/brain/harness"
  mkdir -p "$SCRATCH/brain/runtime/drafts" \
    "$SCRATCH/brain/runtime/queue/approvals" \
    "$SCRATCH/brain/runtime/briefings" \
    "$SCRATCH/brain/runtime/runs"

  # Hermetic reset: pristine knowledge/ + world/ from seed/.
  cp -R "$EXP_DIR/seed/knowledge/." "$SCRATCH/brain/knowledge/"
  cp -R "$EXP_DIR/seed/world/." "$SCRATCH/brain/world/"
  cp -R "$EXP_DIR/bin/." "$SCRATCH/brain/bin/"
  cp -R "$EXP_DIR/harness/." "$SCRATCH/brain/harness/"
  chmod +x "$SCRATCH/brain/bin/brain" "$SCRATCH/brain/bin/run-task.sh" \
    "$SCRATCH/brain/harness/personal-assistant/loop.sh" 2>/dev/null

  # 2. Reproducible date + brain root. Run the harness from the scratch brain.
  export BRAIN_NOW=2026-06-16
  export BRAIN_ROOT="$SCRATCH/brain"
  ( cd "$SCRATCH/brain" && ./harness/personal-assistant/loop.sh "$TRIGGER" )

  # 2b. H-16 checked harness gate (opt-in via GATE=1). Generic: enforces the
  #     write/escalation contract; never reads the task id. On a violation it
  #     does ONE corrective re-prompt in the SAME scratch brain, then re-checks.
  #     The corrective loop.sh run writes its own record into runtime/runs/, so
  #     its cost is folded into the agent cost the scorer aggregates; gate.json
  #     keeps the gate's effect and cost visible per trial.
  if [ "${GATE:-0}" = "1" ]; then
    GATE_TRIAL_DIR="$EVAL_DIR/trial-$k"
    mkdir -p "$GATE_TRIAL_DIR"

    # Cost of the agent's runs BEFORE any corrective pass (to attribute gate cost).
    COST_BEFORE=$(BRAIN_ROOT="$BRAIN_ROOT" python3 - <<'PY'
import os, json, glob
runs = os.path.join(os.environ["BRAIN_ROOT"], "runtime", "runs")
tot = 0.0
for f in glob.glob(os.path.join(runs, "*.json")):
    if f.endswith(".raw.json"):
        continue
    try:
        c = json.load(open(f)).get("cost_usd")
    except Exception:
        c = None
    if isinstance(c, (int, float)):
        tot += c
print(repr(tot))
PY
)

    CHECK1=$(python3 "$EXP_DIR/bin/gate.py" check "$BRAIN_ROOT" "$EXP_DIR/seed")
    FIRED1=$(printf '%s' "$CHECK1" | python3 -c 'import sys,json; print("1" if json.load(sys.stdin)["fired"] else "0")')

    CORRECTED=0
    CHECK2=""
    if [ "$FIRED1" = "1" ]; then
      CORRECTED=1
      CORRECTION=$(printf '%s' "$CHECK1" | python3 -c 'import sys,json; print(json.load(sys.stdin)["correction"] or "")')
      echo "--- gate fired; one corrective re-prompt ---"
      ( cd "$SCRATCH/brain" && ./harness/personal-assistant/loop.sh "$CORRECTION" )
      CHECK2=$(python3 "$EXP_DIR/bin/gate.py" check "$BRAIN_ROOT" "$EXP_DIR/seed")
    fi

    COST_AFTER=$(BRAIN_ROOT="$BRAIN_ROOT" python3 - <<'PY'
import os, json, glob
runs = os.path.join(os.environ["BRAIN_ROOT"], "runtime", "runs")
tot = 0.0
for f in glob.glob(os.path.join(runs, "*.json")):
    if f.endswith(".raw.json"):
        continue
    try:
        c = json.load(open(f)).get("cost_usd")
    except Exception:
        c = None
    if isinstance(c, (int, float)):
        tot += c
print(repr(tot))
PY
)

    # Record what the gate did this trial: fired?, which rules, did the
    # correction resolve it?, and the corrective re-prompt's cost (gate_cost_usd).
    CHECK1="$CHECK1" CHECK2="$CHECK2" CORRECTED="$CORRECTED" \
    COST_BEFORE="$COST_BEFORE" COST_AFTER="$COST_AFTER" \
    GATE_OUT="$GATE_TRIAL_DIR/gate.json" python3 - <<'PY'
import os, json
c1 = json.loads(os.environ["CHECK1"]) if os.environ["CHECK1"].strip() else {}
c2 = json.loads(os.environ["CHECK2"]) if os.environ["CHECK2"].strip() else None
corrected = os.environ["CORRECTED"] == "1"
try:
    before = float(os.environ["COST_BEFORE"])
    after = float(os.environ["COST_AFTER"])
    gate_cost = round(max(0.0, after - before), 6)
except ValueError:
    gate_cost = None
fired = bool(c1.get("fired"))
resolved = (not c2.get("fired")) if (corrected and c2 is not None) else None
out = {
    "gate_enabled": True,
    "fired": fired,
    "rules_fired": c1.get("rules_fired", []),
    "violations": c1.get("violations", []),
    "corrected": corrected,                 # was the single corrective pass used?
    "resolved": resolved,                   # did the re-check pass after correction?
    "rules_fired_after": (c2.get("rules_fired", []) if c2 is not None else None),
    "gate_cost_usd": gate_cost,             # cost of the corrective re-prompt (real spend)
    "escalation_signals_matched": c1.get("escalation_signals_matched", []),
    "knowledge_changed": c1.get("knowledge_changed", []),
    "check_before": c1,
    "check_after": c2,
}
open(os.environ["GATE_OUT"], "w").write(json.dumps(out, indent=2))
print(f"== gate: fired={fired} rules={c1.get('rules_fired', [])} "
      f"corrected={corrected} resolved={resolved} gate_cost_usd={gate_cost}")
PY
  fi

  # 3. Snapshot post-run state. Capture every surface the agent could write:
  #    world/, the filed knowledge/ tree, drafts, the whole queue (approvals +
  #    queued tasks), briefings, and the provider run records.
  AFTER="$EVAL_DIR/trial-$k/after"
  rm -rf "$AFTER"
  mkdir -p "$AFTER/world" "$AFTER/knowledge" \
    "$AFTER/runtime/drafts" "$AFTER/runtime/queue/approvals" \
    "$AFTER/runtime/briefings" "$AFTER/runtime/runs"
  cp -R "$SCRATCH/brain/world/." "$AFTER/world/" 2>/dev/null
  cp -R "$SCRATCH/brain/knowledge/." "$AFTER/knowledge/" 2>/dev/null
  cp -R "$SCRATCH/brain/runtime/drafts/." "$AFTER/runtime/drafts/" 2>/dev/null
  cp -R "$SCRATCH/brain/runtime/queue/." "$AFTER/runtime/queue/" 2>/dev/null
  cp -R "$SCRATCH/brain/runtime/briefings/." "$AFTER/runtime/briefings/" 2>/dev/null
  cp -R "$SCRATCH/brain/runtime/runs/." "$AFTER/runtime/runs/" 2>/dev/null
  # brain-writes.log: score_T8 reads it to confirm knowledge/ writes went
  # through ./bin/brain (a knowledge/ change with no matching log line is a
  # hand-edit). Copy it if the agent produced any brain-mediated write.
  cp "$SCRATCH/brain/runtime/brain-writes.log" "$AFTER/runtime/brain-writes.log" 2>/dev/null

  # 4. Score this trial.
  python3 "$EXP_DIR/bin/score.py" "$TASK_ID" "$EVAL_DIR/trial-$k"
done

# 5. Aggregate across trials -> runtime/evals/<task_id>/score.json
TASK_ID="$TASK_ID" EVAL_DIR="$EVAL_DIR" TRIALS="$TRIALS" python3 - <<'PY'
import os, json, glob, statistics, pathlib

task_id = os.environ["TASK_ID"]
eval_dir = pathlib.Path(os.environ["EVAL_DIR"])
trials = int(os.environ["TRIALS"])

per_trial = []
for k in range(1, trials + 1):
    sj = eval_dir / f"trial-{k}" / "score.json"
    if sj.exists():
        try:
            per_trial.append(json.loads(sj.read_text()))
        except ValueError:
            pass

passes = [t["pass"] for t in per_trial]
n = len(passes)
n_pass = sum(1 for p in passes if p)
# Majority of trials pass. Ties (even N) require a strict majority.
agg_pass = (n_pass * 2) > n if n else False
flaky = (0 < n_pass < n)

def med(vals):
    vals = [v for v in vals if isinstance(v, (int, float))]
    return round(statistics.median(vals), 6) if vals else None

def mn(vals):
    vals = [v for v in vals if isinstance(v, (int, float))]
    return round(min(vals), 6) if vals else None

def mx(vals):
    vals = [v for v in vals if isinstance(v, (int, float))]
    return round(max(vals), 6) if vals else None

agent_costs = [t.get("cost_usd") for t in per_trial]
judge_costs = [t.get("judge_cost_usd") for t in per_trial]
judge_scores = [t.get("judge_score") for t in per_trial if isinstance(t.get("judge_score"), int)]

agg = {
    "task_id": task_id,
    "scoring": per_trial[0]["scoring"] if per_trial else None,
    "trials": n,
    "pass": agg_pass,
    "pass_count": n_pass,
    "flaky": flaky,
    "cost_usd": med(agent_costs),          # median agent cost across trials
    "cost_usd_min": mn(agent_costs),
    "cost_usd_max": mx(agent_costs),
    "judge_cost_usd_total": round(sum(c for c in judge_costs if isinstance(c, (int, float))), 6)
        if any(isinstance(c, (int, float)) for c in judge_costs) else None,
    "judge_score_median": (int(statistics.median(judge_scores))
                           if judge_scores else None),
    "judge_model": per_trial[0].get("judge_model") if per_trial else None,
    "tokens_in_median": med([t.get("tokens_in") for t in per_trial]),
    "tokens_out_median": med([t.get("tokens_out") for t in per_trial]),
    "per_trial": per_trial,
}
(eval_dir / "score.json").write_text(json.dumps(agg, indent=2))

print(f"== {task_id}: {'PASS' if agg_pass else 'FAIL'} "
      f"({n_pass}/{n} trials){' FLAKY' if flaky else ''} "
      f"median_cost={agg['cost_usd']} judge_cost_total={agg['judge_cost_usd_total']}")
PY
