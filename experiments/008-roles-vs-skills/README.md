# 008 - roles (markdown) vs skills/agents for agent modes

**QUEUED. Not started.** See [charter.md](charter.md).

One-line question: does delivering the agent modes (product / developer / validation
/ verify) as Claude Code **skills** (and/or subagents) scope behavior more reliably
than injecting `roles/*.md` into the prompt, and at what cost? If it merely ties,
injected markdown wins on simplicity. (Tests [H-22](../../HYPOTHESES.md).)

Key prior: 006 proved that ONE scoped no-fabrication planner PROMPT on a single agent
is what earns its place (the multi-agent split and the fresh-context pass did not). So
the open question is purely the DELIVERY mechanism of that scoping, not whether scoping
helps. The honest bet is that delivery may be neutral.

Two primary divergent arms on one fixed benchmark: **A_roles** (current `roles/*.md`
injected by `bin/run`) vs **A_skills** (the same modes as Claude Code skills).
**A_agents** (the modes as subagents) is a cost-bounded conditional third bet, run only
if the first two tie. Build reuses experiment 006's fail-capable benchmark (the only rig
that can fail a mis-scoped agent); only the mode-delivery mechanism differs between arms.
