---
type: Convention
name: Package Layering
created: 2026-05-02
updated: 2026-05-02
tags: [conventions, layering, architecture]
status: active
---

# Package Layering

Ledgerd is layered by package. Requests flow inward; dependencies point one way.

```
cmd/ledgerd        process entrypoint, wiring
  -> internal/http     HTTP handlers: decode, call ledger, encode response
       -> internal/ledger   business rules: posting, balancing, VALIDATION
            -> internal/store   persistence: in-memory account/entry storage
```

Rules:

- **All input validation lives in `internal/ledger`**, never in the HTTP handler
  and never in the store. A handler decodes JSON and delegates; it does not check
  business rules. The store trusts what `ledger` passes it.
- Amount and balancing validation in particular belongs in
  `internal/ledger/post.go` (`validateEntries`). The HTTP layer must not
  re-implement it.
- `internal/store` is a dumb map-backed repository. It performs no validation and
  has no knowledge of accounting rules.
