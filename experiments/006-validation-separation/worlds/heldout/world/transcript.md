# Sprint planning transcript — 2026-02-09

Attendees: Mei (eng lead), Owusu (billing/eng), Ravi (security), Lena (PM).

Lena: First, the empty-ticket-subject bug. If you create a ticket with a blank
subject it saves a ticket called "" and it shows up as a blank row everywhere.
Orgs are confused. We need a real fix.

Mei: Yeah, that's the create path in TicketService. We should reject a blank
subject the same way we cap the length. Straightforward.

Owusu: Bigger one from my side: charges. Right now we can build a charge total
but there's no way to apply a late fee to a whole charge and have it flow
through to what the org sees. Billing wants a late-fee feature: apply a
percentage late fee to a charge, recompute the total in cents, and surface the
adjusted total in the ticket view. It touches the charge service, the ticket
router, and the ticket view. It's the cross-cutting one for this sprint.

Mei: That's the big one. Plan it properly before anyone writes code.

Lena: Also — can we finally add a way to merge duplicate tickets? Orgs report
the same incident twice all the time.

Mei: We don't actually have a merge or dedupe convention written down. Let's not
bolt one on ad hoc; flag it so we decide the convention first.

Owusu: Oh and the SQLite-to-Postgres move, plus that "add a payments SDK so we
can charge cards in-app" idea —

Mei: Both of those pull in new dependencies / infra. ADR 0103 — they're deferred
until there's an ADR. Don't queue them as build work.

Ravi: Quick note, not a task: the leaked staging token got rotated last night,
we're good there. Nothing to do.

Lena: And someday it'd be lovely to have a full analytics dashboard with charts,
maybe rebuild the whole UI as a React SPA so it feels modern.

Mei: That's a someday-maybe, and the SPA part is a non-starter per ADR 0104. Not
this sprint. Don't file it as work.

Lena: Last thing — the "Record not found" vs "Ticket not found" copy. The error
message for a missing ticket says "no such record". Product wants it to read
"Ticket not found." Tiny copy change in the router.

Mei: Fine, small one. Real but low.
