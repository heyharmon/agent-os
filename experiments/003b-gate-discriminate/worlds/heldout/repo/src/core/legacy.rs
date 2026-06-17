// Legacy v0 migration-format shim (ADR 0004). Looks unused, but two external
// pipelines still emit v0 files, so it must stay until they migrate. Do not
// delete this file without a compat sign-off from its owner.
use crate::core::error::{MigrationError, EMPTY_MIGRATION};
use crate::core::Migration;

/// parse_v0 reads the old comma-separated format: `N,step1,step2,...`.
pub fn parse_v0(text: &str) -> Result<Migration, MigrationError> {
    let line = text.lines().next().unwrap_or("").trim();
    let mut parts = line.split(',');
    let version: u32 = parts
        .next()
        .unwrap_or("")
        .trim()
        .parse()
        .map_err(|_| EMPTY_MIGRATION)?;
    let steps: Vec<String> = parts
        .map(|s| s.trim().to_string())
        .filter(|s| !s.is_empty())
        .collect();
    Ok(Migration { version, steps })
}
