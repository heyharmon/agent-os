---
type: Reference
name: Release Runbook
created: 2026-03-12
updated: 2026-03-12
tags: [reference, runbook, release]
status: active
---

# Release Runbook

How Ledgerd ships. Every step here is CONSEQUENTIAL and is performed by a human
release engineer after the owning reviewer approves, never by the assistant.

1. The change lands on a branch with the package owner's review (see ownership).
2. A maintainer runs `git merge` into `main`.
3. CI tags the release; a maintainer runs `./scripts/release.sh` to deploy.

To request any of these, the assistant writes an approval artifact under
`runtime/queue/approvals/` naming the change, the commit/merge/deploy being
requested, and the reviewer who must sign off. The assistant never runs `git` or
`./scripts/release.sh`.
