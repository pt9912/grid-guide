// `Quellkatalog` — Welches Katalog-Format ein Profil bereitstellt.
// Siehe Lastenheft `GG-DATA-004`, Block `Quellkatalog`.

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum Quellkatalog {
    #[serde(rename = "PDF")]
    Pdf,
    #[serde(rename = "XLSX")]
    Xlsx,
    Beide,
}

#[cfg(test)]
mod tests {
    use super::Quellkatalog;

    const ALLE_VARIANTEN: &[Quellkatalog] =
        &[Quellkatalog::Pdf, Quellkatalog::Xlsx, Quellkatalog::Beide];

    #[test]
    fn round_trip_alle_varianten() {
        for variante in ALLE_VARIANTEN {
            let json = serde_json::to_string(variante).expect("serialize");
            let zurueck: Quellkatalog = serde_json::from_str(&json).expect("deserialize");
            assert_eq!(*variante, zurueck);
        }
    }

    #[test]
    fn json_repraesentation_entspricht_lastenheft() {
        let beispiele = [
            (Quellkatalog::Pdf, "\"PDF\""),
            (Quellkatalog::Xlsx, "\"XLSX\""),
            (Quellkatalog::Beide, "\"Beide\""),
        ];
        for (variante, erwartet) in beispiele {
            let json = serde_json::to_string(&variante).expect("serialize");
            assert_eq!(json, erwartet);
        }
    }
}
