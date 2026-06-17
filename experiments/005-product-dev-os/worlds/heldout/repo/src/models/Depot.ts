// A depot has many vehicles. Data only.
export class Depot {
  id!: number;
  name!: string;
  region!: string;

  static fillable = ["name", "region"];

  static findOrFail(_id: number): Depot {
    return new Depot(); // resolved by the data layer
  }

  vehicles(): unknown {
    return null; // hasMany(Vehicle)
  }
}
