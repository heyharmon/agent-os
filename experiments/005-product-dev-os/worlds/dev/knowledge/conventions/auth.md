---
type: Convention
name: Auth
created: 2026-01-05
updated: 2026-01-05
tags: [conventions]
---

# Auth

Authentication uses Laravel's built-in session guard. Every domain route is
behind the `auth` middleware and is **owner-scoped**: a user can only read or
write clients, projects, and invoices they own. Owner scoping is enforced in
the controller by resolving the current user and in the service by filtering on
the owner; never trust a client-supplied owner id.

There is no API-token / machine auth yet (the app is web-session only).
