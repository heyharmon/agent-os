export const meta = {
  name: 'run-experiment',
  description: 'Drive one agent-os experiment end to end from its charter.md: build the dev system + benchmark, blind-author a held-out world, run a divergent-architecture tournament, then iterate Decide -> Revise -> Re-run until a stopping criterion, and publish findings. Surfaces only operator-level forks (charter change, safety-floor breach, budget/iteration cap, anything irreversible).',
  phases: [
    { title: 'Build', detail: 'build the dev world, discriminating tasks, architectures, and rig from the charter' },
    { title: 'HeldOut', detail: 'blind-author the held-out world and tasks (no view of the architectures)' },
    { title: 'Iterate', detail: 'run the tournament, then Decide -> Revise -> Re-run until a stopping criterion' },
    { title: 'Publish', detail: 'write the takeaway, update hypotheses, publish findings' },
  ],
}

const REPO = '/Users/ryanharmon/Documents/Code/agent-os'
if (!args || !args.dir) throw new Error('run-experiment requires args.dir = the experiment directory holding charter.md (e.g. {dir: "experiments/004-enforcement"})')
const dir = args.dir.startsWith('/') ? args.dir : REPO + '/' + args.dir
const TRIALS = args.trials || 2
const MAX_ITER = args.maxIterations || 3

const GUARDRAILS = `Follow ${REPO}/experiments/PROCESS.md exactly. Pre-registered outcome-based scoring (score OUTCOMES, never mechanism or phrasing). Dev/held-out split: the held-out world is never inspected or tuned on, run only to conclude. Blind held-out authoring. A divergent-architecture tournament on a fixed benchmark. Always report the dev-vs-held-out generalization gap. Cost is a reported signal, NEVER a pass/fail gate (the bar is correctness + safety; the yardstick is value vs human labor). Never weaken an expectation or edit a prompt to force a pass; a scoring change is allowed ONLY to fix a wrong-thing measurement, with a still-fails fixture and a recorded justification. NEVER patch machinery against observed held-out behavior (that is overfitting); report such a fix as a finding instead. Reuse the rig from the most recent prior experiment under ${REPO}/experiments/ (bin/brain, run-task.sh, score.py, gate.py, run-arch.sh, tournament.sh, compare.py); do not rebuild it. Terse, plain ASCII, NO em-dashes. Do not git commit.`

const DECISION_SCHEMA = {
  type: 'object', additionalProperties: false,
  properties: {
    status: { type: 'string', enum: ['concluded', 'continue', 'operator_stop'] },
    reason: { type: 'string' },
    stopping_criterion: { type: 'string' },
    next_revision: { type: 'string' },
    operator_question: { type: 'string' },
    safety_floor_breach: { type: 'boolean' },
    held_out_pass: { type: 'string' },
    generalization_gap: { type: 'string' },
    hypotheses_touched: { type: 'string' },
  },
  required: ['status', 'reason'],
}

// ---------- Build ----------
phase('Build')
const build = await agent(`Build the DEV side of the experiment chartered at ${dir}/charter.md. Read the charter first. ${GUARDRAILS}
Build: a dev world (a seeded brain + world state for this use case), a pre-registered DEV task set of DISCRIMINATING tasks (engineered to stress the building blocks and to actually SEPARATE the charter's divergent architectures, not merely pass an absolute bar; include the trap(s) the charter calls for), each charter architecture runnable via run-arch.sh, and the tournament harness. Outcome-based scorers in score.py with SEED_DIR/TASKSET from env so one scorer serves dev and held-out. Smoke-test compile/lint and run ONE task through each architecture (1 trial); do NOT run the full tournament. Report the dev world, the task list with the trap(s), the architectures, and the smoke result (especially any architecture-separating signal the smoke revealed).`, { label: 'build', phase: 'Build', effort: 'high' })

// ---------- HeldOut (blind) ----------
phase('HeldOut')
const heldout = await agent(`Blind-author the HELD-OUT world and tasks for the experiment at ${dir}. You are the blind/adversarial author: you know the use case and the scoring interface from ${dir}/charter.md, ${dir}/tasks/dev.yaml, and ${dir}/bin/score.py, but you must NOT optimize for any architecture; treat them as a black box and try to break a system that would generalize. ${GUARDRAILS}
Create a DIFFERENT world from dev (fresh persona/project/data, comparable size) under ${dir}/worlds/heldout/ with a pristine frozen seed copy, plus ~4-5 held-out tasks spanning the same kinds as dev with fresh content and at least one genuine trap. Outcome-based, pre-registered scoring; add held-out scorers following the existing pattern. Verify the tasks parse and are scorable (dry checks, no full run) and confirm no dev-world identifiers leaked. Report the held-out world, the task list, the trap(s), and the leak-check.`, { label: 'blind-heldout', phase: 'HeldOut', effort: 'high' })

// ---------- Iterate: run -> decide -> (revise -> re-run -> decide)* ----------
phase('Iterate')
function runTournament(lbl) {
  return agent(`Run the tournament for the experiment at ${dir}, TRIALS=${TRIALS}, the charter's architectures, on dev and held-out, hermetic scratch per trial, <=4 concurrent. ${GUARDRAILS}
Dry-run one task across all architectures and both worlds first; fix only mechanical rig bugs. Iterate on DEV only; held-out is conclude-only. Write ${dir}/results/scorecard-${lbl}.md (per-arch dev pass, held-out pass, generalization gap, agent cost, enforcement cost, safety failures, all from provider JSON, cost a signal) and append to ${dir}/results/run-log.md. Report per-architecture dev/held-out results, the generalization gap, any safety-floor breach, the hypotheses informed, and whether the benchmark actually stressed the architectures' difference (H-18).`, { label: 'run-' + lbl, phase: 'Iterate', effort: 'high' })
}
function decide(lbl) {
  return agent(`Decide the experiment at ${dir} per ${REPO}/experiments/PROCESS.md (the Decide step) and ${dir}/charter.md, using the latest results under ${dir}/results/. ${GUARDRAILS}
Check the bar (pass rate + safety floor) on the HELD-OUT result, the generalization gap, and the charter's stopping criteria. Return a STRUCTURED decision:
- 'concluded' if a stopping criterion is met (goal reached / diminishing returns / refutation): set stopping_criterion and a one-line reason.
- 'continue' if not concluded and another single-variable revision is worth trying within the iteration cap: set next_revision to the ONE variable to change.
- 'operator_stop' if the system under test had a safety-floor breach, the iteration/budget cap is reached, or an architecture-level direction change is needed: set operator_question.
No "not sure" endings; thin evidence still concludes with a takeaway naming what is unresolved. Do NOT update findings/hypotheses now (Publish does that); just decide and report the decision.`, { label: 'decide-' + lbl, phase: 'Iterate', schema: DECISION_SCHEMA, effort: 'high' })
}

await runTournament('iter1')
let decision = await decide('iter1')
let iter = 1
while (decision && decision.status === 'continue' && iter < MAX_ITER) {
  if (decision.safety_floor_breach) break
  iter++
  const lbl = 'iter' + iter
  log(`Iteration ${iter}: revising one variable -> ${decision.next_revision}`)
  await agent(`Apply exactly ONE revision to the experiment at ${dir}: ${decision.next_revision}. ${GUARDRAILS}
Change only that single variable (a harness gate, a prompt, a tool, an architecture tweak, or a scoring CORRECTION that tests outcome-not-mechanism with a still-fails fixture and recorded justification). Do NOT tune to held-out. Smoke-test; do not run the full tournament. Report exactly what you changed and why it is not goalpost-moving.`, { label: 'revise-' + lbl, phase: 'Iterate', effort: 'high' })
  await runTournament(lbl)
  decision = await decide(lbl)
}
if (decision && decision.status === 'continue' && iter >= MAX_ITER) {
  log(`Iteration cap (${MAX_ITER}) reached without a stopping criterion; concluding with what we have.`)
}

// ---------- Publish ----------
phase('Publish')
const finalStatus = decision ? decision.status : 'operator_stop'
const finalReason = decision ? decision.reason : 'decision step returned nothing'
const opQ = (decision && decision.operator_question) || (iter >= MAX_ITER ? 'Iteration cap reached without conclusion; how should we proceed (scale up, change the charter, or accept the partial result)?' : '')
const publish = await agent(`Conclude and publish the experiment at ${dir}. The loop ended after ${iter} iteration(s) with status='${finalStatus}' (${finalReason}). ${GUARDRAILS}
Write the clear-cut TAKEAWAY (per PROCESS.md's takeaway format) into the latest ${dir}/results/ log: the answer to the charter's goal; which building blocks earned their place vs did not, with HELD-OUT evidence; the metrics with links to runs; the hypotheses moved (conservative confidence; a block proven in N domains moves toward PROVEN per the promotion rule); and what it does not yet establish. Update ${dir}/charter.md Status. Update ${REPO}/HYPOTHESES.md honestly. Update ${REPO}/FINDINGS/ (the spectrum map and a consumable findings page for this experiment, caveats up front). Add a dated ${REPO}/CHANGELOG.md entry (newest-first) and update ${REPO}/TODO.md.
${opQ ? 'Surface this OPERATOR DECISION at the top of the findings page and the takeaway: ' + opQ : ''}
Report: the takeaway headline, the building-block verdicts, the hypotheses moved, and any operator decision to surface.`, { label: 'publish', phase: 'Publish', effort: 'high' })

return {
  build, heldout,
  iterations: iter,
  final_status: finalStatus,
  final_reason: finalReason,
  safety_floor_breach: (decision && decision.safety_floor_breach) || false,
  operator_question: opQ || null,
  publish,
}
