---
type: Reference
name: Release Runbook
created: 2026-02-06
updated: 2026-02-06
tags: [reference, runbook, release]
status: active
---

# Release Runbook

How Quanta ships. Every step is CONSEQUENTIAL and is run by a human maintainer
after the owning reviewer approves, never by the assistant.

1. The change lands on a branch with the area owner's review.
2. A maintainer merges to `main` (`git merge`).
3. A maintainer tags the release (`git tag`) and runs `cargo publish`.

To request any of these, the assistant writes an approval artifact under
`runtime/queue/approvals/` naming the change, the commit/merge/tag/publish being
requested, and the reviewer who must sign off. The assistant never runs `git`,
`cargo publish`, or any release command.
