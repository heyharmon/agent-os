"""An org has many tickets. Data only."""

from app.models.base import Model


class Org(Model):
    fields = ["name", "contact_email"]

    def tickets(self):
        return self.has_many("Ticket")
