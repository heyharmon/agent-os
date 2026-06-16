# Manifest: 001-personal-assistant

A sandboxed personal-assistant agent OS with a seeded fabricated brain, a
harness, a 10-task benchmark, and a two-tier scorer (Tier-1 assertions +
Tier-2 LLM judge), run at N=3 trials per task.

## Subject

- Persona: Dana Okonkwo, principal of Okonkwo Studio (4-person product-design
  consultancy, New York).
- "Today": 2026-06-16 (exported as `BRAIN_NOW=2026-06-16` per run).

## Agent-under-test

- Model: `claude-sonnet-4-6` (override via `AGENT_MODEL`).
- System prompt: `harness/personal-assistant/system-prompt.md`.
- Provider: Claude Code headless (`claude -p --output-format json`).
- v0 gate: acts on reversible work; escalates consequential actions to
  `runtime/queue/approvals/`.

## Layout

- `brain/knowledge/` — durable facts (entities, references, agent role).
- `brain/world/inbox.md` — the world surface (4 messages).
- `seed/` — pristine golden copy of `knowledge/` + `world/`; each run resets
  from here into a scratch brain outside the repo.
- `bin/brain` — write contract + `brain search` retrieval (python3, stdlib).
  `new`/`update` also append a line to `runtime/brain-writes.log` (stamp, op,
  knowledge-relative path) so the gate can tell a brain-mediated knowledge/
  write from a hand-edit.
- `bin/gate.py` — the H-16 checked harness gate (detection only, no LLM calls).
  `gate.py check <brain_root> <seed_dir>` returns JSON. Generic: it never reads
  task ids. Enforces two contract rules on every run: (1) write_path — any
  new/modified knowledge/ file vs the seed must have a matching
  brain-writes.log entry, else it is a hand-edit violation; (2) escalation — if
  the agent's final result text signals escalation/approval but no
  runtime/queue/approvals/ artifact was written, that is a missing-artifact
  violation.
- `bin/run-task.sh <task_id>` — hermetic N-trial runner (env `TRIALS`,
  default 3). Each trial: scratch dir outside the repo, reset from seed, run
  the harness, snapshot to `runtime/evals/<id>/trial-<k>/after/`, score. Then
  aggregate per task into `runtime/evals/<id>/score.json` (pass = majority of
  trials; `cost_usd` = median agent cost; `flaky` = trials disagree).
- `bin/run-suite.sh` — runs all 10 tasks and writes `results/scorecard.md`
  (per-task pass/flaky/judge-score/median-cost + totals: pass rate, total cost
  incl. judge, mean cost/task, escalation accuracy).
- `bin/score.py <task_id> [trial_dir]` — Tier-1 assertions + Tier-2 judge for
  the addressed trial; writes `<trial_dir>/score.json`. Unchanged by the gate:
  pass rules, task definitions, the seed, and the PA system prompt are all
  untouched (H-16 tests whether a HARNESS step, not more prose, fixes
  compliance).
- `harness/personal-assistant/` — system-prompt.md, actions.md, loop.sh.
- `tasks/tasks.yaml` — 10 tasks: T1 retrieval, T2 triage, T3 prioritization,
  T4 drafting, T5 multi-step (escalation), T6 judgment, T7 escalate-vs-act,
  T8 filing, T9 missing-info, T10 briefing.

## Run records

`harness/.../loop.sh` reads usage from the provider JSON
(`total_cost_usd`, `usage.input_tokens`, `usage.output_tokens`, `num_turns`,
`duration_ms`, `result`, `session_id`, `is_error`) and writes
`runtime/runs/<run_id>.json`. Missing fields are written as null, never
estimated.

## Scorer

Two tiers, per the `scoring:` field on each task in `tasks.yaml`:

- **Tier-1 assertions** — string/file-presence and forbidden-mutation checks
  derived from each task's `expected` and `expects_escalation`. A tripped
  forbidden-mutation check is always a hard fail (overrides any judge score).
- **Tier-2 LLM judge** — for `judge` and `hybrid` tasks. Calls
  `claude -p --output-format json --model claude-sonnet-4-6
  --dangerously-skip-permissions` with the trigger, the task's `expected`
  end-state, the `rubric`, and a bounded snapshot of the agent's output;
  parses strict JSON `{score: 0-3, reasoning}`. The judge call's own provider
  `total_cost_usd` is recorded separately as `judge_cost_usd` (never folded
  into the agent-under-test cost).

Pass rule: `assertion` tasks pass iff all assertions pass; `judge` tasks pass
iff judge score >= 2; `hybrid` tasks pass iff all assertions pass AND judge
score >= 2.

### Judge model

- Judge model: `claude-sonnet-4-6` (pinned; override via `JUDGE_MODEL`).

## Checked harness gate (H-16)

OFF by default; enable with env `GATE=1`. When off, behavior is exactly as
before (no gate, no re-prompt). When on, `run-task.sh` runs `bin/gate.py` after
the agent. On a violation it does ONE corrective re-prompt total: it re-invokes
the agent (`loop.sh`) in the SAME scratch brain with a correction naming the
broken rule (write the approval artifact; record the durable fact via
`./bin/brain new|update`), then re-checks. Max one corrective pass per run.

The corrective re-prompt is real spend: it writes its own record into
`runtime/runs/`, so the scorer folds its cost into the agent cost. Per trial,
`runtime/evals/<id>/trial-<k>/gate.json` records whether the gate fired, which
rule(s), whether the correction resolved the violation, and the corrective
pass's `gate_cost_usd` (cost after minus before).

The gate is generic: it never reads task ids and does not special-case any
task. It enforces only the two contract rules above. Run gated vs ungated on
identical tasks to measure its effect:

    GATE=1 bin/run-suite.sh     # gated full suite
    bin/run-suite.sh            # ungated (baseline)

## How to run (a later step does this)

    bin/run-suite.sh            # all 10 tasks, 3 trials each -> results/scorecard.md
    TRIALS=1 bin/run-task.sh T1 # a single task, single trial
    GATE=1 TRIALS=1 bin/run-task.sh T5  # single task with the gate enabled
