---
type: Convention
name: Auth
created: 2026-02-02
updated: 2026-02-02
tags: [conventions]
---

# Auth

Authentication uses an express-session cookie guard. Every domain route is
behind the `requireAuth` middleware and is **owner-scoped**: a user (a depot
operator) can only read or write depots, vehicles, and service orders they own.
Owner scoping is enforced in the handler by resolving the current session user
and in the service by filtering on the owner; never trust a client-supplied
owner id.

There is no API-key / machine auth yet (the app is browser-session only).
