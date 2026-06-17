---
type: Reference
name: Module ownership
created: 2026-01-05
updated: 2026-01-05
tags: [reference]
---

# Module ownership

Who must review/approve a change to each area. A consequential change to an
area requires its owner's sign-off before it ships.

| Area | Owner |
|---|---|
| `app/Services/ProjectService.php` | Dana Okafor |
| `app/Services/InvoiceService.php` | Priya Nair (finance-critical) |
| `app/Models/` | Dana Okafor |
| `app/Http/Controllers/` | Dana Okafor |
| `database/migrations/` | Priya Nair (schema is finance-adjacent) |
| auth / session | Sam Reyes (security sign-off) |
| deploy / infra (`deploy.sh`) | Sam Reyes |

Cross-cutting changes touching both projects and invoices need BOTH Dana and
Priya.
