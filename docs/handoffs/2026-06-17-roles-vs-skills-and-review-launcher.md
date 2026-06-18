# Handoff: queue the roles-vs-skills experiment + build bin/review

## Context you need

Ryan is building **AOS**, an operating system for AI agents + humans doing product development. Core idea: the **Brain is the single source of truth**, agents are replaceable workers, harnesses are job descriptions, Claude Code is the runtime. Three repos, all under GitHub `heyharmon`, all private:

- **`~/Documents/Code/aos`** -> `heyharmon/aos` — pure documentation / north star. Read `docs/AOS.md`, `docs/PRINCIPLES.md`, `docs/ROADMAP.md`, `docs/EVIDENCE.md` first.
- **`~/Documents/Code/aos-product-dev`** -> `heyharmon/aos-product-dev` — the running OS (was `aos-brain`, renamed). Has `bin/brain` (CLI; every brain write goes through it), `bin/run` (spawns a Claude Code agent, records real tokens/cost), `roles/{product,developer,validation}.md`, `brain/{knowledge,runtime}/`, `templates/`, `CLAUDE.md` (operating contract), `docs/LOOP.md`. Brain runtime records are tracked in git.
- **`~/Documents/Code/aos-experiments`** -> `heyharmon/aos-experiments` — research repo. `experiments/PROCESS.md` is the method; `HYPOTHESES.md` the bet register; `CHANGELOG.md` (Keep a Changelog); `EVIDENCE.md` the consolidated proven findings. exp-007 (OKF) is queued there as the precedent to copy.

Proven so far (`EVIDENCE.md`): the basic single-agent file-brain composition (file brain + ripgrep + reversible/escalate tag + named role + provider-JSON cost) + one no-fabrication guardrail. Do not adopt untested ideas; test first.

Milestone 1 of `aos-product-dev` is mostly built: the full loop (issue -> plan -> approve -> build -> validate -> approve) ran for real on a baseline-visibility bug and shipped to `bloomcu/paraloom` PR #9 (draft). Cost capture is wired (`bin/run`). The two tasks below are the next steps, added in `aos/docs/ROADMAP.md` (sections "Human review sessions" and "Open questions").

Environment: nothing running. Date 2026-06-17. Git author used so far: `Ryan Harmon <ryan.harmon@metrifi.com>`. All three repos are clean and pushed. `~/Herd/paraloom` is on Ryan's WIP branch `changelog-session-updates` (do not touch); the merged-pending fix is on pushed branch `baseline-visibility-fix` (PR #9).

## What I want you to do, in order

1. **Queue experiment 008: roles (markdown) vs skills/agents for agent modes — in `aos-experiments`. QUEUE ONLY, do not run.** The open question: the modes (product / developer / validation, plus a verify mode) are `roles/*.md` injected into the prompt today; would Claude Code **skills** (skill files) and/or **subagents/agents** scope behavior better, and at what cost? Follow `experiments/PROCESS.md` and copy the exp-007 pattern exactly:
   - Read `experiments/007-okf-brain-format/charter.md` first as the template.
   - Add **H-22** to `HYPOTHESES.md` (next free id; H-21 is last). Falsifiable claim + pre-registered "Refutes if".
   - Write `experiments/008-roles-vs-skills/charter.md` + `README.md` (008 is next; 004 was discarded, 007 is OKF). Two divergent arms (A_roles = current `roles/*.md`; A_skills = the modes as Claude Code skills and/or agents), one reused proven benchmark (003 coding or 005/006), dev + blind held-out, a pre-registered discriminator per H-18, cost as a signal not a bar.
   - Add a "Queued experiments" entry to `TODO.md` and a dated entry to `CHANGELOG.md`.

2. **Build `bin/review <approval-or-issue-id>` in `aos-product-dev`.** A human-in-the-loop helper: given an approval or issue id, assemble its context from the brain (the issue, its plan, its review, the approval, and the relevant diff) and open an **interactive** `claude` session scoped to it, so Ryan can discuss the approval, ask questions, and see changes. Mirror `bin/run` (Python, reads via `bin/brain get`). Differences from `bin/run`: launch `claude` **interactively** (not `-p`) with the assembled context as the opening prompt, in the right repo dir; for the diff, use the issue's `pr` frontmatter field (e.g. `gh pr diff <n>`) if present, else the branch. The session must be able to write back to the brain (call `bin/brain comment`/`update`/`approve`). This is the "ready command / deep link" the roadmap's "Human review sessions" section describes; also make newly-created approvals print the `bin/review <id>` command.

## Smoke-test

- Task 1: `ls experiments/008-roles-vs-skills/charter.md`; `grep "H-22" HYPOTHESES.md`; charter has both arms + a refute clause + a discriminator; no run performed.
- Task 2: `aos-product-dev/bin/review issue-0001 --dry-run` prints the assembled context (issue-0001 + plan-0001 + review-0001 + approval + PR #9 diff) without launching claude; a real `bin/review issue-0001` drops into an interactive claude session.

## Reference / shortcuts

- Brain CLI: `aos-product-dev/bin/brain {new,get,list,update,status,approve,reject,record-run,search}`. Live objects: `issue-0001` (baseline bug, ready-for-review, has a `pr` field = PR #9), `plan-0001` (approved), `review-0001`, `approval-0001/0002`, `run-0001..0004`. Note: `bin/brain` has no `comment` subcommand yet — add one if Task 2 needs it.
- `bin/run` parses `claude -p ... --output-format json`; usage fields verified real: `total_cost_usd`, `usage.{input_tokens,output_tokens,cache_read_input_tokens,cache_creation_input_tokens}`, `is_error`, `result`, `session_id`.
- `claude` CLI flags: `-p` (print), `--output-format json`, `--append-system-prompt`, `--dangerously-skip-permissions`, `--model`.
- exp-007 charter (queue template): `aos-experiments/experiments/007-okf-brain-format/charter.md`.

## Constraints

- Terse; no em dashes; 10th-grade reading level for docs. Lead with the answer.
- aos-experiments: QUEUE (charter + hypothesis), never RUN without being asked. Follow PROCESS.md honesty rules (pre-register, no overclaiming, confidence labels are earned).
- Reversible vs consequential (`aos-product-dev/CLAUDE.md`): writing files/branches is fine; commit / push / PR / merge are consequential — do not do them without Ryan's OK. Commit only when asked; if you do, branch off the default branch first.
- Don't touch `~/Herd/paraloom`'s `changelog-session-updates` branch or its WIP.
- aos-product-dev: brain writes go through `bin/brain`, never hand-edit `brain/`.

## When you're done

- Task 1: report H-22 + the 008 charter are written and queued (not run); paste the one-line hypothesis claim and the two arms. Ask before committing/pushing aos-experiments.
- Task 2: `bin/review` works (show the dry-run). Ask before committing/pushing aos-product-dev.
- One-line status per task. Propose commits; do not push without approval.
