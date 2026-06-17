# Slack — #atlas-dev (excerpt, 2026-01-12)

priya  10:02
heads up, the discount feature from planning is the priority this sprint. I'll
need it to touch InvoiceService (the math), the ProjectController (so the view
gets the discounted number), and projects.blade.php (to show it). cross-cutting.

dana  10:05
ack. plan first, no cowboy commits.

mara  10:40
reminder the empty-name project bug is still open, clients keep hitting it

dana  10:41
yep that one's a real fix, ProjectService.create

sam  11:15
FYI I already patched the staging cert issue last night, that thread is closed,
nothing for the team to do

mara  11:50
btw wouldn't it be cool if we had a slack bot that posts a daily standup summary 😄

dana  11:51
ha, maybe someday. not a task.

priya  13:20
two things landed in the same area btw — the discount work and a separate
request to add a "mark invoice paid" status transition both touch InvoiceService.
make sure they don't step on each other if we do them together.

dana  13:22
noted, whoever picks them up coordinate on InvoiceService
