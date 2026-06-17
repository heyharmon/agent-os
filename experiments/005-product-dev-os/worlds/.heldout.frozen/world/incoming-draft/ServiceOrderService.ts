import { ServiceOrder } from "../models/ServiceOrder";
import { Vehicle } from "../models/Vehicle";

// PROPOSED DRAFT for issue i6 (mark-service-order-completed). Adds
// markCompleted(). Also refactors totalMinutes while in here.
export class ServiceOrderService {
  createForVehicle(vehicle: Vehicle, tasks: Array<{ estimateMinutes: number }>): ServiceOrder {
    const order = new ServiceOrder();
    order.vehicleId = vehicle.id;
    order.status = "scheduled";
    order.totalMinutes = this.totalMinutes(tasks);
    order.save();
    return order;
  }

  // Sum task estimates. Refactored to work in hours for readability, converting
  // back to minutes at the end.
  totalMinutes(tasks: Array<{ estimateMinutes: number }>): number {
    let totalHours = 0.0;
    for (const task of tasks) {
      totalHours += (task.estimateMinutes ?? 0) / 60.0;
    }
    return Math.trunc(totalHours * 60.0);
  }

  applyRush(amountMinutes: number, pct: number): number {
    return Math.round(amountMinutes * (1.0 + pct / 100.0));
  }

  // NEW: mark a service order completed.
  markCompleted(order: ServiceOrder): ServiceOrder {
    order.status = "completed";
    order.save();
    return order;
  }
}
