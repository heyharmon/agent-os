# Sprint planning transcript — 2026-02-09

Attendees: Theo (eng lead), Lena (operations/eng), Owen (security), Rina (PM).

Rina: First, the empty-vehicle-name bug. If you register a vehicle with a blank
name it saves a vehicle called "" and it shows as a blank row on every depot
board. Operators are confused. We need a real fix.

Theo: Yeah, that's the create path in VehicleService. We should reject a blank
name the same way we cap the length. Straightforward.

Lena: Bigger one from my side: service orders. Right now we can build a total
labor estimate but there's no way to apply a rush multiplier to a whole order
and have it flow through to what the operator sees. Ops wants a rush feature:
apply a percentage rush multiplier to a service order, recompute the total in
minutes, and surface the rushed total in the depot board view. It touches the
service-order service, the controller, and the board view. It's the
cross-cutting one for this sprint.

Theo: That's the big one. Plan it properly before anyone writes code.

Rina: Also — can we finally add rate limiting to the vehicle-list endpoint? A
couple of big depots hammer it.

Theo: We don't actually have a rate-limiting convention written down. Let's not
bolt one on ad hoc; flag it so we decide the convention first.

Lena: Oh and the SQLite-to-MySQL move, plus that "add a maps/routing SDK so we
can auto-assign the nearest depot" idea —

Theo: Both of those pull in new dependencies / infra. ADR 0003 — they're
deferred until there's an ADR. Don't queue them as build work.

Owen: Quick note, not a task: the prod session-secret rotation ran fine over the
weekend, we're good there. Nothing to do.

Rina: And someday it'd be lovely to have a live map dashboard with vehicle pins,
maybe rebuild the whole board as a React SPA so it feels modern.

Theo: That's a someday-maybe, and the SPA part is a non-starter per ADR 0004.
Not this sprint. Don't file it as work.

Rina: Last thing — the "Record not found" vs "Vehicle not found" copy. The error
message for a missing vehicle says "no such record". Product wants it to read
"Vehicle not found." Tiny copy change in the controller.

Theo: Fine, small one. Real but low.

Lena: One more that's NOT for this sprint but write it down so we don't lose it:
eventually we want SLA-breach email alerts. Owen flagged it could leak customer
data in the email body, so it needs a security review and an ADR before any
build. Park it, don't queue it as build work yet.
