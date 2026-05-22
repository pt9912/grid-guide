// Bewusster Verstoss gegen Rule B (GG-CC-002):
// hexagon/ports/* enthalten nur Trait-/Typdefinitionen, keine
// konkreten impl-Bloecke mit Methodenkoerper.
//
// Dieser File darf nur durch `ARCH_CHECK_FIXTURES=on make arch-check`
// geprueft werden — er liegt ausserhalb des Cargo-Builds und ist
// kein produktiver Code.

#[allow(dead_code)]
pub trait DocumentReader {
    fn read(&self, path: &str) -> String;
}

#[allow(dead_code)]
pub struct InlinePdfReader;

impl DocumentReader for InlinePdfReader {
    fn read(&self, _path: &str) -> String {
        // Konkrete Logik in ports/ — bricht die Hexagon-Tabu.
        String::from("dies gehoert in adapters/, nicht in ports/")
    }
}
