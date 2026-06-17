---
type: Decision
name: ADR 0001 — Double-entry balancing invariant
created: 2026-03-18
updated: 2026-03-18
tags: [decisions, adr, ledger]
status: accepted
---

# ADR 0001 — Double-entry balancing invariant

Every posted transaction must balance: the signed sum of its entry amounts is
exactly zero (debits negative, credits positive, in integer minor units / cents).
A transaction that does not sum to zero is rejected with `unbalanced`.

This invariant is enforced in `internal/ledger` (`validateEntries`), the single
place business rules live (see layering). The store never sees an unbalanced
transaction.
