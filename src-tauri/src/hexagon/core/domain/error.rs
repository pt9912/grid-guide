// Validierungsfehler beim Bau immutable Domain-Strukturen.
// Siehe Lastenheft `GG-CC-007` (Immutable Domain-Objekte) — wir
// verhindern teilkonstruierte ungueltige Objekte, indem alle
// Konstruktoren `Result<Self, ValidationError>` zurueckgeben.

use std::fmt;

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ValidationError {
    /// Pflichtfeld leer oder fehlend.
    EmptyField { field: &'static str },
    /// Pflichtkollektion (z. B. `formularlinks`) leer.
    EmptyCollection { field: &'static str },
    /// Format eines Strings entspricht nicht dem Vertrag (z. B.
    /// `YYYY-MM-DD` fuer Datumsfelder).
    InvalidFormat {
        field: &'static str,
        reason: &'static str,
    },
    /// Fachliche Bedingung verletzt (z. B. `bekannte_falltypen`
    /// muss bei `SehrGutErschlossen`/`GutErschlossen` nicht-leer
    /// sein, vgl. GG-FA-CAT-001).
    Inkonsistenz {
        field: &'static str,
        reason: &'static str,
    },
}

impl fmt::Display for ValidationError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::EmptyField { field } => {
                write!(f, "Pflichtfeld `{field}` ist leer")
            }
            Self::EmptyCollection { field } => {
                write!(f, "Pflichtkollektion `{field}` ist leer")
            }
            Self::InvalidFormat { field, reason } => {
                write!(f, "Feld `{field}` hat ungueltiges Format: {reason}")
            }
            Self::Inkonsistenz { field, reason } => {
                write!(f, "Inkonsistenz in `{field}`: {reason}")
            }
        }
    }
}

impl std::error::Error for ValidationError {}

#[cfg(test)]
mod tests {
    use super::ValidationError;

    #[test]
    fn display_pro_variante() {
        // jede Variante hat eine eigene Display-Form; der Test fixiert
        // die deutschsprachige Formulierung, damit aenderungen sichtbar
        // werden.
        let beispiele = [
            (
                ValidationError::EmptyField { field: "name" },
                "Pflichtfeld `name` ist leer",
            ),
            (
                ValidationError::EmptyCollection {
                    field: "formularlinks",
                },
                "Pflichtkollektion `formularlinks` ist leer",
            ),
            (
                ValidationError::InvalidFormat {
                    field: "version_id",
                    reason: "erwartet YYYY-MM-DD",
                },
                "Feld `version_id` hat ungueltiges Format: erwartet YYYY-MM-DD",
            ),
            (
                ValidationError::Inkonsistenz {
                    field: "bekannte_falltypen",
                    reason: "darf bei SehrGutErschlossen nicht leer sein",
                },
                "Inkonsistenz in `bekannte_falltypen`: darf bei SehrGutErschlossen nicht leer sein",
            ),
        ];
        for (err, erwartet) in beispiele {
            assert_eq!(format!("{err}"), erwartet);
        }
    }

    #[test]
    fn ist_std_error() {
        // Sanity: ValidationError implementiert std::error::Error,
        // damit es ueber Boxen/Trait-Objekte propagiert werden kann.
        fn akzeptiert_std_error(_: &dyn std::error::Error) {}
        akzeptiert_std_error(&ValidationError::EmptyField { field: "x" });
    }
}
