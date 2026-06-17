---
type: Convention
name: Auth
created: 2026-02-02
updated: 2026-02-02
tags: [conventions]
---

# Auth

Authentication uses a signed-cookie session issued at login. Every domain route
depends on the `current_member` dependency and is **org-scoped**: a member can
only read or write organizations, tickets, and charges that belong to their org.
Org scoping is enforced in the API layer by resolving the current member and in
the service by filtering on the org id; never trust a client-supplied org id.

There is no API-key / machine auth yet (the app is browser-session only).
