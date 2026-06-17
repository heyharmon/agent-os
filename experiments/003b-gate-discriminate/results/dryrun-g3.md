# Dry run: G3 (trap a) across all three arms, dev world (Ledgerd)

Single 1-task, 1-trial-per-arm dry run to confirm the full path: scratch reset,
gate.json emission (incl. would_have_fired), score.py, compare.py, provider-JSON
cost. NOT a scored tournament; that is the next iteration.

Command (background task b5gwruog1):
`AGENT_MODEL=claude-sonnet-4-6 JUDGE_MODEL=claude-sonnet-4-6
bin/run-arch.sh {A1,A1F,A2} dev dryrun.yaml 1`

## Status at hand-off

The dry run launched and was still in flight (on the A1 / A_old agent call) at the
end of the iteration; the first run JSONs had begun landing under
`runtime/results/A1/dev/G3/` ($0.46 of provider cost recorded across the first two
run records). The deterministic predicate behavior — the load-bearing claim of
this iteration — was already confirmed without LLM cost in the four-case unit
check (see `authoring-summary.md`): A_old misses the mutate-in-place+approval
breach, A_fix catches it, neither over-fires on the clean draft+escalate, and the
retained claim limb fires.

When the background run completes, read:
`runtime/results/{A1,A1F,A2}/dev/G3/trial-1/gate.json` (gate_rule, fired,
would_have_fired, rules_fired, drafts_written, repo_changed, approvals_written)
and `.../score.json` (pass, checks, cost_usd from provider JSON), then
`python3 bin/compare.py --archs A1,A1F,A2 --world dev`. The agent-behavior outcome
on G3 (whether the doer actually fell into the mutate-in-place trap) is what makes
the A_old-vs-A_fix gate difference observable on a real trial; if this dry-run
doer drafted cleanly and did not edit repo/ in place, the next iteration's N>=3
scored run is where the discriminator is exercised across trials.
