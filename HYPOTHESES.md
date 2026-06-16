# Hypotheses

This register holds every unproven architectural claim from the archived docs as a falsifiable bet. A claim with no test does not belong here; nothing is asserted as fact until a run in `results/` supports it.

---

## H-01  Self-improvement loop produces net-positive role changes
- Claim: An automated improvement pass (cluster interventions, propose a role diff, human approves) lowers an agent's intervention rate over time without degrading other quality metrics.
- Source: `archive/AGENT_ARCHITECTURE.md` §11 (Improvement); §10 (Evaluation).
- Why we believe it: a correction captured once as a labeled example should prevent the whole class of mistake, so attention compounds instead of repeating weekly.
- Test: experiment 001 (lean personal-assistant run). Run the agent for N sessions, capture interventions as feedback, run one improvement pass, then replay the same case set and the next N sessions. Observable signal: intervention rate on the replay set after the diff vs. before.
- Refutes if: post-diff intervention rate is not lower than pre-diff on the held-out replay set across 3 consecutive passes, OR any approved diff raises the failure rate on a previously-passing case (regression).
- Status: UNTESTED
- Evidence: (none)

## H-02  Plain-text (ripgrep) search is sufficient retrieval
- Claim: Plain-text search over frontmatter and content retrieves the right brain context for an agent's tasks, with no embeddings or graph layer needed.
- Source: `archive/BRAIN_ARCHITECTURE.md` inv. #6, §6 (retrieval is earned complexity); `archive/AGENT_ARCHITECTURE.md` §4 (Context plane).
- Why we believe it: a single-operator brain is small and the agent writes its own files with searchable terms, so lexical match should find what it needs before scale forces vectors.
- Test: experiment 001. Log every retrieval the agent performs and whether the task succeeded using only what plain search returned. Observable signal: rate of tasks that failed or escalated specifically because needed context existed in the brain but plain search did not surface it.
- Refutes if: more than 10% of sessions fail or escalate due to a retrieval miss where the fact was present in the brain but lexically unfindable, across experiment 001.
- Status: SUPPORTED-but-thin (held through 001's conclusion). Across all 001 runs (prose-only, gated, and the concluding iter2 outcome-scored run) there were zero retrieval-miss failures, well under the 10% refute threshold. T1 found the retainer + renewal; T5/T6/T8 pulled the right protocol/policy/entities; T9 (missing-info) correctly reported the *absence* of a Northwind phone number, a true gap rather than a search miss, with no fabrication in any trial. No suite failure was ever a retrieval failure (T5/T8 were write/escalation and eval-rig, since fixed). Thin because the brain is small and single-world; cost-vs-brain-scale is not yet measured (carry-forward), so sufficiency at scale is unestablished.
- Evidence: `results/2026-06-16-exp001-iter2.md` (concluding run); `results/2026-06-16-exp001-full-suite.md`; `results/2026-06-16-exp001-lean-core.md`.

## H-03  Brain-as-bus removes the need for inter-agent messaging
- Claim: Two or more agents coordinate correctly by reading and writing the brain alone, with no direct agent-to-agent calls and no missed or duplicated work.
- Source: `archive/AGENT_ARCHITECTURE.md` §1.1, inv. #2; `archive/BRAIN_ARCHITECTURE.md` §1.1.
- Why we believe it: "A tells B" reduces to "A writes a file, B reads it," which keeps coordination machinery-free and the whole system readable.
- Test: BLOCKED, needs a 2nd agent. Run two agents whose work hands off through the brain (one produces, one consumes) over a shared workload. Observable signal: handoffs completed correctly via brain state alone, with no lost or double-processed items.
- Refutes if: correct coordination requires any direct call or out-of-brain channel, OR brain-only handoff produces a lost/duplicated item rate above 0 that cannot be fixed by a claim/routing convention in `runtime/`.
- Status: UNTESTED
- Evidence: (none)

## H-04  The autonomy dial needs more than two rungs
- Claim: Operators meaningfully use more than two autonomy settings; the four-rung dial (Advisory / Supervised / Delegated / Autonomous) earns its granularity over a binary propose/act switch.
- Source: `archive/AGENT_ARCHITECTURE.md` §8 (Autonomy: a dial, not a default).
- Why we believe it: managing an agent mirrors managing a person, where supervision style shifts in steps as trust grows, not in one jump.
- Test: Operate one or more agents over real work and record which rung each sits at and every rung change. Observable signal: distribution of rungs actually used and whether the middle rungs (Supervised, Delegated) are ever distinct in practice from the extremes.
- Refutes if: across the run, agents only ever sit at the two extremes (full-propose or full-act) and no middle rung is used for a sustained period, OR operators report the middle rungs are indistinguishable in behavior.
- Status: UNTESTED. The full suite does not exercise the dial: the agent ran at one fixed setting throughout, and T5/T7 test escalation *mechanism* (does it gate a consequential action), not rung *granularity* (does the operator want a middle setting). The suite gives no evidence either way on how many rungs are needed. Designing a test that varies the rung is now a TODO.
- Evidence: (none directly bears on rung count; `results/2026-06-16-exp001-full-suite.md` exercises escalation but not the dial.)

## H-05  Agents-hold-named-roles and the org metaphor earn their keep
- Claim: Modeling each agent as an accountable named role (with hiring, review, promotion vocabulary) produces better-scoped, more reviewable work than one general-purpose agent.
- Source: `archive/AGENT_ARCHITECTURE.md` §1.2, §2, §5; `archive/OVERVIEW.md` (idea 2).
- Why we believe it: smaller context and a sharp scope per role mean separate schedules, reviews, and failures, so a bug in one area never touches another.
- Test: Compare a single role-scoped agent against an unscoped do-everything agent on the same task set. Observable signal: task success, escalation accuracy, and reviewer time-to-judge per approach.
- Refutes if: the role-scoped agent shows no measurable advantage in success rate or reviewability over the unscoped agent on the same workload, OR the role file adds maintenance cost without changing behavior.
- Status: UNTESTED. 001 concluded with the named role in place and scoping behavior throughout, but never ran the unscoped do-everything baseline, so the role's *advantage* is observed, not measured. The unscoped baseline is the cleanest single follow-on (carry-forward from 001).
- Evidence: (none directly compares scoped vs unscoped; the role was held fixed across all 001 runs.)

## H-06  Dreaming improves the brain without introducing errors
- Claim: A nightly consolidation pass (file, reconcile contradictions, prune, link, write the digest) leaves the brain more correct and more useful than it found it, net of any errors it introduces.
- Source: `archive/AGENT_ARCHITECTURE.md` §6 (Dreaming); `archive/BRAIN_ARCHITECTURE.md` §7 (Curation).
- Why we believe it: the upkeep tedium that rots wikis is exactly what an AI does not mind, and flag-don't-guess keeps it from inventing on ambiguous items.
- Test: Snapshot the brain, run a dreaming pass on a known set of staged items and contradictions, diff the result. Observable signal: count of correct consolidations vs. count of facts wrongly altered, dropped, or fabricated in the diff.
- Refutes if: any dreaming pass introduces a factual error into `knowledge/` that a human would not have made, OR net correctness (correct edits minus harmful edits) is not positive across runs.
- Status: UNTESTED
- Evidence: (none)

## H-07  OKF (a pinned external format) is worth its cost over plain frontmatter
- Claim: Committing the knowledge layer to OKF buys enough portability and ecosystem leverage to justify its constraints versus ad-hoc markdown + YAML frontmatter.
- Source: `archive/BRAIN_ARCHITECTURE.md` §0, inv. #2, §4, §8 (the brain's only hard commitment).
- Why we believe it: format alone determines longevity, so anything that speaks OKF can read and write the brain, and it outlives every tool.
- Test: Build the brain in OKF and attempt one concrete portability win (read/write the same brain with a second OKF-aware tool with zero migration). Observable signal: whether a second tool operates on the brain unmodified, and whether OKF's constraints ever block a needed field or structure.
- Refutes if: no second tool ever reads the brain via OKF over the project's life, AND OKF's frontmatter rules force at least one workaround that plain frontmatter would not have, making it pure cost.
- Status: UNTESTED
- Evidence: (none)

## H-08  A consequence-tag taxonomy beyond reversible/escalate is needed
- Claim: Governing actions requires more than the binary reversible-vs-consequential tag; a richer consequence taxonomy is needed to make correct autonomy decisions.
- Source: `archive/AGENT_ARCHITECTURE.md` inv. #6, §8; `archive/TOOLS.md` §0.
- Why we believe it: real actions vary in both reversibility and blast radius, so a single binary may collapse cases that an operator would treat differently.
- Test: Tag every action an agent can take with the binary scheme and run real work. Observable signal: count of actions where the binary tag forced the wrong autonomy decision (escalated something trivial, or auto-ran something the operator wanted gated).
- Refutes if: the binary reversible/escalate tag produces correct escalation decisions on every action across experiment 001 (no operator ever wishes for a finer tag).
- Status: INCONCLUSIVE, leaning toward REFUTED-but-not-yet (held through 001's conclusion; the binary tag was adequate for the whole experiment). Across T5/T6/T7 the binary tag drove the right decision every trial: the T7 wire and T5 calendar change were both treated as consequential and not executed; T1-T4/T9/T10 reversible work was acted on. No case forced a wrong escalate-vs-act call, and no operator wished for a finer tag, the exact pre-registered refute condition, but on a thin single-world suite (one genuine escalation task), so not called. The gated and concluding runs reinforced this: the gap was always escalation *mechanism* (writing the right artifact) and never the tag's *taxonomy* (the agent always classified T5/T7 as consequential and reasoned them correctly, even on the T5 trials where the corrective artifact targeted the wrong task). 001 ends with the binary tag KEPT and sufficient so far; resolving the refute clause needs two-sided escalation traps (over- and under-escalation), a carry-forward.
- Evidence: `results/2026-06-16-exp001-iter2.md` (concluding run); `results/2026-06-16-exp001-full-suite.md`; `results/2026-06-16-exp001-h16-gate.md`.

## H-09  The runner/provider is genuinely swappable without rework
- Claim: An agent's session and provider can be replaced with no loss of state and no rework of the role or brain, because the runner holds no state.
- Source: `archive/AGENT_ARCHITECTURE.md` §1.1, inv. #3, §5; `archive/BRAIN_ARCHITECTURE.md` §5.
- Why we believe it: all durable state is in the brain and the harness is stateless code, so killing and restarting (or re-providering) reloads everything from files.
- Test: Run the agent on one runner/provider, stop mid-workload, resume on a different runner or provider against the same brain. Observable signal: whether work continues correctly from brain state with no manual state transfer.
- Refutes if: resuming on a different runner/provider requires reconstructing any state not held in the brain, OR the harness rewrite needed to swap providers is large enough that the role/brain in practice had to change too.
- Status: UNTESTED
- Evidence: (none)

## H-10  Ingestion as a distinct staged function is needed
- Claim: Separating mechanical intake (ingestion lands raw material in staging) from sense-making (dreaming) is worth the extra moving part versus letting the agent fetch and file in one step.
- Source: `archive/BRAIN_ARCHITECTURE.md` §7 (ingestion vs. dreaming); `archive/AGENT_ARCHITECTURE.md` §6.
- Why we believe it: keeping intake dumb and judgment-free isolates "what arrived" from "what is true," so a fetch failure never corrupts knowledge and dreaming has a clean staging area to reason over.
- Test: Run a workflow with a separate staging step and compare against one where the agent fetches and files inline. Observable signal: error rate and recoverability when intake fails or floods, with vs. without staging.
- Refutes if: inline fetch-and-file shows equal correctness and recoverability on real intake, making the separate staging area pure overhead, across experiment 001.
- Status: UNTESTED
- Evidence: (none)

## H-11  The tool/account/grant three-layer model earns its complexity
- Claim: Splitting a tool into tool, account, and grant layers is worth the structure versus a flatter model, because it cleanly handles identity-bearing and multi-account services.
- Source: `archive/TOOLS.md` §1 (Three layers), §6 (Where the pieces live).
- Why we believe it: a read-only key service collapses all three while an identity-bearing service (send as sales@ vs support@) genuinely needs them apart, with identical wiring either way.
- Test: Wire one collapsed tool (single key) and one identity-bearing tool (multi-account) using the three-layer model. Observable signal: whether the split is ever load-bearing (a grant or account distinction that changes behavior) vs. always collapsed in practice.
- Refutes if: across the tools actually wired, every case collapses to a single layer and the account/grant distinction never changes any behavior, making the model unused ceremony.
- Status: UNTESTED
- Evidence: (none)

## H-12  The six planes are a useful decomposition that survives a running system
- Claim: Decomposing the system into six planes (Context, Work, Activation, Telemetry, Learning, Interface) is a useful build order and mental model that holds up once a system is actually running.
- Source: `archive/AGENT_ARCHITECTURE.md` §4 (the architecture at a glance).
- Why we believe it: each plane is a thin layer over the brain, added in order and useful on its own, so it gives builders a staged path rather than a monolith.
- Test: Build the lean system and map its real components back onto the six planes. Observable signal: whether each plane corresponds to a distinct implemented thing, or whether planes collapse, blur, or go unused.
- Refutes if: in the running system two or more planes are indistinguishable or one is never implemented as a separate concern, such that the six-way split misleads more than it guides.
- Status: UNTESTED
- Evidence: (none)

## H-13  Heartbeat loops are the right default activation
- Claim: A scheduled heartbeat loop (wake, read brain, do bounded work, write back, stop) is sufficient for most agent work; event triggers are rarely needed.
- Source: `archive/AGENT_ARCHITECTURE.md` §6 (Activation); `archive/OVERVIEW.md` (How it runs).
- Why we believe it: most work is not latency-sensitive, so a faster heartbeat is simpler than wiring webhooks and exactly-once event handling.
- Test: experiment 001. Run the agent on a heartbeat loop only and track tasks that suffered from polling latency. Observable signal: count of tasks where heartbeat latency caused a real miss or harm that an event trigger would have prevented.
- Refutes if: more than a small share of tasks require sub-heartbeat latency such that event triggers become mandatory, not optional, for the agent to do its job acceptably.
- Status: UNTESTED
- Evidence: (none)

## H-14  Provider usage numbers make work-per-dollar measurable and useful
- Claim: Recording per-run tokens and cost from provider usage numbers in an append-only run-ledger yields a work-per-dollar metric that actually drives decisions.
- Source: `archive/AGENT_ARCHITECTURE.md` §7 (Telemetry), inv. #5; §10 (Evaluation).
- Why we believe it: you cannot measure work per dollar without recording the dollar, and the harness (not the model) writing the record keeps it honest.
- Test: experiment 001. Capture tokens/cost per run from provider usage and compute work-per-dollar over the run. Observable signal: whether the metric ever changes an operator decision (cadence, model, autonomy, retire an agent).
- Refutes if: the work-per-dollar number is recorded but never informs a single decision across experiment 001, OR provider usage numbers are too coarse/unavailable to attribute cost per run.
- Status: SUPPORTED-but-thin (held through 001's conclusion). Every run's cost and tokens, including each gate corrective re-prompt, came straight from provider JSON, per-task and reproducible, never estimated. The number informed real decisions: judge spend exceeded agent spend (argues for a cheaper judge), and the gate's over-firing was quantified as real spend rather than asserted. Provider numbers were neither too coarse nor unavailable. Thin because the decisions so far are about the *eval rig's* cost, not yet an operator changing an agent's cadence/model/autonomy or retiring an agent on a work-per-dollar basis; and cost-vs-brain-scale is unmeasured (carry-forward).
- Evidence: `results/2026-06-16-exp001-iter2.md` (concluding run, costs incl. corrective passes); `results/2026-06-16-exp001-full-suite.md`; `experiments/001-personal-assistant/results/scorecard.md`.

## H-15  Degrade-to-plain-text holds: the system is useful stripped bare
- Claim: Delete the index, tooling, queue, and logs and the knowledge area remains a valid, readable account a human can use, with no hidden dependency on the tools.
- Source: `archive/AGENT_ARCHITECTURE.md` inv. #9; `archive/BRAIN_ARCHITECTURE.md` inv. #7, §10.
- Why we believe it: the files are the truth and tools only index them, so removing the tools should lose convenience, not correctness.
- Test: Take a running brain, strip the index/tooling/runtime, open the knowledge area raw. Observable signal: whether it is still a coherent, current account a human can read and whether any canonical fact lived only inside a tool.
- Refutes if: stripping the tooling leaves the knowledge area incoherent or stale, OR any canonical fact turns out to have lived only in an index/database rather than in the files.
- Status: UNTESTED
- Evidence: (none)

## H-16  A prose write/escalation contract is not self-enforcing; behavior needs a checked harness step
- Claim: Stating the brain's operating contract in the role/system prompt ("escalate by writing a `runtime/queue/approvals/` artifact, never by asking the user"; "file via `./bin/brain`, never hand-edit `knowledge/`") is NOT sufficient on its own to make a strong model follow it; reliable compliance needs a checked harness step (a gate, validator, or refused write path), not just instruction text.
- Source: experiment 001 full suite, `results/2026-06-16-exp001-full-suite.md` (T5, T8 failures); relates to H-05 (role-text sufficiency), H-08 (escalation mechanism vs. taxonomy).
- Why we believe it: the model reasons correctly about *what* to do (it found the T5 conflict, never silently mutated the calendar, never wired the T7 money, never fabricated the T9 number) but unreliably follows *how* to record it, preferring conversational deferral or direct edits over the prescribed artifact/write path. Reasoning is strong; contract-following is weak. The miss was robust (0/3 on both T5 and T8), so it is a stable behavioral gap, not noise.
- Test: keep the contract in prose only and measure the write-contract compliance rate (escalations written as approval artifacts; filings done via `./bin/brain` with no hand-edits to `knowledge/`) across the suite; then add a checked harness step (validator or gate) and re-measure on the same tasks. Observable signal: compliance rate prose-only vs. with the checked step.
- Refutes if: prose-only compliance is already at or near 100% across a non-trivial set of escalation/filing tasks (i.e. the instruction text alone suffices), OR adding the checked harness step yields no improvement in compliance. Note: the first refute clause is already contradicted by T5/T8 (0/3 each), so refutation would require a much larger prose-only sample showing those were anomalies.
- Status: SUPPORTED-but-thin (held through 002, NOT advanced by it). 001 supported both legs with a named precision caveat. Leg 1 (prose-only insufficient): a robust prose-only 0/3 escalation-artifact failure (T5). Leg 2 (a checked harness step is what fixes it): supported. The `escalation` gate made escalation happen at all, flipping T5 from a prose-only 0/3 to passing under the corrective re-prompt with NO correctness regression on the baseline passers. (The T8 "hand-edit" miss read as a contract failure under the old mechanism-based scorer; outcome scoring later showed the agent had filed correctly via logged `./bin/brain update` all along, so T8 was an eval-rig false failure, not a contract miss the gate had to catch. This sharpens, not weakens, leg 2: prose was insufficient for the escalation artifact specifically.) Precision caveat (the real-but-minor limitation 001 surfaced): the 001 gate keys on deferral VOCABULARY not on consequence (false-positives on reversible tasks T3/T4/T6/T8/T10 at real spend), and its generic "write an approval file" correction can write the artifact about the WRONG task (T5 trials wrote a wire-scam artifact instead of the pickup), so the gate's "resolved" signal can diverge from task correctness, leaving T5 flaky. **002 (code-gate vs agent-checker) did NOT advance H-16**: both enforcement mechanisms passed dev and held-out at 100% with zero safety-floor failures, but the benchmark never stressed the contract. A1's code-gate fired 0 times across all 24 trials (its 001 over-firing weakness did not even surface); A2's agent-checker bounced exactly once (dev D3, recovering a would-be miss the doer would have failed by asking a clarifying question instead of writing the artifact). So both enforce correctly here and neither broke, but the cut is too thin to rank code-gate vs agent-checker on precision or generalization, and 002 ran no prose-only null to re-confirm leg 1 at the larger brain. Net: a checked enforcement step (gate OR checker) beats prose for the escalation contract (001 evidence), an agent-checker is a viable second mechanism that recovered one real under-action (002 evidence), but which enforcement mechanism is better, and at what difficulty the difference shows, is unresolved. Resolving it needs contract-stressing tasks (ambiguous escalation to make the gate over-fire; on-topic/off-topic traps to test the checker's topic-awareness), 1:1 task-kind coverage across worlds, 3 trials, and a prose-only A3 null. SUPPORTED-but-thin, not proven.
- Evidence: `results/2026-06-16-exp001-iter2.md` (concluding run + TAKEAWAY); `results/2026-06-16-exp001-full-suite.md` (prose-only baseline); `results/2026-06-16-exp001-h16-gate.md` and `experiments/001-personal-assistant/results/scorecard-h16-gated.md` (gated re-run); `experiments/002-capable-personal-assistant/results/2026-06-16-exp002-lean.md` and `experiments/002-capable-personal-assistant/results/scorecard-002-lean.md` (002 lean tournament: code-gate vs agent-checker, INCONCLUSIVE ranking).

## H-17  A system tuned on a dev world generalizes to an unseen held-out world (the overfitting check)
- Claim: An architecture iterated only against a visible dev world (persona, inbox, calendar) carries its pass rate to a blind-authored, never-inspected held-out world; a small dev-vs-held-out generalization gap means the system learned the task, not the world.
- Source: experiment 002 charter ("New: does a system tuned on the dev world generalize to an unseen held-out world"); `experiments/PROCESS.md` (Validity: dev/held-out split, multiple worlds, blind authoring).
- Why we believe it: the architecture encodes general mechanisms (file brain, plain-text retrieval, a checked enforcement step), none keyed to a specific entity or message, so a different persona's data should exercise the same machinery with the same outcomes.
- Test: experiment 002 (and every multi-world experiment after). Iterate only on dev; run held-out once at conclusion; report the gap. Observable signal: the dev-vs-held-out pass-rate gap per architecture.
- Refutes if: the held-out pass rate is materially below the dev pass rate (a large generalization gap) for an architecture that met the dev bar, i.e. the system memorized the dev world; OR no held-out world is ever actually run blind.
- Status: SUPPORTED-but-thin. 002 reported a 0-point gap for both A1 (dev 100% / held-out 100%) and A2 (dev 100% / held-out 100%) across two worlds (Marisol Vega dev, Julian Reyes held-out, the latter blind-authored and run only at conclusion). No overfitting detected. Thin and qualified: only 2 trials, only one held-out world, held-out has 5 task kinds vs dev's 6 (no judgment analogue), and a 100%-vs-100% result on an easy benchmark is weak evidence of generalization, since a benchmark that nothing fails cannot show a *gap* either way. The mechanism (blind authoring, never-inspected held-out, gap reporting) worked; the difficulty was too low to stress it. Needs a harder benchmark and a second held-out world to advance.
- Evidence: `experiments/002-capable-personal-assistant/results/2026-06-16-exp002-lean.md`; `experiments/002-capable-personal-assistant/results/scorecard-002-lean.md`.

## H-18  A divergent-architecture tournament only ranks the bets if the benchmark stresses them
- Claim: Putting divergent architectures on one fixed benchmark produces a ranking only when the benchmark is hard enough that at least one bet's weakness surfaces; an easy benchmark on which every bet passes is a null result that validates the rig but cannot pick a winner.
- Source: experiment 002 (A1 code-gate vs A2 doer+checker both 100%, no separation); `experiments/PROCESS.md` (Divergence: "a surprising failure or success teaches more than another small step").
- Why we believe it: a tournament discriminates on observed failures and observed waste; if no architecture's known weakness (A1's gate over-firing, A2's checker cost being unjustified) is triggered, every bet looks equal and cost becomes the only signal, which PROCESS.md forbids using as a disqualifier. The failure mode 002 surfaced is real: we built two divergent bets and learned the benchmark, not the bets, was the binding constraint.
- Test: every divergent tournament. Pre-register, alongside the bets, the specific tasks designed to trigger each bet's hypothesized weakness; after the run, check whether any architecture actually fired its gate/checker/failure path. Observable signal: did at least one architecture diverge in outcome (pass/fail, safety, or material cost) on at least one task; if all converge, the tournament is non-discriminating.
- Refutes if: a tournament with pre-registered weakness-triggering tasks still produces separation between divergent architectures that is fully explained by random trial variance (i.e. difficulty is not the binding constraint; the bets genuinely do not differ), OR the rig cannot be made to discriminate even with adversarially hard tasks (the architectures are truly equivalent).
- Status: SUPPORTED-but-thin (new, from 002). 002 is a clean instance: A1 and A2 tied at 100%/100% with 0 safety failures because the benchmark never made A1's gate over-fire (0 fires / 24 trials) or made A2's checker cost worth its overhead (1 bounce, recovered 1 dev trial). The machinery was sound; the difficulty was the limiting factor. The lesson is methodological: a divergent tournament must ship with tasks that target each bet's weakness, or it cannot rank. Carries directly into the fuller 002-scale run.
- Evidence: `experiments/002-capable-personal-assistant/results/2026-06-16-exp002-lean.md`; `experiments/002-capable-personal-assistant/results/scorecard-002-lean.md`.
