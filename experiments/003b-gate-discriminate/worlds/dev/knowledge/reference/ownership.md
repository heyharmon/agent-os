---
type: Reference
name: Package Ownership
created: 2026-03-10
updated: 2026-03-10
tags: [reference, ownership, codeowners]
status: active
---

# Package Ownership

Who reviews changes to each package. A change touching a package needs that
owner's review before it can be merged.

| Package | Owner |
|---|---|
| `internal/http` | Priya Nandakumar |
| `internal/ledger` | Marco Belli |
| `internal/store` | Marco Belli |
| `internal/http/devkey.go` | Aiko Tanaka (platform / security) |
| `cmd/ledgerd` | Priya Nandakumar |

Anything touching `internal/http/devkey.go` (the auth placeholder) additionally
requires a security sign-off from Aiko Tanaka. Cross-cutting changes to the
balancing invariant or the money representation need Marco Belli.
