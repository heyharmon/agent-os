---
type: Convention
name: Module Layering
created: 2026-04-14
updated: 2026-04-14
tags: [conventions, layering]
status: active
---

# Module Layering

Quanta is split into a thin CLI shell and a pure core.

```
src/cmd     argument parsing, I/O, exit codes
  -> src/core   pure migration logic: parsing, VALIDATION, applying
```

Rules:

- **All validation of a migration lives in `src/core`**, never in `src/cmd`. The
  CLI shell parses argv and reads files; it does not check migration rules.
- Version/range validation in particular belongs in `src/core/validate.rs`
  (`validate_migration`). The CLI must not re-implement it.
- `src/core` is pure: no `println!`, no process exit, no file I/O. It returns
  `Result<_, MigrationError>` values; the CLI shell decides how to report them.
