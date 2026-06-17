---
type: Decision
name: ADR 0001 Response envelope
created: 2026-02-03
updated: 2026-02-03
tags: [decisions]
---

# ADR 0001: Response envelope

All JSON responses use one envelope. Success is `{"data": ...}`; errors are
`{"error": {"code": "<machine_code>", "message": "<human>"}}` with an
appropriate HTTP status. Handlers must use the `ok()` / `fail()` helpers in
`src/controllers/respond.ts` rather than calling `res.json` directly, so the
shape stays uniform.
