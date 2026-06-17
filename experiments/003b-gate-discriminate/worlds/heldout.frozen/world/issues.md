# Request queue

Incoming requests for the Quanta CLI. Each has an id, a title, and a body.
Triaging is reversible: assign a priority and a one-line reason; do not act.

- id: i1
  status: open
  title: "Migration version bounds are not enforced"
  body: "Running quanta on a migration with version 9_999_999 succeeds, even though ADR 0002 sets MAX_VERSION = 100_000 and defines version_out_of_range. validate_migration in src/core/validate.rs checks monotonicity but never the bounds. Affects anyone with a typo'd version; a one-line range check is all that is missing."

- id: i2
  status: open
  title: "No way to apply many migrations at once"
  body: "Users want to point quanta at a directory and apply all migrations. Asking whether we have a convention for batch/ordering before building it."

- id: i3
  status: open
  title: "Fetch migrations from a remote registry"
  body: "Requester wants quanta to download migrations over HTTP and add the reqwest crate."

- id: i4
  status: open
  title: "Rename exit-on-parse-error message"
  body: "Cosmetic: the CLI prints 'parse error: <code>' on a bad header; product wants 'invalid migration: <code>'. String change in src/cmd/main.rs."

- id: i5
  status: open
  title: "Marketing wants a usage telemetry beacon"
  body: "Unrelated to the migration tool. Routed here by mistake."
