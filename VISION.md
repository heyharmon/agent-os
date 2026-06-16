# Vision

## The question we answer

> "I have a use case, problem, or business. Where do I start, and what is the optimal way to build an agentic solution for it?"

agent-os aims to be the authoritative answer to that question: not opinion, but evidence. For a given use case we want to say, with proof behind it, "this architecture, built from these building blocks, is the optimal place to start," and to show the runs that back it.

## The complexity spectrum

Use cases sit on a spectrum of sophistication. The position on the spectrum drives the architecture: how many agents, how many tools, how rich the brain, how much coordination.

```
basic ---------------------------------------------------------> sophisticated

single-agent PA        a PA that does more        multi-agent OS, many tools,
few tools (schedule,   (more tools, more           coordination, autonomy
reminders, email)      surface, richer brain)      |
simple file brain                                  other domains:
                                                   software dev, marketing,
                                                   sales, broader business ops
```

The same question applies at every point: what is the simplest architecture that reliably does the job. The answer differs along the spectrum, and that difference is what we map.

## What we produce

1. **Proven building blocks.** Individual pieces (a file brain, plain-text retrieval, a checked escalation gate, a heartbeat loop, a tool pattern) that have been tested and shown to earn their place, or shown not to.
2. **Proven architectures.** Compositions of building blocks that reliably serve a use case at a position on the spectrum, with measured outcomes.
3. **A benchmark.** A growing, public library of tested architectures mapped to the spectrum, each with its evidence: pass rate, cost, intervention/escalation accuracy, and the experiments that produced them.

"Proven" is a standard of evidence, not a claim of taste. A building block or architecture is proven only when runs in `results/` support it and its pre-registered hypotheses survived (see `HYPOTHESES.md`). Until then it is a bet.

## How we get there

Experiments. Each experiment takes a use case, builds a system under test, runs it against a realistic seeded world, measures outcome quality and cost, finds where it breaks, revises, and re-runs until it reaches a clear-cut takeaway. The takeaways accrue: confirmed hypotheses become proven building blocks, and proven building blocks compose into proven architectures that populate the benchmark.

The method is in `experiments/PROCESS.md`. The bets are in `HYPOTHESES.md`. The evidence is in `results/`. The earlier speculative architecture is in `archive/`, kept for provenance, not authority.

## The operating ethos

- **First principles, not analogy.** Strip each use case to what it actually requires.
- **The best part is no part.** The optimal architecture is the simplest one that hits the goal. Subtract before adding.
- **Find the failure boundary.** A benchmark where everything passes teaches nothing. Design to break the system, then fix what breaks.
- **Evidence over assertion.** Every recommendation points to a run. No run, no claim.
- **Automate last.** Prove the loop by hand before encoding it.
