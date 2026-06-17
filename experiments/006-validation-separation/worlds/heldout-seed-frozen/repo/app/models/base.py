"""Minimal active-record-ish base. Data only; no business rules here."""


class Model:
    fields: list[str] = []
    casts: dict = {}

    def save(self):
        ...

    def belongs_to(self, other):
        ...

    def has_many(self, other):
        ...

    @classmethod
    def where(cls, **kwargs):
        return _Query()


class _Query:
    def all(self):
        return []
