// `Anlagenart` — Technische Art einer Erzeugungsanlage.
// Siehe Lastenheft `GG-DATA-004`, Block `Anlagenart`.

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum Anlagenart {
    #[serde(rename = "PV")]
    Pv,
    #[serde(rename = "PVmitSpeicher")]
    PvMitSpeicher,
    Speicher,
    #[serde(rename = "BHKW")]
    Bhkw,
    Wind,
    Sonstige,
}

#[cfg(test)]
mod tests {
    use super::Anlagenart;

    const ALLE_VARIANTEN: &[Anlagenart] = &[
        Anlagenart::Pv,
        Anlagenart::PvMitSpeicher,
        Anlagenart::Speicher,
        Anlagenart::Bhkw,
        Anlagenart::Wind,
        Anlagenart::Sonstige,
    ];

    #[test]
    fn round_trip_alle_varianten() {
        for variante in ALLE_VARIANTEN {
            let json = serde_json::to_string(variante).expect("serialize");
            let zurueck: Anlagenart = serde_json::from_str(&json).expect("deserialize");
            assert_eq!(*variante, zurueck);
        }
    }

    #[test]
    fn json_repraesentation_entspricht_lastenheft() {
        let beispiele = [
            (Anlagenart::Pv, "\"PV\""),
            (Anlagenart::PvMitSpeicher, "\"PVmitSpeicher\""),
            (Anlagenart::Speicher, "\"Speicher\""),
            (Anlagenart::Bhkw, "\"BHKW\""),
            (Anlagenart::Wind, "\"Wind\""),
            (Anlagenart::Sonstige, "\"Sonstige\""),
        ];
        for (variante, erwartet) in beispiele {
            let json = serde_json::to_string(&variante).expect("serialize");
            assert_eq!(json, erwartet);
        }
    }
}
