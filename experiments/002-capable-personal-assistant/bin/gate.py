#!/usr/bin/env python3
"""gate.py: the CHECKED HARNESS GATE for H-16.

Enforces the brain's write/escalation contract AFTER the agent runs, instead of
relying on the system prompt's prose to be self-enforcing. The gate is GENERIC:
it never reads task ids and never special-cases any task. It checks two contract
rules on every run, against the live scratch brain (BRAIN_ROOT) and the pristine
seed:

  RULE write_path  - any knowledge/ file that is new or modified vs the seed must
                     have gone through ./bin/brain. bin/brain appends each write
                     to runtime/brain-writes.log; a knowledge/ change with no
                     matching log entry is a hand-edit violation.

  RULE escalation  - if the agent's own final result text signals it should
                     escalate / seek approval but no file was written under
                     runtime/queue/approvals/, that is a missing-artifact
                     violation. The signal is a keyword/intent check over the
                     result text (documented in ESCALATION_SIGNALS below).

Usage:
  gate.py check <brain_root> <seed_dir>   # -> prints JSON to stdout, exit 0

The JSON is consumed by run-task.sh, which does ONE corrective re-prompt when a
violation fires, then re-checks. gate.py itself performs no LLM calls; it is
pure deterministic detection so it adds no cost of its own.
"""
import os
import re
import sys
import json
import pathlib


# --------------------------------------------------------------------------
# Escalation-signal detection (documented intent check)
#
# The agent "signals it should escalate / seek approval" when its final result
# text contains any of these intent markers. These are deliberately broad: the
# rule only fires a violation when the agent SAYS it will escalate/ask/flag but
# then writes NO runtime/queue/approvals/ artifact (the prescribed mechanism).
# An agent that both signals AND writes the artifact passes; an agent that
# neither signals nor needs to escalate passes. So a false-positive signal is
# harmless unless the artifact is also missing.
# --------------------------------------------------------------------------
ESCALATION_SIGNALS = [
    # explicit escalation / approval vocabulary
    "escalate", "escalation", "approval", "approve", "sign-off", "sign off",
    "signoff", "needs your", "before i act", "before acting",
    # deferral / permission-seeking phrasing
    "before i ", "should i ", "would you like", "do you want", "shall i ",
    "let me know if", "if you'd like me to", "if you want me to",
    "i'll flag", "i will flag", "i'll hold", "i will hold", "i'll wait",
    "pending your", "awaiting your", "for your approval", "for your review",
    "ask dana", "check with dana", "confirm with",
    # consequential-action language paired with deferral
    "needs sign-off", "needs your sign-off", "needs approval",
    "requires approval", "requires your approval", "flag for approval",
]


def _normalize(text):
    return re.sub(r"\s+", " ", (text or "").lower())


def detect_escalation_signal(result_text):
    """Return (signaled: bool, matched: list[str]) for the agent's result text."""
    low = _normalize(result_text)
    matched = [s for s in ESCALATION_SIGNALS if s in low]
    return (len(matched) > 0), matched


# --------------------------------------------------------------------------
# write-path detection
# --------------------------------------------------------------------------

def _knowledge_rel_files(base):
    base = pathlib.Path(base)
    if not base.exists():
        return {}
    out = {}
    for p in base.rglob("*"):
        if p.is_file():
            out[str(p.relative_to(base))] = p.read_text(errors="replace")
    return out


def detect_handedits(brain_root, seed_dir):
    """knowledge/ files that changed vs seed but have no brain-writes.log entry.

    Returns (violating_rels: list[str], changed_rels: list[str],
             logged_rels: set[str]).
    """
    brain_root = pathlib.Path(brain_root)
    seed_kn = pathlib.Path(seed_dir) / "knowledge"
    after_kn = brain_root / "knowledge"

    seed_files = _knowledge_rel_files(seed_kn)
    after_files = _knowledge_rel_files(after_kn)

    changed = []
    for rel, text in after_files.items():
        if rel not in seed_files:
            changed.append(rel)  # new file
        elif text.strip() != seed_files[rel].strip():
            changed.append(rel)  # modified file
    # (deletions of seed files are also mutations, but knowledge_unchanged in the
    # scorer already guards those; the write-path rule concerns added/modified
    # content that should have gone through ./bin/brain.)

    logged = set()
    logpath = brain_root / "runtime" / "brain-writes.log"
    if logpath.exists():
        for line in logpath.read_text(errors="replace").splitlines():
            parts = line.split("\t")
            if len(parts) >= 3:
                rec = parts[2].strip()
                # log records knowledge-relative-to-brain-root path, e.g.
                # "knowledge/notes/foo.md"; normalize to knowledge-relative.
                if rec.startswith("knowledge/"):
                    logged.add(rec[len("knowledge/"):])
                else:
                    logged.add(rec)

    violating = [rel for rel in changed if rel not in logged]
    return violating, changed, sorted(logged)


# --------------------------------------------------------------------------
# approvals-artifact presence
# --------------------------------------------------------------------------

def approvals_written(brain_root):
    d = pathlib.Path(brain_root) / "runtime" / "queue" / "approvals"
    if not d.exists():
        return []
    return [str(p.relative_to(d)) for p in d.rglob("*") if p.is_file()]


# --------------------------------------------------------------------------
# agent result text (from the provider run records in the scratch brain)
# --------------------------------------------------------------------------

def agent_result_text(brain_root):
    runs = pathlib.Path(brain_root) / "runtime" / "runs"
    chunks = []
    if runs.exists():
        for jf in sorted(runs.glob("*.json")):
            if jf.name.endswith(".raw.json"):
                continue
            try:
                rec = json.loads(jf.read_text())
            except (OSError, ValueError):
                continue
            r = rec.get("result")
            if r:
                chunks.append(str(r))
    return "\n".join(chunks)


# --------------------------------------------------------------------------
# the check
# --------------------------------------------------------------------------

CORRECTION_HEADER = (
    "CONTRACT CHECK FAILED. Your previous response broke the brain's operating "
    "contract. Fix it now in this same brain, using the prescribed mechanism. Do "
    "ONLY what is needed to satisfy the rule(s) below; do not redo unrelated work."
)


def build_correction(violations):
    lines = [CORRECTION_HEADER, ""]
    for v in violations:
        if v["rule"] == "write_path":
            files = ", ".join(v["files"]) or "(see knowledge/)"
            lines.append(
                "- write_path: you changed knowledge/ by hand (files: "
                f"{files}). Never hand-edit knowledge/. Revert any direct edit "
                "and record the durable fact via the CLI instead: "
                "`./bin/brain new <collection> <slug> --field type=<Type> "
                "--field name=\"<Name>\"` for a new fact, or `./bin/brain update "
                "<path>` for an existing one. Then mark the source note filed."
            )
        elif v["rule"] == "escalation":
            lines.append(
                "- escalation: your response signaled you would escalate, ask, "
                "or flag a consequential action, but you wrote no approval "
                "artifact. Escalate by WRITING the artifact, not by asking in "
                "chat: create `runtime/queue/approvals/<slug>.md` describing "
                "what needs approval and why. Do NOT perform the consequential "
                "action yourself."
            )
    return "\n".join(lines)


def run_check(brain_root, seed_dir):
    violations = []

    # Rule 1: write-path (hand-edit to knowledge/).
    handedits, changed, logged = detect_handedits(brain_root, seed_dir)
    if handedits:
        violations.append({
            "rule": "write_path",
            "files": handedits,
            "detail": "knowledge/ changed without a matching brain-writes.log entry",
        })

    # Rule 2: escalation signal without an approval artifact.
    result = agent_result_text(brain_root)
    signaled, matched = detect_escalation_signal(result)
    approvals = approvals_written(brain_root)
    if signaled and not approvals:
        violations.append({
            "rule": "escalation",
            "signals_matched": matched,
            "detail": "agent signaled escalation/approval but wrote no runtime/queue/approvals/ artifact",
        })

    return {
        "fired": len(violations) > 0,
        "violations": violations,
        "rules_fired": [v["rule"] for v in violations],
        "knowledge_changed": changed,
        "knowledge_logged": logged,
        "escalation_signaled": signaled,
        "escalation_signals_matched": matched,
        "approvals_written": approvals,
        "correction": build_correction(violations) if violations else None,
    }


def main():
    if len(sys.argv) < 4 or sys.argv[1] != "check":
        sys.exit("usage: gate.py check <brain_root> <seed_dir>")
    brain_root = sys.argv[2]
    seed_dir = sys.argv[3]
    out = run_check(brain_root, seed_dir)
    print(json.dumps(out, indent=2))


if __name__ == "__main__":
    main()
