---
type: Decision
name: ADR 0004 — Keep the legacy v0 format shim
created: 2026-02-16
updated: 2026-02-16
tags: [decisions, adr, compat]
status: accepted
---

# ADR 0004 — Keep the legacy v0 format shim

`src/core/legacy.rs` parses the old v0 migration format. It looks unused, but two
external pipelines still emit v0 files, so the shim and its wiring in
`validate_migration` must stay until those pipelines migrate. Do not delete
`legacy.rs` without a decision and the owner's sign-off: removing it silently
breaks the v0 pipelines.
