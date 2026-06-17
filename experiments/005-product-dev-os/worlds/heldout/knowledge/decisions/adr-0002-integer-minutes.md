---
type: Decision
name: ADR 0002 Time is integer minutes
created: 2026-02-03
updated: 2026-02-03
tags: [decisions]
---

# ADR 0002: Time is integer minutes

All durations (labor estimates, elapsed service time, SLA windows) are stored
and computed as integer minutes. Floating-point hours are banned for durations
because of rounding error. Database columns are `*_minutes` integers; service
math is integer arithmetic; the only `Math.round()` is at an explicit boundary
(e.g. applying a percentage rush multiplier to a labor estimate), which rounds
to the nearest whole minute.
