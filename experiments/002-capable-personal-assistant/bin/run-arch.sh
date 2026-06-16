#!/usr/bin/env bash
# run-arch.sh ARCH WORLD TASKSET [TRIALS]
#
# Runs one architecture against one (world, taskset), TRIALS times per task, each
# trial in its own hermetic scratch brain OUTSIDE the git repo (so the
# agent-under-test does not inherit the repo's root CLAUDE.md). Carries 001's
# hermetic-scratch + provider-JSON-cost machinery; the two architectures differ
# only in the post-run contract-enforcement step:
#
#   A1  carried single-agent + code-gate. The doer runs once; then bin/gate.py
#       (topic-blind, deterministic) checks the write/escalation contract and,
#       on a violation, the harness does ONE corrective re-prompt in the SAME
#       scratch brain. The corrective pass is real spend folded into the agent
#       cost; gate.json records what fired and its gate_cost_usd.
#
#   A2  doer + checker (two-agent). The doer runs once (same agent as A1); then
#       bin/checker.py (a SECOND claude -p agent) reviews the doer's final output
#       + the after-snapshot against the contract, judging artifact TOPICALITY
#       (is the escalation artifact about THIS task?) and writes-via-CLI, and
#       bounces ONE correction back to the doer if the contract is not met. The
#       checker call's own provider cost is read from its JSON envelope and
#       reported SEPARATELY as checker_cost_usd; the doer's corrective re-prompt
#       is folded into the agent cost. checker.json records the verdict + cost.
#
# Args:
#   ARCH     A1 | A2
#   WORLD    a directory name under worlds/ (e.g. dev, heldout). Its
#            worlds/<WORLD>/{knowledge,world} is the pristine seed.
#   TASKSET  a file under tasks/ (e.g. dev.yaml) listing the tasks to run.
#   TRIALS   trials per task (default 2).
#
# Env: AGENT_MODEL (doer), JUDGE_MODEL (scorer), CHECKER_MODEL (A2 checker).
#
# Writes per task: runtime/results/<ARCH>/<WORLD>/<task_id>/score.json (+ trials).
set -uo pipefail

ARCH="${1:?usage: run-arch.sh ARCH WORLD TASKSET [TRIALS]}"
WORLD="${2:?usage: run-arch.sh ARCH WORLD TASKSET [TRIALS]}"
TASKSET_NAME="${3:?usage: run-arch.sh ARCH WORLD TASKSET [TRIALS]}"
TRIALS="${4:-2}"

case "$ARCH" in
  A1|A2) ;;
  *) echo "unknown ARCH '$ARCH' (want A1 or A2)" >&2; exit 1 ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

SEED_DIR="$EXP_DIR/worlds/$WORLD"
TASKSET="$EXP_DIR/tasks/$TASKSET_NAME"
[ -d "$SEED_DIR/knowledge" ] || { echo "no seed at $SEED_DIR" >&2; exit 1; }
[ -f "$TASKSET" ] || { echo "no taskset at $TASKSET" >&2; exit 1; }

# The scorer reads the same world seed and taskset.
export SEED_DIR TASKSET

# Task ids from the taskset.
TASK_IDS=$(EXP_DIR="$EXP_DIR" TASKSET="$TASKSET" python3 - <<'PY'
import os
ids = []
for line in open(os.environ["TASKSET"]):
    s = line.strip()
    if s.startswith("- id:"):
        ids.append(s.split(":", 1)[1].strip())
print("\n".join(ids))
PY
)

RESULTS_ROOT="$EXP_DIR/runtime/results/$ARCH/$WORLD"
mkdir -p "$RESULTS_ROOT"

trigger_for() {
  TASK_ID="$1" TASKSET="$TASKSET" python3 - <<'PY'
import os, sys
tid = os.environ["TASK_ID"]
trigger = None; cur = None
for line in open(os.environ["TASKSET"]):
    st = line.strip()
    if st.startswith("- id:"):
        cur = st.split(":", 1)[1].strip()
    elif st.startswith("trigger:") and cur == tid:
        v = st.split(":", 1)[1].strip()
        if v and v[0] in "\"'" and v[-1] == v[0]:
            v = v[1:-1]
        trigger = v; break
if trigger is None:
    sys.stderr.write(f"no trigger for {tid}\n"); sys.exit(1)
print(trigger)
PY
}

sum_run_cost() {
  # total cost_usd across runtime/runs/*.json (skips .raw.json) under $1.
  BRAIN_ROOT="$1" python3 - <<'PY'
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
}

for TASK_ID in $TASK_IDS; do
  TRIGGER=$(trigger_for "$TASK_ID") || exit 1
  EVAL_DIR="$RESULTS_ROOT/$TASK_ID"
  rm -rf "$EVAL_DIR"; mkdir -p "$EVAL_DIR"

  for k in $(seq 1 "$TRIALS"); do
    echo "=== $ARCH $WORLD $TASK_ID trial $k/$TRIALS ==="

    SCRATCH=$(mktemp -d "${TMPDIR:-/tmp}/pa2-${ARCH}-${TASK_ID}-t${k}-XXXXXX")
    mkdir -p "$SCRATCH/brain/knowledge" "$SCRATCH/brain/world" \
      "$SCRATCH/brain/bin" "$SCRATCH/brain/harness" \
      "$SCRATCH/brain/runtime/drafts" \
      "$SCRATCH/brain/runtime/queue/approvals" \
      "$SCRATCH/brain/runtime/briefings" \
      "$SCRATCH/brain/runtime/runs"

    cp -R "$SEED_DIR/knowledge/." "$SCRATCH/brain/knowledge/"
    cp -R "$SEED_DIR/world/." "$SCRATCH/brain/world/"
    cp -R "$EXP_DIR/bin/." "$SCRATCH/brain/bin/"
    cp -R "$EXP_DIR/harness/." "$SCRATCH/brain/harness/"
    chmod +x "$SCRATCH/brain/bin/brain" \
      "$SCRATCH/brain/harness/personal-assistant/loop.sh" 2>/dev/null

    export BRAIN_NOW=2026-06-16
    export BRAIN_ROOT="$SCRATCH/brain"

    # --- doer runs (same agent for A1 and A2) ---
    ( cd "$SCRATCH/brain" && ./harness/personal-assistant/loop.sh "$TRIGGER" )

    TRIAL_DIR="$EVAL_DIR/trial-$k"
    mkdir -p "$TRIAL_DIR"

    COST_BEFORE=$(sum_run_cost "$BRAIN_ROOT")

    if [ "$ARCH" = "A1" ]; then
      # --- A1: deterministic code-gate + one corrective re-prompt ---
      CHECK1=$(python3 "$EXP_DIR/bin/gate.py" check "$BRAIN_ROOT" "$SEED_DIR")
      FIRED1=$(printf '%s' "$CHECK1" | python3 -c 'import sys,json; print("1" if json.load(sys.stdin)["fired"] else "0")')
      CORRECTED=0; CHECK2=""
      if [ "$FIRED1" = "1" ]; then
        CORRECTED=1
        CORRECTION=$(printf '%s' "$CHECK1" | python3 -c 'import sys,json; print(json.load(sys.stdin)["correction"] or "")')
        echo "--- A1 gate fired; one corrective re-prompt ---"
        ( cd "$SCRATCH/brain" && ./harness/personal-assistant/loop.sh "$CORRECTION" )
        CHECK2=$(python3 "$EXP_DIR/bin/gate.py" check "$BRAIN_ROOT" "$SEED_DIR")
      fi
      COST_AFTER=$(sum_run_cost "$BRAIN_ROOT")
      CHECK1="$CHECK1" CHECK2="$CHECK2" CORRECTED="$CORRECTED" \
      COST_BEFORE="$COST_BEFORE" COST_AFTER="$COST_AFTER" \
      GATE_OUT="$TRIAL_DIR/gate.json" python3 - <<'PY'
import os, json
c1 = json.loads(os.environ["CHECK1"]) if os.environ["CHECK1"].strip() else {}
c2 = json.loads(os.environ["CHECK2"]) if os.environ["CHECK2"].strip() else None
corrected = os.environ["CORRECTED"] == "1"
try:
    gate_cost = round(max(0.0, float(os.environ["COST_AFTER"]) - float(os.environ["COST_BEFORE"])), 6)
except ValueError:
    gate_cost = None
fired = bool(c1.get("fired"))
resolved = (not c2.get("fired")) if (corrected and c2 is not None) else None
open(os.environ["GATE_OUT"], "w").write(json.dumps({
    "enforcer": "code-gate",
    "fired": fired,
    "rules_fired": c1.get("rules_fired", []),
    "corrected": corrected,
    "resolved": resolved,
    "gate_cost_usd": gate_cost,        # corrective re-prompt cost (folded into agent cost)
    "checker_cost_usd": 0.0,           # A1 has no checker agent
    "check_before": c1,
    "check_after": c2,
}, indent=2))
print(f"== A1 gate: fired={fired} rules={c1.get('rules_fired', [])} "
      f"corrected={corrected} resolved={resolved} gate_cost_usd={gate_cost}")
PY

    else
      # --- A2: agent checker + one corrective bounce to the doer ---
      CHECK1=$(CHECKER_MODEL="${CHECKER_MODEL:-claude-sonnet-4-6}" \
        python3 "$EXP_DIR/bin/checker.py" check "$BRAIN_ROOT" "$SEED_DIR" "$TRIGGER")
      MEETS1=$(printf '%s' "$CHECK1" | python3 -c 'import sys,json; print("1" if json.load(sys.stdin).get("meets") else "0")')
      CHECKER_COST_1=$(printf '%s' "$CHECK1" | python3 -c 'import sys,json; c=json.load(sys.stdin).get("checker_cost_usd"); print(repr(c if isinstance(c,(int,float)) else 0.0))')
      CORRECTED=0; CHECK2=""; CHECKER_COST_2=0.0
      if [ "$MEETS1" = "0" ]; then
        CORRECTED=1
        CORRECTION=$(printf '%s' "$CHECK1" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("correction") or "")')
        if [ -n "$CORRECTION" ]; then
          echo "--- A2 checker bounced; one corrective re-prompt to doer ---"
          ( cd "$SCRATCH/brain" && ./harness/personal-assistant/loop.sh "$CORRECTION" )
          CHECK2=$(CHECKER_MODEL="${CHECKER_MODEL:-claude-sonnet-4-6}" \
            python3 "$EXP_DIR/bin/checker.py" check "$BRAIN_ROOT" "$SEED_DIR" "$TRIGGER")
          CHECKER_COST_2=$(printf '%s' "$CHECK2" | python3 -c 'import sys,json; c=json.load(sys.stdin).get("checker_cost_usd"); print(repr(c if isinstance(c,(int,float)) else 0.0))')
        fi
      fi
      COST_AFTER=$(sum_run_cost "$BRAIN_ROOT")
      CHECK1="$CHECK1" CHECK2="$CHECK2" CORRECTED="$CORRECTED" \
      COST_BEFORE="$COST_BEFORE" COST_AFTER="$COST_AFTER" \
      CHECKER_COST_1="$CHECKER_COST_1" CHECKER_COST_2="$CHECKER_COST_2" \
      GATE_OUT="$TRIAL_DIR/checker.json" python3 - <<'PY'
import os, json
c1 = json.loads(os.environ["CHECK1"]) if os.environ["CHECK1"].strip() else {}
c2 = json.loads(os.environ["CHECK2"]) if os.environ["CHECK2"].strip() else None
corrected = os.environ["CORRECTED"] == "1"
def f(x):
    try: return float(x)
    except ValueError: return 0.0
doer_corrective = round(max(0.0, f(os.environ["COST_AFTER"]) - f(os.environ["COST_BEFORE"])), 6)
checker_cost = round(f(os.environ["CHECKER_COST_1"]) + f(os.environ["CHECKER_COST_2"]), 6)
meets1 = bool(c1.get("meets"))
resolved = bool(c2.get("meets")) if (corrected and c2 is not None) else None
open(os.environ["GATE_OUT"], "w").write(json.dumps({
    "enforcer": "agent-checker",
    "fired": (not meets1),                 # checker bounced?
    "meets_first_pass": meets1,
    "corrected": corrected,
    "resolved": resolved,
    "gate_cost_usd": doer_corrective,      # doer's corrective re-prompt (folded into agent cost)
    "checker_cost_usd": checker_cost,      # the checker agent's own cost (reported separately)
    "reasons_first": c1.get("reasons"),
    "reasons_after": (c2.get("reasons") if c2 is not None else None),
    "knowledge_handedits": c1.get("knowledge_handedits"),
}, indent=2))
print(f"== A2 checker: meets1={meets1} corrected={corrected} resolved={resolved} "
      f"checker_cost_usd={checker_cost} doer_corrective={doer_corrective}")
PY
    fi

    # --- snapshot post-run state ---
    AFTER="$TRIAL_DIR/after"
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
    cp "$SCRATCH/brain/runtime/brain-writes.log" "$AFTER/runtime/brain-writes.log" 2>/dev/null

    # --- score this trial (outcome scorer; reads SEED_DIR + TASKSET from env) ---
    python3 "$EXP_DIR/bin/score.py" "$TASK_ID" "$TRIAL_DIR"
  done

  # --- aggregate across trials for this task ---
  TASK_ID="$TASK_ID" EVAL_DIR="$EVAL_DIR" TRIALS="$TRIALS" ARCH="$ARCH" python3 - <<'PY'
import os, json, statistics, pathlib
task_id = os.environ["TASK_ID"]
eval_dir = pathlib.Path(os.environ["EVAL_DIR"])
trials = int(os.environ["TRIALS"])
arch = os.environ["ARCH"]

per_trial = []
for k in range(1, trials + 1):
    sj = eval_dir / f"trial-{k}" / "score.json"
    if sj.exists():
        try:
            per_trial.append(json.loads(sj.read_text()))
        except ValueError:
            pass

# Enforcement (gate.json for A1, checker.json for A2) per trial.
enf_name = "gate.json" if arch == "A1" else "checker.json"
checker_costs, gate_costs = [], []
for k in range(1, trials + 1):
    ej = eval_dir / f"trial-{k}" / enf_name
    if ej.exists():
        try:
            e = json.loads(ej.read_text())
            checker_costs.append(e.get("checker_cost_usd"))
            gate_costs.append(e.get("gate_cost_usd"))
        except ValueError:
            pass

passes = [t["pass"] for t in per_trial]
n = len(passes); n_pass = sum(1 for p in passes if p)
agg_pass = (n_pass * 2) > n if n else False
flaky = (0 < n_pass < n)

def med(vals):
    vals = [v for v in vals if isinstance(v, (int, float))]
    return round(statistics.median(vals), 6) if vals else None

def total(vals):
    vals = [v for v in vals if isinstance(v, (int, float))]
    return round(sum(vals), 6) if vals else None

agg = {
    "task_id": task_id,
    "arch": arch,
    "scoring": per_trial[0]["scoring"] if per_trial else None,
    "trials": n,
    "pass": agg_pass,
    "pass_count": n_pass,
    "flaky": flaky,
    "cost_usd": med([t.get("cost_usd") for t in per_trial]),          # median agent cost
    "judge_cost_usd_total": total([t.get("judge_cost_usd") for t in per_trial]),
    "checker_cost_usd_total": total(checker_costs),                   # A2 checker (0 for A1)
    "gate_cost_usd_total": total(gate_costs),                         # corrective re-prompt
    "tokens_in_median": med([t.get("tokens_in") for t in per_trial]),
    "tokens_out_median": med([t.get("tokens_out") for t in per_trial]),
    "per_trial": per_trial,
}
(eval_dir / "score.json").write_text(json.dumps(agg, indent=2))
print(f"== {arch} {task_id}: {'PASS' if agg_pass else 'FAIL'} ({n_pass}/{n})"
      f"{' FLAKY' if flaky else ''} agent_cost={agg['cost_usd']} "
      f"checker_cost={agg['checker_cost_usd_total']}")
PY
done

echo "=== $ARCH on $WORLD/$TASKSET_NAME complete; results under $RESULTS_ROOT ==="
