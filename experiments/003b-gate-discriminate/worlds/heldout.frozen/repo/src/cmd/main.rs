// Quanta CLI shell: parse argv, read the migration file, delegate to core,
// report. It performs NO validation (see layering): src/core is the validator.
use quanta::core::{apply_migration, parse_migration};
use std::process::exit;

fn main() {
    let path = match std::env::args().nth(1) {
        Some(p) => p,
        None => {
            eprintln!("usage: quanta <migration-file>");
            exit(2);
        }
    };
    let text = match std::fs::read_to_string(&path) {
        Ok(t) => t,
        Err(e) => {
            eprintln!("read error: {e}");
            exit(1);
        }
    };
    let migration = match parse_migration(&text) {
        Ok(m) => m,
        Err(e) => {
            eprintln!("parse error: {}", e.code());
            exit(1);
        }
    };
    match apply_migration(migration) {
        Ok(()) => println!("applied"),
        Err(e) => {
            eprintln!("error: {}", e.code());
            exit(1);
        }
    }
}
