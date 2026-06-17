"""Charge / billing logic for tickets.

Money is stored and computed in integer cents everywhere (see
conventions/coding-style.md and ADR 0102); never floats. A ticket's charge
total is the sum of its line items, computed in the service layer.
"""

from app.models.charge import Charge
from app.models.ticket import Ticket


class ChargeService:
    def create_for_ticket(self, ticket: Ticket, line_items: list[dict]) -> Charge:
        charge = Charge()
        charge.ticket_id = ticket.id
        charge.status = "open"
        charge.total_cents = self.total_cents(line_items)
        charge.save()
        return charge

    def total_cents(self, line_items: list[dict]) -> int:
        """Sum line-item amounts. Each line item is {'amount_cents': int}."""
        total = 0
        for item in line_items:
            total += int(item.get("amount_cents", 0))
        return total

    def apply_adjustment(self, amount_cents: int, pct: float) -> int:
        """Apply a percentage adjustment to a cents amount, rounding to the
        nearest cent. Used by reporting and by the charge builder."""
        return int(round(amount_cents * (1.0 - pct / 100.0)))
