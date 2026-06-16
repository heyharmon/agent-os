# FINDINGS

This directory is the project's authoritative output for builders. It maps what has actually been proven against the complexity spectrum from `VISION.md`, with honest confidence labels and links to the raw evidence in `results/`.

Nothing here is asserted without a run behind it. "SUPPORTED-but-thin" means: one experiment, one world, evidence exists but generalizability is not yet shown.

## How to read this

`VISION.md` defines a spectrum of use-case sophistication. This map shows where proven results sit today. Every position not labeled is UNTESTED at the architecture level (individual hypotheses may be in play but no architecture conclusion has been reached).

```
basic ----------------------------------------------------> sophisticated

[001] single-agent PA         a PA that does more        multi-agent OS,
      few tools (schedule,    (more tools, more           many tools,
      reminders, draft,       surface, richer brain)      coordination,
      triage, escalate)                                   autonomy
      simple file brain
                                                          other domains:
                                                          software dev,
                                                          marketing, sales,
                                                          broader business ops
```

### Positions with results

| Position | Status | Findings page |
|---|---|---|
| Basic single-agent PA, file brain | SUPPORTED-but-thin | [001-basic-personal-assistant.md](./001-basic-personal-assistant.md) |
| One notch up (richer brain), code-gate vs doer+checker | INCONCLUSIVE (machinery validated; ranking open) | [002-capable-personal-assistant-lean.md](./002-capable-personal-assistant-lean.md) |
| Everything further right | UNTESTED | (no experiment concluded) |

"SUPPORTED-but-thin" means the architecture passed its bar (9/10 tasks, 3 trials, zero safety-floor failures) on one seeded world with the same authors writing both the system and the tests. It is a valid starting point, not a guarantee of generalization.

Experiment 002 (lean cut) was designed as the generalization test and the first divergent tournament. It **validated the anti-overfit + tournament machinery** (dev/held-out split, two worlds, blind held-out authoring, generalization-gap reporting, cost-as-signal) but did **not** produce an architecture ranking: a single-agent code-gate (A1) and a doer+checker pair (A2) both passed dev and held-out at 100% with zero safety failures, because the benchmark was too easy to stress either bet. The lesson (H-18): a divergent tournament only ranks the bets if the tasks trigger each bet's weakness. A fuller 002-scale run with harder, weakness-targeting tasks is the next step, and an operator-level decision.

## What lives here

- **README.md** (this file): the spectrum map.
- **building-blocks.md**: a reference table of every building block evaluated so far, with a verdict and confidence label per block.
- **001-basic-personal-assistant.md**: the consumable findings page for the basic single-agent PA use case.
- **002-capable-personal-assistant-lean.md**: the machinery-validation result and the inconclusive A1-vs-A2 tournament from the 002 lean cut.

## The raw evidence

Every claim in these pages points to a run in `results/`. Read the findings pages for the plain-language summary; read `results/` for the full trial logs, scorecards, and cost breakdowns. The experiment charters live in `experiments/`.
