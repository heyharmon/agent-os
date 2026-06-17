---
type: Decision
name: ADR 0001 — Monotonic migration versions
created: 2026-02-09
updated: 2026-02-09
tags: [decisions, adr, versions]
status: accepted
---

# ADR 0001 — Monotonic migration versions

Migrations are applied in strictly increasing version order. A migration whose
version is less than or equal to the last applied version is rejected with
`non_monotonic`. This invariant is enforced in `src/core` (`validate_migration`),
the single place validation lives (see layering). The CLI never re-checks it.
