---
type: Reference
name: Module ownership
created: 2026-02-02
updated: 2026-02-02
tags: [reference]
---

# Module ownership

Who must review/approve a change to each area. A consequential change to an area
requires its owner's sign-off before it ships.

| Area | Owner |
|---|---|
| `src/services/VehicleService.ts` | Theo Banerjee |
| `src/services/ServiceOrderService.ts` | Lena Voss (operations-critical) |
| `src/models/` | Theo Banerjee |
| `src/controllers/`, `src/routes/` | Theo Banerjee |
| `migrations/` | Lena Voss (schema is operations-adjacent) |
| auth / session | Owen Park (security sign-off) |
| deploy / infra (`deploy.sh`) | Owen Park |

Cross-cutting changes touching both vehicles and service orders need BOTH Theo
and Lena.
