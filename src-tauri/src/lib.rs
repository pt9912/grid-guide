// GridGuide — testbarer Bibliotheks-Kern.
// Siehe spec/lastenheft.md (GG-MVP-001, GG-ARCH-001..008) und
// docs/plan/adr/0003-desktop-runtime-tauri.md.
//
// Standardmuster Tauri 2.x: die App-Konfiguration und der Tauri-
// Builder liegen in `lib.rs`, damit sie gegen `tauri::test::mock_*`
// (MockRuntime) ausgefuehrt werden koennen. src/main.rs ist nur
// noch der Wry-Bootstrap (drei Zeilen) und wird von der Coverage-
// Messung per `--ignore-filename-regex` ausgenommen.
//
// Hinweis: Der main.rs-Exclude steht im Spannungsfeld mit GG-NFA-
// COV-004 Teil 2 (Wiring-Code ist nicht excludable). Aufloesung
// triggert docs/plan/planning/open/013-rust-bootstrap-coverage-
// exception.md, sobald `tauri::test` ein synthetisches Beenden des
// app.run()-Loops anbietet oder ein Headless-Display-Backend
// verfuegbar wird.

use tauri::Runtime;

mod adapters;
pub mod hexagon;

#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {name}, from GridGuide!")
}

/// Konfiguriert einen Tauri-Builder mit allen App-spezifischen
/// Invoke-Handlern. Generisch ueber den Runtime, damit Tests den
/// `MockRuntime` nutzen koennen.
pub fn configure<R: Runtime>(builder: tauri::Builder<R>) -> tauri::Builder<R> {
    builder.invoke_handler(tauri::generate_handler![greet])
}

/// Startet die Tauri-Anwendung mit der Default-Runtime (`Wry`).
/// Aufrufer ist ausschliesslich `src/main.rs`. Aus der Coverage
/// strukturell ausgenommen, weil der `Wry`-Event-Loop ohne reales
/// Display nicht endet.
pub fn run() -> Result<(), tauri::Error> {
    configure(tauri::Builder::default()).run(tauri::generate_context!())
}

#[cfg(test)]
mod tests {
    use super::{configure, greet};

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

    #[test]
    fn configure_baut_app_mit_invoke_handler() {
        // Mock-Runtime statt Wry: kein echter Event-Loop, kein
        // Display. .build() laeuft komplett synchron durch und
        // schlaegt fehl, wenn `generate_handler![greet]` nicht
        // korrekt verdrahtet werden kann oder generate_context!()
        // tauri.conf.json nicht lesen kann.
        let builder = tauri::test::mock_builder();
        let _app = configure(builder)
            .build(tauri::test::mock_context(tauri::test::noop_assets()))
            .expect("App-Build mit Mock-Runtime muss erfolgreich sein");
    }
}
