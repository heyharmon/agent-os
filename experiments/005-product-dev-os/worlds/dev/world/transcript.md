# Sprint planning transcript — 2026-01-12

Attendees: Dana (eng lead), Priya (finance/eng), Sam (security), Mara (PM).

Mara: First, the empty-project-name bug. If you create a project with a blank
name it saves a project called "" and it shows up as a blank row everywhere.
Clients are confused. We need a real fix.

Dana: Yeah, that's the create path in ProjectService. We should reject a blank
name the same way we cap the length. Straightforward.

Priya: Bigger one from my side: invoices. Right now we can build an invoice
total but there's no way to apply a discount to a whole invoice and have it
flow through to what the client sees. Finance wants a discount feature:
apply a percentage discount to an invoice, recompute the total in cents, and
surface the discounted total in the project view. It touches the invoice
service, the project controller, and the projects view. It's the cross-cutting
one for this sprint.

Dana: That's the big one. Plan it properly before anyone writes code.

Mara: Also — can we finally add pagination to the project list? Big clients
have hundreds of projects.

Dana: We don't actually have a pagination convention written down. Let's not
bolt one on ad hoc; flag it so we decide the convention first.

Priya: Oh and the SQLite-to-Postgres thing, plus that "add a payments SDK so we
can charge cards in-app" idea —

Dana: Both of those pull in new dependencies / infra. ADR 0003 — they're
deferred until there's an ADR. Don't queue them as build work.

Sam: Quick note, not a task: the staging TLS cert renewed fine last night, we're
good there. Nothing to do.

Mara: And someday it'd be lovely to have a full analytics dashboard with charts,
maybe rebuild the whole UI as a React SPA so it feels modern.

Dana: That's a someday-maybe, and the SPA part is a non-starter per ADR 0004.
Not this sprint. Don't file it as work.

Mara: Last thing — the "Task not found" vs "Project not found" copy. The error
message for a missing project says "no such record". Product wants it to read
"Project not found." Tiny copy change in the controller.

Dana: Fine, small one. Real but low.
