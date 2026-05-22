// Bewusster Verstoss gegen Rule A (GG-ARCH-003 / GG-CC-003) in der
// erweiterten Form: `pub use` re-exportiert eine Framework-API aus
// hexagon/core. Aus semantischer Sicht ist das genauso verboten wie
// ein direktes `use`, weil andere Module dadurch transitiv Tauri-API
// aus core erhalten — Domain wird zur Framework-Brueckendomain.
//
// Dieser File darf nur durch `ARCH_CHECK_FIXTURES=on make arch-check`
// geprueft werden — er liegt ausserhalb des Cargo-Builds und ist
// kein produktiver Code.

#[allow(unused_imports)]
pub use tauri::Manager;
