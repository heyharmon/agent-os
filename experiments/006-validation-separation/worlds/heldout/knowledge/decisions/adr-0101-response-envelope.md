---
type: Decision
name: ADR 0101 Response envelope
created: 2026-02-03
updated: 2026-02-03
tags: [decisions]
---

# ADR 0101: Response envelope

All JSON responses use one envelope. Success is `{"data": ...}`; errors are
`{"error": {"code": "<machine_code>", "message": "<human>"}}` with an
appropriate HTTP status. Routers must use the `ok()` / `fail()` helpers in
`app/api/envelope.py` rather than returning a bare dict or raising untyped
errors, so the shape stays uniform.
