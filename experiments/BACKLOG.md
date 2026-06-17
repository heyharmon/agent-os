# Experiment backlog

The sanctioned queue the night-runner's Director pulls from when no open experiment has live
work. Each entry is anchored to the spectrum (`VISION.md`) or an open `HYPOTHESES.md` bet, so
opening it is "self-authorize within bounds," not invention. Ordered by priority. The
night-runner may reorder by readiness, may open any entry (writing its `charter.md` first),
and appends genuinely-new but unanchored ideas to the operator queue in the morning report
rather than running them.

Status keys: READY (charter can be written and run), BLOCKED (names what it needs),
PROPOSED (anchored, but the operator may want to shape it first — run only if higher-priority
work is exhausted).

## P0 — finish what is open

1. **Conclude 003 (coding assistant).** READY. Charter exists; lean build pending. Port the
   PA-proven architecture (A1 proven + gate) vs A2 null to the coding domain, run dev then
   the blind held-out project, report the generalization gap. Tests **H-19** (blocks
   generalize PA→coding), H-02 (retrieval on code), H-08 (reversible/escalate in eng),
   H-16 (gate earns its place when consequential actions tempt). Stopping: held-out result +
   a clear which-blocks-carry takeaway.

## P1 — make the tournament discriminate (the H-18 debt)

0. **003b — gate discrimination + the H-20 fix.** OPEN (charter written, no trials run).
   Charter: `experiments/003b-gate-discriminate/charter.md`. Pays down the 003 debt: the coding
   tournament never made the enforcement gate fire usefully (0/22), and 003 surfaced the H-20
   blind spot (presence-of-approval suppresses the consequential rule). Three arms on a
   gate-stressing benchmark: A_old (existing `bin/gate.py`), A_fix (ONLY the H-20 rule change
   `repo_changed AND NOT drafted`), A_null (prose-only). Weakness-targeting traps:
   mutate-in-place-AND-escalate (the H-20 discriminator), over-escalation (over-fire check),
   clean consequential (negative control). NEW dev + NEW blind held-out coding worlds under
   held-out discipline; reuses the 003 rig but references no 003 entity. Tests H-20 (fix), H-16
   (gate earns its place in a 2nd domain), H-18 (benchmark stresses the bets). Stopping: H-20
   settled across trials + held-out result + clear gate-vs-prose takeaway.

2. **002-scale, weakness-targeting tasks.** READY (anchored to H-18 + the 002 operator
   note). The lean 002 could not rank A1 vs A2 because the benchmark was too easy. Ship
   contract-stressing tasks: ambiguous escalation phrasing (over-fire A1's vocabulary-keyed
   gate), on-topic vs off-topic escalation traps (test whether A2's checker topic-awareness
   is load-bearing), 1:1 dev/held-out task-kind coverage, ≥3 trials, a second held-out
   world, and an **A3 null** (prose-only) to re-confirm 001's leg-1 at the larger brain.
   Conclude only if at least one architecture fires its enforcement/failure path.

3. **Adversarial retrieval for H-02.** READY. Plant a fact under a synonym/paraphrase plus a
   near-duplicate distractor to find the lexical-miss boundary of plain-text retrieval; add
   missing-info/refusal tasks with the absent fact made tempting to fabricate. Cheapest
   single hardening; sharpens H-02 across 002 and 003.

4. **Escalation accuracy, both directions.** READY (anchored to H-08). Current suites have
   too few `expects_escalation` tasks to call a real rate. Add over-escalation traps (a
   trivial reversible action the agent should just do) and under-escalation traps (a
   consequential action dressed as routine) so the binary reversible/escalate tag is
   stressed both ways and its refute clause can fire.

## P2 — the marquee bet and roles

5. **H-01 self-improvement loop.** PROPOSED (marquee bet, still UNTESTED). Does an agent that
   writes lessons back into its own brain measurably improve on later tasks? High value, but
   design-heavy: define the metric (improvement on held-out tasks *after* self-authored brain
   writes vs a frozen-brain control), guard against the brain bloating cost without lifting
   pass rate. Worth the operator shaping the charter; run autonomously only if P0/P1 exhausted.

6. **H-05 unscoped baseline (roles earn their keep).** READY. Run a do-everything agent with
   no role file on an existing suite to measure the named role's advantage. The cleanest
   single follow-on left UNTESTED from 001.

7. **Cheaper judge (H-14).** READY. Judge spend exceeded agent spend across 001's suite. Try a
   smaller judge model or push more tasks to assertion-only and confirm scores hold. Pure
   cost-signal hardening; safe to run unattended.

## P3 — move right on the spectrum

8. **One notch further right than 002.** PROPOSED. A use case that needs more tools / more
   surface / a richer brain than the capable-PA, still single-agent. Anchor the architecture
   choice to whatever 001–003 proved load-bearing. Write the charter to name the new failure
   boundary it is designed to find.

9. **Multi-agent (unblocks H-03).** BLOCKED — needs a second agent and a coordination
   contract that does not yet exist. Do not open autonomously; the architecture jump is a
   genuine pivot. Queue for the operator with a proposed minimal two-agent charter.

---

The night-runner keeps this file honest the same way it keeps `HYPOTHESES.md` honest: when it
opens an entry it notes the charter path; when it concludes one it strikes the entry and links
the finding. New anchored ideas it surfaces overnight are appended here (PROPOSED) via the
morning queue, not run on the spot.
