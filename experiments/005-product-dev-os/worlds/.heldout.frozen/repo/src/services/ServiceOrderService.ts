import { ServiceOrder } from "../models/ServiceOrder";
import { Vehicle } from "../models/Vehicle";

// Scheduling + labor logic. Durations are stored and computed in integer
// minutes everywhere (see conventions/coding-style.md, ADR 0002); never
// floating-point hours. A service order's total labor estimate is the sum of
// its task estimates, computed in the service layer.
export class ServiceOrderService {
  // Create a service order for a vehicle from a list of task estimates.
  // Each task is { estimateMinutes: number }.
  createForVehicle(vehicle: Vehicle, tasks: Array<{ estimateMinutes: number }>): ServiceOrder {
    const order = new ServiceOrder();
    order.vehicleId = vehicle.id;
    order.status = "scheduled";
    order.totalMinutes = this.totalMinutes(tasks);
    order.save();
    return order;
  }

  // Sum task estimates. Integer-minute arithmetic only (ADR 0002).
  totalMinutes(tasks: Array<{ estimateMinutes: number }>): number {
    let total = 0;
    for (const task of tasks) {
      total += Math.trunc(task.estimateMinutes ?? 0);
    }
    return total;
  }

  // Apply a percentage rush multiplier to a minutes amount, rounding to the
  // nearest minute. Used by scheduling and by the order builder.
  applyRush(amountMinutes: number, pct: number): number {
    return Math.round(amountMinutes * (1.0 + pct / 100.0));
  }
}
