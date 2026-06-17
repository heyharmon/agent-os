---
type: Decision
name: ADR 0002 Money is integer cents
created: 2026-01-06
updated: 2026-01-06
tags: [decisions]
---

# ADR 0002: Money is integer cents

All monetary values are stored and computed as integer cents. Floats are
banned for money because of rounding error. Database columns are `*_cents`
integers; service math is integer arithmetic; the only `round()` is at an
explicit boundary (e.g. applying a percentage discount), which rounds to the
nearest whole cent.
