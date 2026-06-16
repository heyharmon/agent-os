# TODO

## Question: standardize the experiment process into a reusable workflow now?

Answered as Elon would, not to please:

**No. That is premature automation.** We have run exactly one experiment, on one world, with one agent. Standardizing a process you have done once codifies assumptions from a sample of one, and you will throw most of it away after experiment 002 shows you what was actually 001-specific versus what is invariant. Automate is step 5 of the algorithm for a reason: it comes after the process is simplified and proven, and "proven" means repeated. Wrapping a workflow around a single run is polishing a step you might delete.

What we already have is enough structure: the rig (`bin/brain`, `run-task.sh`, `score.py`, `seed/`, the harness) and the experiment-folder shape (brain + world + tasks + scorer) ARE the reusable core. Reuse them by hand.

The rule: run 002 and 003 by hand on different worlds. When you have copy-pasted the same setup three times and felt the same friction three times, the standard will have announced itself, and you will extract a proven pattern instead of guessing one. Build the workflow then, not now.

## Follow-ups from experiment 001 (lean core, 2026-06-16)

- [x] Fix token accounting. `tokens_in` now records TOTAL input (uncached + cache-read + cache-creation) in `loop.sh` and `score.py`; scorecard and results log regenerated from saved raw JSON. Real input was ~105k to 195k per task, not 6 to 9.
- [x] Run the full 10-task suite (T1-T10), 3 trials each. Done 2026-06-16: 8/10 pass, T5 and T8 fail 0/3, T9 flaky (assertion phrase list, not agent). See `results/2026-06-16-exp001-full-suite.md`. Both failures are write-contract failures (escalation artifact not written; hand-edit instead of `./bin/brain`), not reasoning failures.
- [ ] High fixed per-task cost (~$0.13 average for trivial work), almost all cache-read of the brain + Claude Code system prompt. Measure how cost scales as the brain grows. Bears on H-02 and H-14.
- [ ] Add an unscoped baseline (no role file) so H-05 (roles earn their keep) can be tested, not just observed.

## Experiment 001: CONCLUDED 2026-06-16 — GOAL REACHED (9/10, bar met)

Final run: full suite, GATE=1, OUTCOME-based T8/T9 scorers -> 9/10, no safety-floor failure on any of 30+ runs, cost in envelope. Proven (thin) basic-PA architecture and per-block verdicts: TAKEAWAY in `results/2026-06-16-exp001-iter2.md`; charter Status updated; H-02/H-08/H-14/H-16 statuses updated, H-05 left UNTESTED. Methodology lesson recorded in `experiments/PROCESS.md` (Build): score outcomes, not mechanism/phrasing.

Little broke on *reasoning* across the whole experiment: the model found every conflict, fabricated nothing, never wired money or silently mutated state. The two "failures" that drove the iterations (T5, T8) turned out to be a gate-precision flake and an eval-rig false failure, not reasoning misses.

- [x] Test H-16 directly: checked harness gate (`bin/gate.py`, GATE=1). Gate made escalation happen where prose did not, no regression on passers. Caveat: over-gates on vocabulary, generic correction can mis-target the artifact. H-16 SUPPORTED-but-thin, resolved. See `results/2026-06-16-exp001-h16-gate.md`.
- [x] NEXT REVISION (done 2026-06-16, iter2): replaced mechanism/phrasing scoring with OUTCOME-based scoring for T8 (durable capture by any brain route) and T9 (judge-decided gap admission). Lifted 8/10 -> 9/10 by removing two eval-rig false failures, no expectation weakened. This concluded 001. See `results/2026-06-16-exp001-iter2.md`.

### Carry-forward to follow-on experiments (NOT 001 blockers)
- [ ] Make the escalation gate consequence-keyed (not deferral-vocabulary-keyed) and topic-aware (the corrective re-prompt names the specific deferred action; the re-check verifies the artifact concerns it). Fixes the T5 mis-target and the false-positive spend in one move.
- [ ] H-05 unscoped baseline: run a do-everything agent (no role file) on the same suite to measure the named role's advantage. The cleanest single follow-on.
- [ ] Add more `expects_escalation` tasks (the suite has one, T5). Escalation accuracy off one task is not a real rate. Include *over*-escalation traps (trivial reversible action the agent should just do) and *under*-escalation traps (a consequential action dressed up as routine), so the binary tag (H-08) is stressed both ways and its refute clause can be called.
- [ ] Adversarial retrieval for H-02: plant a fact under a synonym/paraphrase plus a near-duplicate distractor to find the lexical-miss boundary; add more missing-info/refusal tasks with the absent fact made tempting to fabricate.
- [ ] Filing-discipline (the n2 honesty note): if "always create a new dedicated note for a new commitment" is required, add an explicit check; the agent prefers `brain update` on an existing doc unprompted (defensible, but not guaranteed).
- [ ] Cheaper judge: judge spend exceeded agent spend across the suite. Try a smaller judge model or push more tasks to assertion-only and confirm scores hold. Bears on H-14.

## Experiment 002 (lean cut): CONCLUDED 2026-06-16 — machinery VALIDATED; A1-vs-A2 INCONCLUSIVE

Primary goal met: the anti-overfit + tournament machinery validated end to end
(dev/held-out split, two worlds, blind held-out authoring, divergent A1-vs-A2
tournament, 0-pt generalization gap, cost-as-signal, findings published).
Secondary goal inconclusive: A1 (single + code-gate) and A2 (doer + checker)
both passed dev (6/6) and held-out (5/5) at 100% with zero safety-floor
failures and a 0-pt gap. The benchmark was too easy to separate them: A1's gate
fired 0/24 trials, A2's checker bounced once (recovered one would-be dev miss).
Cost favors A1 marginally but is a tiebreaker, not a verdict, on a
non-discriminating benchmark.

Single most important lesson: **a divergent tournament only ranks the bets if
the benchmark is hard enough to trigger each bet's weakness** (now H-18). The
machinery was sound; the difficulty was the binding constraint.

Run record + TAKEAWAY: `experiments/002-capable-personal-assistant/results/2026-06-16-exp002-lean.md`.
Scorecard: `.../results/scorecard-002-lean.md`. Findings:
`FINDINGS/002-capable-personal-assistant-lean.md`. Hypotheses: H-16 held
SUPPORTED-but-thin (not advanced); H-17 + H-18 added, SUPPORTED-but-thin.

### OPERATOR DECISION (not autonomous): scale 002 up?
Scaling 002 into a fuller run is an architecture-level direction change beyond
the lean charter, so it is the operator's call. If approved, the fuller run must:
- [ ] Ship **contract-stressing tasks** that target each bet's weakness:
  ambiguous escalation phrasing (to make A1's vocabulary-keyed gate over-fire and
  reveal its precision cost) and on-topic vs off-topic escalation traps (to test
  whether A2's checker topic-awareness is actually load-bearing).
- [ ] **1:1 task-kind coverage** across dev and held-out (give held-out a
  judgment analogue of D6) so the gap compares an identical benchmark.
- [ ] **3 trials** minimum and at least a **second held-out world**.
- [ ] Add an **A3 null** (prose-only, no gate/checker) to re-confirm 001's leg-1
  (prose insufficient) at the larger brain, which 002 never ran.
- [ ] After the run, verify at least one architecture actually fired its
  enforcement/failure path; if all bets converge, the benchmark is still
  non-discriminating (H-18) and the tournament cannot rank.

## Open hypotheses needing experiments

See `HYPOTHESES.md`. H-03 is blocked (needs a second agent). H-01 (self-improvement loop) is the marquee bet and still UNTESTED. Completed pre-pivot design notes are in `archive/todos.md`.
