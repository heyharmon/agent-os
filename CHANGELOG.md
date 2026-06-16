# Changelog

A log of experiments run, findings recorded, and hypothesis status changes. The architecture docs in `archive/` are pre-evidence provenance; this file records what we learned by building and running.

The format follows [Keep a Changelog](https://keepachangelog.com): newest first, grouped into **Added / Changed / Fixed**. Dates are `YYYY-MM-DD`.

---

## 2026-06-16 — Experiment 001 CONCLUDED: basic-PA architecture proven (thin) at 9/10; score outcomes, not mechanism

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

## 2026-06-16 — Experiment 001 H-16 gated re-run: the checked gate fixes the escalation failure but not the headline rate

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

## 2026-06-16 — Vision and experiment process documented

Set the project's direction and the method. The goal: become the authoritative answer to "where do I start, and what is the optimal way to build an agentic solution for my use case?" by building and proving agent OS architectures across a complexity spectrum of use cases.

### Added
- **`VISION.md`**: the mission, the basic-to-sophisticated use-case spectrum, what we produce (proven building blocks, proven architectures, a benchmark), and the standard of proof.
- **`experiments/PROCESS.md`**: the repeatable loop (Define, Build, Run, Diagnose, Revise, Re-run, Decide), explicit stopping criteria so every experiment ends with a clear-cut takeaway, a decision-rights table that lets the loop run without the operator except on named escalations, and promotion-to-proven criteria. Automation of the loop is deferred until it has driven one experiment to conclusion by hand.
- **`experiments/001-personal-assistant/charter.md`**: retrofit charter for 001 (use case, goal, bar, hypotheses, stopping criteria, budget, current status).

### Changed
- **`README.md`, `CLAUDE.md`**: point to `VISION.md` and `experiments/PROCESS.md`; a fresh agent now follows the process and its decision rights.

## 2026-06-16 — Experiment 001 full 10-task suite: 8/10 pass, failure boundary at the write contract

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

## 2026-06-16 — Pivot: architecture demoted to archive, repo reorganized around experiments

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

## 2026-06-16 — Tools: a building block for reaching beyond the brain

Names how an agent reaches an external service (email, a data API) as a first-class **building block**, the **tool**, and adds a focused doc plus a new recipe kind. A tool is *not* a new plane or invariant: it rides on consequence tags (#6), autonomy (`§8`), escalation (`§9`), secrets (`BRAIN_ARCHITECTURE.md` inv. #8), and the runtime area. "Tool" is the AI-native, human-sized word ("my agent needs gmail"); within a tool, the consequence-tagged operations are **actions** (already invariant #6's word).

### Added
- **`TOOLS.md`** — a building-block doc (subordinate to the two peers). The model: a **tool** offers consequence-tagged **actions**; it separates into **tool / account / grant** (how many collapse is what makes one clean vs fiddly); **direction** (outbound actions, inbound events, or both); a **modular method** (reach = CLI/MCP/API/bash, data strategy = live or materialized) that is agnostic at the architecture level and pinned in the recipe, defaulting to **CLI-first** for token efficiency; two build principles (**power-user fidelity**, **token efficiency under intense use**); and **local materialization** (a cache in the runtime area) as an *earned* upgrade, never the base.
- **New recipe kind: tool recipes** (`recipes/tools/`). `provides: tool:<capability>` (e.g. `tool:email`), consumed by an agent via `requires: [tool:<capability>]`. Added `recipes/tools/TEMPLATE.md` and a worked **`recipes/tools/gmail.md`** (CLI-first, multiple accounts, inbound poll, optional SQLite cache, shared-inbox claim guard).
- **Per-kind recipe templates.** The single root `recipes/TEMPLATE.md` is replaced by a dead-simple `TEMPLATE.md` in each folder (`brains/`, `agents/`, `tools/`, `kits/`).

### Changed
- **`recipes/README.md`** now lists **four** recipe kinds (brain / agent / tool / kit), notes that an agent recipe may `requires: [tool:<x>]`, and indexes `tools/gmail.md`. The root `README.md` adds a `TOOLS.md` row (marked a building block, not a third peer). `recipes/agents/TEMPLATE.md` gains a **Tools** prerequisite line.
  **Impact:** to give an agent an external capability, add a tool recipe under `recipes/tools/` and grant it in the agent's role (account handle + action subset, least-privilege); put the credential in your secret manager and the account **handle** in a `knowledge/tools/<name>/` registry, never the brain. Account count (shared inbox vs separate) is a deployment choice, not a different tool. Nothing in the two constitutions changed, so existing brains/agents need no migration; this only adds a building block. If you mirror the architecture's vocabulary, "an external integration/connection" is now "a **tool**," and the per-operation unit is an "**action**." `AGENT_ARCHITECTURE.md §5` and the personal-assistant recipe now use that split: an agent's **tools** are wired in the harness and granted in the role, and their consequence-tagged operations are **actions** (the PA's harness `tools.md` is renamed `actions.md`, and its step-3 table is now "Action | Consequence | In base?").

The brain drops from three areas to two. An agent's **harness** — its system prompt, loop, tool wiring, and model binding — is machinery, code rather than data, so it now lives **with the runner** that executes it, not in the brain. The brain holds only **knowledge** (durable, OKF: facts + agent roles) and **runtime** (transient exhaust). This sharpens the brain-as-data / runner-as-code split and softens invariant #1: the brain holds all *state*, just not the harness *code*.

### Changed
- **Brain: three areas → two.** `BRAIN_ARCHITECTURE.md` §1.2/§3/§5 now describe **knowledge** and **runtime** only; the harness is explicitly the runner's, not a brain area. Invariant #4 "Three areas, never confused" → **"Two areas, never confused"**; invariant #7's degrade list drops `harness`; the §3 diagram drops the `harness/` branch (with a note that it lives with the runner).
  **Impact:** update any "three areas (knowledge / harness / runtime)" wording in your own docs and `AGENTS.md` to **"two areas (knowledge / runtime)."** You need not physically move `harness/` — colocating it with the brain on one machine is fine — but it is no longer a *brain area*; it is the runner's code. In a split deployment, ship the harness with the runner.
- **`AGENT_ARCHITECTURE.md` invariant #1 reworded.** "Everything lives in the brain" → **"All state lives in the brain"**: everything the system learns or produces lives there; the harness and runner are stateless code outside it. Invariant #3 now notes the runner "holds none (its harness is code, not state)." The §5 anatomy table's "Why it lives in the brain" column becomes **"Where it lives, and why"** (role and reporting in the brain; harness and schedule with the runner; tool *permissions* in the role, *wiring* in the harness). New glossary term **Harness**; §13 gains a Harness row. `OVERVIEW.md`, `README.md`, and `CLAUDE.md` follow.
  **Impact:** wording in your own copies. If you cite invariant #1 as "everything lives in the brain," change it to "all *state* lives in the brain"; the harness is the carve-out.
- **Recipes recategorize `harness/`.** `local-brain` presents the brain as two areas plus the runner's `harness/` (colocated for a one-machine build); `personal-assistant` and `starter-kit` reframe `harness/personal-assistant/` as the runner's machinery, not a brain area. The directory and every path, `loop.sh`, and cron line are unchanged.
  **Impact:** none mechanical — only the framing changed. `harness/` is the runner's, not the brain's.

---

## 2026-06-16 — An agent's scope of work is its **role**, not its "job"

Renames the everyday word for what an agent is accountable for: **"job" → "role"**, and dials back how hard the docs lean on the concept. "Job" reads too close to "task" (a single unit of work); a **role** is a bounded set of responsibilities plus the tools and knowledge for them — a personal assistant, QA testing, prospecting, marketing manager. This refines the *"'job' replaces 'charter'"* entry below: the **agent** is still the durable primitive, and "role" now names its scope of work. Note "role" here is *not* the pre-2026-06-15 sense (a swappable executor, which became "agent") — it means the job description, one level down.

### Changed
- **"Job" → "role" throughout** both architecture docs, `OVERVIEW.md`, `README.md`, `CLAUDE.md`, and the `recipes/` layer. An **agent has a role**: a well-defined scope of work, written as a file in the brain. The §5 anatomy field **"Job" → "Role"**, and "Agents hold jobs" → **"Agents hold roles."**
  **Impact:** rename "job" → "role" in your own docs, prompts, and `AGENTS.md` (e.g. "agents hold jobs" → "agents hold roles"; an agent's registration line `job:` → `role:`). **No structural change:** the OKF type stays **`type: Agent`**, agent definitions stay in **`knowledge/agents/`**, and run-record keys (`agent:` / `session:`) are unchanged — this is wording only.
- **The concept is dialed back.** The docs no longer over-explain it or equate "an agent *is* a job"; the point is simply that each agent has a **well-defined scope of work**. Recurring-task uses of "job" (e.g. "the dreaming job") are now just "dreaming" / "the nightly pass."
  **Impact:** none required; cosmetic if you mirror the architecture's phrasing.

---

## 2026-06-16 — Version control dropped from the architecture

The architecture no longer mentions version control at all. The earlier *"Git is no longer a prescribed technology"* entry demoted **git** to a recommended *capability* (version history); this removes the topic entirely. **OKF is the brain's sole hard commitment.** Version control is an implementation detail every builder already knows how to handle — the docs neither require, recommend, nor discuss it, so they stop cluttering the invariants and recipes with it.

### Changed
- **`BRAIN_ARCHITECTURE.md`** — invariant #2 is now just **"Plain text, conforming to OKF"** (no version-control clause). §0, the §3 diagram, §7, §9 (intro + the dropped "Version control" table row), and the glossary no longer mention version history, audit-via-version, or revert; auditability now rests on the run-ledger and each doc's OKF `log.md`.
- **Cross-doc** — `OVERVIEW.md`, `AGENT_ARCHITECTURE.md` (including the example-stack table, now "Markdown (OKF)" rather than "Markdown + git (OKF)"), and `CLAUDE.md` drop their version-control lines.
- **Recipes de-git'd** — `recipes/brains/local-brain.md` removes git from the stack, prerequisites, ingredients, the "init the repo" step, the `brain` CLI's `commit()` (the CLI just writes files now), the "commits" notes in the command table, the `git log` Doneness check, and both git substitution rows. `recipes/kits/starter-kit.md`, `recipes/README.md`, and `recipes/agents/personal-assistant.md` follow.
  **Impact:** the architecture now asks **nothing** about version control — keep using git (or anything) for your brain exactly as before; it's simply no longer part of the spec, so nothing "complies" or "doesn't" on that axis. If your `AGENTS.md`, docs, or the local-brain `brain` CLI still tie writes to auto-commits or call version control an architectural requirement, you can leave them (harmless) or trim the mentions to match. OKF conformance of the knowledge layer is the only brain requirement. **Supersedes the "Git is no longer a prescribed technology" entry below.**

---

## 2026-06-16 — Agents replace roles; "job" replaces "charter"; machinery area is now `harness/`

A pervasive vocabulary and folder change across both architecture docs, `OVERVIEW.md`, `README.md`, `CLAUDE.md`, and the whole `recipes/` layer. It **reverses the 2026-06-15 "agents take on roles" framing**: the agent is now the single durable primitive, not a swappable executor that fills a role. People think in *agents*, not roles, and treat the model/provider as the swappable part — the architecture now matches that intuition. This is the largest single rename so far; the `/architecture-update` skill will walk a brain through it.

### Changed
- **"Role" is retired as a first-class term; the agent is the durable unit.** An **agent** is the worker you name, hire, trust, and promote; what it's accountable for is its **job** (the everyday word, formerly "role"). The agent's job and memory live in the brain, so the agent persists across runs.
  **Impact:** rename "role" → "agent" throughout your own docs, prompts, and `AGENTS.md`; "the role's scope/job" → "the agent's job". The **"This brain's roles"** list in `AGENTS.md` becomes **"This brain's agents."**
- **Swappability moved down a layer.** Invariant #3 is now **"The runner is swappable"** (was "Agents are swappable"): the **session** (one stateless run) and the **provider** (model + execution environment) are replaceable with no loss of state — *because the agent's job and memory live in the brain*. The agent itself is no longer described as swappable.
  **Impact:** wording, but it inverts the headline. Where your docs say "agents are swappable," say "the session/provider is swappable; the agent persists." New glossary term **Session / provider** replaces **Agent provider**.
- **"Charter" is gone; an agent is defined by its `job`.** The document that pins an agent down is its **job** (`type: Agent`), no longer a "charter" (`type: Role Charter`). One fewer term.
  **Impact:** rename the OKF type **`Role Charter` → `Agent`** in every agent-definition doc, and "charter" → "job" in prose. Any tooling or queries that filter on `type: Role Charter` must update.
- **Brain folders renamed.** `knowledge/roles/` → **`knowledge/agents/`** (the agents' jobs), and the durable machinery area `agents/` → **`harness/`** (each agent's system prompt, loop, tools, model binding). The brain's three areas are now **knowledge / harness / runtime** (invariant #4 and #7 wording: "role machinery" → "agent harness").
  **Impact:** in your brain, `git mv knowledge/roles knowledge/agents` and `git mv agents harness`, then fix path references in `bin/brain`, loop scripts, cron entries, and `AGENTS.md`. Because the agent's *job* now lives at `knowledge/agents/`, the word "agent" no longer names the machinery folder — that is the collision this rename resolves.
- **Run records re-keyed.** The telemetry record's `role:` / `agent:` pair becomes **`agent:` / `session:`**, and `brain run --role R --agent A` becomes `brain run --agent A --session S`.
  **Impact:** update your `loop.sh`/harness and any dashboards or evals that read the `role` field. Existing run-ledger files are history — leave them; new runs use the new keys.
- **Recipes layer renamed.** "Role recipe" → **agent recipe**; the `recipes/roles/` directory → **`recipes/agents/`**; frontmatter `type: role-recipe` → **`agent-recipe`** and `provides: role:<x>` → **`agent:<x>`**.
  **Impact:** if you vendor or author recipes, move the directory and update those frontmatter keys.
- **"System role" → "System agent"** (the dreaming / ingestion / planner owner); "per-role autonomy dial" → "per-agent." In `AGENT_ARCHITECTURE.md §13` the provider cell reads "model + execution environment" rather than "model + harness," so "harness" unambiguously means the new folder.
  **Impact:** wording; rename in your own copies.

---

## 2026-06-16 — Git is no longer a prescribed technology

Resolves a contradiction: the docs are tech-agnostic outside `recipes/` and `kits/`, yet the brain's invariant #2 named **git** as a required technology. The fix separates the brain's *one format commitment* (OKF) from its *required capability* (version history). Git is demoted to the obvious implementation of that capability, named only in recipes.

### Changed
- **`BRAIN_ARCHITECTURE.md` invariant #2** reframed from "Plain text in git, conforming to OKF" to "Plain text, conforming to OKF, under version control." Version control is now a required **capability** (a tracked, reversible history = the audit log and undo), not a prescribed tool. The §0 framing, §9 fill-in table (now a distinct **Version control** row), glossary, and the cross-doc summaries in `AGENT_ARCHITECTURE.md`, `OVERVIEW.md`, and `README.md` follow suit (e.g. "plain files under version control," "a tracked, reversible change you can revert").
  **Impact:** brains built on git are **fully compliant, no action needed** — git remains the default and what every recipe uses. What changed is the *definition of compliance*: a brain kept under any version-control system that tracks changes reversibly now also conforms. If your own docs or `AGENTS.md` describe git as a hard requirement of the architecture, soften that to "version control is required; git is the default." The brain still must be versioned somehow; that requirement did not loosen.

---

## 2026-06-16 — Diagrams: Mermaid for flows

A documentation-convention change. No invariant, layout, or build step changes; the docs read the same, they just render their flow diagrams.

### Changed
- **Flow/graph diagrams are now Mermaid `flowchart` blocks** instead of hand-drawn ASCII (the spine in `AGENT_ARCHITECTURE.md §4`, the improvement loop in §11, the self-improvement loop in `OVERVIEW.md`, and the run loop in `recipes/kits/starter-kit.md`). Directory trees stay ASCII (Mermaid can't draw them), and spectrums/progressions stay tables or labeled ASCII (the autonomy dial, the maturity path). The house-style rule in `CLAUDE.md` records the split, including: don't use generated/raster images for load-bearing diagrams, they aren't diffable, agent-editable, or searchable.
  **Impact:** none required. Mermaid renders on GitHub and most markdown viewers; where it doesn't, it degrades to readable source. If you author new architecture docs in your own brain, follow the same kind-by-kind rule. If you keep a non-Mermaid local renderer for the vendored `.agent-os/` copy, add Mermaid support for the diagrams to render.

---

## 0.2.0 — 2026-06-16 — First tagged release

Tags the accumulated baseline as a stable version: the three-area brain, the *agents take on roles* reframe, the recipes layer, the brain↔architecture reference/vendoring model, and the rename of the project to **Agent OS**. No new behavior beyond the entries below — this is a version marker so brains can pin and update against a named release.

### Changed
- **VERSION `0.1.0` → `0.2.0`.**
  **Impact:** run `/architecture-update` in your brain to re-pin to `0.2.0`. If your brain was built on an earlier `0.1.0` snapshot, the skill will also walk the entries below and apply any you haven't adopted yet (most brains will already be compliant).

---

## 2026-06-15 — Versioning + the brain↔architecture reference model

Brains can now point back to the architecture they were built from, and update against it.

### Added
- **Architecture versioning.** A `VERSION` file (now `0.1.0`) so a brain can pin to a specific release and reconcile against later ones.
  **Impact:** none required — new brains just record the version they were built on.
- **Brains now reference the architecture.** The recipes install, into each brain: a root **`AGENTS.md`** (what the system is, the invariants it must keep, the supported way to extend it = add a role via a role recipe, this brain's roles, and how to update) plus a one-line `CLAUDE.md` shim; a **pinned, read-only `.agent-os/`** vendored snapshot (version + commit + upstream URL); and a **`/architecture-update`** skill that diffs this `CHANGELOG.md` from the brain's pinned version and applies each entry's **Impact** note to reconcile the brain. The model is package-manager-style (vendor + update), *not* clone-and-build-inside.
  **Impact:** if you built a brain before this, add the reference so a coding agent working in it honors the architecture — vendor a pinned copy into `.agent-os/`, write a root `AGENTS.md` (invariants + how to extend via role recipes + your roles), and install the update skill; or re-run the scaffolding from the updated `local-brain` recipe. Then run `/architecture-update` to stay current.

### Changed
- **The architecture is now its own repo:** [github.com/heyharmon/agent-os](https://github.com/heyharmon/agent-os), extracted from a personal docs collection (history preserved). This is the canonical upstream that brains vendor from and update against.
  **Impact:** point any references at the new repo URL.

---

## 2026-06-15 — "Agents take on roles" (role/agent reframe)

A terminology and framing change, not a structural one. The brain layout, charters, run records, and recipes are unchanged on disk.

### Changed
- **The agent is now the foreground actor; a role is the job it holds.** Reversed the earlier framing that demoted "agent" to a "disposable shift of work / pair of hands" and crowned the **role** the "virtual employee." Now: **agents take on roles the way people take jobs** — the agent is the worker (it holds a bounded context, tools, and knowledge); the role is the durable, well-defined job that owns accountability and the tools+knowledge for the work. The "virtual employee" term is retired.
  **Impact:** mostly wording. If your own docs, prompts, or charters call the role a "virtual employee" or the agent a "shift of work / pair of hands," update them — agent = the worker that *fills* a role; role = the job it holds. No change to the brain's areas, charters, or the `agents/` machinery.
- **Swappability is now told through stateless runs + agent providers.** Invariant #3 is renamed **"Agents are swappable"** (was "disposable"): a run holds no state, and the **provider** behind an agent — the model + harness (Anthropic, OpenAI, an open-source model) — can be swapped without touching the role or the brain. New glossary term **Agent provider**.
  **Impact:** if a single model/vendor is baked into your role definitions, move provider choice to the harness layer so it's swappable, per the architecture. No brain or charter changes required.

---

## 2026-06-15 — Three-area brain, System role, and the recipes layer

Inaugural entry establishing the current baseline.

### Added
- **`recipes/` implementation layer.** A prescriptive, stack-specific build layer beneath the tech-agnostic docs, in three kinds: **brain recipes** (the foundation), **role recipes** (one role each, modular), and **kits** (a brain + role(s) combined). The architecture docs stay agnostic; recipes are where a concrete stack is chosen.
  **Impact:** none required — additive. If you want a turnkey build instead of interpreting the architecture yourself, start from a kit.

### Changed
- **The brain is now three areas, not two layers.** `knowledge/` (curated, durable, OKF) · `agents/` (role machinery — prompts, loops, tool lists, skills — durable but *not* OKF) · `runtime/` (work-queue, run-ledger, feedback, evals — transient, not OKF). Role machinery previously had no clear home; it now gets its own area, separated from regenerable runtime exhaust along two axes (*OKF vs. not* and *durable vs. transient*).
  **Impact:** if you implemented the old two-layer split, add an **`agents/`** area and move role machinery (system prompts, loop scripts, tool definitions, skills) into it, out of the runtime/operational layer. The knowledge layer is unchanged. Brain invariant #4 is now "three areas, never confused."
- **Dreaming is owned by a dedicated System role** and split by nature of work: **cross-cutting consolidation** (ingest, reconcile across roles, surface cross-role patterns, the digest) — always global — and **per-role reflection** (a role reviewing its own runs/feedback/charter) — an *earned* split you make only when the global pass is too coarse.
  **Impact:** if you ran dreaming as a role-less nightly job, reassign it to an explicit **System role** so it rolls up to an accountable owner. Start with that one role doing all reflection; split per-role only when warranted.

### Fixed
- **Invariant #4 ("every capability rolls up to a role") is now absolute** — dreaming no longer contradicts it, since the System role owns the cross-cutting work. No carve-out needed.
- **Write contract surfaced in the agent doc.** Agents write back *through the brain's write contract*, not by editing raw files — aligning the agent doc with brain invariant #5.
- **OKF restored to the example stacks**, and database cells labeled as *indexes* over the files, so no example reads as a database-as-source-of-truth (which the brain anti-patterns forbid).
- **Run-ledger format clarified** as illustrative operational-layer state (not OKF knowledge), and stale section cross-references corrected.
