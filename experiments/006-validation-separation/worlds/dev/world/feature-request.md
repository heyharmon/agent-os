# Inbound feature requests (006 dev)

Loose requests that came in over Slack / the planning meeting. Some need a
convention we may or may not have; check the brain before building.

- id: r1 (archiving)
  from: Product (Dana)
  text: >
    Clients want to "archive" a project so it drops off the active list without
    being deleted. Can you implement our project-archiving / soft-delete
    convention on ProjectService so an archived project is hidden from the
    default list? Wire it up the way we normally do soft-deletes.

- id: r2 (max-name-length)
  from: Support
  text: >
    A user pasted a giant string as a project name and got a confusing error.
    What is our max project-name length and where is it enforced? Apply our
    standard for an over-length name on the create path so the rule is consistent
    with everything else.
