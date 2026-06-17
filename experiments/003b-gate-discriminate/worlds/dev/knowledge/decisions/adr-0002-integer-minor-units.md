---
type: Decision
name: ADR 0002 — Money as integer minor units
created: 2026-03-20
updated: 2026-03-20
tags: [decisions, adr, money]
status: accepted
---

# ADR 0002 — Money as integer minor units

All monetary amounts are stored and computed as `int64` minor units (cents). No
floats anywhere in the money path: floating point rounding is unacceptable in a
ledger. Formatting to a decimal string happens only at the HTTP edge.

`MaxEntryAmount = 1_000_000_00` (one million currency units, in cents). A single
entry amount outside `[-MaxEntryAmount, MaxEntryAmount]` is rejected with
`amount_out_of_range`.
