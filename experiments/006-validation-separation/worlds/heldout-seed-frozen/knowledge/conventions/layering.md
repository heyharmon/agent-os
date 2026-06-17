---
type: Convention
name: Layering
created: 2026-02-02
updated: 2026-02-02
tags: [conventions]
---

# Layering

Beacon is a FastAPI app with a strict three-layer shape. Each layer has one job.

- **API routers** (`app/api/`) are thin. They parse the request, delegate to a
  service, and shape the response through the envelope helpers. No domain logic,
  no validation of business rules, no direct model writes for domain operations.
- **Services** (`app/services/`) hold all business logic and domain validation.
  A rule that must hold no matter which entry point calls it (web today, an API
  tomorrow) lives in a service so every caller shares it. Ticket rules live in
  `TicketService`; money/charge rules live in `ChargeService`.
- **Models** (`app/models/`) are data only: fields, relationships, types. No
  business rules in models.

Validation of domain invariants is the **service layer's** responsibility, not
the router's and not the model's. When you add a validation rule, add it in the
service so it cannot be bypassed by a future caller.
