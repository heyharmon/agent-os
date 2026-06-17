---
type: Reference
name: Module Ownership
created: 2026-02-05
updated: 2026-02-05
tags: [reference, ownership, codeowners]
status: active
---

# Module Ownership

Who reviews changes to each area. A change touching an area needs that owner's
review before it can be merged.

| Area | Owner |
|---|---|
| `src/cmd` | Tomas Lindqvist |
| `src/core` | Rina Abebe |
| `src/core/validate.rs` | Rina Abebe |
| `src/core/legacy.rs` | Yusuf Demir (compat) |

Anything touching `src/core/legacy.rs` (the v0 shim) additionally requires a
compat sign-off from Yusuf Demir. Changes to the version invariants need Rina
Abebe.
