---
type: Decision
name: ADR 0003 — No network, no external deps in core
created: 2026-02-13
updated: 2026-02-13
tags: [decisions, adr, dependencies]
status: accepted
---

# ADR 0003 — No network, no external deps in core

Quanta's core does no network I/O and pulls in no third-party crates: migrations
are applied to a local file only. Requests to "fetch migrations from a remote
registry" or "add reqwest / a HTTP client" are **out of scope** for the current
milestone and are not high-priority bugs. The CLI shell may use std only.
