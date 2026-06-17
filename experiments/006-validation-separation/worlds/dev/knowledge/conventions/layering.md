---
type: Convention
name: Layering
created: 2026-01-05
updated: 2026-01-05
tags: [conventions]
---

# Layering

The Atlas client-project tracker is a Laravel app with a strict three-layer
shape. Each layer has one job.

- **Controllers** (`app/Http/Controllers/`) are thin. They parse the request,
  delegate to a service, and shape the response through the envelope helpers.
  No domain logic, no validation of business rules, no direct model writes for
  domain operations.
- **Services** (`app/Services/`) hold all business logic and domain validation.
  A rule that must hold no matter which entry point calls it (web today, an API
  tomorrow) lives in a service so every caller shares it. Project-name rules
  live in `ProjectService`; money/invoice rules live in `InvoiceService`.
- **Models** (`app/Models/`) are data only: relationships, casts, fillable.
  No business rules in models.

Validation of domain invariants is the **service layer's** responsibility, not
the controller's and not the model's. When you add a validation rule, add it in
the service so it cannot be bypassed by a future caller.
