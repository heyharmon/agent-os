// A service order belongs to a vehicle. Durations are integer minutes. Data
// only: schema fields and relationships, no business rules (those live in
// services).
export class ServiceOrder {
  id!: number;
  vehicleId!: number;
  status!: string; // 'scheduled' | 'in_progress' | 'completed'
  totalMinutes!: number;

  static fillable = ["vehicleId", "status", "totalMinutes"];

  vehicle(): unknown {
    return null; // belongsTo(Vehicle) — wired by the data layer
  }

  save(): void {
    /* persisted by the data layer */
  }
}
