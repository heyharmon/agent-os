# Finding 001: Basic single-agent personal assistant

**Headline: A file brain + plain-text retrieval + named role + binary escalation tag + a checked harness gate passes 9/10 realistic PA tasks with zero safety failures. The load-bearing lesson: the model reasons about consequence well but does not follow the escalation contract from prose alone. A checked harness step closes the gap.**

Status: SUPPORTED-but-thin. One seeded world, same authors wrote system and tests, no held-out evidence. Tells you where to start; does not yet show generalization. Experiment 002 is the generalization test.

---

## Caveats, front and center

Read these before anything else.

1. **One world.** All runs used a single seeded brain (one persona, one inbox, one calendar). The architecture may behave differently in another world.
2. **Same authors.** The people who built the system also built the benchmark. There is no blind authoring, no adversarial task set, no independent evaluator.
3. **No held-out evidence.** PROCESS.md requires a held-out world at conclusion. Experiment 001 did not complete that step. The 9/10 result is on the dev world used during iteration.
4. **Therefore: not yet shown to generalize.** The result is a valid, honest starting point for a basic PA build. It is not a proven architecture in the full sense defined by `experiments/PROCESS.md` (which requires at least two experiments or a held-out world). Experiment 002 is explicitly designed to test whether it generalizes.

These are not disclaimers added after the fact. They are the exact conditions of the experiment, stated up front.

---

## What was tested

A single-agent personal assistant at the basic end of the complexity spectrum: small file brain, a handful of capabilities (capture, triage, prioritize, draft, brief, escalate), no second agent, no live external tools. Ten realistic tasks covering the core PA loop, 3 trials each, with a hermetic brain reset per run.

Full charter: `experiments/001-personal-assistant/charter.md`

---

## The architecture that worked

```
  file brain
  (knowledge/ + runtime/)
       |
  plain-text retrieval (ripgrep)
       |
  single named role
       |
  binary reversible/escalate tag on every action
       |
  checked harness gate (enforces escalation contract)
       |
  provider-JSON cost measurement
```

Every piece is plain files. No database, no embeddings, no message bus between agents. The brain is the coordination layer; the harness is the enforcement layer.

Result: 9/10 tasks passing across 3 trials, zero safety-floor failures across all 30 runs, per-task median agent cost $0.08-$0.36.

Raw result: `results/2026-06-16-exp001-iter2.md`

---

## The load-bearing lesson

**The model is a strong reasoner about consequence. It is an unreliable follower of the write/escalation contract in prose alone.**

Across every run (30 total), the model:
- Found every conflict and consequential action (calendar clash, BEC wire scam, missing contact info).
- Fabricated nothing (zero invented facts, zero invented phone numbers).
- Wired no money, deleted nothing, sent nothing without authorization.

But in the prose-only baseline, the model repeatedly failed to produce the required escalation artifact (an approval file in `runtime/queue/approvals/`) even when it recognized the action as consequential and said so in chat. T5 (multi-step conflict detection) failed 0/3 on the prose-only baseline: correct reasoning in chat, no artifact written.

A checked harness gate (a step in the harness that detects deferral signals, looks for the artifact, and issues a corrective re-prompt if absent) fixed the compliance. No prompt editing, no additional instruction text.

The implication for builders: do not rely on instruction text alone to enforce operational contracts. Build the check into the harness.

Evidence:
- Prose-only baseline: `results/2026-06-16-exp001-full-suite.md` (T5 0/3, T8 0/3)
- Gated re-run: `results/2026-06-16-exp001-h16-gate.md`
- Concluding run with corrected scoring: `results/2026-06-16-exp001-iter2.md`

---

## Cost: a signal, not a verdict

Grand total across the full concluding run: $4.31 (30 tasks x 3 trials). Breakdown:
- Agent cost: $2.27 (per-task median $0.08-$0.36)
- Judge cost: $2.04 (a Tier-2 LLM judge scoring 7 of 10 tasks)

The judge cost exceeded the agent cost. The immediate signal: a cheaper judge (deterministic assertions instead of an LLM where possible) is the highest-leverage cost improvement.

How to frame the agent cost against human labor: a capable PA handling scheduling, triage, conflict detection, and drafting charges $25-$60 per hour. A task taking a human 5-15 minutes costs $2-$15 in labor. The agent's $0.08-$0.36 per task is 10-100x cheaper at this capability level, with no scheduling overhead. Cost is not the constraint at these levels; reliability and scope are.

The gate's false-positives (it fired on reversible tasks at real spend) are the most actionable cost item: T4 and T10 each drew corrective re-prompts they did not need, adding ~$0.10-$0.20 per task in unnecessary gate spend. A consequence-keyed gate (fires on consequence, not deferral vocabulary) would recover this.

---

## Building-block verdicts

| Block | Verdict | Confidence | Detail |
|---|---|---|---|
| File brain | Keep, load-bearing | SUPPORTED-but-thin | Every fact had a findable home; 30 runs, zero silent mutations of durable state. |
| Plain-text retrieval | Keep, sufficient | SUPPORTED-but-thin | Zero retrieval misses; true absence (missing phone) reported correctly, not fabricated. Scale untested. |
| Binary reversible/escalate tag | Keep, sufficient so far | INCONCLUSIVE (leaning no-refute) | Correct call on every consequential action. One genuine escalation task is thin evidence; two-sided traps needed to settle the refute clause. |
| Checked harness gate | Keep, load-bearing | SUPPORTED-but-thin | Prose-only 0/3 on escalation compliance; gate fixed it. Named precision caveat: current implementation keys on vocabulary, not consequence. |
| Named role | Keep provisionally | UNTESTED as comparison | Scoped behavior throughout but no unscoped baseline was run, so advantage is observed, not measured. |
| Provider-JSON cost | Keep | SUPPORTED-but-thin | Every number came from provider JSON per trial, reproducible. Drove real decisions about the eval rig. Thin decision set. |

Full building-block table: `FINDINGS/building-blocks.md`

---

## What this does not establish

- **Generalization.** One world. A second world (experiment 002) is the direct test.
- **The role's advantage.** No unscoped baseline was run. H-05 stays UNTESTED.
- **Gate precision.** The current gate has two known precision failures: vocabulary-keyed false-positives, and generic corrective re-prompts that can target the wrong task. Both are harness-fixable; neither caused a safety event.
- **Retrieval at scale.** The brain is small. Sufficiency at a larger brain is not measured.
- **The full autonomy dial.** All runs used a single fixed autonomy setting. Granularity of the dial (H-04) is untested.

---

## What to do with this result

If you are building a basic single-agent PA, this architecture is a valid, honest starting point:

1. File brain: plain markdown, knowledge/ and runtime/, nothing fancier.
2. Plain-text retrieval: ripgrep or equivalent. Skip embeddings until you have evidence you need them.
3. A single named role file scoping the agent's accountabilities and constraints.
4. Tag every action binary: reversible (act) or consequential (escalate). The binary is sufficient so far.
5. A checked harness gate enforcing the escalation contract. Not instruction text alone. The gate is the finding.
6. Track cost per run from provider JSON from day one.

Do not call this proven until you have run it on a world you did not design and tasks written by someone who did not see the system internals. Experiment 002 does exactly that; watch those results.
