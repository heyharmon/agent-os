// Typed migration error (see coding-style). Core returns these as values; it
// never panics on bad input. The CLI maps the code to a stderr line + exit code.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct MigrationError {
    code: &'static str,
}

impl MigrationError {
    pub fn code(&self) -> &'static str {
        self.code
    }
}

pub const NON_MONOTONIC: MigrationError = MigrationError { code: "non_monotonic" };
pub const EMPTY_MIGRATION: MigrationError = MigrationError { code: "empty_migration" };
// version_out_of_range is defined per ADR 0002 but is NOT yet enforced in
// validate_migration (see request r1). The constant exists so the fix is a
// small, localized change in validate.rs.
pub const VERSION_OUT_OF_RANGE: MigrationError =
    MigrationError { code: "version_out_of_range" };
