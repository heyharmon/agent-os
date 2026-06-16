# CLAUDE.md — agent-os

## What this directory is

An **experimentation repo**: we test what actually works for putting agents to work, then let principles emerge from evidence. The architecture docs in `archive/` are pre-evidence speculation. Read them for context; never cite them as authority.

Your task here is to run experiments, record results, and keep the hypothesis register honest. Follow `experiments/PROCESS.md`. Within an experiment's charter you proceed autonomously (revise one variable, re-run, update status); the process names the few decisions that stop for the operator (charter changes, architecture-level pivots, budget breach, any safety-floor failure, anything irreversible or outward-facing). Do not weaken a task's expectation or edit the agent's prompt to force a pass; a real failure is the result.

## The files

| File / Dir | What it is |
|---|---|
| `VISION.md` | The goal: proven agent OS architectures across a complexity spectrum of use cases. |
| `experiments/PROCESS.md` | How an experiment runs from charter to clear-cut takeaway, plus decision rights. |
| `HYPOTHESES.md` | The register of bets: one row per claim, with Status and a pre-registered "Refutes if" condition. |
| `experiments/` | One folder per experiment: a `charter.md` (goal, bar, stopping criteria), the system under test, the benchmark. |
| `results/` | Outputs and observations from each run. Link from HYPOTHESES.md. |
| `archive/` | Pre-evidence architecture docs (OVERVIEW, AGENT_ARCHITECTURE, BRAIN_ARCHITECTURE, recipes). Read-only. Do not edit. |
| `CHANGELOG.md` | Record of experiment results and hypothesis status changes. |
| `TODO.md` | Working notes, backlog, and open questions. |

## The open hypotheses

Your job with `HYPOTHESES.md` is to keep it honest:

- Every claim must be falsifiable. It must have a pre-registered "Refutes if" condition written before the test runs.
- Status must be accurate: UNTESTED, IN PROGRESS, SUPPORTED, REFUTED, or ABANDONED.
- Evidence must link to a file in `results/`. A claim with no linked run is a hypothesis, not a finding.
- A claim with no test does not belong in the register. File it or drop it.

## The three operating rules of the rig

1. **Writes go through the brain CLI.** Do not write directly to the brain's knowledge layer; use the CLI so writes are logged and repeatable.
2. **`runtime/` is disposable.** Never treat anything in `runtime/` as durable. Rebuild it, wipe it, restart it freely.
3. **No secrets in the repo.** Credentials, tokens, and keys go in env vars or a local secrets file that is gitignored. Never commit them.

## Committing & the changelog

Commit at meaningful stopping points only, never on every edit.

**When.** Commit when a run completes, a hypothesis status changes, or the register is meaningfully updated. Let mid-experiment edits ride until they settle.

**How.** Commit directly to `main` (no branch/PR ceremony). Stage only the files that changed. Update `CHANGELOG.md` in the same commit so the two never drift. Follow Keep a Changelog format (newest first; Added/Changed/Fixed; dated).

**At what altitude.** Log experiment results and hypothesis status changes (example: "H-02 moved to SUPPORTED after experiment 001"). The audience is us learning. Typos, phrasing, and formatting are committed but not logged.

## Conventions & voice

- Prose is tight and declarative, leaning on tables and the org/employee vocabulary where still apt. Match that register.
- **Diagrams: plain ASCII, always, kept extremely simple.** Use small ASCII for flows, directory trees, and labeled spectrums so they read raw and stay diffable. No Mermaid (it doesn't render everywhere and reads worse as source) and no generated/raster images (not diffable, not agent-editable, they break the degrade-to-plain-text ethos). Prefer the fewest boxes and arrows that carry the idea.
- Cross-reference by file and section (e.g. `results/001/observations.md`) as needed.

## The litmus test

For any claim in this repo: can you point at the run in `results/` that supports it? If not, it is a hypothesis. File it in `HYPOTHESES.md` with a falsifiable test. Do not assert it in prose.

**Guardrail:** do not add a named concept, plane, role, or invariant to the running system to satisfy a hypothesis before running the cheapest experiment that could refute it. Automate last.
