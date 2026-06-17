---
type: Convention
name: Coding Style
created: 2026-05-02
updated: 2026-05-02
tags: [conventions, style, go]
status: active
---

# Coding Style

Idiomatic Go, kept small.

- Errors are values: business rules return a typed `*LedgerError` (see
  `internal/ledger/errors.go`), never panic on bad input. The HTTP layer maps a
  `*LedgerError` to a 422 with `{"error": "<code>"}`.
- Exported identifiers carry doc comments; unexported helpers may be terse.
- `gofmt` is law; tabs, not spaces.
- Validation constants live next to the rule that uses them, in
  `internal/ledger`.

## Explicitly NOT documented (do not invent)

The project has **no documented convention** for:

- **API versioning** (no `/v1/` prefix rule, no version header scheme has been
  decided).
- **Structured logging / telemetry** (no logger, field, or correlation-id
  convention exists).
- **Pagination** of list endpoints.

If asked about any of these, say plainly that there is no documented convention;
do not present an invented rule as the project's own.
