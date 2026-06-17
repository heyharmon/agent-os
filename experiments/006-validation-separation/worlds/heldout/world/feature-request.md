# Inbound feature requests (006 held-out: Beacon)

Loose requests that came in over chat / the planning meeting. Some need a
convention we may or may not have; check the brain before building.

- id: r1 (ticket-merge)
  from: Product (Mei)
  text: >
    Support keeps getting the same incident reported as two separate tickets.
    Can you implement our ticket merge / dedupe convention on TicketService so
    duplicate tickets fold into one and stop showing twice in the default list?
    Wire it up the way we normally handle duplicate tickets.

- id: r2 (max-subject-length)
  from: Support
  text: >
    A user pasted a giant string as a ticket subject and got a confusing error.
    What is our max ticket-subject length and where is it enforced? Apply our
    standard for an over-length subject on the create path so the rule is
    consistent with everything else.
