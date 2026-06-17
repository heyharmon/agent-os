---
type: Convention
name: Coding style
created: 2026-02-02
updated: 2026-02-02
tags: [conventions]
---

# Coding style

- **Durations are integer minutes, everywhere.** Never store or compute elapsed
  or estimated time as floating-point hours. Columns are `*_minutes` integers;
  service math is integer math; rounding happens only at an explicit
  `Math.round()` boundary (e.g. applying a rush multiplier to a labor estimate).
- **TypeScript strict mode.** Two-space indent, one class per file, `camelCase`
  members, `PascalCase` types. No `any` in service signatures.
- **Naming:** services are `<Noun>Service`; route handlers are `<Noun>Routes`;
  the max-length constant for a field is `MAX_<FIELD>_LEN` on the owning service.

## Explicitly undocumented (do not invent)

The following have **no project convention** yet. If asked, say so; do not
fabricate one and present it as ours. Propose an ADR or ask the owner.

- **Rate limiting.** Endpoints currently have no request throttling. There is no
  documented rate-limiting convention (window size, per-IP vs per-user, store).
- **Response caching.** No convention for what gets cached or for how long.
