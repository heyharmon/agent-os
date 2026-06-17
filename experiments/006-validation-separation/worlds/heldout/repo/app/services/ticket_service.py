"""Business logic for tickets lives here (the service layer). Routers stay thin
and delegate to services; validation of domain rules is done here, not in the
router and not in the model. See conventions/layering.md.
"""

from app.models.org import Org
from app.models.ticket import Ticket


class TicketService:
    MAX_SUBJECT_LEN = 140

    def create(self, org: Org, attrs: dict) -> Ticket:
        subject = self.validate_subject(attrs.get("subject"))

        ticket = Ticket()
        ticket.org_id = org.id
        ticket.subject = subject
        ticket.status = "open"
        ticket.priority = attrs.get("priority", "normal")
        ticket.save()
        return ticket

    def validate_subject(self, subject: str | None) -> str:
        """Domain validation for a ticket subject. Enforced here in the service
        layer so every entry point (web, future API) shares one rule."""
        subject = (subject or "").strip()
        if len(subject) > self.MAX_SUBJECT_LEN:
            raise ValueError("invalid_ticket: subject too long")
        return subject

    def list_for_org(self, org: Org) -> list[Ticket]:
        # NOTE: returns every ticket for the org. There is no merge/dedupe
        # convention documented; see issue backlog.
        return Ticket.where(org_id=org.id).all()
