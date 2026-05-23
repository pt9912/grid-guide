// Kontrollierte Vokabulare gemaess Lastenheft `GG-DATA-004`.
//
// Konvention:
//   - Eine Datei pro Vokabular, identifier-gleichnamiges Enum.
//   - Strikt `#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash,
//     Serialize, Deserialize)]` — Vokabulare sind value-objects
//     gemaess `GG-CC-007` (Immutable Domain-Objekte).
//   - Variantennamen folgen Rust-Konvention (PascalCase, keine
//     Unterstriche). Wo das Lastenheft eine andere Schreibweise
//     vorsieht (Akronyme, `PV_NS_OhneSpeicher`), uebersetzt
//     `#[serde(rename = "<Lastenheft-Form>")]` die externe
//     Repraesentation zurueck — die Lastenheft-Schreibweise ist
//     der Vertrag fuer JSON/TOML.
//   - Jedes Modul enthaelt einen `round_trip_alle_varianten`-Test
//     (alle Varianten serialisieren -> deserialisieren -> identisch),
//     der die Serde-Bindings absichert und gleichzeitig die
//     Coverage-Schwelle aus `GG-NFA-COV-001` (80 % Lines) trifft.

pub mod anlagenart;
pub mod dokumenttyp;
pub mod falltyp;
pub mod katalogstatus;
pub mod nachnutzungsstatus;
pub mod profiltyp;
pub mod quellkatalog;
pub mod xlsx_zweck;
pub mod zugangsart;

pub use anlagenart::Anlagenart;
pub use dokumenttyp::Dokumenttyp;
pub use falltyp::Falltyp;
pub use katalogstatus::Katalogstatus;
pub use nachnutzungsstatus::Nachnutzungsstatus;
pub use profiltyp::Profiltyp;
pub use quellkatalog::Quellkatalog;
pub use xlsx_zweck::XlsxZweck;
pub use zugangsart::Zugangsart;
