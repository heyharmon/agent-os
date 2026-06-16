# Experiment process

How we run an experiment from question to clear-cut takeaway. The point of writing it down is so that progress follows a process instead of a series of judgment calls: most steps run without asking the operator, and the few that need a human are named explicitly (see Decision rights).

## What an experiment is

An experiment answers one question about how to build an agent operating system for a use case at a position on the complexity spectrum (see `VISION.md`). It is not open-ended. Every experiment has a **charter** before it starts and a **takeaway** when it ends.

### Charter (write `charter.md` before building)

- **Use case + spectrum position.** What it is, and where on basic-to-sophisticated it sits.
- **Goal.** The question being answered, stated so a result can settle it. "Optimal" here means the simplest architecture that meets the bar, not the most capable.
- **Bar.** The concrete success threshold: target pass rate, the safety floor (failures that are never acceptable), and an acceptable cost envelope.
- **Hypotheses in play.** Which `HYPOTHESES.md` entries this experiment tests (each with a pre-registered "Refutes if").
- **Stopping criteria.** The conditions under which the experiment ends (below).
- **Budget.** A spend and/or iteration cap before the operator is consulted.

## The loop

```
   Define          Build              Run               Diagnose
  (charter)  -->  (system under  -->  (N trials,   -->  (where did it
                   test + bench)       measured)         break, and why)
                                                              |
        ^                                                     v
        |                                                  Revise
     Decide  <----  Re-run & compare  <-------------  (one change:
   (continue or      (better? no                       gate, prompt,
    conclude)         regression?)                      tool, architecture)
```

1. **Define.** Write the charter.
2. **Build.** The system under test (brain, agent(s), tools, harness) and the benchmark (seeded realistic world, task set, scorer). Reuse the rig (`bin/brain`, `run-task.sh`, `score.py`, `seed/`) by hand; do not build new machinery you do not yet need.
3. **Run.** Each task in a hermetic scratch reset from `seed/`, N trials (default 3) to measure variance. Record outcome correctness, cost and tokens from provider JSON (never estimated), and escalation/intervention accuracy.
4. **Diagnose.** Classify every failure. The most useful distinction we have found: does it fail at *reasoning* (wrong judgment) or at *contract* (right judgment, wrong execution of how the system requires it to act)? They have different fixes.
5. **Revise.** Change one variable, recorded as an intervention: a harness gate, a prompt edit, a tool, an architecture change. One change at a time so the re-run attributes cause.
6. **Re-run and compare.** Did the change move the metric without regressing a previously passing case? Provider numbers, same tasks.
7. **Decide.** Continue the loop, or conclude (stopping criteria).

## Stopping criteria

An experiment ends when one of these is true. Each yields a clear-cut takeaway.

- **Goal reached.** Hits the bar (pass rate + safety floor + cost envelope) with no regression across N trials. Takeaway: this architecture is proven for this use case; these building blocks are load-bearing, these are not.
- **Diminishing returns.** K consecutive iterations (default 3) with no material improvement. Takeaway: this is the ceiling of this architecture for this use case; here is the limiting factor.
- **Refutation.** A core charter hypothesis meets its pre-registered "Refutes if." Takeaway: the bet was wrong; here is what that rules out, and what to try instead.

A "we are not sure yet" ending is not allowed. If the evidence is thin, the takeaway says so and names the single next experiment that would settle it.

## The takeaway (write it when the experiment ends)

A concluded experiment writes a takeaway in its `results/` log that states, in plain terms:
- the answer to the charter's goal,
- the architecture and the building blocks that earned their place (and those that did not),
- the metrics that back it (pass rate, cost, escalation accuracy), with links to runs,
- the hypotheses it moved, and
- what it does not yet establish.

## Decision rights (what runs without the operator)

The agent proceeds autonomously on:
- mechanical rig fixes (paths, parsing, scorer bugs) that expose rather than hide a result,
- single-variable revisions and re-runs inside the charter,
- updating hypothesis status and writing results,
- running trials and independent tasks in parallel.

The agent stops and consults the operator on:
- changing the charter (goal, bar, stopping criteria) or the spectrum target,
- an architecture-level direction change not anticipated by the charter,
- exceeding the budget cap,
- any safety-floor failure (e.g. the agent took a consequential action it should have escalated),
- anything irreversible or outward-facing (sending, paying, publishing, deleting beyond the sandbox).

Weakening a task's expectation or editing the agent's prompt to force a pass is never allowed. A real failure is the result.

## Promotion to proven

- A **building block** is proven when it has earned its place across at least two experiments (or two use cases), with the metric that justifies it recorded each time.
- An **architecture** is proven when an experiment reaches its goal with no safety-floor failures and the result holds across N trials, and it is the simplest composition that does so.
- Promotion is an edit to the benchmark (the proven-architectures library) plus the hypothesis status changes that support it. Provisional results stay labeled SUPPORTED-but-thin until a second experiment confirms them.

## Running at scale, and automation

The rig already runs tasks and trials in parallel (hermetic scratch per run). Independent experiments can run in parallel the same way.

We will encode this process as a dynamic workflow (one that drives Define-through-Decide and only surfaces the Decision-rights escalations) once it has driven at least one experiment to a clear-cut takeaway by hand. Automating the loop before it is proven would lock in a guessed process; automate last.
