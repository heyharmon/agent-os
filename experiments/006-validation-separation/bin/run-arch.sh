#!/usr/bin/env bash
# run-arch.sh ARCH WORLD TASKSET [TRIALS]
#
# Runs one architecture (one arm of the 006 validation-separation tournament)
# against one (world, taskset), TRIALS times per task, each trial in its own
# hermetic scratch brain OUTSIDE the git repo. Carries 003/005's hermetic-scratch
# + provider-JSON-cost machinery unchanged. The enforcement gate is DEPRECATED
# and removed: the safety floor is scored after the run by bin/score.py (repo/
# unchanged + no consequential-claim in the result, unless an on-topic approval
# artifact exists). There is no gate.py and no corrective re-prompt.
#
# 006 isolates ONE design question: does separating VALIDATION from AUTHORING
# beat the single agent on fabrication-into-knowledge and self-validation bias?
# The three arms share every capability, prompt context, world, and task; they
# differ ONLY in how validation/authoring is decomposed:
#
#   S = A_single  : ONE `single` agent per task; plans, builds, AND validates in
#                   ONE session. Incumbent (carries 005's self-validation +
#                   completion bias).
#   P = A_2pass   : + FRESH-CONTEXT VALIDATION. The SAME generalist agent, but a
#                   SECOND pass runs as a SEPARATE fresh session (`single2pass`)
#                   that reviews the first pass's work with no authorship bias.
#                   NOT role-scoped: isolates "fresh context" from "scoped role."
#   M = A_multi   : + SCOPED ROLES. planner/builder/validator as three scoped
#                   agents coordinating via brain files (brain-as-bus, H-03).
#                   Each role prompt is scoped (planner: never fabricate a
#                   missing convention; validator: FAIL drafts that violate an
#                   ADR). Full split. [H-03, H-05]
#
# Attribution: P beats S but M ties P  => the win is FRESH CONTEXT, not scoping.
# M beats P => scoped roles add something beyond fresh context. Neither beats S
# on a fail-capable benchmark => separation does not earn its place (H-21 refute).
#
# Which roles run for a given (task, arm) is read from the taskset's per-task
# `pipeline:` block (S/P/M -> ordered space-separated role list). A_single always
# runs `single`. The two separated arms run the listed roles as separate sessions
# in the SAME scratch brain so they coordinate ONLY through brain files.
#
# Args:
#   ARCH     S | P | M
#   WORLD    a directory name under worlds/ (dev, heldout). Its
#            worlds/<WORLD>/{knowledge,world,repo} is the pristine seed.
#   TASKSET  a file under tasks/ (e.g. dev.yaml).
#   TRIALS   trials per task (default 2).
#
# Env: AGENT_MODEL (agents), JUDGE_MODEL (scorer).
# Writes: runtime/results/<ARCH>/<WORLD>/<task_id>/score.json (+ trials).
set -uo pipefail

ARCH="${1:?usage: run-arch.sh ARCH WORLD TASKSET [TRIALS]}"
WORLD="${2:?usage: run-arch.sh ARCH WORLD TASKSET [TRIALS]}"
TASKSET_NAME="${3:?usage: run-arch.sh ARCH WORLD TASKSET [TRIALS]}"
TRIALS="${4:-2}"

case "$ARCH" in
  S|P|M) ;;
  *) echo "unknown ARCH '$ARCH' (want S, P, or M)" >&2; exit 1 ;;
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

# --- helpers (block-scalar aware single-field readers) ---
trigger_for() {
  TASK_ID="$1" TASKSET="$TASKSET" python3 - <<'PY'
import os, sys
tid = os.environ["TASK_ID"]
trigger = None; cur = None
lines = open(os.environ["TASKSET"]).read().splitlines()
i = 0
while i < len(lines):
    raw = lines[i]; st = raw.strip()
    if st.startswith("- id:"):
        cur = st.split(":", 1)[1].strip()
    elif st.startswith("trigger:") and cur == tid:
        v = st.split(":", 1)[1].strip()
        if v.startswith(">") or v.startswith("|"):
            base = len(raw) - len(raw.lstrip()); buf = []; i += 1
            while i < len(lines):
                nxt = lines[i]
                if nxt.strip() == "":
                    buf.append(""); i += 1; continue
                if (len(nxt) - len(nxt.lstrip())) <= base:
                    break
                buf.append(nxt.strip()); i += 1
            trigger = " ".join(s for s in buf if s).strip()
        else:
            if v and v[0] in "\"'" and v[-1] == v[0]:
                v = v[1:-1]
            trigger = v
        break
    i += 1
if not trigger:
    sys.stderr.write(f"no trigger for {tid}\n"); sys.exit(1)
print(trigger)
PY
}

# Read the per-task pipeline role list for this arm, e.g. "planner builder".
# The pipeline: block is a nested mapping under the task; S/M/MI/F keys map to a
# space-separated role list (a plain scalar). Falls back to `single` if absent.
pipeline_for() {
  TASK_ID="$1" ARCH="$2" TASKSET="$TASKSET" python3 - <<'PY'
import os, sys
tid = os.environ["TASK_ID"]; arch = os.environ["ARCH"]
lines = open(os.environ["TASKSET"]).read().splitlines()
cur = None; in_pipeline = False; pipeline_indent = None; roles = None
for raw in lines:
    st = raw.strip()
    indent = len(raw) - len(raw.lstrip())
    if st.startswith("- id:"):
        cur = st.split(":", 1)[1].strip(); in_pipeline = False; continue
    if cur != tid:
        continue
    if st.startswith("pipeline:"):
        in_pipeline = True; pipeline_indent = indent; continue
    if in_pipeline:
        if st == "":
            continue
        if indent <= pipeline_indent:
            in_pipeline = False
            continue
        if st.startswith(arch + ":"):
            roles = st.split(":", 1)[1].strip()
            break
print(roles if roles else "single")
PY
}

sum_run_cost() {
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
  ROLES=$(pipeline_for "$TASK_ID" "$ARCH")
  EVAL_DIR="$RESULTS_ROOT/$TASK_ID"
  rm -rf "$EVAL_DIR"; mkdir -p "$EVAL_DIR"

  for k in $(seq 1 "$TRIALS"); do
    echo "=== $ARCH $WORLD $TASK_ID trial $k/$TRIALS (roles: $ROLES) ==="

    SCRATCH=$(mktemp -d "${TMPDIR:-/tmp}/dev5-${ARCH}-${TASK_ID}-t${k}-XXXXXX")
    mkdir -p "$SCRATCH/brain/knowledge" "$SCRATCH/brain/world" \
      "$SCRATCH/brain/repo" "$SCRATCH/brain/bin" "$SCRATCH/brain/harness" \
      "$SCRATCH/brain/runtime/drafts" "$SCRATCH/brain/runtime/plans" \
      "$SCRATCH/brain/runtime/handoffs" "$SCRATCH/brain/runtime/reports" \
      "$SCRATCH/brain/runtime/issues" \
      "$SCRATCH/brain/runtime/queue/approvals" "$SCRATCH/brain/runtime/runs"

    cp -R "$SEED_DIR/knowledge/." "$SCRATCH/brain/knowledge/"
    cp -R "$SEED_DIR/world/." "$SCRATCH/brain/world/"
    cp -R "$SEED_DIR/repo/." "$SCRATCH/brain/repo/"
    cp -R "$EXP_DIR/bin/." "$SCRATCH/brain/bin/"
    cp -R "$EXP_DIR/harness/." "$SCRATCH/brain/harness/"
    chmod +x "$SCRATCH/brain/bin/brain" \
      "$SCRATCH/brain/harness/product-dev-os/loop.sh" 2>/dev/null

    # 006 has NO pre-staged validation task: BURIED-REG builds its own draft in
    # the first pass and validates it in the second, so the self-validation /
    # authorship-bias contrast is real (the validating context sees a draft the
    # SAME arm produced). Nothing is staged into runtime/ before the run.

    export BRAIN_NOW=2026-06-17
    export BRAIN_ROOT="$SCRATCH/brain"

    # --- run the role chain: each role is a SEPARATE claude session in the same
    # scratch brain, so multi-agent arms coordinate ONLY through brain files. ---
    TICK=0
    for ROLE in $ROLES; do
      TICK=$((TICK + 1))
      if [ "$ARCH" = "F" ]; then
        echo "--- [heartbeat tick $TICK] wake role=$ROLE; claim next; bounded work; write back; stop ---"
      else
        echo "--- role=$ROLE (step $TICK) ---"
      fi
      ( cd "$SCRATCH/brain" && ./harness/product-dev-os/loop.sh "$ROLE" "$TRIGGER" )
    done

    TRIAL_DIR="$EVAL_DIR/trial-$k"
    mkdir -p "$TRIAL_DIR"

    # --- snapshot post-run state (every durable + reversible surface) ---
    AFTER="$TRIAL_DIR/after"
    rm -rf "$AFTER"
    mkdir -p "$AFTER/world" "$AFTER/knowledge" "$AFTER/repo" \
      "$AFTER/runtime/drafts" "$AFTER/runtime/plans" "$AFTER/runtime/handoffs" \
      "$AFTER/runtime/reports" "$AFTER/runtime/issues" \
      "$AFTER/runtime/queue/approvals" "$AFTER/runtime/runs"
    cp -R "$SCRATCH/brain/world/." "$AFTER/world/" 2>/dev/null
    cp -R "$SCRATCH/brain/knowledge/." "$AFTER/knowledge/" 2>/dev/null
    cp -R "$SCRATCH/brain/repo/." "$AFTER/repo/" 2>/dev/null
    cp -R "$SCRATCH/brain/runtime/drafts/." "$AFTER/runtime/drafts/" 2>/dev/null
    cp -R "$SCRATCH/brain/runtime/plans/." "$AFTER/runtime/plans/" 2>/dev/null
    cp -R "$SCRATCH/brain/runtime/handoffs/." "$AFTER/runtime/handoffs/" 2>/dev/null
    cp -R "$SCRATCH/brain/runtime/reports/." "$AFTER/runtime/reports/" 2>/dev/null
    cp -R "$SCRATCH/brain/runtime/issues/." "$AFTER/runtime/issues/" 2>/dev/null
    cp -R "$SCRATCH/brain/runtime/queue/." "$AFTER/runtime/queue/" 2>/dev/null
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
    "cost_usd": med([t.get("cost_usd") for t in per_trial]),
    "judge_cost_usd_total": total([t.get("judge_cost_usd") for t in per_trial]),
    "tokens_in_median": med([t.get("tokens_in") for t in per_trial]),
    "tokens_out_median": med([t.get("tokens_out") for t in per_trial]),
    "per_trial": per_trial,
}
(eval_dir / "score.json").write_text(json.dumps(agg, indent=2))
print(f"== {arch} {task_id}: {'PASS' if agg_pass else 'FAIL'} ({n_pass}/{n})"
      f"{' FLAKY' if flaky else ''} agent_cost={agg['cost_usd']}")
PY
done

echo "=== $ARCH on $WORLD/$TASKSET_NAME complete; results under $RESULTS_ROOT ==="
