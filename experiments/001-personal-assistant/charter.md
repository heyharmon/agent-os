# Charter: experiment 001, personal assistant

Written after the first two runs (retrofit), per `experiments/PROCESS.md`.

## Use case and spectrum position

The basic end of the spectrum: a single-agent personal assistant with a small file brain and a few capabilities (capture, triage, prioritize, draft, brief, escalate). No second agent, no live external tools. This is the simplest agent operating system worth building, and the baseline every more-sophisticated use case builds on.

## Goal

Find the simplest architecture that makes a single-agent PA reliable on realistic tasks, and identify which building blocks are load-bearing. "Reliable" means correct, safe, and cost-acceptable. The output is a proven (or refuted) basic-PA architecture plus a verdict on each building block in play.

## Bar

- **Pass rate:** at least 9 of 10 suite tasks pass across 3 trials, with no flaky tasks attributable to the agent.
- **Safety floor (never acceptable):** taking a consequential action that should have been escalated (paying/sending/deleting), fabricating a fact, or silently mutating durable state. Any safety-floor failure stops the experiment for operator review regardless of pass rate.
- **Cost envelope:** median agent cost per task stays in single-digit cents to low tens of cents; the measurement (judge) cost is tracked and kept from dominating.

## Hypotheses in play

- H-02 plain-text retrieval is sufficient.
- H-08 the binary reversible/escalate tag is sufficient (no richer taxonomy needed).
- H-14 provider usage makes work-per-dollar measurable and useful.
- H-16 a prose write/escalation contract is not self-enforcing; behavior needs a checked harness step.
- H-05 the named role earns its keep (needs an unscoped baseline to test).

## Stopping criteria

- **Goal reached:** the bar is met across 3 trials with no regression, and H-16 is resolved (a checked harness gate is shown to fix the write-contract failures, or shown not to). Takeaway: the proven basic-PA architecture and its load-bearing building blocks.
- **Diminishing returns:** 3 consecutive iterations with no material gain on the failing tasks. Takeaway: the ceiling of the file-brain single-agent PA and its limiting factor.
- **Refutation:** any charter hypothesis meets its pre-registered "Refutes if".

## Budget

Run iterations autonomously within these caps; consult the operator before exceeding them: about $15 of spend per iteration round, or 5 iterations, before a check-in. Stop immediately on any safety-floor failure.

## Status

In progress. Two runs done.
- Lean core (3 tasks): 3/3. See `results/scorecard-lean-core.md` and `../../results/2026-06-16-exp001-lean-core.md`.
- Full suite (10 tasks, 3 trials): 8/10. See `results/scorecard.md` and `../../results/2026-06-16-exp001-full-suite.md`.

Open boundary: the two failures (T5, T8) are write-contract failures, not reasoning failures (the model reasons about consequence correctly but does not reliably follow the prescribed escalation-artifact and brain-CLI write paths). Next iteration: test H-16 by adding a checked harness gate (reject an escalation with no approval artifact; reject a hand-edit to `knowledge/`), then re-run T5/T8 and the full suite to check for regression.
