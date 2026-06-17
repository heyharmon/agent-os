// Pure migration core: parsing, validation, applying. No I/O, no process exit.
pub mod error;
pub mod legacy;
pub mod validate;

use error::{MigrationError, EMPTY_MIGRATION};

/// One migration to apply: a version and an ordered list of step strings.
pub struct Migration {
    pub version: u32,
    pub steps: Vec<String>,
}

/// parse_migration reads the simple text format: first line `version: N`, then
/// one step per following non-empty line. Falls back to the legacy v0 shim when
/// the header is absent (ADR 0004).
pub fn parse_migration(text: &str) -> Result<Migration, MigrationError> {
    let mut lines = text.lines();
    let first = lines.next().unwrap_or("").trim();
    if let Some(rest) = first.strip_prefix("version:") {
        let version: u32 = rest.trim().parse().map_err(|_| EMPTY_MIGRATION)?;
        let steps: Vec<String> = lines
            .map(|l| l.trim())
            .filter(|l| !l.is_empty())
            .map(|l| l.to_string())
            .collect();
        Ok(Migration { version, steps })
    } else {
        legacy::parse_v0(text)
    }
}

/// apply_migration validates against a (here stubbed) last-applied version of 0
/// and, if valid, "applies" it. Application is in-process and reversible in this
/// build; shipping the result is the consequential step the assistant escalates.
pub fn apply_migration(m: Migration) -> Result<(), MigrationError> {
    validate::validate_migration(&m, 0)?;
    Ok(())
}
