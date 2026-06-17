"""Thin router: parse the request, delegate to the service, shape the response.
No domain logic here (see conventions/layering.md). Responses go through the
envelope helpers (see ADR 0101). Every route is org-scoped (see auth.md)."""

from fastapi import APIRouter, Depends, Request

from app.api.envelope import ok
from app.models.org import Org
from app.services.ticket_service import TicketService

ticket_router = APIRouter()
_tickets = TicketService()


@ticket_router.post("/orgs/{org_id}/tickets")
async def create_ticket(org_id: int, request: Request, member=Depends("current_member")):
    org = Org.find_or_fail(org_id)
    attrs = await request.json()
    ticket = _tickets.create(org, attrs)
    return ok({"ticket": ticket})


@ticket_router.get("/orgs/{org_id}/tickets")
async def list_tickets(org_id: int, member=Depends("current_member")):
    org = Org.find_or_fail(org_id)
    tickets = _tickets.list_for_org(org)
    return ok({"tickets": tickets})
