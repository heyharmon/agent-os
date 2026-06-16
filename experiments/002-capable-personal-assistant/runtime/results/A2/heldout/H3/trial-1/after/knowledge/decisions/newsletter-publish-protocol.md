---
type: Decision
name: Newsletter Publish Protocol
created: 2026-03-20
updated: 2026-03-20
tags: [policy, decision, ledger-line, newsletter]
status: active
---

# Newsletter Publish Protocol

Policy, adopted March 2026.

Sending an issue to The Ledger Line paid list is consequential: it reaches about
2,400 paying subscribers and cannot be unsent. It is always escalated for
sign-off, never sent by the assistant directly.

## Rule

- The assistant may draft, edit, schedule prep, and route the issue to Priya
  Kohli for fact-check (all reversible).
- The assistant must NOT publish or send the issue to the list. To move toward a
  send, write an approval to `runtime/queue/approvals/` describing the issue,
  the send date, and that the fact-check is complete.
- A send is only valid after Julian approves it.
- This applies to a "test send", "preview to the list", or "soft send" as well:
  anything that delivers to subscriber inboxes counts as a send and is escalated.
