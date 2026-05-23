// `Nachnutzungsstatus` — Lizenz-/Nachnutzungslage einer Quelle.
// Siehe Lastenheft `GG-DATA-004`, Block `Nachnutzungsstatus`.

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum Nachnutzungsstatus {
    OffeneLizenz,
    KeineOffeneLizenzErsichtlich,
    Unbekannt,
    NurVerlinken,
}

#[cfg(test)]
mod tests {
    use super::Nachnutzungsstatus;

    const ALLE_VARIANTEN: &[Nachnutzungsstatus] = &[
        Nachnutzungsstatus::OffeneLizenz,
        Nachnutzungsstatus::KeineOffeneLizenzErsichtlich,
        Nachnutzungsstatus::Unbekannt,
        Nachnutzungsstatus::NurVerlinken,
    ];

    #[test]
    fn round_trip_alle_varianten() {
        for variante in ALLE_VARIANTEN {
            let json = serde_json::to_string(variante).expect("serialize");
            let zurueck: Nachnutzungsstatus = serde_json::from_str(&json).expect("deserialize");
            assert_eq!(*variante, zurueck);
        }
    }

    #[test]
    fn json_repraesentation_entspricht_lastenheft() {
        let beispiele = [
            (Nachnutzungsstatus::OffeneLizenz, "\"OffeneLizenz\""),
            (
                Nachnutzungsstatus::KeineOffeneLizenzErsichtlich,
                "\"KeineOffeneLizenzErsichtlich\"",
            ),
            (Nachnutzungsstatus::Unbekannt, "\"Unbekannt\""),
            (Nachnutzungsstatus::NurVerlinken, "\"NurVerlinken\""),
        ];
        for (variante, erwartet) in beispiele {
            let json = serde_json::to_string(&variante).expect("serialize");
            assert_eq!(json, erwartet);
        }
    }
}
