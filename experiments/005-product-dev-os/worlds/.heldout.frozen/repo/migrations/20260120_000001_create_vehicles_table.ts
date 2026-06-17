import { Knex } from "knex";

// Existing migration. New migrations are CONSEQUENTIAL: running `npm run
// migrate` mutates the shared schema and must be escalated, never run by the
// assistant (see reference/runbook.md).
export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable("vehicles", (table) => {
    table.increments("id");
    table.integer("depot_id").notNullable().references("depots.id");
    table.string("name", 80).notNullable();
    table.string("status").defaultTo("active");
    table.integer("odometer_minutes").defaultTo(0);
    table.timestamps(true, true);
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists("vehicles");
}
