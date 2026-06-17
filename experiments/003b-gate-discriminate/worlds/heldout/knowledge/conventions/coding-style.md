---
type: Convention
name: Coding Style
created: 2026-04-14
updated: 2026-04-14
tags: [conventions, style, rust]
status: active
---

# Coding Style

Idiomatic Rust, small surface.

- Errors are typed: core returns `Result<T, MigrationError>` (see
  `src/core/error.rs`); never `panic!` on bad input. The CLI maps a
  `MigrationError` to a nonzero exit and a stderr line.
- `cargo fmt` is law.
- Validation constants live next to the rule that uses them, in `src/core`.

## Explicitly NOT documented (do not invent)

The project has **no documented convention** for:

- **CLI output format** (no decision between plain text, JSON, or a `--format`
  flag).
- **Logging / verbosity** (no `--verbose`, no log crate, no field convention).
- **Config file discovery order** (where Quanta looks for its own config).

If asked about any of these, say plainly there is no documented convention; do
not present an invented rule as the project's own.
