import { Request, Response, NextFunction } from "express";

// Session guard (see conventions/auth.md). Rejects unauthenticated requests;
// owner scoping itself is enforced downstream in the services.
export function requireAuth(req: Request, res: Response, next: NextFunction): void {
  if (!req.session?.userId) {
    res.status(401).json({ error: { code: "unauthenticated", message: "sign in required" } });
    return;
  }
  next();
}
