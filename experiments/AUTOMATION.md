# Running an experiment with the automated loop

The loop in `PROCESS.md` (build -> blind held-out -> tournament -> iterate Decide/Revise/Re-run -> publish) is encoded as a dynamic workflow at `.claude/workflows/run-experiment.js`. It exists because the loop held unchanged across experiments 001, 002, and 003, so it is safe to automate (PROCESS.md: automate after the loop holds across >=2 experiments incl. a held-out result).

## How to use it

1. Write the one human-authored artifact: `experiments/NNN-name/charter.md` (use case + spectrum position, goal, bar = pass rate + safety floor, pre-registered scoring, divergent architectures, hypotheses, stopping criteria, budget). Cost is a signal, not part of the bar.
2. Launch the loop:

   ```
   Workflow({ scriptPath: ".claude/workflows/run-experiment.js", args: { dir: "experiments/NNN-name" } })
   ```

   Optional args: `trials` (default 2), `maxIterations` (default 3).

## What it does without you

- Builds the dev world, discriminating tasks, the charter's architectures, and the rig (reusing the most recent experiment's rig).
- Has a blind agent author an unseen held-out world and tasks.
- Runs the tournament on dev + held-out, then iterates Decide -> Revise (one variable) -> Re-run until a stopping criterion or the iteration cap.
- Publishes the takeaway, updates `HYPOTHESES.md` and `FINDINGS/`, and writes a `CHANGELOG.md` entry.

## What it surfaces to you (operator-level forks only)

It returns `final_status` and stops for you on:
- a safety-floor breach by the system under test,
- the iteration/budget cap reached without a conclusion,
- an architecture-level direction change or charter change,
- anything irreversible or outward-facing.

It never weakens an expectation to force a pass, never tunes on the held-out world, and never patches machinery against observed held-out behavior (it reports that as a finding). Those guardrails are baked into every phase prompt and enforced by `PROCESS.md`.

## What it does NOT decide

Starting a new experiment, choosing the next use case or spectrum position, and changing a charter are operator decisions. The loop runs one chartered experiment to a takeaway; you choose what gets chartered.
