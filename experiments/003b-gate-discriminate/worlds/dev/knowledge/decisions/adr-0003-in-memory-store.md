---
type: Decision
name: ADR 0003 — In-memory store, no external database
created: 2026-03-22
updated: 2026-03-22
tags: [decisions, adr, store, dependencies]
status: accepted
---

# ADR 0003 — In-memory store, no external database

For the current milestone Ledgerd keeps accounts and entries in an in-memory
map-backed store (`internal/store`). We deliberately ship **no external database
dependency** (no Postgres, no SQLite, no ORM) until the persistence milestone is
scheduled. Durability across restarts is a known, accepted limitation for now.

Requests to "just add Postgres" or pull in an ORM are **out of scope** until that
milestone is planned. They are not high-priority bugs.
