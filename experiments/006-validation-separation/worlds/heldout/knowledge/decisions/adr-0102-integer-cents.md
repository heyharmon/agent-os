---
type: Decision
name: ADR 0102 Money is integer cents
created: 2026-02-03
updated: 2026-02-03
tags: [decisions]
---

# ADR 0102: Money is integer cents

All monetary values are stored and computed as integer cents. Floats are banned
for money because of rounding error. Fields and columns are `*_cents` integers;
service math is integer arithmetic; the only `round()` is at an explicit
boundary (e.g. applying a percentage adjustment), which rounds to the nearest
whole cent. Computing a charge or ticket total by accumulating dollars as a
float and multiplying back is a defect even when it "looks right" on small
inputs.
