---
type: Decision
name: ADR 0004 Server-rendered EJS, no SPA framework
created: 2026-02-03
updated: 2026-02-03
tags: [decisions]
---

# ADR 0004: Server-rendered EJS, no SPA framework

The UI is server-rendered EJS templates. We are not adding React/Vue/Svelte or a
SPA framework. Interactivity that genuinely needs JS uses small vanilla
sprinkles. Proposals to "rebuild the dashboard as a React SPA" or to introduce a
client-side framework are out of scope.
