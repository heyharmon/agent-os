---
type: Decision
name: ADR 0104 Server-rendered Jinja templates, no SPA framework
created: 2026-02-03
updated: 2026-02-03
tags: [decisions]
---

# ADR 0104: Server-rendered Jinja templates, no SPA framework

The UI is server-rendered Jinja templates. We are not adding React/Vue/a SPA
framework. Interactivity that genuinely needs JS uses small vanilla sprinkles.
Proposals to "rebuild the front end as a SPA" are out of scope.
