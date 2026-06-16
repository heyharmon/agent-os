# Finding 002 (lean cut): the anti-overfit + tournament machinery works; the A1-vs-A2 ranking is inconclusive

**Headline: This lean cut validated the experiment machinery end to end (dev/held-out split, two worlds, blind held-out authoring, a divergent-architecture tournament, generalization-gap reporting, cost-as-signal, findings publication). It did NOT produce a usable architecture ranking: a single-agent code-gate (A1) and a doer+checker pair (A2) both passed dev and held-out at 100% with zero safety failures, because the benchmark was too easy to stress either bet. The load-bearing lesson: a divergent tournament only ranks the bets if the tasks are hard enough to trigger each bet's weakness.**

Status: machinery VALIDATED-but-thin; A1-vs-A2 INCONCLUSIVE. Two worlds, 2 trials each, blind-authored held-out. This page documents a machinery-validation result, not a consumable architecture recommendation. For a basic single-agent PA, [001](./001-basic-personal-assistant.md) remains the starting point; 002 did not change it.

---

## What this was

A deliberately lean first cut at one notch up the spectrum: a single-user PA with a richer brain, run as a head-to-head tournament between two divergent ways of enforcing the write/escalation contract. Its primary job was to validate the anti-overfit and tournament machinery cheaply before scaling it up.

Charter: `experiments/002-capable-personal-assistant/charter.md`
Run record + takeaway: `experiments/002-capable-personal-assistant/results/2026-06-16-exp002-lean.md`
Scorecard (all costs from provider JSON): `experiments/002-capable-personal-assistant/results/scorecard-002-lean.md`

---

## The two bets

- **A1, single agent + code-gate** (carried from 001): one agent, file brain, plain-text retrieval, a deterministic harness gate enforcing the escalation-artifact and write-via-CLI contract. Known weakness: the gate is topic-blind and over-fires on phrasing.
- **A2, doer + checker** (two-agent, divergent): one agent does the work; a separate checker agent reviews actions against the contract (escalation artifact present AND on-topic, writes via CLI) and bounces a correction if not. Expected more capable but more expensive; a first step toward multi-agent.

---

## Result

| arch | dev pass | held-out pass | generalization gap | safety-floor failures |
|---|---|---|---|---|
| A1 (single + code-gate) | 100% (6/6) | 100% (5/5) | 0 pts | 0 |
| A2 (doer + checker) | 100% (6/6) | 100% (5/5) | 0 pts | 0 |

Both pass the held-out bar with a 0-point generalization gap and zero safety failures. On correctness + safety + generalization (the ranking axes), they are tied.

---

## Why the ranking is inconclusive

The benchmark did not stress either bet:

- **A1's code-gate fired 0 times across all 24 trials.** 001's known weakness (topic-blind over-firing on escalation phrasing) never even surfaced, so we did not observe the precision cost that would count against A1.
- **A2's checker fired exactly once** (dev D3, trial 2): the doer asked a clarifying question instead of writing the approval artifact; the checker caught the missing artifact, bounced one correction, and the doer filed an on-topic approval. That trial would have failed `approval_file_written` without the bounce, so the checker recovered a would-be dev miss A1's task happened not to hit. One recovered trial on the visible dev world is a signal, not a generalization result; it did not recur on held-out.

Cost is the only separating signal, and per `experiments/PROCESS.md` cost is a tiebreaker, never a disqualifier. A2's checker roughly doubles enforcement spend (~$0.84 dev / ~$0.63 held-out) for one recovered dev trial here. Framed against the human-labor value of the task (cents-to-a-third-of-a-dollar per task vs minutes-to-tens-of-minutes of assistant work), cost is not binding at this maturity. So cost favors A1 marginally, but on a benchmark that stressed neither, that does not declare a winner.

**A divergent bet that does not get stressed is not a failed bet; it is a benchmark that failed to discriminate.** A2 did not break (zero safety failures, recovered one trial). A1 did not break (zero failures, zero waste). The evidence cannot rank them.

---

## The load-bearing lesson

**A divergent-architecture tournament only ranks the bets if the benchmark is hard enough to trigger at least one bet's weakness.** Both architectures passing at 100% validates that the rig runs and that neither bet is broken, but a benchmark nothing fails cannot pick a winner, and cannot show a generalization gap either way. The difficulty, not the rig, was the binding constraint. This is now a hypothesis in its own right (H-18) and the central design requirement for the fuller 002-scale run: ship the tournament with tasks that target each bet's hypothesized weakness, or it cannot discriminate.

---

## What the machinery proved (this was the point)

Every anti-overfit and tournament mechanism the charter named ran and produced a coherent, provider-JSON-backed result:

| Mechanism | Worked? | Detail |
|---|---|---|
| Dev/held-out split | Yes | Tuned only on dev; held-out run once at conclusion. |
| Two worlds from one template | Yes | Marisol Vega (dev), Julian Reyes (held-out), different persona/data. |
| Blind held-out authoring | Yes | H1-H5 authored by an agent told only the use case and persona shape, not the architectures or scoring. |
| Divergent tournament | Ran, but non-discriminating | A1 vs A2 on one fixed benchmark; both passed (see above). |
| Generalization-gap reporting | Yes | 0-pt gap computed and reported per architecture. |
| Cost-as-signal | Yes | Every figure from provider JSON, framed vs human labor, never gated. |
| Findings publication | Yes | This page + the spectrum map + the run record + scorecard. |

What was thin or wasteful, stated plainly: the benchmark was too easy to separate the bets; held-out has 5 task kinds vs dev's 6 (no judgment analogue, so the comparison is not 1:1); 2 trials is too few for variance; and no prose-only null was run to re-confirm 001's leg-1 finding at the larger brain.

---

## What this does not establish

- **An A1-vs-A2 winner.** Inconclusive. Resolving it needs contract-stressing tasks (ambiguous escalation to make A1's gate over-fire; on-topic/off-topic traps to test whether A2's checker topic-awareness is load-bearing), 1:1 task-kind coverage across worlds, 3 trials, a second held-out world, and an A3 prose-only null.
- **Generalization, strongly.** A 0-point gap on an easy benchmark is weak evidence; a benchmark nothing fails cannot show a gap either way (H-17 SUPPORTED-but-thin).
- **Anything new about the basic-PA blocks.** 001's verdicts stand unchanged; 002 did not re-test them under stress.

---

## What to do with this result

- If you are building a basic single-agent PA, ignore this page and use [001](./001-basic-personal-assistant.md). 002 did not change that recommendation.
- If you are designing a divergent-architecture comparison, take the lesson: pre-register, alongside the bets, the specific tasks meant to trigger each bet's weakness, and after the run verify at least one architecture actually fired its failure/enforcement path. If all bets converge, the benchmark is non-discriminating and the tournament cannot rank, no matter how clean the rig.
- Scaling 002 up (more worlds, harder tasks, more architectures, an A3 null) is an operator-level decision. The lean cut did its job: it validated the machinery cheaply and showed exactly what a fuller run must fix.
