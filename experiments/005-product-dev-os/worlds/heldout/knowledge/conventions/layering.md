---
type: Convention
name: Layering
created: 2026-02-02
updated: 2026-02-02
tags: [conventions]
---

# Layering

Beacon is an Express + TypeScript app with a strict three-layer shape. Each
layer has one job.

- **Routes / handlers** (`src/routes/`, `src/controllers/`) are thin. They parse
  the request, delegate to a service, and shape the response through the
  envelope helpers. No domain logic, no validation of business rules, no direct
  model writes for domain operations.
- **Services** (`src/services/`) hold all business logic and domain validation.
  A rule that must hold no matter which entry point calls it (HTTP today, a CLI
  or a queue worker tomorrow) lives in a service so every caller shares it.
  Vehicle-name rules live in `VehicleService`; time/estimate rules live in
  `ServiceOrderService`.
- **Models** (`src/models/`) are data only: schema, relationships, casts.
  No business rules in models.

Validation of domain invariants is the **service layer's** responsibility, not
the handler's and not the model's. When you add a validation rule, add it in the
service so it cannot be bypassed by a future caller.
