---
type: Decision
name: ADR 0001 Response envelope
created: 2026-01-06
updated: 2026-01-06
tags: [decisions]
---

# ADR 0001: Response envelope

All JSON responses use one envelope. Success is `{"data": ...}`; errors are
`{"error": {"code": "<machine_code>", "message": "<human>"}}` with an
appropriate HTTP status. Controllers must use the `ok()` / `fail()` helpers on
the base `Controller` rather than calling `response()->json` directly, so the
shape stays uniform.
