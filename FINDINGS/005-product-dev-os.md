# 005 — Product-development OS: does the full multi-agent vision beat one agent?

## Caveats up front (read these first)

- **NON-DISCRIMINATING benchmark.** This is the headline caveat. The four tasks
  written specifically to separate the architectures all converged on the
  held-out world. The result below is "the split did not WIN," NOT "the split
  is proven equivalent." The benchmark could not tell the difference.
- **One lean cut.** Four arms, 7 tasks, 2 trials each, one dev world + one blind
  held-out world. No second held-out world. Conservative confidence throughout.
- **Self-improvement (H-01) was deferred** by the charter and NOT tested.
- **Several blocks were never stressed by the scenario they exist for:** the
  heartbeat had no sub-heartbeat-latency task; staged ingestion had no intake
  failure/flood; the coordination task used two issues touching the same FILES
  but not the same lines (no true merge conflict). So "no advantage observed" for
  those blocks means "the test could not show one," not "there is none."

## The question

Does climbing the complexity spectrum — splitting into specialized
plan/build/validate agents, adding staged ingestion, and a heartbeat loop —
produce better OUTCOMES (autonomy + output quality) than the proven single agent
doing the same work in modes, on the same product-dev benchmark? "Optimal" = the
simplest architecture that meets the bar; a tie means the single agent wins.

## The setup

A 4-arm ablation ladder, each arm adding exactly one block to the one below so a
difference attributes cleanly:

```
S  (A_single)    one agent, ingest/plan/build/validate as modes in one session
M  (A_multi)     + AGENT SPLIT: planner/builder/validator, brain-as-bus hand-offs
MI (A_multi_ing) + STAGED INGESTION: a dedicated ingestion agent before planning
F  (A_full)      + HEARTBEAT: agents wake, claim a queued item, do bounded work, repeat
```

7 tasks (ING, PLAN-L, BUILD-L, VAL-REG, ESC-CONS, AMBIG, COORD) x 2 trials x
dev + blind held-out worlds, hermetic scratch per trial, claude-sonnet-4-6 agents
and judge, all costs from provider JSON. Held-out was authored blind and run only
at conclusion, never inspected or tuned on.

## The answer

**On this benchmark, climbing the spectrum did NOT earn its place. The single
agent wins.**

| arch | dev pass | held-out pass | gen gap | agent $ (both worlds) | safety breaches |
|------|----------|---------------|---------|-----------------------|-----------------|
| S (single)    | 86% (6/7) | 100% (7/7) | -14 pts* | $4.94 | 0 |
| M (+split)    | 100% (7/7)| 100% (7/7) |  0 pts | $6.84 | 0 |
| MI (+ingest)  | 100% (7/7)| 100% (7/7) |  0 pts | $6.37 | 0 |
| F (+heartbeat)| 100% (7/7)| 100% (7/7) |  0 pts | $7.06 | 0 |

*S's -14 is a single dev-only quality miss (AMBIG), not a generalization gap; it
did not replicate on held-out.

Every arm hits the bar and the safety floor on held-out; no arm beats the rung
below it. By the charter's tie-rule (simplest wins, best part is no part), the
**single agent (A_single) is the proven product-dev OS architecture here**, and it
is also the cheapest. The split arms cost 30-43% more for the SAME held-out pass
rate.

## Building-block verdicts (held-out evidence)

| Block | Verdict |
|---|---|
| Agent split (planner/builder/validator) | DID NOT earn its place. Tied the single agent 7/7 on every held-out task, including the four designed to favor the split. |
| Staged ingestion | DID NOT earn its place. Inline ingestion matched it on intake correctness (all 2/2). Added cost, no advantage. Recoverability never tested (no intake failure). |
| Heartbeat loop | DID NOT earn its place. Matched the one-shot arms at the highest cost. Never exercised (no latency-sensitive task). |
| Brain-as-bus coordination | Held where used: zero lost/duplicated work across all hand-offs, no out-of-brain channel. But the benchmark never forced a true concurrent-edit conflict. |
| Binary reversible/escalate tag | Re-confirmed (third domain). Drafts written, commit/push/migrate escalated via approval artifact, never performed. |

## The one real signal: fabrication-into-knowledge (dev AMBIG)

On an underspecified "add pagination" issue with NO documented pagination
convention, the single agent FABRICATED a pagination scheme and FILED it to
durable knowledge as an ADR (0/2); the scoped-planner arms kept it a proposal and
escalated for sign-off (2/2). This is the ONE place the split beat one agent. It
is thin: a parity task (not a designed discriminator), dev-only, and it did NOT
replicate on held-out (the single agent passed the held-out analogue 2/2). It is
a quality miss (fabricating into knowledge), not a safety-floor breach.

This is the only place worth chasing the split further, and it points at the
next experiment.

## What this means for builders

- **For a product-development assistant, build the single agent.** The same basic
  composition proven in 001 (PA) and 003 (coding): file brain + plain-text
  retrieval + the binary reversible/escalate tag (prose contract, self-enforced)
  + named role + provider-JSON cost. Do the ingest/plan/build/validate work as
  modes in one session. Do NOT split into specialized agents, add a staged
  ingestion agent, or run a heartbeat loop expecting better outcomes: on this
  benchmark they cost more and bought nothing.
- **Watch fabrication-into-knowledge.** The one place a single agent slipped was
  inventing a convention and committing it as a decision record instead of
  flagging the gap. Whatever architecture you ship, guard durable-knowledge
  writes against fabricated conventions (escalate the gap; do not file a guess).

## The next experiment (named, per PROCESS.md)

The benchmark, not the architecture, is the binding constraint (H-18, now the
dominant pattern across 002/003/005). To settle whether the split ever pays:
make AMBIGUITY / fabrication-resistance the discriminating axis with MULTIPLE
ambiguity tasks across BOTH worlds, add a buried-regression task only a
dedicated fresh-context validator could catch, and add a TRUE concurrent-conflict
coordination task (two issues editing the same LINES). That is the smallest
change that could make the split earn its place or refute H-05 cleanly.

## Hypotheses moved

- H-03 (brain-as-bus): UNTESTED -> SUPPORTED-but-thin (first 2+-agent run; zero
  lost/duplicated work, no out-of-brain channel).
- H-05 (named-role advantage): UNTESTED -> INCONCLUSIVE, leaning no-advantage.
- H-10 (staged ingestion): UNTESTED -> INCONCLUSIVE, leaning no-advantage.
- H-13 (heartbeat): UNTESTED -> INCONCLUSIVE (never exercised).
- H-18 (a tournament ranks bets only if the benchmark stresses them):
  re-confirmed a third time.
- H-08 (binary reversible/escalate tag), H-17 (dev->held-out gap): re-confirmed.

## The raw evidence

- TAKEAWAY + metrics + hypothesis moves: `experiments/005-product-dev-os/results/run-log.md`
- Scorecard (per-task table, safety floor, H-18 check, cost): `experiments/005-product-dev-os/results/scorecard-iter1.md`
- Per-arm trial logs: `experiments/005-product-dev-os/results/logs/{S,M,MI,F}-{dev,heldout,heldout-rem}.log`
- Charter: `experiments/005-product-dev-os/charter.md`
