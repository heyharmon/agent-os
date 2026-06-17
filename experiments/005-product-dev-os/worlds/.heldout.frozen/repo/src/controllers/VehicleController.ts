import { Request, Response } from "express";
import { VehicleService } from "../services/VehicleService";
import { Depot } from "../models/Depot";
import { ok } from "./respond";

// Thin handler: parse the request, delegate to the service, shape the response.
// No domain logic here (see conventions/layering.md). Responses go through the
// envelope helper (ADR 0001).
export class VehicleController {
  constructor(private vehicles: VehicleService) {}

  store(req: Request, res: Response): void {
    const depot = Depot.findOrFail(Number(req.params.depotId));
    const vehicle = this.vehicles.create(depot, req.body);
    ok(res, { vehicle });
  }

  index(req: Request, res: Response): void {
    const depot = Depot.findOrFail(Number(req.params.depotId));
    const vehicles = this.vehicles.listForDepot(depot);
    ok(res, { vehicles });
  }
}
