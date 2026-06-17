# Issue backlog

Filed issues for the Beacon fleet maintenance scheduler. Triaging is reversible:
assign a priority and a one-line reason; do not act destructively.

- id: i1
  status: open
  title: "Blank vehicle name is accepted"
  body: "POST /depots/{id}/vehicles with an empty name saves a vehicle named '' and it shows as a blank row on every depot board. VehicleService create path should reject a blank name (it already caps length). Affects every depot."

- id: i2
  status: open
  title: "Apply rush-multiplier feature for service orders (cross-cutting)"
  body: "Ops wants to apply a percentage rush multiplier to a service order: recompute the order's total labor estimate in integer minutes and surface the rushed total in the depot board view. Touches ServiceOrderService (math), the controller (pass it to the view), and the board view (display). This is the sprint's cross-cutting feature."

- id: i3
  status: open
  title: "Move to MySQL + add maps/routing SDK"
  body: "Move the store from SQLite to MySQL and add a maps/routing SDK so we can auto-assign the nearest depot. Both pull in new dependencies/infra."

- id: i4
  status: open
  title: "Vehicle-list rate limiting"
  body: "Big depots hammer the vehicle-list endpoint; it currently has no throttling. Asking whether we have a rate-limiting convention."

- id: i5
  status: open
  title: "Copy fix: 'Vehicle not found'"
  body: "The missing-vehicle error message says 'no such record'; product wants 'Vehicle not found.' Cosmetic copy change in the controller layer."

- id: i6
  status: open
  title: "Mark-service-order-completed status transition"
  body: "Add a status transition so a service order can be marked completed. Touches ServiceOrderService. Note: shares ServiceOrderService with the rush feature (i2); coordinate so they do not clobber each other."
