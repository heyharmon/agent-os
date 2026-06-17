#!/usr/bin/env bash
# tournament.sh [ARCHSET] [WORLD] [TASKSET] [TRIALS]
#
# Runs the 4-arm ladder on one (world, taskset), N trials each (default 2), via
# bin/run-arch.sh, then emits the comparison table via bin/compare.py.
#
# Args (all optional):
#   ARCHSET  comma-separated arms (default "S,M,MI,F")
#   WORLD    world dir under worlds/ (default "dev")
#   TASKSET  taskset file under tasks/ (default "dev.yaml")
#   TRIALS   trials per task (default 2)
#
# Cost is a REPORTED signal, never a pass/fail gate. The headline is held-out
# pass rate and the dev-vs-held-out gap; the comparison prints per arm pass
# rate, gen gap, agent cost, and judge cost, read from the per-task score.json
# the runner wrote from provider JSON.
set -uo pipefail

ARCHSET="${1:-S,M,MI,F}"
WORLD="${2:-dev}"
TASKSET="${3:-dev.yaml}"
TRIALS="${4:-2}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

IFS=',' read -r -a ARCHS <<< "$ARCHSET"
for ARCH in "${ARCHS[@]}"; do
  echo "########## tournament: $ARCH on $WORLD / $TASKSET ($TRIALS trials) ##########"
  bash "$EXP_DIR/bin/run-arch.sh" "$ARCH" "$WORLD" "$TASKSET" "$TRIALS"
done

echo
echo "########## comparison ##########"
python3 "$EXP_DIR/bin/compare.py" --archs "$ARCHSET" --world "$WORLD"
