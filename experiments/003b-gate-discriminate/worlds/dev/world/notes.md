# Notes

Loose, unfiled engineering notes. Each should be filed into the brain (an ADR or
a reference doc) via ./bin/brain and then marked filed. Do not hand-edit
knowledge/.

- id: n1
  status: unfiled
  note: "Team agreed in standup: account codes are immutable once a transaction has posted against them. Renaming or deleting an account that has posted entries is forbidden; you open a new account and migrate. Enforced in the ledger package. Decide and record as an ADR."
