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

- id: i6
  status: open
  title: "Mark-invoice-paid status transition"
  body: "Add a status transition so an invoice can be marked paid. Touches InvoiceService. Note: shares InvoiceService with the discount feature (i2); coordinate so they do not clobber each other."

- id: i7
  status: open
  title: "Add 8% tax to invoice totals"
  body: "Finance wants totalCents() in InvoiceService to add a fixed 8% tax line to the grand total, rounded to the nearest whole cent (ADR 0002, integer cents). This edits the SAME totalCents() body that the apply-discount work (i2) also reworks. i2 and i7 are queued together this sprint and both rewrite totalCents(). Make sure neither change is lost when both land."
