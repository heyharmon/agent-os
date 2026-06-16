#!/usr/bin/env python3
"""compare.py: the tournament comparison emitter.

Reads the per-task score.json files that run-arch.sh wrote under
runtime/results/<ARCH>/<WORLD>/<task_id>/score.json and prints a table: per
architecture, the pass rate on the dev world, the held-out pass rate (filled in
later when worlds/heldout exists and has been run), the generalization gap
(dev - heldout), the median agent cost, and the checker/gate cost.

COST IS A REPORTED SIGNAL, not a pass/fail gate (per the charter). The headline
the experiment cares about is the held-out pass rate and the dev-vs-held-out
gap; cost is a tiebreaker.

Usage:
  compare.py --archs A1,A2 [--world dev] [--heldout heldout]
The dev world defaults to 'dev'; the held-out world defaults to 'heldout' and is
simply reported as "(not run)" until that world exists and has been run.
"""
import os
import sys
import json
import argparse
import pathlib

EXP_DIR = pathlib.Path(__file__).resolve().parent.parent
RESULTS = EXP_DIR / "runtime" / "results"


def load_world(arch, world):
    """Aggregate one (arch, world): pass rate + cost signals across its tasks."""
    base = RESULTS / arch / world
    if not base.exists():
        return None
    tasks = []
    for d in sorted(base.iterdir()):
        sj = d / "score.json"
        if sj.is_file():
            try:
                tasks.append(json.loads(sj.read_text()))
            except ValueError:
                pass
    if not tasks:
        return None
    n = len(tasks)
    n_pass = sum(1 for t in tasks if t.get("pass"))

    def s(key):
        vals = [t.get(key) for t in tasks if isinstance(t.get(key), (int, float))]
        return round(sum(vals), 6) if vals else 0.0

    return {
        "n_tasks": n,
        "n_pass": n_pass,
        "pass_rate": (n_pass / n) if n else 0.0,
        "agent_cost_total": s("cost_usd"),
        "checker_cost_total": s("checker_cost_usd_total"),
        "gate_cost_total": s("gate_cost_usd_total"),
        "judge_cost_total": s("judge_cost_usd_total"),
        "flaky": [t["task_id"] for t in tasks if t.get("flaky")],
        "fails": [t["task_id"] for t in tasks if not t.get("pass")],
    }


def pct(x):
    return f"{round(100*x)}%" if x is not None else "n/a"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--archs", default="A1,A2")
    ap.add_argument("--world", default="dev")
    ap.add_argument("--heldout", default="heldout")
    args = ap.parse_args()
    archs = [a.strip() for a in args.archs.split(",") if a.strip()]

    rows = []
    for arch in archs:
        dev = load_world(arch, args.world)
        held = load_world(arch, args.heldout)
        rows.append((arch, dev, held))

    # Header.
    cols = ["arch", f"{args.world} pass", "heldout pass", "gen gap",
            "agent $", "checker/gate $", "judge $ (excl)"]
    widths = [6, 12, 12, 9, 10, 16, 16]
    def fmt(vals):
        return " | ".join(str(v).ljust(w) for v, w in zip(vals, widths))
    print(fmt(cols))
    print("-+-".join("-" * w for w in widths))

    for arch, dev, held in rows:
        if dev is None:
            print(fmt([arch, "(not run)", "", "", "", "", ""]))
            continue
        dev_pr = dev["pass_rate"]
        dev_cell = f"{pct(dev_pr)} ({dev['n_pass']}/{dev['n_tasks']})"
        if held is None:
            held_cell = "(not run)"
            gap_cell = "n/a"
        else:
            held_pr = held["pass_rate"]
            held_cell = f"{pct(held_pr)} ({held['n_pass']}/{held['n_tasks']})"
            gap_cell = f"{round(100*(dev_pr - held_pr))} pts"
        # Enforcement cost: checker (A2) or gate corrective (A1); show the one in play.
        enf = dev["checker_cost_total"] + dev["gate_cost_total"]
        print(fmt([
            arch, dev_cell, held_cell, gap_cell,
            f"${dev['agent_cost_total']:.4f}",
            f"${enf:.4f}",
            f"${dev['judge_cost_total']:.4f}",
        ]))

    print()
    print("Notes:")
    print("- Cost is a REPORTED signal and tiebreaker, never a pass/fail gate.")
    print("- 'agent $' = total median doer cost incl. any corrective re-prompt.")
    print("- 'checker/gate $' = A2 checker-agent cost, or A1 gate corrective cost.")
    print("- 'judge $ (excl)' = scoring-judge cost; excluded from architecture cost.")
    print("- Held-out columns fill in once worlds/heldout exists and is run.")
    for arch, dev, held in rows:
        if dev and (dev["flaky"] or dev["fails"]):
            print(f"- {arch} {args.world}: fails={dev['fails']} flaky={dev['flaky']}")


if __name__ == "__main__":
    main()
