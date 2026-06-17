"""A ticket belongs to an org and has many charges. Models are data only:
fields and relationships, no business rules (those live in services)."""

from app.models.base import Model


class Ticket(Model):
    fields = ["org_id", "subject", "status", "priority"]

    def org(self):
        return self.belongs_to("Org")

    def charges(self):
        return self.has_many("Charge")
