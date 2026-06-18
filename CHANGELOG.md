# Changelog

A log of experiments run, findings recorded, and hypothesis status changes. The architecture docs in `archive/` are pre-evidence provenance; this file records what we learned by building and running.

The format follows [Keep a Changelog](https://keepachangelog.com): newest first, grouped into **Added / Changed / Fixed**. Dates are `YYYY-MM-DD`.

---

## 2026-06-17 - Queued experiment 007: OKF as the brain's knowledge format

Chartered a test of whether committing the brain's knowledge layer to Google's Open Knowledge Format (OKF v0.1) is worth its cost over our current ad-hoc markdown + YAML frontmatter (H-07). Not started; no runs. Queued while scaffolding the separate `aos-product-dev` build, which deliberately ships plain frontmatter until this settles.

### Added
- **`experiments/007-okf-brain-format/`** (charter + README). Two divergent brain-format arms (A_plain vs A_okf) on the reused 003 coding benchmark, dev + blind held-out. Pre-registers a portability discriminator per H-18: point a generic OKF-aware reader at each brain and require it to answer using only OKF-standard fields. Bar = task-pass parity (OKF must not regress) plus a fired portability win; safety floor unchanged (no fabrication, no consequential action).

### Changed
- **H-07 (OKF worth its cost over plain frontmatter): UNTESTED -> UNTESTED, QUEUED as 007.** Updated with the published OKF v0.1 spec facts (markdown + frontmatter, one required `type`, six standard fields, reserved `index.md`/`log.md`, a markdown-link graph) and a sharpened, fireable test. Key prior: OKF v0.1 is nearly identical to the proven file brain, so the cost side is small and the open question is whether the interop benefit is real or ceremony.
  - **Impact:** do not adopt OKF in any build until 007 supports it.
- **`TODO.md`:** added a "Queued experiments" entry for 007.

## 2026-06-17 - Added the consolidated evidence reference; renamed the repo to aos-experiments

Synthesized everything proven across experiments 001-006 into a single consumable reference, and renamed the GitHub repo `agent-os` -> `aos-experiments`.

### Added
- **`EVIDENCE.md`:** a dated, cross-referenced reference for anyone building an agentic operating system. Principles, patterns that earned their place (the 5-block basic composition + the one no-fabrication guardrail), patterns that did NOT (gate, fresh-context pass, multi-agent split, staged ingestion, heartbeat), honest confidence labels carried from `FINDINGS/building-blocks.md`, and the open spectrum. Every claim traces to a run; the H-16 demotion keeps its "absence of evidence, not proof" caveat.

### Changed
- **Repo renamed `agent-os` -> `aos-experiments`** (GitHub repo + origin remote). The `EVIDENCE.md` repo references point to `heyharmon/aos-experiments`. The local working directory name is unchanged.

## 2026-06-17 - Experiment 006 CONCLUDED: separation EARNS its place on fabrication, and the win is SCOPED ROLES, not fresh context

Ran the 3-arm tournament (S=single, P=fresh-context second pass / same generalist, M=scoped planner/builder/validator) x 6 two-sided tasks x 2 trials x dev (Atlas/Laravel) + blind held-out (Beacon/FastAPI), hermetic scratch per trial, claude-sonnet-4-6 agents + judge, all costs from provider JSON, held-out run conclude-only and byte-identical to its frozen seed before and after. Reused the 005 rig; added only the arms, tasks, scorers, and one prompt (`single2pass`). No gate. TAKEAWAY + metrics: `experiments/006-validation-separation/results/run-log.md`; scorecard: `experiments/006-validation-separation/results/scorecard-iter1.md`; findings: `FINDINGS/006-validation-separation.md`.

**Primary result (the charter's goal): YES, narrowly, and the win is SCOPED ROLES.** On a benchmark that was finally FAIL-CAPABLE on the targeted axis (the single agent demonstrably FAILS FAB-GAP 0/2 on dev AND FAB-GAP-H 0/2 on held-out, filing a fabricated convention to durable `knowledge/`), the scoped-roles arm M is the only arm that does not fabricate (FAB-GAP-H 2/2: admits the gap, escalates an ADR/owner sign-off), with no over-escalation/false-fail regression (0/4 all arms), no safety regression (0 breaches), and a small non-positive generalization gap. Held-out pass: S 83% / P 83% / M 100%; gen gap 0 / -17 / -17 pts.

**The decisive nuance (the confound-reducer paid off): FRESH CONTEXT did NOT help.** P (the same generalist run a second time with fresh eyes, no role scoping) equals the single agent on the discriminating axis (both FAB-GAP-H 0/2), because pass-1 commits the fabrication to durable knowledge before the fresh pass looks, and a fresh pass cannot un-file it. So the load-bearing mechanism is a planner PROMPT scoped to "flag the gap, never fabricate a missing convention," ONE guardrail added to the single agent, NOT separation per se and NOT a multi-agent split. P was also the worst value (~2x S cost, zero gain on the axis that mattered).

**This is the CONFIDENT outcome the charter sought, not a benchmark-limited one.** The benchmark could actually fail the single agent (unlike 002/003/005), so "scoped roles win" is a real ranking. Concluding after 1 iteration is correct: the primary fabrication axis settled cleanly, and continuing would mean re-authoring BURIED-REG against observed self-catch behavior (overfitting, barred).

**Unresolved (reported, not patched):** the self-validation / authorship-bias half (BURIED-REG) did NOT discriminate, every arm including S self-caught its own float-math regression 2/2 on both worlds, so H-21's self-validation half is untested here, and H-03 held but was never stressed to failure (the same-method conflict was mechanically reconcilable). One scorer false-positive (`merged into` noun-sense) cost P one DEV trial; one of three trips is on held-out, so per the rig rule the scorer was NOT patched against held-out behavior; reported as a finding, does not move the held-out headline.

**OPERATOR DECISION to surface: None.** Operator delegated all direction decisions for this autonomous run; nothing irreversible or outward-facing occurred (hermetic sandbox). No safety-floor breach, no budget breach. A direction finding, not a stop-the-line escalation.

### Changed
- **Experiment 006: CHARTERED -> CONCLUDED.** Separation earns its place on fabrication-into-knowledge via scoped roles; fresh context does not. Charter Status updated with the result and the hypothesis moves.
  - **Impact:** For fabrication-into-knowledge, add ONE guardrail to the single agent: a planner/author prompt scoped to "flag a missing convention and escalate it; never fabricate one and file it to durable knowledge." Do NOT add a fresh-context second pass for this (the bad write already happened by the time it runs, and it costs ~2x). Do NOT expect a separated validator to catch authorship bias on a clearly-specified regression: the single agent self-caught it every time.
- **H-21 (separation prevents fabrication + self-validation bias): UNTESTED -> SUPPORTED-but-narrow.** Fabrication half supported by SCOPED ROLES only (M 0/2 vs S/P 2/2 fabrication on held-out, no over-escalation regression). NOT supported by fresh context (P = S). Self-validation half untested (BURIED-REG non-discriminating). The real mechanism is a scoped no-fabrication planner, not separation per se.
- **H-05 (scoping beats fresh context / named-role advantage): INCONCLUSIVE -> SUPPORTED-but-thin.** The first clean positive: M (scoped) beats P (fresh context, same generalist) on FAB-GAP-H 2/2 vs 0/2, replicated on held-out, no regression. 005's "no advantage" was a benchmark limitation, now corrected on a fail-capable benchmark.
- **H-03 (brain-as-bus): SUPPORTED-but-thin (held, advanced).** The CONFLICT task forced a real same-method edit collision (harder than 005's same-file-only COORD); M's two-builder hand-off through brain files lost no work 2/2 both worlds. Still not stressed to a genuine irreconcilable conflict.
- **H-18 (a tournament ranks bets only if the benchmark stresses them): streak broken on one axis.** The fail-capable, weakness-targeted benchmark DID discriminate on FAB-GAP (S fails, M passes, replicated on held-out): the first counterexample to the 002/003/005 "we keep building easy ones" pattern. It did NOT discriminate on BURIED-REG (a guessed weakness that did not manifest).
- **H-08 (binary reversible/escalate tag): re-confirmed a FOURTH time.** ESC-CONS/ESC-CONS-H drafted + escalated, never performed, every arm, both worlds; 0 breaches across all 72 trials.
- **H-17 (dev->held-out gap): re-confirmed, and strengthened.** Small non-positive gap (0/-17/-17), and this time on a benchmark where a gap COULD have appeared: the dev failure (S fabricates) replicated exactly on held-out, the cleanest no-overfit signal yet.
- **`FINDINGS/README.md`, `FINDINGS/building-blocks.md`:** spectrum map, positions table, and block table updated with the 006 result (scoped no-fabrication authoring role EARNED IT; fresh-context pass NOT SUPPORTED on this axis; separated-validator self-validation INCONCLUSIVE; brain-as-bus held under a same-method collision), caveats up front.
- **`TODO.md`:** 006 marked concluded; carry-forward recorded (the self-validation half needs a fresh, blind-authored subtle-regression world; re-authoring 006's BURIED-REG is barred as overfitting).

### Added
- **`FINDINGS/006-validation-separation.md`:** consumable findings page, caveats up front (narrow win; self-validation half untested; one lean cut; H-03 not stressed to failure; the scorer false-positive), the scoped-roles verdict, per-block verdicts with held-out evidence, the discriminating mechanism (fabrication committed in pass 1), builder guidance, and the named next experiment.

## 2026-06-17 - Experiment 006 CHARTERED: does separating validation from authoring earn its place? (the discriminating fight)

Autonomous follow-on to 005 (operator delegated). 005's single-agent-wins verdict is only as strong as its benchmark, which was non-discriminating for the third straight time (H-18). 006 builds the benchmark we have failed to build three times: hard enough that the single agent can actually FAIL, targeted at the one axis where separation already showed an edge in 005 (the dev AMBIG fabrication-into-knowledge divergence). Three sharpened arms: A_single (one session) vs A_2pass (one agent, fresh-context validation pass) vs A_multi (scoped planner/builder/validator). The A_2pass arm is the confound-reducer: it isolates whether any win is from fresh context or from role-scoping. Two-sided tasks (convention absent → escalate, vs present → use; buried regression → fail, vs clean build → pass) so over-separation is penalized. New hypothesis H-21 registers the bet.

### Added
- **`HYPOTHESES.md` H-21** (separating validation from authoring prevents self-validation bias and fabrication-into-knowledge): NEW, from the 005 dev AMBIG divergence. Two-sided refute clause. UNTESTED; 006 chartered to settle it.
- **`experiments/006-validation-separation/charter.md`:** goal, 3-arm tournament, two-sided fabrication/self-validation/conflict benchmark with a pre-registered discrimination check (the benchmark must be able to fail A_single or it is too easy), bar, stopping criteria, budget, operator delegation.
  - **Impact:** none to builders yet (a bet, not a finding). The 005 single-agent recommendation stands until 006 produces held-out evidence.

## 2026-06-17 - Experiment 005 CONCLUDED: the SINGLE AGENT is the proven product-dev OS; the multi-agent machinery did not earn its place (benchmark non-discriminating)

Ran the 4-arm ablation ladder (S=single, M=+agent-split, MI=+staged-ingestion, F=+heartbeat) x 7 tasks x 2 trials x dev + blind held-out worlds, hermetic scratch per trial, claude-sonnet-4-6 agents + judge, all costs from provider JSON, held-out run conclude-only and never inspected. Reused the prior rig (bin/brain, run-task/run-arch/tournament, score.py, compare.py); no gate. TAKEAWAY + metrics: `experiments/005-product-dev-os/results/run-log.md`; scorecard: `experiments/005-product-dev-os/results/scorecard-iter1.md`; findings: `FINDINGS/005-product-dev-os.md`.

**Primary result (the charter's goal): NO, climbing the spectrum did not produce better outcomes on this benchmark.** On the blind held-out world every arm passed 100% (7/7) with a clean safety floor (zero unapproved consequential actions, zero lost/duplicated work across all 112 trials), and no arm beat the rung below it. By the charter's tie-rule (a tie means the single agent wins on simplicity), the **single agent (A_single) is the proven product-dev OS architecture here**, and it is also the cheapest (~$4.94 agent vs $6.37-7.06 for the split arms). The agent split, staged ingestion, and heartbeat bought zero measurable held-out advantage; the middle is deleted.

**The only divergence in the entire 56-cell matrix was dev AMBIG:** the single agent fabricated a pagination convention and FILED it to durable knowledge as an ADR (0/2), while the scoped-planner arms kept it a proposal and escalated (2/2). This is the one place the split beat one agent. It is thin: a parity task (not a designed discriminator), dev-only, and it did NOT replicate on held-out. It is a fabrication-into-knowledge quality miss, not a safety-floor breach.

**Stopping criterion: NON-DISCRIMINATING benchmark (H-18).** The four pre-registered discriminator tasks (PLAN-L, BUILD-L, VAL-REG, COORD) ALL converged on held-out. The blocker is benchmark discrimination, not a tunable arm variable, so another single-variable revision would not move the result; concluding after 1 iteration is correct.

### Changed
- **Experiment 005: CHARTERED -> CONCLUDED.** Single agent wins for the product-dev use case on this benchmark; the multi-agent blocks did not earn their place. Charter Status updated with the result, the hypothesis moves, and the pending operator decision.
  - **Impact:** For a product-development assistant, build the SINGLE AGENT (the 001/003 composition: file brain + plain-text retrieval + binary reversible/escalate tag + named role + provider-JSON cost), doing ingest/plan/build/validate as modes in one session. Do NOT split into specialized agents, add a staged-ingestion agent, or run a heartbeat loop expecting better outcomes: on this benchmark they cost 30-43% more and bought nothing. Guard durable-knowledge writes against fabricated conventions (the one place a single agent slipped).
- **H-03 (brain-as-bus coordination): UNTESTED -> SUPPORTED-but-thin.** The first 2+-agent experiment, finally unblocked. The multi-agent arms coordinated every hand-off (planner->builder->validator, builder->builder) through brain files alone, with zero lost/duplicated work across all COORD/COORD-H trials on both worlds, no out-of-brain channel. Thin: the benchmark never forced a true concurrent-edit conflict.
  - **Impact:** brain-as-bus is a viable coordination mechanism for multi-agent hand-offs; it has one data point and was not stressed by a genuine merge conflict.
- **H-05 (named-role advantage): UNTESTED -> INCONCLUSIVE, leaning no-advantage.** The long-missing unscoped baseline ran. On held-out the scoped split showed no measurable advantage over the one general agent (refute-clause language). Not called REFUTED because the benchmark was non-discriminating and the dev AMBIG fabrication edge, though dev-only, is real and worth re-testing.
  - **Impact:** the scoped agent split did not earn its place on this benchmark; whether it ever does is open and points at the next experiment.
- **H-10 (staged ingestion): UNTESTED -> INCONCLUSIVE, leaning no-advantage.** Inline ingestion matched staged on intake correctness (all 2/2); staged added cost, no advantage. Recoverability leg never tested (no intake failure/flood).
- **H-13 (heartbeat loop): UNTESTED -> INCONCLUSIVE.** No advantage observed, but the benchmark has no sub-heartbeat-latency task, so the mode was never exercised. Cannot move toward refute on a benchmark that does not test it.
- **H-18 (a tournament ranks bets only if the benchmark stresses them): re-confirmed a THIRD time (002, 003, 005).** Even with four pre-registered weakness-targeting discriminators, all converged on held-out. The dominant pattern is now that our benchmarks are not hard enough to separate divergent architectures; building harder, weakness-triggering tasks is the binding constraint on ranking any architecture bet.
- **H-08 (binary reversible/escalate tag) and H-17 (dev->held-out gap): re-confirmed.** H-08 in a third domain (product-dev: drafts vs commit/push/migrate handled correctly every trial); H-17 with a 0-pt gap for M/MI/F (S's -14 is a dev-only miss, not a generalization gap), no overfitting.
  - **Impact:** more confidence both are domain-general; both still thin per the conservative-confidence rule.
- **`FINDINGS/README.md`, `FINDINGS/building-blocks.md`:** spectrum map and block table updated with the 005 result and the four multi-agent block verdicts (all "did not earn its place" / INCONCLUSIVE, with the non-discriminating caveat up front; brain-as-bus SUPPORTED-but-thin).
- **`TODO.md`:** 005 marked concluded; carry-forwards recorded (the harder discrimination-targeting benchmark is the named next experiment).

### Added
- **`FINDINGS/005-product-dev-os.md`:** consumable findings page, caveats up front (non-discriminating benchmark; one lean cut; self-improvement deferred; several blocks never stressed by the scenario they exist for), the single-agent verdict, per-block verdicts with held-out evidence, the fabrication-into-knowledge signal, builder guidance, and the named next experiment.

### Operator decision to surface
The product-dev OS conclusion is: ship the single agent. Before building any multi-agent product-dev machinery, decide whether to fund a harder, discrimination-targeting benchmark (MULTIPLE ambiguity/fabrication tasks across both worlds + a buried-regression task only a fresh-context validator could catch + a TRUE concurrent-conflict coordination task editing the same lines) or accept the single agent for this use case. No safety-floor breach, no budget breach (~$36 of a ~$250 ceiling), nothing irreversible occurred; this is a direction decision, not a stop-the-line escalation.

## 2026-06-17 - Experiment 005 CHARTERED: does the full multi-agent product-dev OS beat one agent?

The biggest jump on the spectrum so far: from the proven basic single-agent position (001 PA, 003 coding) toward the sophisticated multi-agent OS end. Use case is a product-development operating system (ingest meetings/Slack → triage → plan → build → validate → approve, proactive, vision-aware, learns from interventions). The charter tests whether climbing the spectrum actually improves outcomes (autonomy + output quality) over the proven single agent on the same product-dev benchmark.

Design choices (operator-set): a divergent tournament NOW (not a staged ladder); test the full vision against the single-agent baseline ("everything at once") as a delete-first move (if the maximal system does not beat the minimal proven one, delete the middle); win condition is autonomy + output quality (not throughput); keep the A_multi ablation arm; defer self-improvement (H-01) to a later stage. To avoid a confounded "it won but we don't know why" result, the arms are a **4-arm ablation ladder**, each adding exactly one block: A_single → A_multi (agent split, H-03/H-05) → A_multi_ing (staged ingestion, H-10) → A_full (heartbeat, H-13). The benchmark is pre-registered to DISCRIMINATE (the trap that left 002/003 unable to rank): four tasks designed to favor the split, with a post-run check that at least one arm actually diverged or the benchmark is declared non-discriminating (H-18).

### Added
- **`experiments/005-product-dev-os/charter.md`:** use case + spectrum position, goal, per-rung comparative bar + absolute safety floor (zero unapproved consequential actions; zero lost/duplicated work across hand-offs), pre-registered outcome-based scoring with the discrimination check, hypotheses in play (H-03 and H-05 finally unblocked by the first 2+-agent experiment; plus H-10/H-13 and re-confirm H-02/H-08/H-17/H-19), stopping criteria, budget, and a recorded operator delegation for an unattended overnight autonomous run.
  - **Impact:** none to builders yet (no results). This is a bet, not a finding. The single-agent composition from 001/003 remains the recommended basic architecture until 005 produces held-out evidence.



Operator decision: accept that the checked enforcement gate looks unnecessary for current frontier models and demote it. The model self-enforces the consequential-action contract from prose alone (drafts the reversible part, escalates the consequential part) even when explicitly tempted. Across the experiments that could measure it the checked gate fired 0 useful times (002: 0/24; 003: 0/22), did no work, and on the one real coding breach recorded `would_have_fired=false` (the H-20 approval-presence blind spot), so it would not have caught it. The only positive signal was 001 T5, which was thin and where the gate also over-fired on phrasing and could mis-target its corrective artifact.

Honest framing (H-18 caveat): this is an ABSENCE of a fired enforcement path across every benchmark we could construct, NOT proof that prose suffices under adversarial stress. We could not build a benchmark that reliably induced the breach. Two gate-stressing experiments were attempted and thrown out without a scored crux: 004 (a runaway smoke test that hung) and 003b (redundant). The conclusion is "no evidence the gate is needed for current frontier models, and it is unnecessary overhead on every task we could build," NOT "proven unnecessary in all cases." The thread is closed on current evidence rather than fully resolved.

### Changed
- **H-16 (prose contract not self-enforcing; needs a checked step): RESOLVED 2026-06-17 -> NOT SUPPORTED for current frontier models / gate DEMOTED.** Prior history kept. The checked enforcement gate is demoted as unnecessary overhead; the prose reversible/escalate contract is self-enforced.
  - **Impact:** Do NOT add a checked enforcement gate to a basic single-agent assistant in PA or coding. State the reversible/escalate contract in prose; current frontier models follow it. Rely on the doer + outcome scoring. The honest caveat applies: this is demoted on current evidence, not proven unnecessary under adversarial stress we could not construct.
- **H-20 (the gate's mutate-in-place blind spot): RETIRED / MOOT.** The gate is demoted, so fixing its consequential-rule blind spot is no longer pursued. The blind spot remains recorded as observed history.
  - **Impact:** none for builders; the gate it would have fixed is dropped.
- **`FINDINGS/building-blocks.md`:** the checked-gate row verdict changed to NOT RECOMMENDED / DEMOTED; the cross-domain section now states the proven basic architecture DROPS the gate. The proven basic architecture is now: file brain + plain-text retrieval + the binary reversible/escalate tag (a prose contract the model self-enforces) + named role + provider-JSON cost.
  - **Impact:** the recommended basic composition no longer includes the gate. Build the five blocks above and nothing more for a basic single-agent assistant.
- **`FINDINGS/README.md`, `FINDINGS/001-basic-personal-assistant.md`, `FINDINGS/003-coding-assistant-lean.md`:** the forward/headline recommendation no longer includes the checked gate. Per-experiment historical observations (001 genuinely saw the gate help T5) are kept as history; only the forward recommendation was demoted.
  - **Impact:** builders following these pages should not add the gate.
- **`.claude/workflows/run-experiment.js`:** the runTournament prompt re-hardened against the recursive-launcher hang that took down 004 (use the committed bounded `run-arch.sh`/`tournament.sh` as-is; no improvised re-check-and-re-correct loop; every `claude -p` under a wall-clock timeout; concurrency <=4; timeouts/errors recorded as failed trials; rely on persisted `score.json`). `gate.py` dropped from the GUARDRAILS rig-reuse list (the gate is deprecated).
  - **Impact:** future experiment runs are protected against the 004 runaway and will not reintroduce the gate.
- **`TODO.md`:** the enforcement thread marked closed; the gate-fix and gate-stressing carry-forwards retired.

## 2026-06-16 - Repo hygiene: gitignore runtime scratch; drop provisional throwaway experiments

### Changed
- **`runtime/` is now gitignored.** It had been committing thousands of disposable scratch files; dropped from tracking and ignored going forward.

### Removed
- **Provisional throwaway experiments `003b-gate-discriminate` and `004-enforcement-stress`** and their `results/` artifacts, built and run outside the experiment envelope on an unreliable rig and never audited. The H-18/H-20 gate-discrimination question they targeted remains OPEN (see the 003 takeaway below and `HYPOTHESES.md` H-20): the next experiment should reliably induce the in-place-mutation breach and run a divergent gate-predicate tournament to settle it.

## 2026-06-16 - Experiment 003 (lean cut) CONCLUDED: basic blocks GENERALIZE PA -> coding; enforcement gate did NOT carry

Ran the cross-domain generalization test: the PA-proven basic architecture ported to a single-agent coding assistant, as a two-architecture tournament (A_proven = ported architecture incl. the checked enforcement gate; A_null = same agent, prose-only, no gate) across a visible dev project (Tasklet, layered Python) and a blind, never-inspected held-out project (Plotline, TypeScript staged pipeline), 2 trials per task, hermetic scratch brain per trial, all costs from provider JSON. Run record + TAKEAWAY: `results/2026-06-16-exp003-lean.md`; scorecard: `experiments/003-coding-assistant/results/scorecard-003-lean.md`; findings: `FINDINGS/003-coding-assistant-lean.md`.

**Primary result (the charter's goal): the basic building blocks are domain-general.** All five core blocks (file brain, plain-text retrieval, binary reversible/escalate tag, missing-info/refusal, filing via `./bin/brain`, named role + provider-JSON cost) carried from PA to the blind held-out coding project with NO break and NO domain-specific rework. Plain-text retrieval (H-02) passed its sternest test yet, grepping CODE rather than notes, finding the exact validation home + cap + correct layer on both projects with zero misses. A_proven held-out 5/5, A_null 4/5. The carried blocks crossed the two-domain threshold and are closer to PROVEN.

**Secondary result: the enforcement gate did NOT earn its place in coding.** A_proven's gate fired 0/22 trials, did no work, and on the one real safety-floor breach (A_null CH3 t1, an in-place repo mutation = simulated commit) recorded `would_have_fired=false`, because its consequential rule `(repo_changed OR claimed) AND NOT approvals` is suppressed the moment an approval artifact exists, even though repo/ had also been mutated. The gate would have let the identical violation through. A_proven beat A_null by DOER behavior, not the gate. New cross-domain failure mode recorded as H-20. Per H-18 the benchmark still did not stress the gate's purpose: the discriminating trap was handled by the doer alone, so gate-vs-no-gate was never separated by the gate firing.

### Changed
- **Experiment 003 (lean cut): Chartered -> CONCLUDED.** Primary goal MET (blocks generalize PA -> coding, H-19 SUPPORTED-but-thin), secondary goal NEGATIVE-but-valuable (the gate did not carry; a design flaw surfaced). Charter Status updated with the result, the hypothesis moves, and the pending operator decision on the next direction.
  - **Impact:** For a basic single-agent assistant in PA OR coding, use the 001 composition (file brain, plain-text retrieval, binary reversible/escalate tag, named role, provider-JSON cost); these now have cross-domain evidence. Do NOT ship the current enforcement gate into a coding assistant expecting it to catch consequential actions: its consequential rule is suppressed by approval-presence (H-20). Either fix the rule to `repo_changed AND NOT drafted` (gate the action, not approval-presence) or rely on the doer + outcome scoring, which is what actually held here.
- **H-02 (plain-text retrieval sufficient) and H-08 (binary reversible/escalate tag sufficient): SUPPORTED-but-thin -> SUPPORTED across two domains.** Both carried cleanly from PA to coding; H-02 survived its sternest test (code retrieval), H-08 mapped onto draft-vs-commit/push/delete on the explicit code traps. Each remains thin (one lean cut per domain); refute clauses unchanged.
  - **Impact:** more confidence that these two blocks are domain-general mechanisms, not PA-specific. The binary tag still needs two-sided escalation traps to settle its refute clause.
- **H-16 (prose contract not self-enforcing; needs a checked step): held SUPPORTED-but-thin in PA only, NOT generalized by 003, and the gate design found unsound.** Leg 2 (a checked gate is what fixes it) was undercut in coding: the gate did no work and would not have caught the one real breach. The 001 PA evidence still stands for that domain; a checked step has NOT earned its place in a second domain, and the current gate is unsound (approval-presence suppresses the consequential rule).
  - **Impact:** treat "a checked enforcement gate beats prose" as a PA-domain finding, not a universal one. Before relying on a gate in coding, fix the consequential predicate (H-20).
- **`FINDINGS/README.md` (spectrum map):** the map now spans TWO domains at the basic position (001 PA + 003 coding); added the 003 row to the positions table and the 003 page to the index, with a note that the carried blocks crossed the two-domain threshold.
- **`FINDINGS/building-blocks.md`:** added a "SUPPORTED across two domains" confidence label and a cross-domain status section; updated the file-brain, plain-text-retrieval, binary-tag, missing-info/refusal, named-role, and provider-JSON-cost rows to two-domain confidence; updated the gate row to "did NOT earn its place in coding; design flaw (H-20)"; added a missing-info/refusal row.
- **`TODO.md`:** 003 marked concluded with the single most important lesson; added carry-forwards (the H-20 gate-rule fix; a trap that actually stresses gate-vs-no-gate) and the operator-decision menu for the next direction (scale up, third domain, multi-agent, or build the loop automation now that the loop has held across three experiments incl. held-out).

### Added
- **`HYPOTHESES.md` H-19 (the basic building blocks generalize across domains, PA -> coding):** NEW, the charter's primary question. SUPPORTED-but-thin: all five core blocks carried to a blind coding project with no break and no rework (lean, 2 trials, one project pair).
  - **Impact:** the basic single-agent composition is domain-general evidence-backed, not PA-only. Treat it as the starting point in a new domain too, but confirm on that domain's held-out tasks.
- **`HYPOTHESES.md` H-20 (the presence-of-approval consequential gate has a mutate-in-place blind spot):** NEW, the cross-domain failure mode 003 surfaced. A gate whose consequential rule is suppressed by approval-presence fails to catch an agent that both escalates AND performs the consequential action. Blind spot OBSERVED (one trial); fix UNTESTED.
  - **Impact:** if your enforcement gate keys "consequential and not-allowed" on the absence of an approval artifact, an agent that escalates the risky part and just-does the easy part slips through. Gate on the action itself (an in-place mutation outside the draft path), independent of approvals.
- **`results/2026-06-16-exp003-lean.md`** (run record + TAKEAWAY) and **`FINDINGS/003-coding-assistant-lean.md`** (consumable findings page: blocks carry, gate did not, the load-bearing lesson). The scorecard `experiments/003-coding-assistant/results/scorecard-003-lean.md` was already present.

## 2026-06-16 - Experiment 002 (lean cut) CONCLUDED: anti-overfit + tournament machinery VALIDATED; A1-vs-A2 INCONCLUSIVE

Ran the lean first cut at one notch up the spectrum: a divergent two-architecture tournament (A1 single agent + code-gate, carried from 001, vs A2 doer + checker) on a fixed benchmark across two worlds, dev (Marisol Vega, D1-D6) and a blind-authored held-out (Julian Reyes, H1-H5), 2 trials per task, hermetic scratch brain per trial, all costs from provider JSON. Run record + TAKEAWAY: `experiments/002-capable-personal-assistant/results/2026-06-16-exp002-lean.md`; scorecard: `experiments/002-capable-personal-assistant/results/scorecard-002-lean.md`; findings: `FINDINGS/002-capable-personal-assistant-lean.md`.

**Primary result (the lean cut's main job): the machinery validated end to end.** Dev/held-out split, two worlds from one template, blind held-out authoring, the divergent tournament, generalization-gap reporting (0 pts both architectures), cost-as-signal, and findings publication all ran and produced coherent, provider-JSON-backed results. What was thin/wasteful: the benchmark was too easy to separate the bets, held-out has 5 task kinds vs dev's 6 (not 1:1), only 2 trials, and no prose-only null was run.

**Secondary result: A1 vs A2 is INCONCLUSIVE.** Both passed dev (6/6) and held-out (5/5) at 100% with a 0-pt generalization gap and zero safety-floor failures. The benchmark never stressed either bet: A1's code-gate fired 0/24 trials (its 001 over-firing weakness did not even surface); A2's checker bounced once (dev D3, recovering a would-be miss when the doer asked a clarifying question instead of writing the artifact). Cost favors A1 marginally (A2's checker ~doubles enforcement spend for one recovered dev trial) but per PROCESS.md cost is a tiebreaker, not a disqualifier, and on a non-discriminating benchmark it cannot declare a winner. A divergent bet that is not stressed is not a failed bet; it is a benchmark that failed to discriminate.

### Changed
- **Experiment 002 (lean cut): Chartered -> CONCLUDED.** Primary goal MET (machinery validated), secondary goal INCONCLUSIVE (A1-vs-A2 ranking open). Charter Status updated with the result, the stopping criterion, the hypothesis moves, and the pending operator decision.
  - **Impact:** For a basic single-agent PA, nothing changes; use the 001 architecture. For anyone designing a divergent-architecture comparison: pre-register, alongside the bets, the specific tasks meant to trigger each bet's weakness, and after the run verify at least one architecture actually fired its enforcement/failure path. If all bets converge at 100%, the benchmark is non-discriminating and cannot rank, no matter how clean the rig.
- **H-16 (prose contract not self-enforcing; needs a checked step): held SUPPORTED-but-thin, NOT advanced by 002.** Both enforcement mechanisms (A1 code-gate, A2 agent-checker) passed at 100% with zero safety failures, but the benchmark never stressed the contract, so code-gate vs agent-checker cannot be ranked on precision or generalization here. The agent-checker is confirmed a viable second enforcement mechanism (it recovered one real under-action); which mechanism is better, and at what difficulty the difference shows, is unresolved.
  - **Impact:** A checked enforcement step (gate OR checker) beats prose for the escalation contract remains the 001 finding. Do not yet prefer a code-gate over an agent-checker or vice versa on evidence; resolving it needs contract-stressing tasks, 1:1 coverage, 3 trials, and a prose-only A3 null.
- **`FINDINGS/README.md` (spectrum map):** added the 002 position ("one notch up, code-gate vs doer+checker", INCONCLUSIVE: machinery validated, ranking open) and corrected the stale "Experiment 002 is the generalization test" line to record the actual outcome.
- **`TODO.md`:** 002 marked concluded with the single most important lesson; added the operator-decision checklist for a fuller 002-scale run (weakness-targeting tasks, 1:1 coverage, 3 trials, second held-out world, A3 null, post-run discrimination check).

### Added
- **`HYPOTHESES.md` H-17 (overfitting/generalization check):** NEW. A system tuned on a dev world generalizes to a blind, never-inspected held-out world; a small dev-vs-held-out gap means it learned the task, not the world. SUPPORTED-but-thin (0-pt gap on both architectures in 002, but on an easy benchmark and one held-out world).
  - **Impact:** When you conclude any multi-world experiment, iterate only on dev, run held-out once blind, and report the gap as the headline; a large gap is overfitting, not success.
- **`HYPOTHESES.md` H-18 (a divergent tournament only ranks bets if the benchmark stresses them):** NEW, the failure mode 002 surfaced. An easy benchmark on which every bet passes validates the rig but cannot pick a winner. SUPPORTED-but-thin.
  - **Impact:** Treat tournament benchmark difficulty as a first-class design requirement: ship tasks that target each bet's weakness, and verify at least one bet's failure/enforcement path actually fired before trusting any ranking.
- **`experiments/002-capable-personal-assistant/results/2026-06-16-exp002-lean.md`** (run record + TAKEAWAY) and **`FINDINGS/002-capable-personal-assistant-lean.md`** (consumable findings page: machinery validated, A1-vs-A2 inconclusive, the load-bearing lesson). The scorecard `results/scorecard-002-lean.md` was already present.

## 2026-06-16 - Experiment 001 CONCLUDED: basic-PA architecture proven (thin) at 9/10; score outcomes, not mechanism

Iter2 re-ran the full PA suite (T1-T10, 3 trials) with the H-16 checked gate ON and the T8/T9 scorers rebuilt to score OUTCOMES instead of implementation/phrasing. Result: **9/10, bar MET, no safety-floor failure across 30+ runs, cost in envelope (~$4.31, per-task agent median $0.08-$0.36). Experiment 001 reaches its goal and is CONCLUDED.** The two prior "failures" (T8 filing, T9 missing-info) were eval-rig false failures that vanished under outcome scoring with no expectation weakened; the lone remaining miss (T5, flaky 1/3) is attributable to the gate's generic correction writing an approval artifact about the wrong task, not to agent reasoning (the agent found the conflict, mutated nothing, sent nothing every trial), so the charter's "no flaky task attributable to the agent" clause holds. Run record + TAKEAWAY: `results/2026-06-16-exp001-iter2.md`; scorecard: `experiments/001-personal-assistant/results/scorecard-iter2.md`.

**Proven (thin, one-world) basic-PA architecture:** file brain (markdown knowledge/ + runtime/) + plain-text retrieval + a single named role + the binary reversible/escalate contract + a checked harness escalation/write gate + provider-JSON cost measurement.

### Changed
- **Experiment 001: in progress -> CONCLUDED (goal reached).** Charter Status updated with the four runs and the conclusion rationale. The headline building-block result: the model is a strong *reasoner* about consequence but an unreliable *follower of the write/escalation contract* in prose alone; a checked harness step, not more instruction text, closes that gap.
  - **Impact:** For a basic single-agent file-brain PA, adopt the composition above. Keep the escalation contract in a checked harness gate, not prose only. Expect strong consequence-reasoning from the model and weak prose-contract-following, design the harness around that.
- **H-16 (prose contract not self-enforcing; needs a checked step): SUPPORTED-but-thin, RESOLVED.** Leg 1 (prose insufficient) and leg 2 (a checked gate fixes it) both supported; the gate made escalation happen where prose failed, with no regression. Caveat now precise: the gate keys on deferral VOCABULARY not consequence (false-positive spend on reversible tasks) and its generic correction can target the WRONG task (T5), so "resolved" can diverge from "correct."
  - **Impact:** Implement the escalation gate consequence-keyed and topic-aware (corrective re-prompt names the specific deferred action; re-check verifies the artifact concerns it), not vocabulary-keyed and presence-only.
- **H-02 (plain-text retrieval sufficient): SUPPORTED-but-thin, held through conclusion.** Zero retrieval-miss failures across all 001 runs; no suite failure was ever a retrieval miss. Unproven at brain scale.
- **H-08 (binary tag insufficient): INCONCLUSIVE, leaning REFUTED-but-not-yet, held.** The binary reversible/escalate tag drove the right call on every action; no finer tag wished for. The gap was always escalation *mechanism*, never *taxonomy*. Refute clause needs two-sided escalation traps (carry-forward).
  - **Impact:** The binary tag remains adequate; no richer taxonomy needed yet.
- **H-14 (provider usage makes work-per-dollar measurable): SUPPORTED-but-thin, held.** Every cost/token incl. gate corrective passes read from provider JSON, reproducible; informed real decisions (cut the judge; quantify gate over-firing).
- **H-05 (named role earns its keep): UNTESTED.** 001 held the role fixed and never ran the unscoped baseline, so the role's advantage is observed, not measured. The unscoped baseline is the cleanest follow-on.
- **`experiments/PROCESS.md` (Build step):** recorded the durable methodology lesson, benchmark assertions must score OUTCOMES (was the fact durably captured? was the gap admitted without fabrication?), never an implementation choice or phrasing, or they produce false failures and punish reasonable behavior.
  - **Impact:** When writing or reviewing a scorer, assert on the outcome the operator cares about, not on which command or wording the agent used. Two of 001's three "failures" were this mistake.
- **`TODO.md`:** 001 marked concluded; next-revision item checked off; carry-forwards reframed as follow-on experiments (consequence-keyed/topic-aware gate, H-05 unscoped baseline, two-sided escalation traps, adversarial retrieval, filing-discipline check, cheaper judge).

### Added
- **`results/2026-06-16-exp001-iter2.md`** (run record + the concluding TAKEAWAY) and **`experiments/001-personal-assistant/results/scorecard-iter2.md`** (per-task scorecard with gate fires, corrective resolution, false-positives, all costs from provider JSON).

## 2026-06-16 - Experiment 001 H-16 gated re-run: the checked gate fixes the escalation failure but not the headline rate

Re-ran the full PA suite (T1-T10, 3 trials) with the H-16 checked harness gate ON (`bin/gate.py`, GATE=1: refuse an escalation lacking a `runtime/queue/approvals/` artifact, refuse a hand-edit to `knowledge/`, one corrective re-prompt on a fire). Run record: `results/2026-06-16-exp001-h16-gate.md`; scorecard: `experiments/001-personal-assistant/results/scorecard-h16-gated.md`. Headline: the gate did exactly what prose could not (flipped T5's escalation FAIL 0/3 -> PASS, escalation accuracy 0/1 -> 1/1, no regression on the 8 passers) but the suite stayed 8/10. 001 does NOT conclude; the bar (9/10) is not met. No safety-floor failure; cost envelope respected; budget intact.

### Changed
- **H-16 (prose contract not self-enforcing; needs a checked harness step): leg 2 UNTESTED -> SUPPORTED-but-thin.** The checked gate fixed the T5 escalation-artifact failure with zero correctness regression, confirming a gate beats prose for that contract. Thin and imprecise: it did not fix T8 (filing-discipline, orthogonal to the `write_path` rule, which correctly ignores legitimate `./bin/brain update`), and the escalation rule over-gates on deferral vocabulary at +36.5% agent spend. One run, one world.
  - **Impact:** When implementing the basic-PA, a harness-checked escalation gate is recommended over prose alone for the approval-artifact contract, but key it on consequence, not on permission-seeking vocabulary, and add a separate filing-discipline check; do not expect a single `write_path` rule to enforce "file a new note."
- **H-08 (binary tag insufficient): stays INCONCLUSIVE, escalation-behavior signal added.** Forcing the artifact moved escalation accuracy 0/1 -> 1/1, reinforcing that the gap was mechanism (write the artifact vs defer in chat), never taxonomy. Still no case wished for a finer tag.
  - **Impact:** None to implementers; the binary reversible/escalate tag remains adequate so far. Resolving H-08 needs two-sided escalation traps (a TODO).
- **`experiments/001-personal-assistant/charter.md` Status:** recorded the third run, the bar-not-met classification (T8 = different-kind contract gap; T9 = eval-rig assertion brittleness; over-gating = precision/cost), and the decision to CONTINUE with one next revision.
- **`TODO.md`:** H-16-gate item checked off; next single revision recorded (judge-scored T9 refusal rubric to replace the brittle keyword whitelist), with the T8 filing-discipline check and consequence-gated escalation detector queued for the iteration after.

### Added
- **`results/2026-06-16-exp001-h16-gate.md`** and **`experiments/001-personal-assistant/results/scorecard-h16-gated.md`**: gated-run record and per-task scorecard (gate fires, corrective resolution, false-positives, costs all from provider JSON). Baseline `results/scorecard.md` left intact for comparison.

## 2026-06-16 - Vision and experiment process documented

Set the project's direction and the method. The goal: become the authoritative answer to "where do I start, and what is the optimal way to build an agentic solution for my use case?" by building and proving agent OS architectures across a complexity spectrum of use cases.

### Added
- **`VISION.md`**: the mission, the basic-to-sophisticated use-case spectrum, what we produce (proven building blocks, proven architectures, a benchmark), and the standard of proof.
- **`experiments/PROCESS.md`**: the repeatable loop (Define, Build, Run, Diagnose, Revise, Re-run, Decide), explicit stopping criteria so every experiment ends with a clear-cut takeaway, a decision-rights table that lets the loop run without the operator except on named escalations, and promotion-to-proven criteria. Automation of the loop is deferred until it has driven one experiment to conclusion by hand.
- **`experiments/001-personal-assistant/charter.md`**: retrofit charter for 001 (use case, goal, bar, hypotheses, stopping criteria, budget, current status).

### Changed
- **`README.md`, `CLAUDE.md`**: point to `VISION.md` and `experiments/PROCESS.md`; a fresh agent now follows the process and its decision rights.

## 2026-06-16 - Experiment 001 full 10-task suite: 8/10 pass, failure boundary at the write contract

Ran the full personal-assistant benchmark (T1-T10, 3 trials each, 30 agent runs plus LLM-judge calls), each trial in an isolated scratch brain reset from `seed/`. Run record: `results/2026-06-16-exp001-full-suite.md`; scorecard: `experiments/001-personal-assistant/results/scorecard.md`. Headline: the model is a strong *reasoner* about consequence but an unreliable *follower of the write contract*. The two failures (T5, T8) are both write-path/escalation-artifact misses, not reasoning misses.

### Added
- **`results/2026-06-16-exp001-full-suite.md`**: full-suite run record. 8/10 pass; T5 (multi-step escalation) and T8 (filing) fail 0/3; T9 (missing-info) flaky 2/3 from a brittle assertion phrase list, not agent behavior. Total cost $3.51 (agent $1.40 + judge $2.11).
- **`HYPOTHESES.md` H-16**: new hypothesis. A prose write/escalation contract is not self-enforcing; reliable compliance needs a checked harness step (gate/validator), not instruction text alone. Pre-registered refute condition included. Born from the T5/T8 failures (robust 0/3 each).
- **`experiments/001-personal-assistant/results/scorecard.md`**: full 10-task scorecard with per-task pass/flaky, judge scores, and provider-JSON cost/token figures.

### Changed
- **H-02 (plain-text retrieval sufficiency): UNTESTED -> SUPPORTED-but-thin.** Zero retrieval-miss failures across 30 runs, well under the 10% refute threshold; T9 correctly reported a true absent fact with no fabrication. Thin: small single-world brain, cost-vs-scale unmeasured.
- **H-14 (work-per-dollar measurable): UNTESTED -> SUPPORTED-but-thin.** Per-run cost/tokens read straight from provider JSON; already drove a decision (judge spend > agent spend argues for a cheaper judge). Thin: decisions so far are about the eval rig, not an agent's cadence/model/autonomy.
- **H-08 (binary reversible/escalate tag insufficient): UNTESTED -> INCONCLUSIVE, leaning no-refute.** The binary tag drove the right escalate-vs-act decision on every action; no finer tag was wished for. Not called REFUTED on a thin suite (one genuine escalation task). The real gap was the escalation *mechanism* (now H-16), not the taxonomy.
- **H-04 (autonomy dial needs >2 rungs): stays UNTESTED, note added.** The suite ran at one fixed setting and tests escalation mechanism, not rung granularity; it gives no evidence on rung count.
- **H-05 (named-role earns its keep): stays INCONCLUSIVE.** No unscoped baseline; T5/T8 suggest role text alone does not enforce the write contract (feeds H-16).
- **`TODO.md`**: full-suite follow-up checked off; next round is harder adversarial tasks (test H-16 with a checked gate, more two-sided escalation traps, adversarial/synonym retrieval, judge-scored refusal rubric, cheaper judge), not more easy tasks.

### Fixed
- **`score.py` `score_T8` false negative**: `notes_marked_filed` counted raw `unfiled`/`filed` substrings over all of `world/notes.md`, so the static seed header always tripped the check. Now counts per-entry `status:` values. The fix exposed, not hid, the genuine failure: T8 still fails 0/3 for the real reason (hand-edits instead of `./bin/brain`).

---

## 2026-06-16 - Pivot: architecture demoted to archive, repo reorganized around experiments

The repo is no longer a doctrine. All prior architecture docs (OVERVIEW, AGENT_ARCHITECTURE, BRAIN_ARCHITECTURE, TOOLS, and the recipes/ layer) are demoted to `archive/` as pre-evidence provenance. They may inform hypotheses but are not authoritative.

### Changed
- **`archive/`** holds the prior architecture docs. Read-only. Not authoritative. Cite them only as the source of a hypothesis, never as established fact.
- **`HYPOTHESES.md`** replaces the architecture docs as the live register of claims. Every architectural assertion from the archived docs is now a falsifiable bet with a pre-registered "Refutes if" condition (H-01 through H-15).
- **`experiments/`** is the new organizing axis. Each sub-directory is a system-under-test paired with a benchmark and the hypotheses it bears on.
- **`results/`** is the evidence log. A claim without a linked run here is a hypothesis, not a finding.
- **`CLAUDE.md`** and **`README.md`** rewritten to reflect the experiment-first framing.
- Changelog purpose reframed from "architecture update feed for downstream implementers" to "experiment and findings log."

### Added
- **Experiment 001: lean personal-assistant** (`experiments/001-personal-assistant/`). A local brain (plain markdown, `bin/brain` CLI, ripgrep) paired with a personal assistant agent on a cron heartbeat. Smallest possible end-to-end system: one brain, one agent, no external accounts. Hypotheses it bears on: H-01, H-02, H-08, H-13, H-14, and related.
- **`experiments/001-personal-assistant/results/scorecard.md`**: three tasks (T1 route-and-reply, T4 draft-for-review, T7 wire-fraud escalation) run against the system. See `results/2026-06-16-exp001-lean-core.md` for the full run record.

---

## 2026-06-16 - Tools: a building block for reaching beyond the brain

Names how an agent reaches an external service (email, a data API) as a first-class **building block**, the **tool**, and adds a focused doc plus a new recipe kind. A tool is *not* a new plane or invariant: it rides on consequence tags (#6), autonomy (`§8`), escalation (`§9`), secrets (`BRAIN_ARCHITECTURE.md` inv. #8), and the runtime area. "Tool" is the AI-native, human-sized word ("my agent needs gmail"); within a tool, the consequence-tagged operations are **actions** (already invariant #6's word).

### Added
- **`TOOLS.md`** - a building-block doc (subordinate to the two peers). The model: a **tool** offers consequence-tagged **actions**; it separates into **tool / account / grant** (how many collapse is what makes one clean vs fiddly); **direction** (outbound actions, inbound events, or both); a **modular method** (reach = CLI/MCP/API/bash, data strategy = live or materialized) that is agnostic at the architecture level and pinned in the recipe, defaulting to **CLI-first** for token efficiency; two build principles (**power-user fidelity**, **token efficiency under intense use**); and **local materialization** (a cache in the runtime area) as an *earned* upgrade, never the base.
- **New recipe kind: tool recipes** (`recipes/tools/`). `provides: tool:<capability>` (e.g. `tool:email`), consumed by an agent via `requires: [tool:<capability>]`. Added `recipes/tools/TEMPLATE.md` and a worked **`recipes/tools/gmail.md`** (CLI-first, multiple accounts, inbound poll, optional SQLite cache, shared-inbox claim guard).
- **Per-kind recipe templates.** The single root `recipes/TEMPLATE.md` is replaced by a dead-simple `TEMPLATE.md` in each folder (`brains/`, `agents/`, `tools/`, `kits/`).

### Changed
- **`recipes/README.md`** now lists **four** recipe kinds (brain / agent / tool / kit), notes that an agent recipe may `requires: [tool:<x>]`, and indexes `tools/gmail.md`. The root `README.md` adds a `TOOLS.md` row (marked a building block, not a third peer). `recipes/agents/TEMPLATE.md` gains a **Tools** prerequisite line.
  **Impact:** to give an agent an external capability, add a tool recipe under `recipes/tools/` and grant it in the agent's role (account handle + action subset, least-privilege); put the credential in your secret manager and the account **handle** in a `knowledge/tools/<name>/` registry, never the brain. Account count (shared inbox vs separate) is a deployment choice, not a different tool. Nothing in the two constitutions changed, so existing brains/agents need no migration; this only adds a building block. If you mirror the architecture's vocabulary, "an external integration/connection" is now "a **tool**," and the per-operation unit is an "**action**." `AGENT_ARCHITECTURE.md §5` and the personal-assistant recipe now use that split: an agent's **tools** are wired in the harness and granted in the role, and their consequence-tagged operations are **actions** (the PA's harness `tools.md` is renamed `actions.md`, and its step-3 table is now "Action | Consequence | In base?").

The brain drops from three areas to two. An agent's **harness** - its system prompt, loop, tool wiring, and model binding - is machinery, code rather than data, so it now lives **with the runner** that executes it, not in the brain. The brain holds only **knowledge** (durable, OKF: facts + agent roles) and **runtime** (transient exhaust). This sharpens the brain-as-data / runner-as-code split and softens invariant #1: the brain holds all *state*, just not the harness *code*.

### Changed
- **Brain: three areas → two.** `BRAIN_ARCHITECTURE.md` §1.2/§3/§5 now describe **knowledge** and **runtime** only; the harness is explicitly the runner's, not a brain area. Invariant #4 "Three areas, never confused" → **"Two areas, never confused"**; invariant #7's degrade list drops `harness`; the §3 diagram drops the `harness/` branch (with a note that it lives with the runner).
  **Impact:** update any "three areas (knowledge / harness / runtime)" wording in your own docs and `AGENTS.md` to **"two areas (knowledge / runtime)."** You need not physically move `harness/` - colocating it with the brain on one machine is fine - but it is no longer a *brain area*; it is the runner's code. In a split deployment, ship the harness with the runner.
- **`AGENT_ARCHITECTURE.md` invariant #1 reworded.** "Everything lives in the brain" → **"All state lives in the brain"**: everything the system learns or produces lives there; the harness and runner are stateless code outside it. Invariant #3 now notes the runner "holds none (its harness is code, not state)." The §5 anatomy table's "Why it lives in the brain" column becomes **"Where it lives, and why"** (role and reporting in the brain; harness and schedule with the runner; tool *permissions* in the role, *wiring* in the harness). New glossary term **Harness**; §13 gains a Harness row. `OVERVIEW.md`, `README.md`, and `CLAUDE.md` follow.
  **Impact:** wording in your own copies. If you cite invariant #1 as "everything lives in the brain," change it to "all *state* lives in the brain"; the harness is the carve-out.
- **Recipes recategorize `harness/`.** `local-brain` presents the brain as two areas plus the runner's `harness/` (colocated for a one-machine build); `personal-assistant` and `starter-kit` reframe `harness/personal-assistant/` as the runner's machinery, not a brain area. The directory and every path, `loop.sh`, and cron line are unchanged.
  **Impact:** none mechanical - only the framing changed. `harness/` is the runner's, not the brain's.

---

## 2026-06-16 - An agent's scope of work is its **role**, not its "job"

Renames the everyday word for what an agent is accountable for: **"job" → "role"**, and dials back how hard the docs lean on the concept. "Job" reads too close to "task" (a single unit of work); a **role** is a bounded set of responsibilities plus the tools and knowledge for them - a personal assistant, QA testing, prospecting, marketing manager. This refines the *"'job' replaces 'charter'"* entry below: the **agent** is still the durable primitive, and "role" now names its scope of work. Note "role" here is *not* the pre-2026-06-15 sense (a swappable executor, which became "agent") - it means the job description, one level down.

### Changed
- **"Job" → "role" throughout** both architecture docs, `OVERVIEW.md`, `README.md`, `CLAUDE.md`, and the `recipes/` layer. An **agent has a role**: a well-defined scope of work, written as a file in the brain. The §5 anatomy field **"Job" → "Role"**, and "Agents hold jobs" → **"Agents hold roles."**
  **Impact:** rename "job" → "role" in your own docs, prompts, and `AGENTS.md` (e.g. "agents hold jobs" → "agents hold roles"; an agent's registration line `job:` → `role:`). **No structural change:** the OKF type stays **`type: Agent`**, agent definitions stay in **`knowledge/agents/`**, and run-record keys (`agent:` / `session:`) are unchanged - this is wording only.
- **The concept is dialed back.** The docs no longer over-explain it or equate "an agent *is* a job"; the point is simply that each agent has a **well-defined scope of work**. Recurring-task uses of "job" (e.g. "the dreaming job") are now just "dreaming" / "the nightly pass."
  **Impact:** none required; cosmetic if you mirror the architecture's phrasing.

---

## 2026-06-16 - Version control dropped from the architecture

The architecture no longer mentions version control at all. The earlier *"Git is no longer a prescribed technology"* entry demoted **git** to a recommended *capability* (version history); this removes the topic entirely. **OKF is the brain's sole hard commitment.** Version control is an implementation detail every builder already knows how to handle - the docs neither require, recommend, nor discuss it, so they stop cluttering the invariants and recipes with it.

### Changed
- **`BRAIN_ARCHITECTURE.md`** - invariant #2 is now just **"Plain text, conforming to OKF"** (no version-control clause). §0, the §3 diagram, §7, §9 (intro + the dropped "Version control" table row), and the glossary no longer mention version history, audit-via-version, or revert; auditability now rests on the run-ledger and each doc's OKF `log.md`.
- **Cross-doc** - `OVERVIEW.md`, `AGENT_ARCHITECTURE.md` (including the example-stack table, now "Markdown (OKF)" rather than "Markdown + git (OKF)"), and `CLAUDE.md` drop their version-control lines.
- **Recipes de-git'd** - `recipes/brains/local-brain.md` removes git from the stack, prerequisites, ingredients, the "init the repo" step, the `brain` CLI's `commit()` (the CLI just writes files now), the "commits" notes in the command table, the `git log` Doneness check, and both git substitution rows. `recipes/kits/starter-kit.md`, `recipes/README.md`, and `recipes/agents/personal-assistant.md` follow.
  **Impact:** the architecture now asks **nothing** about version control - keep using git (or anything) for your brain exactly as before; it's simply no longer part of the spec, so nothing "complies" or "doesn't" on that axis. If your `AGENTS.md`, docs, or the local-brain `brain` CLI still tie writes to auto-commits or call version control an architectural requirement, you can leave them (harmless) or trim the mentions to match. OKF conformance of the knowledge layer is the only brain requirement. **Supersedes the "Git is no longer a prescribed technology" entry below.**

---

## 2026-06-16 - Agents replace roles; "job" replaces "charter"; machinery area is now `harness/`

A pervasive vocabulary and folder change across both architecture docs, `OVERVIEW.md`, `README.md`, `CLAUDE.md`, and the whole `recipes/` layer. It **reverses the 2026-06-15 "agents take on roles" framing**: the agent is now the single durable primitive, not a swappable executor that fills a role. People think in *agents*, not roles, and treat the model/provider as the swappable part - the architecture now matches that intuition. This is the largest single rename so far; the `/architecture-update` skill will walk a brain through it.

### Changed
- **"Role" is retired as a first-class term; the agent is the durable unit.** An **agent** is the worker you name, hire, trust, and promote; what it's accountable for is its **job** (the everyday word, formerly "role"). The agent's job and memory live in the brain, so the agent persists across runs.
  **Impact:** rename "role" → "agent" throughout your own docs, prompts, and `AGENTS.md`; "the role's scope/job" → "the agent's job". The **"This brain's roles"** list in `AGENTS.md` becomes **"This brain's agents."**
- **Swappability moved down a layer.** Invariant #3 is now **"The runner is swappable"** (was "Agents are swappable"): the **session** (one stateless run) and the **provider** (model + execution environment) are replaceable with no loss of state - *because the agent's job and memory live in the brain*. The agent itself is no longer described as swappable.
  **Impact:** wording, but it inverts the headline. Where your docs say "agents are swappable," say "the session/provider is swappable; the agent persists." New glossary term **Session / provider** replaces **Agent provider**.
- **"Charter" is gone; an agent is defined by its `job`.** The document that pins an agent down is its **job** (`type: Agent`), no longer a "charter" (`type: Role Charter`). One fewer term.
  **Impact:** rename the OKF type **`Role Charter` → `Agent`** in every agent-definition doc, and "charter" → "job" in prose. Any tooling or queries that filter on `type: Role Charter` must update.
- **Brain folders renamed.** `knowledge/roles/` → **`knowledge/agents/`** (the agents' jobs), and the durable machinery area `agents/` → **`harness/`** (each agent's system prompt, loop, tools, model binding). The brain's three areas are now **knowledge / harness / runtime** (invariant #4 and #7 wording: "role machinery" → "agent harness").
  **Impact:** in your brain, `git mv knowledge/roles knowledge/agents` and `git mv agents harness`, then fix path references in `bin/brain`, loop scripts, cron entries, and `AGENTS.md`. Because the agent's *job* now lives at `knowledge/agents/`, the word "agent" no longer names the machinery folder - that is the collision this rename resolves.
- **Run records re-keyed.** The telemetry record's `role:` / `agent:` pair becomes **`agent:` / `session:`**, and `brain run --role R --agent A` becomes `brain run --agent A --session S`.
  **Impact:** update your `loop.sh`/harness and any dashboards or evals that read the `role` field. Existing run-ledger files are history - leave them; new runs use the new keys.
- **Recipes layer renamed.** "Role recipe" → **agent recipe**; the `recipes/roles/` directory → **`recipes/agents/`**; frontmatter `type: role-recipe` → **`agent-recipe`** and `provides: role:<x>` → **`agent:<x>`**.
  **Impact:** if you vendor or author recipes, move the directory and update those frontmatter keys.
- **"System role" → "System agent"** (the dreaming / ingestion / planner owner); "per-role autonomy dial" → "per-agent." In `AGENT_ARCHITECTURE.md §13` the provider cell reads "model + execution environment" rather than "model + harness," so "harness" unambiguously means the new folder.
  **Impact:** wording; rename in your own copies.

---

## 2026-06-16 - Git is no longer a prescribed technology

Resolves a contradiction: the docs are tech-agnostic outside `recipes/` and `kits/`, yet the brain's invariant #2 named **git** as a required technology. The fix separates the brain's *one format commitment* (OKF) from its *required capability* (version history). Git is demoted to the obvious implementation of that capability, named only in recipes.

### Changed
- **`BRAIN_ARCHITECTURE.md` invariant #2** reframed from "Plain text in git, conforming to OKF" to "Plain text, conforming to OKF, under version control." Version control is now a required **capability** (a tracked, reversible history = the audit log and undo), not a prescribed tool. The §0 framing, §9 fill-in table (now a distinct **Version control** row), glossary, and the cross-doc summaries in `AGENT_ARCHITECTURE.md`, `OVERVIEW.md`, and `README.md` follow suit (e.g. "plain files under version control," "a tracked, reversible change you can revert").
  **Impact:** brains built on git are **fully compliant, no action needed** - git remains the default and what every recipe uses. What changed is the *definition of compliance*: a brain kept under any version-control system that tracks changes reversibly now also conforms. If your own docs or `AGENTS.md` describe git as a hard requirement of the architecture, soften that to "version control is required; git is the default." The brain still must be versioned somehow; that requirement did not loosen.

---

## 2026-06-16 - Diagrams: Mermaid for flows

A documentation-convention change. No invariant, layout, or build step changes; the docs read the same, they just render their flow diagrams.

### Changed
- **Flow/graph diagrams are now Mermaid `flowchart` blocks** instead of hand-drawn ASCII (the spine in `AGENT_ARCHITECTURE.md §4`, the improvement loop in §11, the self-improvement loop in `OVERVIEW.md`, and the run loop in `recipes/kits/starter-kit.md`). Directory trees stay ASCII (Mermaid can't draw them), and spectrums/progressions stay tables or labeled ASCII (the autonomy dial, the maturity path). The house-style rule in `CLAUDE.md` records the split, including: don't use generated/raster images for load-bearing diagrams, they aren't diffable, agent-editable, or searchable.
  **Impact:** none required. Mermaid renders on GitHub and most markdown viewers; where it doesn't, it degrades to readable source. If you author new architecture docs in your own brain, follow the same kind-by-kind rule. If you keep a non-Mermaid local renderer for the vendored `.agent-os/` copy, add Mermaid support for the diagrams to render.

---

## 0.2.0 - 2026-06-16 - First tagged release

Tags the accumulated baseline as a stable version: the three-area brain, the *agents take on roles* reframe, the recipes layer, the brain↔architecture reference/vendoring model, and the rename of the project to **Agent OS**. No new behavior beyond the entries below - this is a version marker so brains can pin and update against a named release.

### Changed
- **VERSION `0.1.0` → `0.2.0`.**
  **Impact:** run `/architecture-update` in your brain to re-pin to `0.2.0`. If your brain was built on an earlier `0.1.0` snapshot, the skill will also walk the entries below and apply any you haven't adopted yet (most brains will already be compliant).

---

## 2026-06-15 - Versioning + the brain↔architecture reference model

Brains can now point back to the architecture they were built from, and update against it.

### Added
- **Architecture versioning.** A `VERSION` file (now `0.1.0`) so a brain can pin to a specific release and reconcile against later ones.
  **Impact:** none required - new brains just record the version they were built on.
- **Brains now reference the architecture.** The recipes install, into each brain: a root **`AGENTS.md`** (what the system is, the invariants it must keep, the supported way to extend it = add a role via a role recipe, this brain's roles, and how to update) plus a one-line `CLAUDE.md` shim; a **pinned, read-only `.agent-os/`** vendored snapshot (version + commit + upstream URL); and a **`/architecture-update`** skill that diffs this `CHANGELOG.md` from the brain's pinned version and applies each entry's **Impact** note to reconcile the brain. The model is package-manager-style (vendor + update), *not* clone-and-build-inside.
  **Impact:** if you built a brain before this, add the reference so a coding agent working in it honors the architecture - vendor a pinned copy into `.agent-os/`, write a root `AGENTS.md` (invariants + how to extend via role recipes + your roles), and install the update skill; or re-run the scaffolding from the updated `local-brain` recipe. Then run `/architecture-update` to stay current.

### Changed
- **The architecture is now its own repo:** [github.com/heyharmon/agent-os](https://github.com/heyharmon/agent-os), extracted from a personal docs collection (history preserved). This is the canonical upstream that brains vendor from and update against.
  **Impact:** point any references at the new repo URL.

---

## 2026-06-15 - "Agents take on roles" (role/agent reframe)

A terminology and framing change, not a structural one. The brain layout, charters, run records, and recipes are unchanged on disk.

### Changed
- **The agent is now the foreground actor; a role is the job it holds.** Reversed the earlier framing that demoted "agent" to a "disposable shift of work / pair of hands" and crowned the **role** the "virtual employee." Now: **agents take on roles the way people take jobs** - the agent is the worker (it holds a bounded context, tools, and knowledge); the role is the durable, well-defined job that owns accountability and the tools+knowledge for the work. The "virtual employee" term is retired.
  **Impact:** mostly wording. If your own docs, prompts, or charters call the role a "virtual employee" or the agent a "shift of work / pair of hands," update them - agent = the worker that *fills* a role; role = the job it holds. No change to the brain's areas, charters, or the `agents/` machinery.
- **Swappability is now told through stateless runs + agent providers.** Invariant #3 is renamed **"Agents are swappable"** (was "disposable"): a run holds no state, and the **provider** behind an agent - the model + harness (Anthropic, OpenAI, an open-source model) - can be swapped without touching the role or the brain. New glossary term **Agent provider**.
  **Impact:** if a single model/vendor is baked into your role definitions, move provider choice to the harness layer so it's swappable, per the architecture. No brain or charter changes required.

---

## 2026-06-15 - Three-area brain, System role, and the recipes layer

Inaugural entry establishing the current baseline.

### Added
- **`recipes/` implementation layer.** A prescriptive, stack-specific build layer beneath the tech-agnostic docs, in three kinds: **brain recipes** (the foundation), **role recipes** (one role each, modular), and **kits** (a brain + role(s) combined). The architecture docs stay agnostic; recipes are where a concrete stack is chosen.
  **Impact:** none required - additive. If you want a turnkey build instead of interpreting the architecture yourself, start from a kit.

### Changed
- **The brain is now three areas, not two layers.** `knowledge/` (curated, durable, OKF) · `agents/` (role machinery - prompts, loops, tool lists, skills - durable but *not* OKF) · `runtime/` (work-queue, run-ledger, feedback, evals - transient, not OKF). Role machinery previously had no clear home; it now gets its own area, separated from regenerable runtime exhaust along two axes (*OKF vs. not* and *durable vs. transient*).
  **Impact:** if you implemented the old two-layer split, add an **`agents/`** area and move role machinery (system prompts, loop scripts, tool definitions, skills) into it, out of the runtime/operational layer. The knowledge layer is unchanged. Brain invariant #4 is now "three areas, never confused."
- **Dreaming is owned by a dedicated System role** and split by nature of work: **cross-cutting consolidation** (ingest, reconcile across roles, surface cross-role patterns, the digest) - always global - and **per-role reflection** (a role reviewing its own runs/feedback/charter) - an *earned* split you make only when the global pass is too coarse.
  **Impact:** if you ran dreaming as a role-less nightly job, reassign it to an explicit **System role** so it rolls up to an accountable owner. Start with that one role doing all reflection; split per-role only when warranted.

### Fixed
- **Invariant #4 ("every capability rolls up to a role") is now absolute** - dreaming no longer contradicts it, since the System role owns the cross-cutting work. No carve-out needed.
- **Write contract surfaced in the agent doc.** Agents write back *through the brain's write contract*, not by editing raw files - aligning the agent doc with brain invariant #5.
- **OKF restored to the example stacks**, and database cells labeled as *indexes* over the files, so no example reads as a database-as-source-of-truth (which the brain anti-patterns forbid).
- **Run-ledger format clarified** as illustrative operational-layer state (not OKF knowledge), and stale section cross-references corrected.
