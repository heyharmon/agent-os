---
type: brain-recipe          # brain-recipe | agent-recipe | kit
name: kebab-case-id         # stable id other recipes reference
title: "Human Readable Title"
description: "One line: what this builds and for whom."
stage: 0                    # maturity stage reached (AGENT_ARCHITECTURE.md §12)
provides: brain             # what capability this stands up (e.g. brain, agent:personal-assistant)
requires: []                # recipes this needs first (e.g. [local-brain]); [] for a brain
pairs-with: []              # recipes commonly combined with this
stack: []                   # headline tech, e.g. [claude-code, markdown, git, cron]
---

# {{Title}}

> One-paragraph pitch: what you'll cook and why you'd want it. Plain language.

## Yields

What you end up with, in a line or two — and which architecture stage it reaches.

## Prerequisites

- **Brain:** which brain recipe must already exist (agent recipes & kits only).
- **Accounts / keys:** anything external.
- **Runtimes:** languages, CLIs, tools that must be installed.

## Ingredients

The prescriptive stack — the specific technology choices. This is what separates a
recipe from the architecture doc. Pick one of everything; alternatives go in
*Substitutions*, not here.

| Component | Choice | Why this one |
|---|---|---|
| … | … | … |

## Steps

The ordered build plan. Concrete enough that a coding agent can execute it cold.

1. …
2. …
3. …

## Doneness

How you (or a verifying agent) know it works. Checkable, not vibes. These become the
first evals (`AGENT_ARCHITECTURE.md §10`).

- [ ] …
- [ ] …

## Pairs with

Compatible recipes — brains this agent runs on, agents that complement this one, kits
that include it.

## Substitutions

Swap-outs and earned upgrades. The base stays maximally simple; here's how to grow it
when the work demands it — and the signal that tells you it's time.

| Instead of… | Use… | When |
|---|---|---|
| … | … | … |
