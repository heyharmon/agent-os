# Handoff: run experiment 007 (OKF as the brain's knowledge format)

## Context you need

We are deciding, on evidence, whether the file brain's **knowledge layer** should commit to Google's Open Knowledge Format (OKF v0.1) or stay as today's ad-hoc markdown + YAML frontmatter. This is hypothesis **H-07**. A separate build (`aos-product-dev`, another repo) is shipping plain frontmatter now and will only adopt OKF if this experiment says it earns its place. Your job is to run 007 to a clear-cut takeaway.

The charter is written and is the authority: [`experiments/007-okf-brain-format/charter.md`](../../experiments/007-okf-brain-format/charter.md). Read it and [`experiments/PROCESS.md`](../../experiments/PROCESS.md) and H-07 in [`HYPOTHESES.md`](../../HYPOTHESES.md) before doing anything. Nothing has run yet; there are no results.

**The key prior that should shape the whole run:** OKF v0.1 is *nearly identical* to the file brain we already proved. It is markdown + YAML frontmatter, a directory of concept files, exactly one required field (`type`), six standardized/queryable fields (`type`, `title`, `description`, `resource`, `tags`, `timestamp`), reserved `index.md`/`log.md`, and concepts linked by ordinary markdown links. So the cost side is small, and the real question is whether the **portability/interop benefit ever fires**, or whether OKF is neutral ceremony here. Build the experiment so that benefit *can* fire, or conclude honestly that it does not.

State: branch `main`, clean, last commit `1e99108` (queued the charter + H-07 update + CHANGELOG). No local services needed. Provider: match what 003 used (read its scripts).

## What I want you to do, in order

1. **Build the two arms by reusing the 003 rig.** The richest knowledge layer lives in experiment 003. Reuse its rig and benchmark unchanged: [`experiments/003-coding-assistant/bin/`](../../experiments/003-coding-assistant/bin/) (`brain`, `score.py`, `compare.py`, `run-arch.sh`, `tournament.sh`), [`worlds/dev`, `worlds/heldout`, `worlds/heldout.frozen`](../../experiments/003-coding-assistant/worlds/), [`tasks/dev.yaml`, `tasks/heldout.yaml`](../../experiments/003-coding-assistant/tasks/), and the [`harness/`](../../experiments/003-coding-assistant/harness/). **Do NOT use `gate.py`** (the enforcement gate is demoted, H-16).
   - **A_plain** = 003 exactly as-is (the proven baseline).
   - **A_okf** = a copy of 003 where you convert **only** the `knowledge/` layer of each world to OKF v0.1 (add the required `type`, the six standard fields where they apply, `index.md`/`log.md`, OKF-style markdown links). Leave the tasks, scorer, agent, retrieval, and `runtime/` identical. Only the knowledge-layer format may differ. Isolate the variable.

2. **Define the OKF-portability discriminator before running** (this is the pre-registered H-18 trap that makes the benefit fire). Write a tiny, brain-agnostic "generic OKF reader" that parses only OKF-standard frontmatter fields and knows nothing about our layout, then require it to answer a fixed query (e.g. "list every concept of `type: convention` with its `title` and `description`"). Pre-register the reader and the query in the charter's "open design notes" section before any run.

3. **Run the task suite on both arms**, `tasks/dev.yaml` then the blind `tasks/heldout.yaml`, default 3 trials, hermetic scratch per trial, costs from provider JSON (never estimated). Run held-out **once** at conclusion; keep `worlds/heldout.frozen` byte-identical before and after. Score outcomes, not mechanism.

4. **Run the portability discriminator** against both brains. Record: does the generic OKF reader answer correctly against A_okf with zero migration, and demonstrably *fail* against A_plain? If it can also read A_plain (because plain frontmatter already carries the fields), the portability win did **not** fire, say so.

5. **Record the constraint-bite check.** During conversion and the runs, note any case where OKF's rules forced a field or structure that plain frontmatter would not have. Zero forced workarounds is the good outcome for OKF.

6. **Diagnose, decide, conclude** per PROCESS.md stopping criteria. Resolve H-07 against its pre-registered refute clause.

## Smoke-test / what a result looks like

- Task parity: A_okf held-out pass-rate equals A_plain (OKF must not regress task quality). A drop counts against OKF.
- Portability: the generic OKF reader answers the fixed query against A_okf and cannot against A_plain (win fires) - or it reads both (win does not fire).
- Constraint bite: count of OKF-forced workarounds (target 0).
- Honest null is a valid takeaway: if parity holds and the portability win never fires, conclude "OKF is neutral here: no measured benefit, low measured cost" and say what would change the answer.

## Constraints

- Follow PROCESS.md honesty rules absolutely: pre-register before running; do not weaken a task to force a pass; do not patch the scorer against held-out behavior; one variable at a time; hermetic trials; cost is a signal, never a bar.
- **Never fabricate or overclaim a result.** Confidence labels are earned (PROVEN-ish / SUPPORTED-but-thin / INCONCLUSIVE / etc.). A thin result says it is thin.
- Decision rights: proceed autonomously on rig reuse, single-variable runs, and writing results/hypothesis updates. **Stop and consult the operator** before changing the charter or the 003 benchmark, on any safety-floor breach, or on anything outward-facing.
- Writing style: terse, no em dashes, plain language.

## When you're done

- Write the takeaway in `experiments/007-okf-brain-format/results/run-log.md` and a scorecard alongside it.
- Update **H-07** status in `HYPOTHESES.md` (UNTESTED -> the result, with evidence links).
- Add a dated `CONCLUDED` entry to `CHANGELOG.md` (Keep a Changelog format) and flip the charter Status.
- Add `FINDINGS/007-okf-brain-format.md` if the result warrants it; update `EVIDENCE.md` only if a block's verdict actually moves.
- Report back to Ryan: the one-line answer (does OKF earn its place over plain frontmatter?), the three signals (task parity, portability win fired?, constraint bites), the dev-vs-held-out gap, and what it does not yet establish.
