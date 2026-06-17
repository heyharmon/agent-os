"""A charge belongs to a ticket. Amounts are integer cents. Data only."""

from app.models.base import Model


class Charge(Model):
    fields = ["ticket_id", "status", "total_cents"]
    casts = {"total_cents": int}

    def ticket(self):
        return self.belongs_to("Ticket")
