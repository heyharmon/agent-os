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
      triage, escalate)        [002]                      autonomy
      simple file brain                                   [005] product-dev OS:
                                                          tested split + staged
[003] single-agent coding                                 ingestion + heartbeat
      assistant (same blocks,                             vs ONE agent.
      different domain)                                    SINGLE AGENT won;
                                                          added blocks bought no
                                                          held-out edge (and the
                                                          benchmark could not
                                                          discriminate).
                                                          other domains:
                                                          marketing, sales,
                                                          broader business ops
```

The biggest jump on the spectrum so far, 005, was attempted and bounced back: a
4-arm tournament (single agent vs +agent-split vs +staged-ingestion vs +heartbeat)
on a product-development benchmark concluded that the **single agent is the proven
architecture for this use case** — every arm passed the held-out world 7/7 with a
clean safety floor and none beat the rung below it, so by the simplest-wins rule
the single agent won (and it was cheapest). The multi-agent machinery did NOT earn
its place. Critical caveat: the benchmark was NON-DISCRIMINATING (the four tasks
designed to separate the arms all converged on held-out), so this is "the split
did not win here," not "the split is proven useless." See the 005 page.

The map now spans TWO domains at the basic position: 001 (personal assistant) and 003 (coding assistant). 003 ran the same basic blocks on a software-engineering project to test whether they were PA-specific. They were not: the file brain, plain-text retrieval, binary reversible/escalate tag, named role, and provider-JSON cost all carried, so they have crossed the two-domain threshold and are closer to PROVEN. The recommended basic architecture is exactly those blocks: file brain + plain-text retrieval + the binary reversible/escalate tag (a prose contract the model self-enforces) + named role + provider-JSON cost. The checked enforcement gate is NOT part of the recommendation: it was demoted 2026-06-17 as unnecessary overhead for current frontier models (it fired 0 useful times across 002 and 003 and would not have caught the one real coding breach; H-16 NOT SUPPORTED, H-20 retired). See the 003 page and building-blocks.md.

### Positions with results

| Position | Status | Findings page |
|---|---|---|
| Basic single-agent PA, file brain | SUPPORTED-but-thin | [001-basic-personal-assistant.md](./001-basic-personal-assistant.md) |
| One notch up (richer brain), code-gate vs doer+checker | INCONCLUSIVE (machinery validated; ranking open) | [002-capable-personal-assistant-lean.md](./002-capable-personal-assistant-lean.md) |
| Basic single-agent coding assistant (cross-domain) | SUPPORTED-but-thin (blocks carry PA -> coding; gate DEMOTED) | [003-coding-assistant-lean.md](./003-coding-assistant-lean.md) |
| Multi-agent product-dev OS (split + staged ingestion + heartbeat) vs one agent | SINGLE AGENT WINS; added blocks did not earn their place (benchmark non-discriminating) | [005-product-dev-os.md](./005-product-dev-os.md) |
| Everything further right | UNTESTED | (no experiment concluded) |

"SUPPORTED-but-thin" means the architecture passed its bar (9/10 tasks, 3 trials, zero safety-floor failures) on one seeded world with the same authors writing both the system and the tests. It is a valid starting point, not a guarantee of generalization.

Experiment 002 (lean cut) was designed as the generalization test and the first divergent tournament. It **validated the anti-overfit + tournament machinery** (dev/held-out split, two worlds, blind held-out authoring, generalization-gap reporting, cost-as-signal) but did **not** produce an architecture ranking: a single-agent code-gate (A1) and a doer+checker pair (A2) both passed dev and held-out at 100% with zero safety failures, because the benchmark was too easy to stress either bet. The lesson (H-18): a divergent tournament only ranks the bets if the tasks trigger each bet's weakness. A fuller 002-scale run with harder, weakness-targeting tasks is the next step, and an operator-level decision.

## What lives here

- **README.md** (this file): the spectrum map.
- **building-blocks.md**: a reference table of every building block evaluated so far, with a verdict and confidence label per block.
- **001-basic-personal-assistant.md**: the consumable findings page for the basic single-agent PA use case.
- **002-capable-personal-assistant-lean.md**: the machinery-validation result and the inconclusive A1-vs-A2 tournament from the 002 lean cut.
- **003-coding-assistant-lean.md**: the cross-domain generalization result, the basic blocks carry from PA to coding; the enforcement gate did not.
- **005-product-dev-os.md**: the 4-arm product-dev tournament. The single agent beat (tied, so won on simplicity) the agent split, staged ingestion, and heartbeat on the held-out world; the benchmark could not discriminate the arms.

## The raw evidence

Every claim in these pages points to a run in `results/`. Read the findings pages for the plain-language summary; read `results/` for the full trial logs, scorecards, and cost breakdowns. The experiment charters live in `experiments/`.
