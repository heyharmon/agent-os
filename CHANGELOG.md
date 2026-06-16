# Changelog

Notable changes to the **agent & brain architecture** (the docs in this directory and the `recipes/` implementation layer).

**For implementers:** if you've built an agentic system from these docs, this is your update feed. Skim new entries and apply the **Impact** notes to your own project — you can point your coding agent straight at this file and ask it to reconcile your implementation with the latest architecture. Entries are written at meaningful stopping points, not on every edit.

The format follows [Keep a Changelog](https://keepachangelog.com): newest first, grouped into **Added / Changed / Fixed**, with an **Impact** line wherever a change asks something of downstream projects. Dates are `YYYY-MM-DD`; changes that ask nothing of implementers (typos, internal phrasing) are left out.

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
