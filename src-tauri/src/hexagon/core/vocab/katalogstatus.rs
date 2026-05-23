// `Katalogstatus` — Erschliessungsgrad einer Quelle.
// Siehe Lastenheft `GG-DATA-004`, Block `Katalogstatus`.

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum Katalogstatus {
    SehrGutErschlossen,
    GutErschlossen,
    TeilweiseErschlossen,
    NichtVerifiziert,
}

#[cfg(test)]
mod tests {
    use super::Katalogstatus;

    const ALLE_VARIANTEN: &[Katalogstatus] = &[
        Katalogstatus::SehrGutErschlossen,
        Katalogstatus::GutErschlossen,
        Katalogstatus::TeilweiseErschlossen,
        Katalogstatus::NichtVerifiziert,
    ];

    #[test]
    fn round_trip_alle_varianten() {
        for variante in ALLE_VARIANTEN {
            let json = serde_json::to_string(variante).expect("serialize");
            let zurueck: Katalogstatus = serde_json::from_str(&json).expect("deserialize");
            assert_eq!(*variante, zurueck);
        }
    }

    #[test]
    fn json_repraesentation_entspricht_lastenheft() {
        let beispiele = [
            (Katalogstatus::SehrGutErschlossen, "\"SehrGutErschlossen\""),
            (Katalogstatus::GutErschlossen, "\"GutErschlossen\""),
            (
                Katalogstatus::TeilweiseErschlossen,
                "\"TeilweiseErschlossen\"",
            ),
            (Katalogstatus::NichtVerifiziert, "\"NichtVerifiziert\""),
        ];
        for (variante, erwartet) in beispiele {
            let json = serde_json::to_string(&variante).expect("serialize");
            assert_eq!(json, erwartet);
        }
    }
}
