// Immutable Domain-Strukturen (M2-Welle 2).
// Siehe `spec/architecture.md` §3 (`GG-AR-COMP-*`),
// Lastenheft `GG-CC-007` (Immutable Domain-Objekte),
// `GG-FA-CAT-001` (Profile), `GG-DATA-005` (Profilversion),
// `GG-FA-VAL-001..003` (Falltyp-Pflichtfelder/-unterlagen).
//
// Aufteilung in kritisch (90 %-Schwelle gemaess GG-NFA-COV-002)
// und unkritisch (80 % gemaess GG-NFA-COV-001):
//   - kritisch: profile.rs, profilversion.rs, falltyp.rs
//   - unkritisch (Basis): project.rs, document.rs, warning.rs,
//     formularlink.rs, error.rs
//
// Die kritischen Pfade werden vom `make coverage-critical`-Target
// (siehe Makefile + tools/coverage-critical.sh) separat
// ausgewertet.

pub mod document;
pub mod error;
pub mod falltyp;
pub mod formularlink;
pub mod profile;
pub mod profilversion;
pub mod project;
pub mod warning;

pub use document::Document;
pub use error::ValidationError;
pub use falltyp::Falltyp;
pub use formularlink::Formularlink;
pub use profile::Profile;
pub use profilversion::Profilversion;
pub use project::Project;
pub use warning::{Warning, WarningLevel};
