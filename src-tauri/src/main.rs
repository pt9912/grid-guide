// GridGuide — Tauri-Desktop-Assistent.
// Siehe spec/lastenheft.md (GG-MVP-001, GG-ARCH-001..008) und
// docs/plan/adr/0003-desktop-runtime-tauri.md.
//
// M1-Welle-1-Skelett: nur Hexagon-Layout-Stubs plus eine triviale
// greet-Funktion. Tauri-Runtime-Integration (Commands, Webview)
// folgt in M1-Welle 2.

mod adapters;
mod hexagon;

fn greet(name: &str) -> String {
    format!("Hello, {name}, from GridGuide!")
}

fn main() {
    println!("{}", greet("World"));
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
