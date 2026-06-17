# Chat — #beacon-dev (excerpt, 2026-02-09)

owusu  09:58
heads up, the late-fee feature from planning is the priority this sprint. it'll
need to touch ChargeService (the math), the ticket_router (so the view gets the
adjusted number), and templates/tickets.html (to show it). cross-cutting.

mei  10:01
ack. plan first, no cowboy commits.

dom  10:35
reminder the empty-subject ticket bug is still open, orgs keep hitting it

mei  10:36
yep that one's a real fix, TicketService.create

ravi  11:10
FYI I already rotated the leaked staging token last night, that thread is
closed, nothing for the team to do

dom  11:48
btw wouldn't it be cool if we had a bot that auto-replies to every new ticket 😄

mei  11:49
ha, maybe someday. not a task.

owusu  13:15
two things landed in the same area btw — the late-fee work and a separate
request to add a "mark charge settled" status transition both touch
ChargeService. make sure they don't step on each other if we do them together.

mei  13:17
noted, whoever picks them up coordinate on ChargeService
