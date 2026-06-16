# Building blocks

A reference table of every architectural building block evaluated so far, with a plain-language verdict, an honest confidence label, and a link to the experiment behind it.

Nothing here is claimed beyond what the runs show. Labels:

- **SUPPORTED-but-thin**: at least one experiment supports this block, but on a single world with the same authors writing system and tests. Not yet shown to generalize.
- **UNTESTED**: the block was in use but no controlled comparison was run (e.g. no baseline without it). Cannot yet measure its contribution.
- **INCONCLUSIVE**: the experiment ran but the evidence does not settle the question. Named carry-forward test needed.
- **REFUTED**: a pre-registered refute condition was met. Do not build on this.

---

## Blocks evaluated in experiment 001 (basic single-agent PA)

| Building block | What it is | Verdict | Confidence | Experiment |
|---|---|---|---|---|
| File brain | Plain markdown files in knowledge/ (durable facts) and runtime/ (queues, approvals, inbox). No database, no vector store. | Keep. Every fact had a findable home; degrade-to-plain-text was never violated; the agent wrote and read it correctly across 30 runs. | SUPPORTED-but-thin (one small world) | [001](../results/2026-06-16-exp001-iter2.md) |
| Plain-text retrieval (H-02) | ripgrep over frontmatter and content; no embeddings, no graph layer. | Keep. Zero retrieval-miss failures across 30 runs, well under the 10% refute threshold. The agent correctly reported a true absence (no Northwind phone) without fabricating. Sufficiency at brain scale is not yet measured. | SUPPORTED-but-thin (small brain; scale untested) | [001](../results/2026-06-16-exp001-iter2.md), [full suite](../results/2026-06-16-exp001-full-suite.md) |
| Binary reversible/escalate tag (H-08) | Every action tagged as either reversible (act) or consequential (escalate). No finer taxonomy. | Keep, sufficient so far. The binary tag drove the right escalate-vs-act call on every consequential action across all trials. No case forced a wrong call; no operator wished for a finer tag. The gap in the one escalation task (T5) was always about mechanism (write the right artifact), never about taxonomy. The pre-registered refute clause needs two-sided escalation traps to fully settle; not yet called REFUTED. | INCONCLUSIVE, leaning no-refute (one genuine escalation task is thin) | [001](../results/2026-06-16-exp001-iter2.md), [h16-gate](../results/2026-06-16-exp001-h16-gate.md) |
| Checked escalation/write gate (H-16) | A harness step that detects deferral signals, requires an approval artifact to exist before proceeding, and issues a corrective re-prompt if not. | Keep, load-bearing. Prose-only failed the escalation contract 0/3 (T5); the gate is what made escalation happen at all. No correctness regression on passing tasks. Real-but-minor precision caveat: the current gate keys on deferral vocabulary, not consequence (false-positives on reversible tasks at real spend), and its generic correction can write an approval about the wrong task. The fix is a consequence-keyed, topic-aware gate; this is a hardening item for a follow-on, not a reason to remove the gate. | SUPPORTED-but-thin (one world, named precision caveat) | [001](../results/2026-06-16-exp001-iter2.md), [h16-gate](../results/2026-06-16-exp001-h16-gate.md), [full suite](../results/2026-06-16-exp001-full-suite.md) |
| Named role (H-05) | A scoped role file that defines the agent's accountabilities, constraints, and capabilities. | Keep provisionally. The role scoped the agent's behavior throughout 001; the agent never acted outside it. BUT 001 never ran the unscoped do-everything baseline, so the role's advantage over a baseline agent is observed, not measured. | UNTESTED as a comparison (no baseline without it) | [001 charter](../experiments/001-personal-assistant/charter.md) |
| Provider-JSON cost measurement (H-14) | Per-run tokens and cost read directly from provider usage JSON, not estimated. Recorded per task and per trial including corrective re-prompts. | Keep. Every cost figure in 001 (including each gate corrective pass) came from provider JSON, reproducible per trial. The numbers informed real decisions: judge spend exceeded agent spend, making the judge the thing to cut, not the agent. Thin because the decisions so far are about the eval rig's cost, not yet an operator changing an agent's cadence or retiring it on a work-per-dollar basis. | SUPPORTED-but-thin (real numbers, thin decision set) | [001](../results/2026-06-16-exp001-iter2.md) |

---

## Blocks not yet evaluated

These are in `HYPOTHESES.md` but no experiment has concluded on them.

| Building block | Hypothesis | Status |
|---|---|---|
| Self-improvement loop | H-01 | UNTESTED |
| Brain-as-bus inter-agent coordination | H-03 | UNTESTED (blocked: needs 2nd agent) |
| Autonomy dial granularity | H-04 | UNTESTED |
| Dreaming / nightly consolidation | H-06 | UNTESTED |
| OKF format vs plain frontmatter | H-07 | UNTESTED |
| Runner/provider swap | H-09 | UNTESTED |
| Staged ingestion | H-10 | UNTESTED |
| Tool/account/grant model | H-11 | UNTESTED |
| Six-planes decomposition | H-12 | UNTESTED |
| Heartbeat loop as default activation | H-13 | UNTESTED |
| Degrade-to-plain-text | H-15 | UNTESTED |
