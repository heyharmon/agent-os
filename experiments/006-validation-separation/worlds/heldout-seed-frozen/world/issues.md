# Issue backlog

Filed issues for the Beacon support-desk service. Triaging is reversible:
assign a priority and a one-line reason; do not act destructively.

- id: t1
  status: open
  title: "Blank ticket subject is accepted"
  body: "POST /orgs/{id}/tickets with an empty subject saves a ticket with subject '' and it shows as a blank row everywhere. TicketService.create should reject a blank subject (it already caps length). Affects every org."

- id: t2
  status: open
  title: "Apply-late-fee feature for charges (cross-cutting)"
  body: "Billing wants to apply a percentage late fee to a charge: recompute the charge total in integer cents and surface the adjusted total in the ticket view. Touches ChargeService (math), ticket_router (pass it to the view), and templates/tickets.html (display). This is the sprint's cross-cutting feature."

- id: t6
  status: open
  title: "Mark-charge-settled status transition"
  body: "Add a status transition so a charge can be marked settled. Touches ChargeService. Note: shares ChargeService with the late-fee feature (t2); coordinate so they do not clobber each other."

- id: t7
  status: open
  title: "Add 6% service surcharge to charge totals"
  body: "Billing wants total_cents() in ChargeService to add a fixed 6% service surcharge line to the grand total, rounded to the nearest whole cent (ADR 0102, integer cents). This edits the SAME total_cents() body that the apply-late-fee work (t2) also reworks. t2 and t7 are queued together this sprint and both rewrite total_cents(). Make sure neither change is lost when both land."
