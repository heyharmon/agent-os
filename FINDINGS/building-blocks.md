# Building blocks

A reference table of every architectural building block evaluated so far, with a plain-language verdict, an honest confidence label, and a link to the experiment behind it.

Nothing here is claimed beyond what the runs show. Labels:

- **SUPPORTED-but-thin**: at least one experiment supports this block, but on a single world with the same authors writing system and tests. Not yet shown to generalize.
- **SUPPORTED across two domains**: the block earned its place in two distinct domains (e.g. PA and coding). Per the promotion rule (`experiments/PROCESS.md`) this is closer to PROVEN, but still thin if each domain is a single lean cut.
- **UNTESTED**: the block was in use but no controlled comparison was run (e.g. no baseline without it). Cannot yet measure its contribution.
- **INCONCLUSIVE**: the experiment ran but the evidence does not settle the question. Named carry-forward test needed.
- **REFUTED**: a pre-registered refute condition was met. Do not build on this.

---

## Cross-domain status (experiment 003: PA -> coding)

Experiment 003 ported the basic single-agent blocks to a coding assistant on a blind held-out software project (`FINDINGS/003-coding-assistant-lean.md`). The result: the five core blocks below ALL carried with no break and no domain-specific rework, so they crossed the two-domain threshold and are now closer to PROVEN. The one block that was DROPPED is the checked enforcement gate: across 002 (fired 0/24) and 003 (fired 0/22) it fired 0 useful times, and on the single real coding breach it would not have caught it (its consequential rule is suppressed by approval-presence, the H-20 blind spot). RESOLVED 2026-06-17: the gate is demoted as unnecessary overhead for current frontier models, which self-enforce the prose reversible/escalate contract; the proven basic architecture no longer includes it. The confidence column below reflects this.

**Proven basic architecture after the demotion:** file brain + plain-text retrieval + the binary reversible/escalate tag (a prose contract the model self-enforces) + named role + provider-JSON cost. No checked enforcement gate.

---

## Blocks evaluated in experiment 001 (basic single-agent PA), extended by 003 (coding)

| Building block | What it is | Verdict | Confidence | Experiment |
|---|---|---|---|---|
| File brain | Plain markdown files in knowledge/ (durable facts) and runtime/ (queues, approvals, inbox). No database, no vector store. | Keep. Every fact had a findable home in 001 (30 runs); in 003 it held project conventions, ADRs, ownership, and runbooks for two software projects, and the agent learned each from the brain and used it. Degrade-to-plain-text never violated. | SUPPORTED across two domains (PA + coding; each thin) | [001](../results/2026-06-16-exp001-iter2.md), [003](../results/2026-06-16-exp003-lean.md) |
| Plain-text retrieval (H-02) | ripgrep over frontmatter and content; no embeddings, no graph layer. | Keep. Zero retrieval-miss failures in 001 (30 runs); in 003, the sternest test yet (grepping CODE), it found the exact validation home + cap + correct layer/stage on both software projects from the brain's conventions, zero misses. Reported true absences without fabricating in both domains. Sufficiency at brain scale still not measured. | SUPPORTED across two domains (PA + coding; scale untested) | [001](../results/2026-06-16-exp001-iter2.md), [003](../results/2026-06-16-exp003-lean.md) |
| Binary reversible/escalate tag (H-08) | Every action tagged as either reversible (act) or consequential (escalate). No finer taxonomy. | Keep, sufficient in both domains. In 001 the tag drove the right escalate-vs-act call on every action; in 003 it mapped cleanly onto draft-a-patch (reversible) vs commit/push/delete (escalate), correct on the explicit code traps in nearly every trial. No case forced a wrong call; no operator wished for a finer tag in either domain. The refute clause still needs two-sided escalation traps to fully settle; not yet REFUTED. | INCONCLUSIVE, leaning no-refute, now held in two domains | [001](../results/2026-06-16-exp001-iter2.md), [003](../results/2026-06-16-exp003-lean.md) |
| Checked escalation/write gate (H-16, H-20) | A harness step that requires an approval artifact to exist before proceeding and issues a corrective re-prompt if not. | NOT RECOMMENDED / DEMOTED (2026-06-17). Unnecessary overhead for current frontier models; the prose reversible/escalate contract is self-enforced. The gate fired 0 useful times across 002 (0/24) and 003 (0/22), did no work, and on the one real coding breach recorded `would_have_fired=false` (consequential rule `(repo_changed OR claimed) AND NOT approvals` is suppressed by approval-presence, the H-20 blind spot), so it would not have caught it. The model drafts the reversible part and escalates the consequential part from prose alone even when explicitly tempted. The only positive signal was 001 T5, which was thin and where the gate also over-fired on phrasing and could mis-target its artifact. HONEST CAVEAT (H-18): this is an absence of a fired enforcement path across every benchmark we could build, NOT proof prose suffices under adversarial stress; we could not construct a benchmark that reliably induced the breach (003b/004 were thrown out without a scored crux). Demoted on current evidence, not proven unnecessary in all cases. | NOT SUPPORTED for current frontier models / DEMOTED (H-16 resolved; H-20 retired) | [001](../results/2026-06-16-exp001-iter2.md), [003](../results/2026-06-16-exp003-lean.md) |
| Missing-info / refusal | The agent states an absent fact/convention plainly and does not fabricate it; offers to capture it instead. | Keep. In 001 (T9) the agent reported a true absence (no Northwind phone) without fabricating; in 003 (C4/CH4) it stated plainly that the project has no documented versioning/logging convention and offered to draft an ADR, no fabrication, on both projects. | SUPPORTED across two domains (PA + coding; each thin) | [001](../results/2026-06-16-exp001-iter2.md), [003](../results/2026-06-16-exp003-lean.md) |
| Named role (H-05) | A scoped role file that defines the agent's accountabilities, constraints, and capabilities. | Keep provisionally. The role scoped the agent's behavior throughout 001 and 003 (PA and coding); the agent never acted outside it. BUT no experiment has run the unscoped do-everything baseline, so the role's advantage over a baseline agent is observed, not measured. | UNTESTED as a comparison (no baseline without it), used in two domains | [001 charter](../experiments/001-personal-assistant/charter.md), [003](../results/2026-06-16-exp003-lean.md) |
| Provider-JSON cost measurement (H-14) | Per-run tokens and cost read directly from provider usage JSON, not estimated. Recorded per task and per trial including corrective re-prompts. | Keep. Every cost figure in 001 and 003 (including each gate corrective pass) came from provider JSON, reproducible per trial; framed against human-labor value in both. Thin because the decisions so far are about the eval rig's cost (cut the judge; the gate added nothing), not yet an operator changing an agent's cadence or retiring it on a work-per-dollar basis. | SUPPORTED across two domains (real numbers, thin decision set) | [001](../results/2026-06-16-exp001-iter2.md), [003](../results/2026-06-16-exp003-lean.md) |

---

## Blocks evaluated in experiment 005 (multi-agent product-dev OS vs one agent)

Experiment 005 put a 4-arm ablation ladder on a product-development benchmark
(single agent vs +agent-split vs +staged-ingestion vs +heartbeat), concluding
that the **single agent is the proven architecture for this use case**
(`FINDINGS/005-product-dev-os.md`). Every arm passed the held-out world 7/7 with a
clean safety floor and none beat the rung below it, so the simplest arm won.
**Critical caveat: the benchmark was NON-DISCRIMINATING** (the four tasks designed
to separate the arms all converged on held-out), so each "did not earn its place"
below means "showed no advantage on a benchmark that could not stress it," NOT
"proven useless."

| Building block | What it is | Verdict | Confidence | Experiment |
|---|---|---|---|---|
| Agent split (named roles) | planner/builder/validator as three scoped agents in separate sessions vs one agent doing it in modes. | Did NOT earn its place. Tied the single agent 7/7 on every held-out task, including the four designed to favor the split. Only edge was dev AMBIG (fabrication-into-knowledge), dev-only, did not replicate. | INCONCLUSIVE, leaning no-advantage (H-05) | [005](../experiments/005-product-dev-os/results/scorecard-iter1.md) |
| Brain-as-bus coordination | 2+ agents coordinate by reading/writing brain files only, no direct calls. | Held where used: zero lost/duplicated work across all hand-offs on both worlds, no out-of-brain channel needed. But never stressed by a true concurrent-edit conflict (COORD used same-file, not same-line, issues). | SUPPORTED-but-thin (H-03; first 2+-agent run) | [005](../experiments/005-product-dev-os/results/scorecard-iter1.md) |
| Staged ingestion | a dedicated ingestion agent parses transcripts/Slack into filed issues before planning, vs parsing inline in-context. | Did NOT earn its place. Inline matched staged on intake correctness (all 2/2 on ING/ING-H). Added cost, no advantage. Recoverability leg never tested (no intake failure/flood). | INCONCLUSIVE, leaning no-advantage (H-10) | [005](../experiments/005-product-dev-os/results/scorecard-iter1.md) |
| Heartbeat loop | agents wake on a schedule, claim a queued item, do bounded work, write back, repeat, vs one-shot per issue. | Did NOT earn its place; matched the one-shot arms at the highest cost. But NEVER exercised: the benchmark has no sub-heartbeat-latency task, so the mode it exists for was not tested. | INCONCLUSIVE (H-13) | [005](../experiments/005-product-dev-os/results/scorecard-iter1.md) |

---

## Blocks evaluated in experiment 006 (validation-separation, a fail-capable benchmark)

Experiment 006 built the benchmark 002/003/005 never managed: hard enough that the
single agent demonstrably FAILS (it files a fabricated convention to durable
knowledge, FAB-GAP 0/2 on both worlds), targeted at the one weakness 005 surfaced.
It ran three arms, S (single), P (fresh-context second pass, same generalist), and
M (scoped planner/builder/validator), to isolate whether any win is FRESH CONTEXT
or SCOPED ROLES (`FINDINGS/006-validation-separation.md`). Result: scoped roles win
on fabrication-into-knowledge; fresh context does not. The decisive mechanism is a
planner PROMPT scoped to "flag the gap, never fabricate," ONE guardrail on the
single agent, not a multi-agent split. The self-validation half did not reproduce.

| Building block | What it is | Verdict | Confidence | Experiment |
|---|---|---|---|---|
| Scoped no-fabrication authoring role | A planner/author prompt scoped to "flag a missing convention and escalate it; never fabricate one and file it to durable knowledge." | EARNED ITS PLACE on fabrication-into-knowledge. M did not fabricate on held-out (FAB-GAP-H 0/2) where the single agent and the fresh-context arm both did (2/2), with no over-escalation regression (FAB-USE-H 2/2, uses a convention that DOES exist). The one block that did the work. | SUPPORTED-but-narrow (one axis, one cut; H-21 fabrication half, H-05) | [006](../experiments/006-validation-separation/results/scorecard-iter1.md) |
| Fresh-context validation pass | The same generalist agent run a second time with fresh context (no role scoping) to review the build before approval. | DID NOT earn its place. P equalled the single agent on the discriminating axis (both FAB-GAP-H 0/2): pass-1 commits the fabrication to durable knowledge before fresh eyes look, and a fresh pass cannot un-file it. Worst value (~2x single-agent cost, zero gain on the axis that mattered). | NOT SUPPORTED on this axis (H-21 fresh-context leg) | [006](../experiments/006-validation-separation/results/scorecard-iter1.md) |
| Separated validator vs self-validation (authorship bias) | A separate validator session reviewing the author's own freshly-written code for a buried regression. | INCONCLUSIVE / not tested. BURIED-REG did NOT discriminate: every arm, including the single agent, self-caught its own float-math regression 2/2 on both worlds. The authorship bias 005 hinted at did not manifest on a clearly-specified ADR-violation regression. | INCONCLUSIVE (H-21 self-validation half; non-discriminating) | [006](../experiments/006-validation-separation/results/scorecard-iter1.md) |
| Brain-as-bus under a same-method collision (H-03) | M's two builders edit the SAME method/lines via two issues queued together, coordinating only through brain files. | Held: 0 lost-work on CONFLICT/CONFLICT-H, both changes survived and reconciled 2/2 on both worlds. Harder than 005's same-file-only collision, but the edits were mechanically reconcilable, so the bus was not forced to break. | SUPPORTED-but-thin (held across two experiments, never stressed to failure) | [006](../experiments/006-validation-separation/results/scorecard-iter1.md), [005](../experiments/005-product-dev-os/results/scorecard-iter1.md) |

---

## Blocks not yet evaluated

These are in `HYPOTHESES.md` but no experiment has concluded on them.

| Building block | Hypothesis | Status |
|---|---|---|
| Self-improvement loop | H-01 | UNTESTED (deferred by 005 charter) |
| Autonomy dial granularity | H-04 | UNTESTED |
| Dreaming / nightly consolidation | H-06 | UNTESTED |
| OKF format vs plain frontmatter | H-07 | UNTESTED |
| Runner/provider swap | H-09 | UNTESTED |
| Tool/account/grant model | H-11 | UNTESTED |
| Six-planes decomposition | H-12 | UNTESTED |
| Degrade-to-plain-text | H-15 | UNTESTED |
