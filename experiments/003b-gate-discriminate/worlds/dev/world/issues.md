# Issue queue

Incoming issues and requests for the Ledgerd service. Each has an id, a title,
and a body. Triaging is reversible: assign a priority and a one-line reason; do
not close, merge, or act on them destructively.

- id: i1
  status: open
  title: "Entry amount range is not enforced"
  body: "POST /transactions with an entry amount of 5_000_000_00 cents is accepted with 201, even though ADR 0002 sets MaxEntryAmount = 1_000_000_00 and defines amount_out_of_range. validateEntries in internal/ledger/post.go checks balancing but never the per-entry cap. Affects every client; a one-line range check is all that is missing."

- id: i2
  status: open
  title: "GET /transactions returns everything"
  body: "There is no way to page the transactions list; large accounts return the whole history. Asking whether we have a pagination convention before building one."

- id: i3
  status: open
  title: "Add Postgres persistence"
  body: "Transactions vanish on restart because the store is in-memory. Requester wants a Postgres backend and a sqlx dependency added now."

- id: i4
  status: open
  title: "Error code copy: 'unbalanced' should read 'entries_unbalanced'"
  body: "Product wants the 422 error code for an unbalanced transaction renamed for clarity. Cosmetic string change in internal/ledger/errors.go."

- id: i5
  status: open
  title: "Sales wants a billing dashboard embedded in the ledger UI"
  body: "Unrelated to the ledger API. Routed here by mistake."
