# Building an Agentic Operating System: the evidence

**Last updated: 2026-06-17.** Source repo: [`heyharmon/aos-experiments`](https://github.com/heyharmon/aos-experiments).

This is the consolidated, evidence-backed reference for anyone building an agentic operating system. Every principle, pattern, and tip below traces to a run in this repo. Where the evidence is thin or absent, it says so. Nothing here is asserted on taste.

How to read the confidence labels (from `FINDINGS/building-blocks.md`):

- **PROVEN-ish (two domains)**: earned its place in two distinct domains, each still a lean cut.
- **SUPPORTED-but-thin**: one experiment supports it, single world, same authors wrote system and test.
- **SUPPORTED-but-narrow**: supported on one axis only; a related axis is untested.
- **INCONCLUSIVE**: ran, but the evidence does not settle it. A named follow-up is needed.
- **DEMOTED / NOT SUPPORTED**: a pre-registered refute condition was met, or the block fired zero useful times across every benchmark we could build.
- **UNTESTED**: in use, or hypothesized, but no controlled comparison was run.

Provenance: the authority for any claim is the linked run in `results/` or `experiments/*/results/`. The bets are in `HYPOTHESES.md`; the method is in `experiments/PROCESS.md`; the per-experiment writeups are in `FINDINGS/`. The pre-evidence architecture docs in `archive/` are provenance, not authority. Do not cite them as fact.

---

## TL;DR: what to build

For a basic single-agent assistant (personal-assistant or coding, proven across both domains), build exactly five blocks and nothing more:

```
  file brain  +  plain-text retrieval  +  binary reversible/escalate tag
              +  named role  +  provider-JSON cost measurement
```

Do NOT add a checked enforcement gate. Do NOT split into multiple agents. Do NOT add staged ingestion or a heartbeat loop expecting better outcomes. On every benchmark we could build, those cost 30 to 100 percent more and bought nothing measurable. The one exception we found: on tasks where a missing convention must be flagged rather than invented, add ONE scoped prompt guardrail (below).

The governing rule is the project ethos (`VISION.md`): **the best part is no part.** Subtract before adding. A block earns its place by beating the simpler thing on a benchmark hard enough to tell them apart, or it does not go in.

---

## Part 1: Principles

### P1. Start with the simplest architecture that could work, and make complexity earn its way in.
Across six experiments, the simplest arm won or tied every time a benchmark could not prove otherwise. Experiment 005 put a single agent against +agent-split, +staged-ingestion, and +heartbeat on a product-dev workload; every arm passed the held-out world 7/7 and none beat the rung below it, so the single agent won on simplicity (`FINDINGS/005-product-dev-os.md`). The burden of proof is on the added part.

### P2. The files are the truth. State lives in the brain; code is stateless.
All durable state lives in plain markdown files (the "brain"). The runner, harness, and provider are stateless code outside it. This is what makes the file brain hold up: every fact had a findable home across 30 runs in 001, and in 003 the same structure held two software projects' conventions, ADRs, ownership, and runbooks with no rework (`results/2026-06-16-exp003-lean.md`). Keep knowledge (durable) separate from runtime (transient exhaust); treat `runtime/` as disposable.

### P3. The model is a strong reasoner about consequences and an honest reporter of gaps. Build on that.
Repeatedly, the model reasoned correctly about what to do: it found conflicts, never silently mutated a calendar, never wired money, and reported true absences (a missing phone number, an undocumented convention) without fabricating (001 T9, 003 C4/CH4). Design the system to lean on this strength rather than to second-guess it.

### P4. State the operating contract in prose. Current frontier models self-enforce it.
The biggest reversal in this repo. We hypothesized a prose reversible/escalate contract was not self-enforcing and needed a checked harness gate (H-16). After three experiments the gate fired **zero useful times** (002: 0/24 trials; 003: 0/22) and on the one real breach would not have caught it. The model drafts the reversible part and escalates the consequential part from instruction text alone, even when explicitly tempted ("just commit", "just push", "delete the legacy file"). The gate is demoted as unnecessary overhead (`HYPOTHESES.md` H-16, resolved 2026-06-17).

> Honest caveat (do not overclaim): this is an *absence* of a fired enforcement path across every benchmark we could construct, NOT proof that prose suffices under adversarial stress. We could not build a benchmark that reliably induced the breach. If your domain has genuinely adversarial inputs, treat prose-only enforcement as unproven there and re-test.

### P5. Find the failure boundary, or you have learned nothing.
A benchmark where everything passes validates your rig and ranks nothing (H-18). Three straight tournaments (002, 003, 005) could not separate divergent architectures because no bet's weakness ever fired. Experiment 006 finally broke the streak by targeting a *real, observed* weakness (fabrication-into-knowledge) and verifying fail-capability before ranking, the single agent demonstrably failed, so a winner could be named (`FINDINGS/006-validation-separation.md`). Design tasks to break the system on the axis you care about.

### P6. Separate what arrived from what is true.
The one durable separation that earned its place: an authoring step must not invent a missing fact and commit it to durable knowledge. Everything else (separate sessions, fresh context, multi-agent splits) is unproven or refuted on our benchmarks.

### P7. Measure work per dollar from real provider numbers, not estimates.
Every cost figure across all experiments came straight from provider usage JSON, per task and per trial, reproducible (H-14). Real numbers drove real decisions (cut the judge when judge spend exceeded agent spend; quantify the gate's waste as actual dollars). You cannot manage work-per-dollar without recording the dollar, and the harness, not the model, must write the record.

### P8. Prove generalization with a blind held-out world. Report the gap as the headline.
Iterate only on a visible dev world; author a second world blind, never inspect it, and run it once at conclusion. Report the dev-vs-held-out pass-rate gap (H-17). A small gap means the system learned the task, not the world. The cleanest signal we got: in 006 the single agent's fabrication failure replicated *exactly* on the unseen world (0/2 both), no overfit, while the scoped arm passed both.

### P9. Automate the loop last.
Prove the experiment loop by hand before encoding it. Two throwaway experiments (003b, 004) were built and run on an unreliable rig outside the envelope and discarded without a scored crux; one hung in a runaway launcher loop. Hand-run discipline is what keeps findings honest.

---

## Part 2: Patterns that earned their place

### The file brain
Plain markdown: `knowledge/` for durable facts (conventions, decisions, ownership, personas, policies) and `runtime/` for transient exhaust (queues, approvals, inbox). No database, no vector store. Held across two domains (PA + coding), each thin. Evidence: 001, 003.

### Plain-text (ripgrep) retrieval
ripgrep over frontmatter and content. No embeddings, no graph layer. Zero retrieval-miss failures across 30 runs in 001; in 003 it passed its sternest test, grepping *code* rather than notes, finding the exact validation home, cap, and correct layer on two projects with zero misses (H-02). **Caveat: sufficiency at large brain scale is unmeasured.** A single-operator brain is small; lexical match has not been tested where scale would force vectors.

### The binary reversible/escalate tag
Tag every action as either reversible (act on it) or consequential (escalate by writing an approval artifact, never by performing it). No richer taxonomy. The split mapped cleanly onto "draft an email vs send it" and "draft a patch vs commit/push/delete" across four experiments and three domains, with zero safety-floor breaches and no operator ever wishing for a finer tag (H-08). **Caveat: the refute clause needs two-sided escalation traps (both over- and under-escalation) to fully settle; not yet exercised.**

### The named role
A scoped role file defining the agent's accountabilities, constraints, and capabilities. The agent never acted outside it across two domains. **Caveat: until 006, no experiment ran the unscoped do-everything baseline, so the role's *general* advantage is observed, not measured (H-05).** What 006 *did* prove is narrower, see below.

### The scoped no-fabrication authoring guardrail (the one piece of "separation" that paid)
A planner/author prompt scoped to: "flag a missing convention and escalate it; never fabricate one and file it to durable knowledge." On a fail-capable benchmark (006), this single guardrail was the only thing that stopped the agent from inventing a missing pagination convention and committing it as an ADR. The scoped arm passed the held-out fabrication trap 2/2 where both the plain single agent and a fresh-context second pass failed 0/2, with no over-escalation regression (`FINDINGS/006-validation-separation.md`, H-21 fabrication half). **This is one guardrail prompt on the single agent, not a multi-agent split.** Confidence: SUPPORTED-but-narrow (one axis, one cut).

### Brain-as-bus coordination (when you genuinely have 2+ agents)
Agents coordinate by reading and writing brain files only, no direct agent-to-agent calls and no out-of-brain channel. Held across two experiments with zero lost or duplicated work, including a same-method edit collision in 006 (H-03). **Caveat: never stressed to failure, the colliding edits were always mechanically reconcilable, so a genuinely irreconcilable conflict was never forced.** And note: 005/006 found no outcome advantage to having multiple agents at all on these benchmarks, so reach for this only once multi-agent has earned its place in your domain.

### Provider-JSON cost measurement
Per-run tokens and cost read directly from provider usage JSON, recorded per task and per trial including any corrective passes. Held across two domains. **Caveat: the decisions it has driven so far are about the eval rig's cost, not yet an operator changing an agent's cadence/model/autonomy on a work-per-dollar basis.**

---

## Part 3: Patterns that did NOT earn their place (on our benchmarks)

Subtract these unless your domain produces evidence they are needed.

| Pattern | Verdict | Why | Where |
|---|---|---|---|
| Checked enforcement gate | DEMOTED / NOT SUPPORTED | Fired 0 useful times across 002 (0/24) and 003 (0/22); would not have caught the one real breach (approval-presence suppressed its consequential rule, the H-20 blind spot). The model self-enforces from prose. | H-16, H-20 |
| Fresh-context second pass (same generalist) | NOT SUPPORTED on the fabrication axis | Pass-1 commits the fabrication to durable knowledge *before* the fresh pass looks, and a fresh pass cannot un-file it. Equalled the single agent on the axis that mattered, at ~2x the cost. | H-21, 006 |
| Multi-agent split (planner/builder/validator) | INCONCLUSIVE, leaning no-advantage | Tied the single agent 7/7 on every held-out task in 005, including the four designed to favor the split. The lone edge (fabrication) is better bought with one scoped prompt. | H-05, 005 |
| Staged ingestion agent | INCONCLUSIVE, leaning no-advantage | Inline parsing matched a dedicated ingestion agent on intake correctness; staged only added cost. (Recoverability under intake failure/flood was never tested.) | H-10, 005 |
| Heartbeat activation loop | INCONCLUSIVE | Matched one-shot arms at the highest cost. But never exercised: the benchmark had no sub-heartbeat-latency task, so the mode it exists for was not tested. | H-13, 005 |

A divergent bet that is never stressed is not a failed bet, it is a benchmark that failed to discriminate. "Did not earn its place" here means "showed no advantage on a benchmark that could not stress it," not "proven useless." If your use case has the pressure these patterns exist for (real concurrent-edit conflicts, sub-heartbeat latency, intake that floods or fails), re-test them.

---

## Part 4: Tips for running it honestly

1. **Score outcomes, not mechanism.** Assert on the outcome the operator cares about ("was the fact durably captured? was the gap admitted without fabrication?"), never on which command or wording the agent used. Two of experiment 001's three early "failures" were eval-rig false failures from scoring implementation choices, not behavior (`experiments/PROCESS.md`, Build step).
2. **Pre-register the refute condition before the run.** Every claim in `HYPOTHESES.md` carries a falsifiable "Refutes if" written before the test. A claim with no test, or no linked run in `results/`, is a hypothesis, not a finding.
3. **Pre-register the weakness-triggering tasks too.** Alongside each architecture bet, write the specific task meant to trigger that bet's weakness, then after the run verify at least one bet's failure path actually fired. If all bets pass, the benchmark is non-discriminating and ranks nothing (H-18).
4. **Author the held-out world blind and run it once.** Never inspect it before conclusion. Keep it byte-identical to its frozen seed before and after the run. Do not patch a scorer against held-out behavior (that is overfitting).
5. **Run hermetic.** A fresh scratch brain per trial, reset from seed. State leaking between trials hides real failures and invents fake ones.
6. **Do not weaken a task to force a pass.** A real failure is the result. Do not edit the agent's prompt or lower a task's expectation to get green.
7. **Writes go through the brain CLI.** Do not hand-edit the knowledge layer; route writes through the CLI so they are logged and repeatable.
8. **Let cost be a signal, not a disqualifier.** On a non-discriminating benchmark, the cheaper arm wins by the tie-rule, but you cannot use cost to kill a bet whose weakness was never stressed.

---

## Part 5: The spectrum and what is still open

The vision (`VISION.md`) maps use cases on a complexity spectrum and asks, at every point, "what is the simplest architecture that reliably does the job?"

```
basic -----------------------------------------------------> sophisticated

single-agent assistant        product-dev OS,             multi-agent OS,
(PA, coding):                  ingest/plan/build/          many tools, rich
the 5-block composition        validate as MODES in        coordination, autonomy
PROVEN-ish in 2 domains        ONE agent (005)             [largely UNTESTED]
                               + 1 no-fabrication
                               guardrail (006)
```

What we have evidence for sits at the basic-to-lower-middle of the spectrum. The sophisticated end is mostly open. Notable UNTESTED hypotheses (`HYPOTHESES.md`): the self-improvement loop (H-01), the autonomy dial's granularity (H-04), nightly "dreaming" consolidation (H-06), runner/provider swap (H-09), the tool/account/grant model (H-11), the six-planes decomposition (H-12), and degrade-to-plain-text (H-15).

The honest summary as of 2026-06-17: **the basic single-agent file-brain composition is the proven starting point, climbing the spectrum has not yet bought measurable outcome gains on any benchmark we built, and the binding constraint on every ranking has been building benchmarks hard enough to tell architectures apart.** Build the simplest thing, instrument it with real cost, find where it breaks on your own held-out world, and add a part only when it beats the simpler thing on that boundary.

---

*This document summarizes findings from experiments 001 through 006 in [`heyharmon/aos-experiments`](https://github.com/heyharmon/aos-experiments). For the underlying evidence see `HYPOTHESES.md`, `FINDINGS/`, `CHANGELOG.md`, and the per-experiment `results/` directories. When the experiments advance, update this file and re-date it.*
