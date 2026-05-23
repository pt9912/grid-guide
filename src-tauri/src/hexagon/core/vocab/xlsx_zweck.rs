// `XlsxZweck` — Klassifikation von XLSX-Quellen gemaess `GG-FA-CAT-005`.
// Siehe Lastenheft `GG-DATA-004`, Block `XlsxZweck`.

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum XlsxZweck {
    Formular,
    Hilfsdatei,
    Stammdatendatei,
    RedispatchDatei,
    Branchenhilfe,
}

#[cfg(test)]
mod tests {
    use super::XlsxZweck;

    const ALLE_VARIANTEN: &[XlsxZweck] = &[
        XlsxZweck::Formular,
        XlsxZweck::Hilfsdatei,
        XlsxZweck::Stammdatendatei,
        XlsxZweck::RedispatchDatei,
        XlsxZweck::Branchenhilfe,
    ];

    #[test]
    fn round_trip_alle_varianten() {
        for variante in ALLE_VARIANTEN {
            let json = serde_json::to_string(variante).expect("serialize");
            let zurueck: XlsxZweck = serde_json::from_str(&json).expect("deserialize");
            assert_eq!(*variante, zurueck);
        }
    }

    #[test]
    fn json_repraesentation_entspricht_lastenheft() {
        let beispiele = [
            (XlsxZweck::Formular, "\"Formular\""),
            (XlsxZweck::Hilfsdatei, "\"Hilfsdatei\""),
            (XlsxZweck::Stammdatendatei, "\"Stammdatendatei\""),
            (XlsxZweck::RedispatchDatei, "\"RedispatchDatei\""),
            (XlsxZweck::Branchenhilfe, "\"Branchenhilfe\""),
        ];
        for (variante, erwartet) in beispiele {
            let json = serde_json::to_string(&variante).expect("serialize");
            assert_eq!(json, erwartet);
        }
    }
}
