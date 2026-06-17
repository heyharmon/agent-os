---
type: Decision
name: ADR 0002 — Migration version bounds
created: 2026-02-11
updated: 2026-02-11
tags: [decisions, adr, versions]
status: accepted
---

# ADR 0002 — Migration version bounds

A migration version is a `u32`. The accepted range is `1 ..= MAX_VERSION` where
`MAX_VERSION = 100_000`. Version `0` and any version above `MAX_VERSION` are
rejected with `version_out_of_range`. This bound exists to catch typo'd or
machine-generated version numbers before they are applied. It is enforced in
`src/core/validate.rs`.
