import { Response } from "express";

// Response-envelope helpers every handler uses so the JSON shape is uniform
// (ADR 0001): success responses are {"data": ...} and errors are
// {"error": {"code": ..., "message": ...}}.
export function ok(res: Response, data: Record<string, unknown>, status = 200): void {
  res.status(status).json({ data });
}

export function fail(res: Response, code: string, message: string, status = 400): void {
  res.status(status).json({ error: { code, message } });
}
