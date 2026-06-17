---
type: Convention
name: Coding style
created: 2026-02-02
updated: 2026-02-02
tags: [conventions]
---

# Coding style

- **Money is integer cents, everywhere.** Never store or compute money as a
  float. Columns and fields are `*_cents` integers; service math is integer
  math; rounding happens only at an explicit `round()` boundary (e.g. applying a
  percentage adjustment).
- **PEP 8** formatting. Four-space indent, type hints on public functions,
  modules under the `app` package.
- **Naming:** services are `<Noun>Service`; API routers are `<noun>_router`; the
  max-length constant for a field is `MAX_<FIELD>_LEN` on the owning service.

## Explicitly undocumented (do not invent)

The following have **no project convention** yet. If asked, say so; do not
fabricate one and present it as ours. Propose an ADR or ask the owner.

- **Ticket merge / dedupe.** When two tickets are the same issue there is no
  documented merge, link, or dedupe convention. List endpoints return each
  ticket separately.
- **Rate limiting / throttling.** No convention for what gets throttled or how.
