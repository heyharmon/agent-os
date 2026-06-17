#!/usr/bin/env python3
"""compare.py: the tournament comparison emitter for experiment 006.

Reads the per-task score.json files run-arch.sh wrote under
runtime/results/<ARCH>/<WORLD>/<task_id>/score.json and prints a table: per
architecture (S, P, M), the pass rate on the dev world, the held-out pass
rate (filled in when worlds/heldout has been run), the generalization gap
(dev - heldout, H-17), median agent cost, and judge cost (excluded from
architecture cost). The enforcement gate is deprecated; there is no gate cost
column.

COST IS A REPORTED SIGNAL, not a pass/fail gate (charter + PROCESS.md). The
headline is the held-out pass rate and the dev-vs-held-out gap; cost is a
tiebreaker and a runaway-waste flag, framed against human labor.

Usage:
  compare.py --archs S,P,M [--world dev] [--heldout heldout]
"""
import os
import sys
import json
import argparse
import pathlib

EXP_DIR = pathlib.Path(__file__).resolve().parent.parent
RESULTS = EXP_DIR / "runtime" / "results"


def load_world(arch, world):
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
        "judge_cost_total": s("judge_cost_usd_total"),
        "flaky": [t["task_id"] for t in tasks if t.get("flaky")],
        "fails": [t["task_id"] for t in tasks if not t.get("pass")],
    }


def pct(x):
    return f"{round(100*x)}%" if x is not None else "n/a"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--archs", default="S,P,M")
    ap.add_argument("--world", default="dev")
    ap.add_argument("--heldout", default="heldout")
    args = ap.parse_args()
    archs = [a.strip() for a in args.archs.split(",") if a.strip()]

    rows = []
    for arch in archs:
        dev = load_world(arch, args.world)
        held = load_world(arch, args.heldout)
        rows.append((arch, dev, held))

    cols = ["arch", f"{args.world} pass", "heldout pass", "gen gap",
            "agent $", "judge $ (excl)"]
    widths = [6, 14, 14, 9, 11, 16]
    def fmt(vals):
        return " | ".join(str(v).ljust(w) for v, w in zip(vals, widths))
    print(fmt(cols))
    print("-+-".join("-" * w for w in widths))

    for arch, dev, held in rows:
        if dev is None:
            print(fmt([arch, "(not run)", "", "", "", ""]))
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
        print(fmt([
            arch, dev_cell, held_cell, gap_cell,
            f"${dev['agent_cost_total']:.4f}",
            f"${dev['judge_cost_total']:.4f}",
        ]))

    print()
    print("Notes:")
    print("- Cost is a REPORTED signal and tiebreaker, never a pass/fail gate.")
    print("- 'agent $' = total median agent cost summed across the arm's roles.")
    print("- 'judge $ (excl)' = scoring-judge cost; excluded from architecture cost.")
    print("- Arms: S=A_single, P=A_2pass (fresh-context validation), "
          "M=A_multi (scoped roles).")
    print("- Held-out columns fill in once worlds/heldout exists and is run.")
    for arch, dev, held in rows:
        if dev and (dev["flaky"] or dev["fails"]):
            print(f"- {arch} {args.world}: fails={dev['fails']} flaky={dev['flaky']}")


if __name__ == "__main__":
    main()
