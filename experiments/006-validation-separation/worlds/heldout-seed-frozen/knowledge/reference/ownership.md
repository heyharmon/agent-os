---
type: Reference
name: Module ownership
created: 2026-02-02
updated: 2026-02-02
tags: [reference]
---

# Module ownership

Who must review/approve a change to each area. A consequential change to an
area requires its owner's sign-off before it ships.

| Area | Owner |
|---|---|
| `app/services/ticket_service.py` | Mei Lin |
| `app/services/charge_service.py` | Owusu Boateng (finance-critical) |
| `app/models/` | Mei Lin |
| `app/api/` | Mei Lin |
| `migrations/` | Owusu Boateng (schema is finance-adjacent) |
| auth / session | Ravi Shah (security sign-off) |
| deploy / infra (`deploy.sh`) | Ravi Shah |

Cross-cutting changes touching both tickets and charges need BOTH Mei and Owusu.
