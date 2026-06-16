# Agent OS, an experiment

This repo is not a doctrine. It is an experiment to discover what actually works for putting agents to work.

We build small agent operating systems, give them realistic tasks, and measure outcome quality and token cost. Principles emerge from evidence, not assertion. The aim is to become the authoritative answer to "where do I start, and what is the optimal way to build an agentic solution for my use case?" See `VISION.md`.

## Structure

| Path | What it is |
| --- | --- |
| `VISION.md` | The goal: proven agent OS architectures across a complexity spectrum of use cases |
| `experiments/PROCESS.md` | How we run an experiment from question to clear-cut takeaway |
| `HYPOTHESES.md` | Every unproven claim as a falsifiable bet |
| `experiments/` | Each experiment: a charter, a system-under-test, a benchmark, and the hypotheses it bears on |
| `experiments/001-personal-assistant/` | First experiment: a single-agent personal assistant on a file brain |
| `results/` | The evidence log: run outputs, scores, costs |
| `archive/` | Earlier architecture docs, kept for provenance only. Not authoritative. |

## The one operating principle

For any claim in this repo, you should be able to point at a run in `results/` that supports it. If you cannot, it is a hypothesis, not a fact.

## How to contribute

Follow `experiments/PROCESS.md`: charter an experiment (use case, goal, bar, stopping criteria), build the system under test, run it, find where it breaks, revise, and re-run until a clear-cut takeaway. Pick the hypotheses it tests from `HYPOTHESES.md` and update their status from the evidence.
