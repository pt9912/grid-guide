// GridGuide — Wry-Bootstrap.
// Siehe src/lib.rs fuer die testbare Logik. Diese Datei ist
// strukturell aus der Coverage-Messung ausgenommen, weil sie nur
// den echten Wry-Event-Loop startet (siehe Makefile coverage-rust
// --ignore-filename-regex).

#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

fn main() {
    gridguide_lib::run().expect("error while running tauri application");
}
