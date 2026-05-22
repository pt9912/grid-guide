// GridGuide — Tauri-Desktop-Assistent.
// Siehe spec/lastenheft.md (GG-MVP-001, GG-ARCH-001..008) und
// docs/plan/adr/0003-desktop-runtime-tauri.md.
//
// M1-Welle-2-Stand: Tauri-Builder verdrahtet, greet als
// #[tauri::command] registriert. Hexagonale Adapter und Use-Cases
// folgen in M2..M7.

#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod adapters;
mod hexagon;

#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {name}, from GridGuide!")
}

/// Konfiguriert und startet die Tauri-Anwendung.
///
/// Ausgelagert aus `main()`, damit `main()` ein dreizeiliger Bootstrap
/// bleibt und die App-Konstruktion in Tests gegen einen Mock-Runtime
/// gefahren werden kann (folgt in M2+ mit echten Adaptern).
fn run() -> Result<(), tauri::Error> {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![greet])
        .run(tauri::generate_context!())
}

fn main() {
    run().expect("error while running tauri application");
}

#[cfg(test)]
mod tests {
    use super::greet;

    #[test]
    fn greet_includes_name_and_app() {
        let actual = greet("Alice");
        assert!(actual.contains("Alice"), "Name fehlt: {actual}");
        assert!(actual.contains("GridGuide"), "App-Name fehlt: {actual}");
    }

    #[test]
    fn greet_empty_name_still_returns_text() {
        let actual = greet("");
        assert!(actual.contains("GridGuide"));
    }
}
