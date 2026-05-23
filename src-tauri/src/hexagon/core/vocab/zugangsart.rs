// `Zugangsart` — Wie eine Quelle technisch erreichbar ist.
// Siehe Lastenheft `GG-DATA-004`, Block `Zugangsart`.

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum Zugangsart {
    #[serde(rename = "PDF")]
    Pdf,
    #[serde(rename = "XLSX")]
    Xlsx,
    Portal,
    #[serde(rename = "HTML")]
    Html,
    OnlineRegister,
    #[serde(rename = "ELSTER")]
    Elster,
}

#[cfg(test)]
mod tests {
    use super::Zugangsart;

    const ALLE_VARIANTEN: &[Zugangsart] = &[
        Zugangsart::Pdf,
        Zugangsart::Xlsx,
        Zugangsart::Portal,
        Zugangsart::Html,
        Zugangsart::OnlineRegister,
        Zugangsart::Elster,
    ];

    #[test]
    fn round_trip_alle_varianten() {
        for variante in ALLE_VARIANTEN {
            let json = serde_json::to_string(variante).expect("serialize");
            let zurueck: Zugangsart = serde_json::from_str(&json).expect("deserialize");
            assert_eq!(*variante, zurueck);
        }
    }

    #[test]
    fn json_repraesentation_entspricht_lastenheft() {
        let beispiele = [
            (Zugangsart::Pdf, "\"PDF\""),
            (Zugangsart::Xlsx, "\"XLSX\""),
            (Zugangsart::Portal, "\"Portal\""),
            (Zugangsart::Html, "\"HTML\""),
            (Zugangsart::OnlineRegister, "\"OnlineRegister\""),
            (Zugangsart::Elster, "\"ELSTER\""),
        ];
        for (variante, erwartet) in beispiele {
            let json = serde_json::to_string(&variante).expect("serialize");
            assert_eq!(json, erwartet);
        }
    }
}
