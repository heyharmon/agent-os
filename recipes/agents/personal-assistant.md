---
type: agent-recipe
name: personal-assistant
title: "Personal Assistant"
description: "Your first hire: a PA that captures and triages what you throw at it, keeps a prioritized task list, writes you a daily briefing, drafts outputs, and escalates anything consequential — all from the brain, no external accounts."
stage: 1
provides: agent:personal-assistant
requires: [local-brain]
pairs-with: [local-brain]
stack: [claude-code, bash, cron]
---

# Personal Assistant

> The most relatable first agent: a personal assistant / chief of staff. You hand it things — tasks, notes, half-formed ideas — and it files them, keeps them prioritized, tells you each morning what's urgent and what's next, drafts what it can, and asks before doing anything it shouldn't decide alone. Deliberately **brain-only** in this version: it works entirely from the brain and local files, no email or calendar accounts to wire up. Those grow into their own agent recipes later (**Communications Manager**, **Scheduler**) — which is the modular-agents idea in action: this seat is where they spin out from.

## Yields

One accountable agent that runs on a heartbeat and a daily briefing, fully defined by files in the brain, writing a run record every time it acts. Reaches **Stage 1** (`AGENT_ARCHITECTURE.md §12`) — real, hands-off help with the everyday pile, telemetry from day one. Starts at **Supervised** authority (`§8`): acts on reversible work, gates the consequential.

## Prerequisites

- **Brain:** a [`local-brain`](../brains/local-brain.md) (or any brain that `provides: brain`) already built on this machine.
- **Accounts / keys:** a Claude Code install authenticated for headless use (`claude -p`). **Nothing else** — no email, no calendar, no OAuth.
- **Runtimes:** `bash`, `cron` (or `launchd` on macOS), and the brain's `bin/brain` on `PATH`.

## Ingredients

| Component | Choice | Why this one |
|---|---|---|
| Provider | Claude Code, headless (`claude -p`) | runs the agent's harness; satisfies the run contract (wake → read → bounded work → write → stop, `§5`); nothing to host |
| Activation | two `cron` schedules — hourly triage + a morning brief | cadence matches the job (`§6`); both are inspectable config; no event plumbing |
| Loop glue | a `bash` wrapper (`loop.sh <mode>`) | generates the run id and writes the run record *around* the session (inv. #5) |
| Writes | the brain's `bin/brain` CLI | one write contract; the agent never edits raw files |
| Job & harness | files in the brain | so improvement and promotion are readable diffs (`§5`, `§11`) |

## Steps

1. **Write the job** — `brain new agents personal-assistant --title "Personal Assistant" --type Agent`, then fill `knowledge/agents/personal-assistant/index.md` with:
   - **Responsibilities:** *capture* what you hand it; *triage* it into the brain; keep a *prioritized* task list; write a *daily briefing*; *draft* outputs for your review; *escalate* decisions it shouldn't make alone.
   - **Authority level:** `Supervised`.
   - **Tools, consequence-tagged** (inv. #6) — step 3.
   - **Escalation rule:** anything whose consequence exceeds Supervised authority is *escalated, not executed* (step 4).
   - **Schedule:** hourly triage; daily briefing at, say, 7am.

2. **Create the harness** under `harness/personal-assistant/` in the brain repo (machinery, not knowledge — deletable tooling, inv. #7):
   - `system-prompt.md` — you are the Personal Assistant; read your job at `knowledge/agents/personal-assistant/index.md`; do **bounded** work using only your tools; write everything back through `bin/brain`; escalate per your job; then stop.
   - `tools.md` — the tool list with consequence tags (step 3).
   - `loop.sh` — the wrapper, taking a mode argument (`heartbeat` | `brief`) (step 5).

3. **Define tools, each tagged by consequence** (`§8` mechanism). Base set is deliberately safe so the agent is sound at Supervised — and brain-only:

   | Tool | Consequence | In base? |
   |---|---|---|
   | `brain search` / read files | reversible | yes |
   | triage / file to the brain (`brain new`, additive `brain update`) | reversible | yes |
   | set/adjust task **priority** (frontmatter on queue items) | reversible | yes |
   | draft an output (write a draft file to the brain) | reversible | yes |
   | write the **daily briefing** (to `runtime/briefings/`) | reversible | yes |
   | `brain queue add` (capture follow-up work) | reversible | yes |
   | `escalate` (write to the approvals queue) | reversible | yes |
   | send email / message / post externally / book a meeting / delete | **consequential** | no — escalate (and the home of future agent recipes) |

4. **Wire escalation.** "Escalate" = write a file to `runtime/queue/approvals/` describing the proposed consequential action and what it's waiting on. This is the **outbound** approval queue (`§9`) — the agent's actions waiting for *you*, distinct from the inbound task queue you fill. At Supervised, this is your oversee surface; the daily briefing surfaces it so nothing waits silently.

5. **Write `loop.sh`** — the harness that makes telemetry non-optional (inv. #5). It, not the session, writes the run record:

   ```bash
   #!/usr/bin/env bash
   set -uo pipefail
   cd "$(dirname "$0")/../.." || exit 1          # brain root
   export PATH="$PWD/bin:$PATH"
   mkdir -p runtime/drafts runtime/briefings runtime/queue/approvals
   MODE="${1:-heartbeat}"; AGENT=personal-assistant; SESSION="pa-$MODE"
   RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)-pa-$MODE"; START=$(date +%s); STATUS=ok
   case "$MODE" in
     heartbeat) TASK="Heartbeat $RUN_ID. Read your job and runtime/queue/; capture & triage new items \
       into knowledge/ via bin/brain; (re)prioritize; draft into runtime/drafts/; escalate per your job; stop." ;;
     brief)     TASK="Morning brief $RUN_ID. Read runtime/queue/ (incl. approvals) and recent runtime/runs/; \
       write runtime/briefings/$(date +%F).md — urgent items, today's priorities, what's waiting on me; stop." ;;
   esac
   # --output-format json so the harness reads REAL usage/cost (§7), never estimates it
   RESP=$(claude -p --output-format json \
     --append-system-prompt "$(cat harness/$AGENT/system-prompt.md)" "$TASK" 2>&1) || STATUS=failed
   DUR=$(( $(date +%s) - START ))
   RECORD=$(RESP="$RESP" RUN_ID="$RUN_ID" STATUS="$STATUS" DUR="$DUR" python3 -c '
   import json, os; r = os.environ
   try: d = json.loads(r["RESP"])
   except Exception: d = {}
   u = d.get("usage", {})
   print(json.dumps({"run_id": r["RUN_ID"], "trigger": "heartbeat", "duration_s": int(r["DUR"]),
     "outcome": r["STATUS"], "tokens_in": u.get("input_tokens", 0), "tokens_out": u.get("output_tokens", 0),
     "cost_usd": round(d.get("total_cost_usd", 0) or 0, 4), "num_turns": d.get("num_turns")}))')
   brain run --agent "$AGENT" --session "$SESSION" --json "$RECORD"
   ```
   The harness reads tokens/cost from `claude -p --output-format json` — the provider's own usage report — and writes them into the run record (`§7`); it never estimates. It also scaffolds the `runtime/` subdirs the agent writes into.

6. **Schedule it.** Two cron entries from the brain root:
   ```
   0 * * * * cd /path/to/brain && ./harness/personal-assistant/loop.sh heartbeat
   0 7 * * * cd /path/to/brain && ./harness/personal-assistant/loop.sh brief
   ```
   Commit everything.

   **Permissions note (headless runs):** a cron run is unattended — no human is there to approve tool prompts. The agent writes through `bin/brain` and the shell (not an interactive editor tool), and Claude Code must be allowed to run those without prompting (e.g. run with permissions skipped, or an allowlist for `bin/brain` + file writes under `runtime/`). In testing, a permission-gated editor tool simply made the agent fall back to the shell — but don't rely on that; configure it.

7. **Register the agent in `AGENTS.md`.** Add a line under the brain's **"This brain's agents"** list (created by the `local-brain` recipe) so any agent working here knows this one exists and where it lives:
   `- **personal-assistant** — job: \`knowledge/agents/personal-assistant/index.md\`; harness: \`harness/personal-assistant/\`.`
   This is how each agent recipe stays modular: it appends itself to the reference rather than rewriting it.

## Doneness

- [ ] **Capture & triage:** `brain queue add "call dentist; also note that Acme renewed for 12 months"` → the next heartbeat files the durable fact (Acme) into `knowledge/`, keeps the task, and tags its priority.
- [ ] **Prioritize:** queue items carry a priority; something marked urgent rises to the top.
- [ ] **Briefing:** the morning run writes `runtime/briefings/<today>.md` listing urgent items, today's priorities, and what's waiting on you.
- [ ] **Telemetry:** each run leaves a record in `runtime/runs/` with the `§7` fields.
- [ ] **Escalation:** a consequential task ("email Acme the renewal terms") lands in `runtime/queue/approvals/` and is **not** executed.
- [ ] **Swappable runner:** killing a run mid-flight loses nothing — the next session reloads state from the brain (inv. #3).

## Pairs with

- **[`local-brain`](../brains/local-brain.md)** — its required foundation.
- **Communications Manager** (future agent recipe) — takes over email/messaging with the integration the PA deliberately omits; the PA escalations become its inbound work.
- **Scheduler** (future agent recipe) — owns calendar, meetings, and time-slotting.
- A future **dreaming recipe** (Stage 3) — nightly consolidation + the improvement loop that turns your corrections into job diffs (`§11`).

## Substitutions

| Instead of… | Use… | When |
|---|---|---|
| Claude Code (`claude -p`) | Codex / a custom agent SDK | you prefer another provider — the run contract (`§5`) is identical |
| `cron` | `launchd`, a managed scheduler, or an event webhook | you're on macOS, or latency on a specific event genuinely matters (`§6`) |
| brain-only PA | add a **Communications Manager** and/or **Scheduler** agent on the same brain | you want real email/calendar action and are ready to wire one integration — done as a *new agent recipe*, not by bloating this one (`§2`, `§12`) |
| `Supervised` authority | `Delegated` → `Autonomous` | the agent's evals prove it out — raise authority as earned promotion, a readable diff to the job (`§8`, `§11`) |
| manual feedback capture | the dreaming job's improvement pass | you reach Stage 3+ and want corrections clustered into job diffs automatically (`§11`) |
