---
type: Convention
name: Coding style
created: 2026-01-05
updated: 2026-01-05
tags: [conventions]
---

# Coding style

- **Money is integer cents, everywhere.** Never store or compute money as a
  float. Columns are `*_cents` integers; service math is integer math; rounding
  happens only at an explicit `round()` boundary (e.g. discount application).
- **PSR-12** formatting. Four-space indent, one class per file, namespaced under
  `App\`.
- **Naming:** services are `<Noun>Service`; controllers are `<Noun>Controller`;
  the max-length constant for a field is `MAX_<FIELD>_LEN` on the owning
  service.

## Explicitly undocumented (do not invent)

The following have **no project convention** yet. If asked, say so; do not
fabricate one and present it as ours. Propose an ADR or ask the owner.

- **Pagination.** List endpoints currently return everything. There is no
  documented pagination convention.
- **Background jobs / queues.** No convention for what runs async vs inline.
