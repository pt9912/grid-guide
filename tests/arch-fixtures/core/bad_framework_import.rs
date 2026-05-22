// Bewusster Verstoss gegen Rule A (GG-ARCH-003 / GG-CC-003):
// hexagon/core darf keine Framework-/Adapter-Crates importieren.
//
// Dieser File darf nur durch `ARCH_CHECK_FIXTURES=on make arch-check`
// geprueft werden — er liegt ausserhalb des Cargo-Builds und ist
// kein produktiver Code.

use tauri::Manager;

#[allow(dead_code)]
fn this_should_never_be_in_core() {
    let _ = Manager::default();
}
