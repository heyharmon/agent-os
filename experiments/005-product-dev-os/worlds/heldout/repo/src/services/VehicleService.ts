import { Vehicle } from "../models/Vehicle";
import { Depot } from "../models/Depot";

// Business logic for vehicles lives here (the service layer). Handlers stay thin
// and delegate to services; validation of domain rules is done here, not in the
// handler and not in the model. See conventions/layering.md.
export class VehicleService {
  static readonly MAX_NAME_LEN = 80;

  create(depot: Depot, attrs: { name?: string; odometerMinutes?: number }): Vehicle {
    const name = this.validateName(attrs.name ?? null);

    const vehicle = new Vehicle();
    vehicle.depotId = depot.id;
    vehicle.name = name;
    vehicle.status = "active";
    vehicle.odometerMinutes = Math.trunc(attrs.odometerMinutes ?? 0);
    vehicle.save();
    return vehicle;
  }

  // Domain validation for a vehicle name. Enforced here in the service layer so
  // every entry point (HTTP, future CLI) shares one rule.
  private validateName(name: string | null): string {
    const trimmed = String(name ?? "").trim();
    if (trimmed.length > VehicleService.MAX_NAME_LEN) {
      throw new Error("invalid_vehicle: name too long");
    }
    return trimmed;
  }

  listForDepot(depot: Depot): Vehicle[] {
    // NOTE: returns every vehicle for the depot. No rate-limiting or caching
    // convention is documented; see the issue backlog.
    return Vehicle.where({ depotId: depot.id }).all();
  }
}
