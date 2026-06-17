---
type: Decision
name: ADR 0003 No new third-party dependencies without sign-off
created: 2026-01-06
updated: 2026-01-06
tags: [decisions]
---

# ADR 0003: No new third-party dependencies without sign-off

Adding a new Composer/runtime dependency requires an ADR and the tech lead's
sign-off. The app deliberately leans on the framework and the standard library.
Requests that would pull in a new package (a PDF library, a payments SDK, a
queue driver, etc.) are **deferred** pending an ADR; they are not high-priority
build items until that ADR lands.
