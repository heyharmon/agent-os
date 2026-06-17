# Experiment 007: OKF as the brain's knowledge format

**Status: QUEUED (not started). No runs, no results yet.** Tests H-07.

## Use case + spectrum position

The knowledge-layer *format* for the file brain. Basic end of the spectrum: the file brain itself is already proven (H-02, H-19); this asks only whether pinning its knowledge layer to an external spec (OKF v0.1) is worth its cost over the ad-hoc markdown + YAML frontmatter we use today.

This is a format question, not an architecture question. The agent, retrieval, tags, and roles are held fixed at the proven single-agent composition. Only the knowledge layer's format changes between arms.

## Background (published OKF v0.1)

OKF is markdown + YAML frontmatter: a directory of "concept" files, one required field (`type`), six standardized/queryable fields (`type`, `title`, `description`, `resource`, `tags`, `timestamp`), reserved `index.md` (progressive disclosure) and `log.md` (chronological history), and concepts cross-linked by ordinary markdown links. It formalizes the LLM-wiki pattern.

The key prior: this is **nearly identical to the brain's current format**. So the cost side is small, and the experiment's real job is to find out whether the portability/interop benefit ever *fires*, or whether OKF is neutral ceremony here.

## Goal

Settle H-07: does committing the knowledge layer to OKF v0.1 buy enough portability/interop to justify its constraints, versus our current ad-hoc frontmatter? "Worth it" = a real, fired portability win with no task-quality regression. "Optimal" = the simplest format that meets the bar.

## Bar

- **Pass-rate floor:** A_okf must match A_plain on the held-out task suite (no quality regression from the format). Parity is the floor, not an improvement target.
- **Safety floor (never acceptable):** no fabrication of a missing convention into durable knowledge; no consequential action taken instead of escalated. Unchanged from prior experiments.
- Cost is tracked and reported, never a bar (per PROCESS.md).

## Arms (divergent bets)

- **A_plain** (baseline, proven): the brain exactly as today, ad-hoc markdown + YAML frontmatter. Expected to pass the task suite and to NOT be readable by a generic OKF tool.
- **A_okf**: the same knowledge content, knowledge layer committed to OKF v0.1 (required `type`, the six standard fields, `index.md`/`log.md`, OKF-style links). Same agent, same retrieval, same tasks.

A third arm is unnecessary; two divergent formats on one fixed benchmark is the cleanest cut.

## Scoring (pre-registered)

Reuse experiment 003's coding brain and task suite (richest knowledge layer: conventions, ADRs, ownership, runbook), dev + blind held-out world. Convert only the knowledge layer to OKF for A_okf; do not touch tasks or scorer.

Three signals, scored on outcomes:

1. **Task pass-rate parity.** Run the 003 suite on both arms, dev + held-out, default 3 trials. Correct outcome = identical pass/fail per task. OKF fails the bar if held-out pass-rate drops vs A_plain.
2. **Portability win (the discrimination task, H-18).** Pre-registered to make the difference fire: point a generic, brain-agnostic OKF-aware reader (knows only the OKF v0.1 standard fields, nothing about our layout) at each brain and require it to answer a fixed query (e.g. "list every concept of `type: convention` with its `title` and `description`"). Correct outcome = the OKF tool answers correctly against A_okf with zero migration, and demonstrably cannot against A_plain. If the OKF tool can answer against A_plain too (because plain frontmatter already carries the fields), the portability win did NOT fire.
3. **Constraint-bite check.** During conversion and the runs, record any case where OKF's rules force a field or structure that plain frontmatter would not have. Correct outcome for OKF = zero forced workarounds.

## Hypotheses in play

- **H-07** (primary). Refutes if: the portability win never fires (signal 2) AND OKF forces at least one workaround (signal 3) -> pure cost. Also counts against OKF if A_okf lowers held-out pass-rate (signal 1).
- **H-18** (discipline): the portability task is the pre-registered discriminator. If it does not fire and pass-rates tie, the honest takeaway is "OKF is neutral here": no measured benefit, low measured cost. That is a valid conclusion, not a non-result.
- **H-17** (discipline): held-out is authored blind and run once; report the dev-vs-held-out gap.

## Stopping criteria

- **Goal reached / refuted:** the three signals are measured on held-out across N trials and H-07's refute clause is or is not met.
- **Diminishing returns:** not expected (single fixed comparison, no tuning loop).
- A "not sure yet" ending is not allowed; if thin, name the next experiment.

## Budget

Small. One benchmark reuse, two arms, default 3 trials, one conversion pass. Cap: stop and consult the operator before exceeding the cost of a single prior experiment (~003 scale) or before any change to the 003 tasks/scorer.

## Decision rights

Queuing and chartering were operator-requested. Running follows PROCESS.md: autonomous on rig reuse, single-variable runs, hypothesis-status updates; stop and consult the operator before changing this charter, the 003 benchmark, or on any safety-floor breach.

## Open design notes (resolve at Build, before first run)

- Pick the "generic OKF-aware reader" for signal 2: simplest is a tiny script that parses only OKF-standard frontmatter fields and refuses anything non-standard, so it is a fair stand-in for "a second tool that speaks OKF and nothing about our layout." Pre-register it before running.
- Decide whether `agents/` (role machinery) and `runtime/` are in scope. Per the archived three-area model they are explicitly NOT OKF; this experiment converts only `knowledge/`. Keep it that way to isolate the variable.
