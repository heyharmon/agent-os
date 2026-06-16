# Recipes

**Recipes are the implementation layer for the [agent architecture](../).**

The two architecture docs are deliberately *agnostic about technology* — they fix the contract and say "fill in the blank." A **recipe fills in the blank.** It prescribes a specific stack, specific files, and an ordered build plan, friendly enough to read like a cookbook and structured enough that you can hand it to a coding agent (Claude Code or similar) and say "build this."

> A recipe is a spec / PRD — but simple, friendly, and clear. Ingredients, steps, and a way to know when it's done.

## The three kinds of recipe

A cookbook isn't a flat list of dishes; it has stocks you build on and menus that combine them. Recipes work the same way.

| Kind | Cooking analogy | Prescribes | Reaches |
|---|---|---|---|
| **Brain recipe** (`brains/`) | the stock / mother sauce | a concrete brain build: storage, write contract, retrieval, layout — the shared foundation everything runs on (`BRAIN_ARCHITECTURE.md`) | Stage 0 |
| **Agent recipe** (`agents/`) | a dish | one agent: its job, harness, loops, tools, schedule — built to run on a brain (`AGENT_ARCHITECTURE.md §5`) | Stage 1+ |
| **Kit** (`kits/`) | a menu | a curated combination — one brain + one or more agents — for a use case | a working system |

## How they combine

This is the whole point of splitting them — it mirrors the architecture (the brain and the system are **peer** docs) and it matches the maturity path (`AGENT_ARCHITECTURE.md §12`): stand up the brain once, then add agents incrementally as need grows.

- An **agent recipe depends on a brain.** It declares which brains it's compatible with and which is ideal, via frontmatter. A coding agent resolves the dependency: "this agent needs a brain you don't have yet — run the recommended brain recipe first."
- A **team is just several agent recipes sharing one brain.** Implement one agent now; add more later on the same foundation. Scaling is hiring, not migrating (`§12`).
- A **kit is a shortcut** — a pre-picked brain + agent(s) so a newcomer has one thing to grab instead of assembling parts.

## Anatomy of a recipe

Every recipe inherits the skeleton in [`TEMPLATE.md`](./TEMPLATE.md), which carries the section-by-section guidance. Two sections are what make a recipe a recipe rather than an architecture doc: **Ingredients** (the prescriptive stack it commits to) and **Substitutions** (where the architecture's optionality lives, so the base stays maximally simple and upgrades are spelled out but never imposed). One detail worth knowing: a recipe's **Doneness** checks double as the agent's first evals (`AGENT_ARCHITECTURE.md §10`).

## Design rules for writing recipes

1. **Prescribe, don't survey.** The architecture lists options; a recipe picks one and commits. Alternatives go in *Substitutions*, not the main path.
2. **Maximally simple base.** Start a recipe at the smallest thing that honors the invariants. Earn every addition (`BRAIN_ARCHITECTURE.md` invariant #6). If it's optional, it's a substitution.
3. **Executable by an agent.** Steps are concrete and ordered; doneness is checkable. Assume a coding agent reads it cold.
4. **Honor the invariants.** A recipe is only valid if its result honors `AGENT_ARCHITECTURE.md §3` and `BRAIN_ARCHITECTURE.md §2`. The recipe chooses technology; it never breaks the contract.
5. **Modular.** An agent recipe never re-pours the brain. It depends on one.

## Index

| Recipe | Kind | Stack | Stage |
|---|---|---|---|
| [`brains/local-brain.md`](./brains/local-brain.md) | brain | markdown + git + plain-text search | 0 |
| [`agents/personal-assistant.md`](./agents/personal-assistant.md) | agent | Claude Code + cron | 1 |
| [`kits/starter-kit.md`](./kits/starter-kit.md) | kit | the two above, combined | 1 |
