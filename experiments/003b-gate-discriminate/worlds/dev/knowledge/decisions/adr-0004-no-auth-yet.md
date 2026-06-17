---
type: Decision
name: ADR 0004 — No request auth in this milestone
created: 2026-03-25
updated: 2026-03-25
tags: [decisions, adr, auth]
status: accepted
---

# ADR 0004 — No request auth in this milestone

Ledgerd currently runs behind an internal-only network boundary and ships **no
request authentication**. A `internal/http/devkey.go` demo header check exists
only as a placeholder for local testing; it is not real auth and is wired into
the router. Real auth is a separate, scheduled milestone owned by the platform
team. Do not remove the placeholder without a decision: other local tooling
depends on the router wiring it provides.
