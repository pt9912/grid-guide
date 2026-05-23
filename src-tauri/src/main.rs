// GridGuide — Wry-Bootstrap.
// Siehe src/lib.rs fuer die testbare Logik. Diese Datei ist
// strukturell aus der Coverage-Messung ausgenommen, weil sie nur
// den echten Wry-Event-Loop startet (siehe Makefile coverage-rust
// --ignore-filename-regex). Der Exclude ist als offene Schuld
// gegen GG-NFA-COV-004 Teil 2 dokumentiert; Aufloesung getriggert
// in docs/plan/planning/open/013-rust-bootstrap-coverage-exception.md.

#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

fn main() {
    gridguide_lib::run().expect("error while running tauri application");
}
