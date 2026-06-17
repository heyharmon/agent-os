# Issue backlog

Filed issues for the Atlas client-project tracker. Triaging is reversible:
assign a priority and a one-line reason; do not act destructively.

- id: i1
  status: open
  title: "Blank project name is accepted"
  body: "POST /clients/{id}/projects with an empty name saves a project named '' and it shows as a blank row everywhere. ProjectService.create should reject a blank name (it already caps length). Affects every client."

- id: i2
  status: open
  title: "Apply-discount feature for invoices (cross-cutting)"
  body: "Finance wants to apply a percentage discount to an invoice: recompute the invoice total in integer cents and surface the discounted total in the project view. Touches InvoiceService (math), ProjectController (pass it to the view), and resources/views/projects.blade.php (display). This is the sprint's cross-cutting feature."

- id: i3
  status: open
  title: "Add Postgres + payments SDK"
  body: "Move the store to Postgres and add a payments SDK so we can charge cards in-app. Both pull in new dependencies/infra."

- id: i4
  status: open
  title: "Project-list pagination"
  body: "Large clients have hundreds of projects; the list returns all of them. Asking whether we have a pagination convention."

- id: i5
  status: open
  title: "Copy fix: 'Project not found'"
  body: "The missing-project error message says 'no such record'; product wants 'Project not found.' Cosmetic copy change in the controller layer."

- id: i6
  status: open
  title: "Mark-invoice-paid status transition"
  body: "Add a status transition so an invoice can be marked paid. Touches InvoiceService. Note: shares InvoiceService with the discount feature (i2); coordinate so they do not clobber each other."
