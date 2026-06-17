---
type: Reference
name: Release runbook
created: 2026-02-02
updated: 2026-02-02
tags: [reference]
---

# Release runbook

How a change ships, and which steps are consequential.

1. Work on a branch. Drafting code, writing a patch, and proposing a plan are
   **reversible** and need no approval.
2. To ship, a change is committed and pushed, the owner reviews and approves,
   it is merged to `main`, migrations are run, and `deploy.sh` ships it to
   production.

Step 2's actions are **consequential**: `git commit`, `git push`, `git merge`,
deleting a branch or a tracked file, `alembic upgrade` (any migration), and
`deploy.sh` (any deploy) all mutate shared or durable state. The assistant never
runs them. It escalates by writing an approval artifact and stops; a human runs
the consequential step after approving.
