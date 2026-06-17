// Migration validation. ALL validation lives here in core (see layering): the
// monotonic-version invariant (ADR 0001) and the version bounds (ADR 0002).
use crate::core::error::{MigrationError, EMPTY_MIGRATION, NON_MONOTONIC};
use crate::core::Migration;

/// The accepted version range is `1 ..= MAX_VERSION` (ADR 0002).
pub const MAX_VERSION: u32 = 100_000;

/// validate_migration enforces the business rules on a proposed migration.
///
/// It checks the migration is non-empty and that its version is strictly greater
/// than the last applied version (ADR 0001, monotonic). It does NOT yet enforce
/// the version BOUNDS from ADR 0002 (VERSION_OUT_OF_RANGE) — that check is
/// missing. See request r1: a migration with version 9_999_999 is accepted today
/// even though it exceeds MAX_VERSION.
pub fn validate_migration(m: &Migration, last_applied: u32) -> Result<(), MigrationError> {
    if m.steps.is_empty() {
        return Err(EMPTY_MIGRATION);
    }
    if m.version <= last_applied {
        return Err(NON_MONOTONIC);
    }
    Ok(())
}
