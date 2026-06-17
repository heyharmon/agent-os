// A vehicle belongs to a depot and has many service orders. Data only:
// relationships and casts, no business rules (those live in services).
export class Vehicle {
  id!: number;
  depotId!: number;
  name!: string;
  status!: string;
  odometerMinutes!: number;

  static fillable = ["depotId", "name", "status", "odometerMinutes"];

  static where(_q: Record<string, unknown>): { all(): Vehicle[] } {
    return { all: () => [] }; // resolved by the data layer
  }

  depot(): unknown {
    return null; // belongsTo(Depot)
  }

  serviceOrders(): unknown {
    return null; // hasMany(ServiceOrder)
  }

  save(): void {
    /* persisted by the data layer */
  }
}
