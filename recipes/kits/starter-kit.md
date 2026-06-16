---
type: kit
name: starter-kit
title: "Starter Kit"
description: "The smallest end-to-end agentic system: a Local Brain plus one Personal Assistant. The base most people should start from and build upon."
stage: 1
provides: system:starter
requires: [local-brain, personal-assistant]
pairs-with: []
stack: [markdown, git, python, ripgrep, claude-code, cron]
---

# Starter Kit

> The whole thing, smallest version: a durable brain and one agent that works for you on a schedule — nothing cloud, nothing you can't read. Grab this if you want a single thing to build first. It's two modular recipes presented as one menu; once it runs, you grow it by adding more agent recipes onto the same brain, never by rebuilding.

## Yields

A working **Stage 1** system (`AGENT_ARCHITECTURE.md §12`): a git-backed brain you can query by hand, and a Personal Assistant that captures and triages what you hand it, keeps a prioritized task list, writes you a daily briefing, drafts outputs, escalates the consequential, and logs every run. The end-to-end "hello world" of the architecture.

## What you get

Everything lives in **one git repo**, nothing hidden, nothing cloud: the brain's three areas (`knowledge/` · `harness/` · `runtime/`) with the PA's job under `knowledge/agents/`, its harness under `harness/personal-assistant/`, and the `bin/brain` write contract. The full layout is in [`local-brain`](../brains/local-brain.md) (the brain) and [`personal-assistant`](../agents/personal-assistant.md) (the agent's files and run loop); the kit just builds both into the same repo. The runner holds nothing: kill it mid-run and the next session reloads everything from the brain.

```mermaid
flowchart TD
    cron["cron · hourly + 7am"] --> loop["loop.sh · the wrapper"]
    loop --> session["claude -p · swappable session"]
    session -- "reads job + queue,<br/>writes facts / drafts / approvals via bin/brain" --> brain
    loop -- "writes run record" --> brain[("THE BRAIN · one git repo<br/>knowledge / harness / runtime")]
    you["YOU"] -- "drop tasks · read briefings · approve actions" --> brain
```

## Prerequisites

- **Runtimes:** `git`, `python3` + `pyyaml`, `ripgrep`, `bash`, `cron`/`launchd`.
- **Accounts:** a headless-authenticated Claude Code (`claude -p`).
- Nothing else — no cloud, no database, no accounts.

## Ingredients

This kit is a combination, not a new stack. It bundles:

| Part | Recipe | Reaches |
|---|---|---|
| The foundation | [`brains/local-brain`](../brains/local-brain.md) | Stage 0 |
| The first agent | [`agents/personal-assistant`](../agents/personal-assistant.md) | Stage 1 |

## Steps

1. **Build the brain.** Follow [`local-brain`](../brains/local-brain.md) end to end. Stop when its *Doneness* checks pass — you now have Stage 0.
2. **Hire the agent.** Follow [`personal-assistant`](../agents/personal-assistant.md), which runs on the brain from step 1. Stop when its *Doneness* checks pass — you now have Stage 1.
3. **Smoke-test end to end** (the kit's own check, below).

## Doneness

The combined test — both recipes' Doneness, plus the round trip that proves they work *together*:

- [ ] `brain queue add "draft a welcome note for new client Acme (urgent); note that Acme renewed for 12 months"` then trigger a heartbeat (or wait for cron).
- [ ] The next run: triages the task, files the durable fact by creating `knowledge/entities/acme/` via `bin/brain`, marks the task urgent, drafts the note to the brain, and appends a run record to `runtime/runs/`.
- [ ] The morning `brief` run writes `runtime/briefings/<today>.md` with the urgent Acme item at the top.
- [ ] `brain search Acme` finds the new entity.
- [ ] A consequential task lands in `runtime/queue/approvals/` instead of executing.
- [ ] `git log` reads as a clean, human-readable history of everything the system did.

## Pairs with

This is the base you build *onto*:

- **Add more agent recipes** on the same brain to go from one agent to a team (Stage 2) — Comms Manager, Scheduler, Product-Dev, etc. Each declares `requires: [local-brain]`, so it drops in with no change to the foundation. Scaling is hiring, not migrating (`§12`).
- **Add a dreaming recipe** (Stage 3) for nightly consolidation and the self-improvement loop (`§11`).

## Substitutions

Inherit the substitutions from both component recipes — swap the provider, the scheduler, the search layer, or raise the agent's autonomy independently. Because the kit is just two modular recipes, you can replace either side without touching the other; that decoupling is the entire reason brain and agent are separate recipes.
