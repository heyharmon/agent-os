# An Architecture for a Brain

### A technology-agnostic vision for the shared memory an agent system reads, writes, and coordinates through — from a personal notes store to the working memory of a whole agent organization

**Audience:** the operator who wants a durable, understandable memory for their agent system, and any builder (in any stack) who will implement it.
**Companion document:** [`AGENT_ARCHITECTURE.md`](./AGENT_ARCHITECTURE.md) describes the *system around the brain* — the roles, loops, and learning that read and write it. This document describes the **brain itself**: the Context plane. See [`README.md`](./README.md) for how the docs relate.

---

## 0. What this is, and what it is not

This is a **vision and a set of invariants** — the rules that don't bend — not an implementation, the same contract as the agent architecture doc applied to its foundation. It fixes the *structure, strategy, and conventions* of the brain and says nothing about which search tool, write tool, scheduler, or agent you use.

> **It is opinionated about structure and convention, and agnostic about technology — with one deliberate exception.**

That exception is the **storage format**: the brain's knowledge layer follows the [Open Knowledge Format (OKF)](https://github.com/GoogleCloudPlatform/knowledge-catalog/tree/main/okf), plain-text markdown with a small structured header (YAML frontmatter). A format is a *convention*, the kind of thing the architecture is free to fix (like "frontmatter is the schema"), and it is the only thing the brain pins down. Note what is *not* on that list: the architecture also requires the brain to keep a **version history** (so every change has an audit trail and an undo), but that is a required *capability*, not a named tool. Git is the obvious way to provide it and what the recipes use, yet a brain on any system that tracks changes reversibly is compliant. Everything built on top of the files, how they're searched, written to, and kept current, and the agents themselves, stays fill-in-the-blank.

Why commit to the format and nothing else? Because the format is the one decision that determines **portability and longevity**. Get it right and the brain outlives every tool that touches it: any agent, any model, any vendor that speaks OKF can read and write it. Get it wrong and you rebuild your whole setup every time your tools change. Versioning is the other non-negotiable, but since any version-control tool serves, pinning the *format* is the only place a specific commitment earns its keep.

**Read it as a compass, not a checklist.** Start with a handful of files. Add structure only when the work demands it.

---

## 1. The core ideas

### 1.1 The brain is the single source of truth — and the bus

All the lasting information the agent system relies on lives here, and agents coordinate *through* it rather than by talking to each other (see `AGENT_ARCHITECTURE.md §1.1`). One home per fact; everything else links to it. This is what lets agents stay swappable: their memory and their desk are in the brain, not in them.

### 1.2 Three areas: knowledge, agents, and runtime

The brain holds three kinds of file, and keeping them distinct is its most important structural decision: the **knowledge area** (curated, durable "what is true": entities, projects, decisions, reference, and the **role-charters** that define the agent org; conforms to OKF), the **agents area** (each role's durable **machinery**: system prompts, loops, tool lists, skills; code and config rather than curated facts, so outside OKF), and the **runtime area** (the transient **exhaust** of work in progress: work-queue, run-ledger, feedback, eval results; regenerable and safe to delete, outside OKF). §3 gives the shape; §4 and §5 detail each.

Why three and not two: two axes separate them, *OKF vs. not* and *durable vs. transient*. Knowledge is both; agents is durable but not OKF (authored source you can't regenerate by replaying history, so it earns its own home rather than being lumped in with runtime); runtime is neither.

### 1.3 The AI organizes; the files just store

The brain is kept current by *agents doing the tidying* — filing, linking, reconciling — not by some rigid import system. Keeping the knowledge organized is itself agent work (the dreaming job, §7). This is the bet that makes plain files work at scale: the thing that made wikis rot — the tedium of upkeep — is exactly what an AI doesn't mind.

---

## 2. The invariants (the constitution)

A brain is compliant if and only if it honors these. Everything else is free.

1. **One source of truth.** Every fact lives in exactly one canonical file; everything else links to it.
2. **Plain text, conforming to OKF, under version control.** The knowledge layer is markdown + YAML frontmatter (OKF, the brain's one *format* commitment), kept in something that tracks every change reversibly so its history is the audit log and undo. Version control is a required *capability*, not a prescribed tool: git is the obvious implementation and what the recipes use, but any system that versions the files reversibly complies.
3. **Frontmatter is the schema.** If a detail isn't in the frontmatter, nothing can reliably search or sort by it. Keep the set of fields small — resist any you won't actually use.
4. **Three areas, never confused.** Curated knowledge (durable, OKF), role machinery (durable, not OKF), and runtime state (transient, not OKF) stay clearly separated.
5. **Writes go through a contract.** Agents add and update through one defined doorway, not by editing raw files however they like, so the brain stays consistent. (What that doorway looks like is yours to choose — see §6.)
6. **Retrieval is earned complexity.** Begin with plain text search over frontmatter and content; add vectors or a graph only when that demonstrably falls short.
7. **Degrade gracefully.** Delete the index, the tooling, the agents area, and the entire runtime area, and the knowledge area is still a valid OKF bundle a human can read.
8. **Sensitivity is explicit; secrets never live here.** Restricted material is marked as such; credentials go in a secret manager, never the brain.
9. **Simplicity is the tiebreaker.** When two designs both work, choose the one you can still read in six months.

---

## 3. The shape: three areas

```
  THE BRAIN  ·  one versioned repo, plain text
  │
  ├─ knowledge/   curated · durable · OKF-conformant
  │     roles (charters) · entities · projects · decisions · reference
  │
  ├─ agents/      role machinery · durable · NOT OKF
  │     one folder per role: system-prompt · loop · tools · skills
  │
  └─ runtime/     exhaust of running · transient or append-only · NOT OKF
        work-queue · run-ledger · feedback · eval-results
```

Directory names are conventional, not mandated — what matters is the three-way split and that the knowledge area is an OKF bundle. The areas map onto the agent architecture's planes: knowledge *is* the Context plane; **agents** holds the machinery of the Work and Activation planes (a role's staff and its schedules); **runtime** is where the Work, Telemetry, and Learning planes persist their transient state.

---

## 4. The knowledge layer

Curated, durable, OKF-conformant. The conventions:

- **One canonical document per concept**, identified by its path. Dated history lives beside it (OKF's `log.md`); a directory's `index.md` is its table of contents.
- **Frontmatter is the schema, and it follows OKF** — a required `type`, OKF's recommended fields, and any extra fields you need as OKF extension keys (conformant tools preserve them). Lightly:

```yaml
---
type: Entity                      # required (OKF)
title: "Acme Daycare"
description: "Retainer client; daycare SaaS."
tags: [client, retainer]
timestamp: 2026-06-14T14:30:00Z   # last meaningful change
status: active                    # an extension field
---
```

- **Documents link to each other** with ordinary links in the text — a web of connected knowledge with no special database behind it. Broken links are fine; they simply mark knowledge you haven't filled in yet.
- **Role-charters are first-class knowledge.** A role (per `AGENT_ARCHITECTURE.md §2`) is defined by a charter document (`type: Role Charter`) holding its responsibilities, its authority level, and its consequence-tagged tools. Because it's a knowledge file, improving or promoting a role is a readable diff to it.

---

## 5. The agents and runtime areas

Two non-OKF areas sit beside the knowledge layer.

### The agents area — durable machinery

Each role's **agent** lives here, one folder per role: the system prompt, the loop/heartbeat script, the tool list, any skills — the machinery that fills the role. This is authored code and config — durable, versioned, and edited deliberately (the improvement loop opens diffs against it, just as it does against charters, `AGENT_ARCHITECTURE.md §11`). It is not OKF (it isn't curated facts) and it is not exhaust (you can't regenerate it by replaying history). A role's **charter** — the durable contract — lives in the knowledge area (`knowledge/roles/`); its **agent** — the current implementation of that contract — lives here. That split is exactly why agents stay swappable while the role persists: rebuild the agent or swap the provider behind it; the charter and the brain are untouched.

### The runtime area — transient exhaust

The runtime state of work, kept deliberately separate from both curated knowledge and machinery because it is mechanical, not authored. Four conventional collections:

- **Work-queue** — the tasks roles claim and complete (the inbound side of coordination).
- **Run-ledger** — an append-only record of every agent run: tokens, cost, actions, outcome (`AGENT_ARCHITECTURE.md §7`).
- **Feedback** — captured human interventions, the labeled examples the improvement loop learns from (`AGENT_ARCHITECTURE.md §11`).
- **Eval results** — per-role acceptance checks and dated scorecards (`AGENT_ARCHITECTURE.md §10`).

These are files too, but they are not OKF and not curated: they can be regenerated or replayed, you only ever add to them, and they are safe to delete. Deleting them loses history but never corrupts knowledge — which is the whole point of the split.

---

## 6. The write contract and retrieval

Two components sit over the files. The architecture fixes the *pattern*; you choose the technology.

- **A write contract.** Agents create and update through a small, defined interface rather than editing raw files at will — so frontmatter stays valid, links stay consistent, and the change timestamp always bumps. *One way:* a tiny `brain` CLI; equally valid: a library, an API, or an MCP server. The contract is the invariant; its form is not.
- **A retrieval path, kept as simple as the work allows.** Agents are excellent at search; lean on it. *Start* with plain text search over the files — for example a lightweight full-text index — and treat fancier approaches (embeddings, a knowledge graph) as an upgrade you earn only when plain search visibly fails (invariant #6).

---

## 7. Curation: ingestion and dreaming

A brain stays useful only if something keeps it current — and that something is a scheduled agent, not a pipeline. This is the **dreaming** job of `AGENT_ARCHITECTURE.md §6` (owned by the System role), run when things are quiet:

1. **Ingest.** Pull new raw material (mail, transcripts, exports) into a staging area, then file each item into the right place in the knowledge layer — extracting durable facts, updating frontmatter, appending to history. **Flag, don't guess:** ambiguous or sensitive items wait for a human.
2. **Consolidate.** Reconcile contradictions, add links, prune, and generate the digest.
3. **Improve.** Cluster the feedback against the eval scorecards and open diffs against role-charters (`AGENT_ARCHITECTURE.md §11`).

The whole operation is one agent session, fully inspectable in the version history: the format makes the curation auditable.

---

## 8. The growth path

The brain is the same thing at every size; you grow it by adding files, never by changing its nature.

- **A handful of notes** — a personal brain you and a chat agent use by hand. Already useful (the agent architecture's Stage 0).
- **A structured knowledge layer** — entities, projects, decisions seeded from real work; retrievable.
- **Roles + the agents and runtime areas** — charters, machinery, and the queue/ledger, so agents do real work and report it.
- **A maintained, self-improving brain** — the dreaming job keeps it current and proposes charter improvements.

Scaling is addition, not migration — the same reason the agent architecture scales. **When to reach past plain files:** questions that hop across many connected facts ("what led to this decision?"), many agents writing at once and colliding, or non-technical teammates who need a point-and-click interface. Then add a heavier search or graph layer *over the same files*, and because the knowledge layer is OKF, the wider ecosystem (catalogs, visualizers) works with zero migration (the portability §0 is built on).

---

## 9. Filling in the blanks

The OKF format is fixed and so is keeping a version history; everything else, including *which* tool versions the files, is a choice. Two compliant brains that share a format but no code:

| Component | Example A (local) | Example B (hosted) |
|---|---|---|
| Storage format | markdown + YAML, OKF | markdown + YAML, OKF |
| Version control | local git | hosted git (or another VCS) |
| Write contract | a small CLI | an API or MCP server |
| Retrieval | local full-text index | a managed search service |
| Curation schedule | cron on an always-on machine | a managed scheduler |
| Curating agent | a headless coding agent | any agent runtime |

Both honor §2. Both are readable raw. Swap any cell without touching the others — that is what the format-only commitment buys.

---

## 10. Anti-patterns

- **A database as the source of truth.** The moment the real, canonical state lives somewhere you can't just open and read, you've lost the brain's core properties. The files are the truth; everything else is just an index over them.
- **Prescribing technology the format doesn't require.** Pinning a specific index, language, or harness re-creates the lock-in the OKF commitment exists to prevent. Commit to the format; stay loose on the rest.
- **Confusing the three areas.** Telemetry, queue items, and role machinery are not curated knowledge; forcing them into OKF documents adds friction, and letting runtime state or scripts sprawl into the knowledge area rots it.
- **A retrieval stack ahead of need.** Vectors and graphs before plain search has demonstrably failed is complexity you can't eyeball, paid for up front.
- **Manual upkeep as the plan.** If keeping the brain current depends on human discipline, it will rot. Curation is the dreaming agent's job; humans clear flags, they don't file everything.
- **Secrets in the brain.** Ever. Use a secret manager.

> **The test, always:** delete the tooling and open the repo raw — is it still a clear, current account of what's true? If not, the problem is the content, not the tools.

---

## 11. Glossary

The brain and its three areas are defined in §1–§3; this lists only terms a reader might jump to.

- **OKF (Open Knowledge Format)** — the open standard the knowledge layer conforms to: plain-text markdown + YAML frontmatter. The brain's one format commitment; kept under version control (git by default, not mandated).
- **Write contract** — the defined interface agents write through, in place of editing raw files (§6).
- **Dreaming** — the scheduled curation agent that keeps the brain current and improving (§7; `AGENT_ARCHITECTURE.md §6`).

---

*Prime directive, restated: the brain is plain, versioned text you can understand at any time, structured so agents retrieve and update it reliably, and committed to one format so it outlives every tool that touches it. Opinionated about structure; agnostic about technology; loyal to OKF. When in doubt, keep it readable.*
