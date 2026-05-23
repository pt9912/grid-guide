// `Profilversion` — versionierte Momentaufnahme eines Profils.
// Siehe Lastenheft `GG-DATA-005` (Profilversionierung).
//
// Kritischer Domaincode gemaess GG-NFA-COV-002 (Profil- und
// Profilversionsverwaltung); 90 %-Line-Coverage-Schwelle gilt.

use serde::{Deserialize, Serialize};

use super::ValidationError;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct Profilversion {
    version_id: String,
    retrieved_at: String,
    source_url: String,
    notes: Option<String>,
}

impl Profilversion {
    /// Konstruktor mit Validierung. Konventionen aus GG-DATA-005:
    ///   - `version_id`: kalenderbasierter Bezeichner `YYYY-MM-DD`.
    ///   - `retrieved_at`: ISO-Datum (im MVP `YYYY-MM-DD`; volle
    ///     Zeitstempel waeren V1).
    ///   - `source_url`: nicht leer.
    pub fn try_new(
        version_id: String,
        retrieved_at: String,
        source_url: String,
        notes: Option<String>,
    ) -> Result<Self, ValidationError> {
        if !is_calendar_date(&version_id) {
            return Err(ValidationError::InvalidFormat {
                field: "version_id",
                reason: "erwartet YYYY-MM-DD",
            });
        }
        if !is_calendar_date(&retrieved_at) {
            return Err(ValidationError::InvalidFormat {
                field: "retrieved_at",
                reason: "erwartet YYYY-MM-DD (ISO 8601 Datumsteil)",
            });
        }
        if source_url.trim().is_empty() {
            return Err(ValidationError::EmptyField {
                field: "source_url",
            });
        }
        Ok(Self {
            version_id,
            retrieved_at,
            source_url,
            notes,
        })
    }

    pub fn version_id(&self) -> &str {
        &self.version_id
    }
    pub fn retrieved_at(&self) -> &str {
        &self.retrieved_at
    }
    pub fn source_url(&self) -> &str {
        &self.source_url
    }
    pub fn notes(&self) -> Option<&str> {
        self.notes.as_deref()
    }
}

/// `YYYY-MM-DD`-Format ohne Wertebereich-Pruefung von Monat/Tag.
/// Volle Kalender-Plausibilitaet ist V1 (braucht `chrono` oder
/// `time`); fuer M2 reicht der Format-Vertrag.
fn is_calendar_date(s: &str) -> bool {
    if s.len() != 10 {
        return false;
    }
    let bytes = s.as_bytes();
    bytes[4] == b'-'
        && bytes[7] == b'-'
        && bytes[0..4].iter().all(u8::is_ascii_digit)
        && bytes[5..7].iter().all(u8::is_ascii_digit)
        && bytes[8..10].iter().all(u8::is_ascii_digit)
}

#[cfg(test)]
mod tests {
    use super::{is_calendar_date, Profilversion, ValidationError};

    fn baue() -> Profilversion {
        Profilversion::try_new(
            "2026-05-23".into(),
            "2026-05-23".into(),
            "https://example.de/katalog".into(),
            Some("Erstabruf".into()),
        )
        .expect("happy-path muss bauen")
    }

    #[test]
    fn happy_path_baut_und_getter_geben_pflichtfelder_zurueck() {
        let v = baue();
        assert_eq!(v.version_id(), "2026-05-23");
        assert_eq!(v.retrieved_at(), "2026-05-23");
        assert_eq!(v.source_url(), "https://example.de/katalog");
        assert_eq!(v.notes(), Some("Erstabruf"));
    }

    #[test]
    fn notes_optional_darf_none_sein() {
        let v = Profilversion::try_new(
            "2026-05-23".into(),
            "2026-05-23".into(),
            "https://example.de".into(),
            None,
        )
        .expect("baut");
        assert_eq!(v.notes(), None);
    }

    #[test]
    fn version_id_ohne_yyyy_mm_dd_wird_abgelehnt() {
        let err = Profilversion::try_new(
            "23.05.2026".into(),
            "2026-05-23".into(),
            "https://example.de".into(),
            None,
        )
        .unwrap_err();
        assert!(matches!(
            err,
            ValidationError::InvalidFormat {
                field: "version_id",
                ..
            }
        ));
    }

    #[test]
    fn retrieved_at_ohne_yyyy_mm_dd_wird_abgelehnt() {
        let err = Profilversion::try_new(
            "2026-05-23".into(),
            "23.05.2026".into(),
            "https://example.de".into(),
            None,
        )
        .unwrap_err();
        assert!(matches!(
            err,
            ValidationError::InvalidFormat {
                field: "retrieved_at",
                ..
            }
        ));
    }

    #[test]
    fn leere_source_url_wird_abgelehnt() {
        let err =
            Profilversion::try_new("2026-05-23".into(), "2026-05-23".into(), "   ".into(), None)
                .unwrap_err();
        assert!(matches!(
            err,
            ValidationError::EmptyField {
                field: "source_url"
            }
        ));
    }

    #[test]
    fn serde_round_trip_erhaelt_alle_felder() {
        let v = baue();
        let json = serde_json::to_string(&v).expect("serialize");
        let zurueck: Profilversion = serde_json::from_str(&json).expect("deserialize");
        assert_eq!(v, zurueck);
    }

    #[test]
    fn is_calendar_date_akzeptiert_und_lehnt_ab() {
        // Sanity-Test fuer den internen Format-Pruefer — fixiert die
        // Heuristik (Laenge 10, Trennzeichen an Position 4 und 7,
        // Rest ASCII-Ziffern).
        assert!(is_calendar_date("2026-05-23"));
        assert!(is_calendar_date("0000-00-00")); // Format ok, Wertebereich V1
        assert!(!is_calendar_date(""));
        assert!(!is_calendar_date("26-05-23"));
        assert!(!is_calendar_date("2026-05-23T12:00"));
        assert!(!is_calendar_date("2026/05/23"));
        assert!(!is_calendar_date("2026-AB-23"));
    }
}
