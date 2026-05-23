// `Dokumenttyp` — Klassifikation der Dokumente in einem Antrag.
// Siehe Lastenheft `GG-DATA-004`, Block `Dokumenttyp`.

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum Dokumenttyp {
    Formular,
    Zertifikat,
    Datenblatt,
    Lageplan,
    Messkonzept,
    Inbetriebsetzungsprotokoll,
    Betreiberwechselformular,
    Steuerformular,
    Unbekannt,
}

#[cfg(test)]
mod tests {
    use super::Dokumenttyp;

    const ALLE_VARIANTEN: &[Dokumenttyp] = &[
        Dokumenttyp::Formular,
        Dokumenttyp::Zertifikat,
        Dokumenttyp::Datenblatt,
        Dokumenttyp::Lageplan,
        Dokumenttyp::Messkonzept,
        Dokumenttyp::Inbetriebsetzungsprotokoll,
        Dokumenttyp::Betreiberwechselformular,
        Dokumenttyp::Steuerformular,
        Dokumenttyp::Unbekannt,
    ];

    #[test]
    fn round_trip_alle_varianten() {
        for variante in ALLE_VARIANTEN {
            let json = serde_json::to_string(variante).expect("serialize");
            let zurueck: Dokumenttyp = serde_json::from_str(&json).expect("deserialize");
            assert_eq!(*variante, zurueck);
        }
    }

    #[test]
    fn json_repraesentation_entspricht_lastenheft() {
        let beispiele = [
            (Dokumenttyp::Formular, "\"Formular\""),
            (Dokumenttyp::Zertifikat, "\"Zertifikat\""),
            (Dokumenttyp::Datenblatt, "\"Datenblatt\""),
            (Dokumenttyp::Lageplan, "\"Lageplan\""),
            (Dokumenttyp::Messkonzept, "\"Messkonzept\""),
            (
                Dokumenttyp::Inbetriebsetzungsprotokoll,
                "\"Inbetriebsetzungsprotokoll\"",
            ),
            (
                Dokumenttyp::Betreiberwechselformular,
                "\"Betreiberwechselformular\"",
            ),
            (Dokumenttyp::Steuerformular, "\"Steuerformular\""),
            (Dokumenttyp::Unbekannt, "\"Unbekannt\""),
        ];
        for (variante, erwartet) in beispiele {
            let json = serde_json::to_string(&variante).expect("serialize");
            assert_eq!(json, erwartet);
        }
    }
}
