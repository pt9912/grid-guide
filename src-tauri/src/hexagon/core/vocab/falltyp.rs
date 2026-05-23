// `Falltyp` — MVP-Minimalmenge der unterstuetzten Antragsfaelle.
// Siehe Lastenheft `GG-DATA-004`, Block `Falltyp`. V1-Erweiterungen
// sind ausdruecklich vorgesehen; jeder neue Falltyp braucht eine
// passende Pflichtfeld-/Pflichtunterlagenliste im `seed`-Modul.

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum Falltyp {
    Steckersolar,
    #[serde(rename = "PV_NS_OhneSpeicher")]
    PvNsOhneSpeicher,
    #[serde(rename = "PV_NS_MitSpeicher")]
    PvNsMitSpeicher,
    #[serde(rename = "PV_Ab135kW")]
    PvAb135kW,
    Redispatch,
    Betreiberwechsel,
}

#[cfg(test)]
mod tests {
    use super::Falltyp;

    const ALLE_VARIANTEN: &[Falltyp] = &[
        Falltyp::Steckersolar,
        Falltyp::PvNsOhneSpeicher,
        Falltyp::PvNsMitSpeicher,
        Falltyp::PvAb135kW,
        Falltyp::Redispatch,
        Falltyp::Betreiberwechsel,
    ];

    #[test]
    fn round_trip_alle_varianten() {
        for variante in ALLE_VARIANTEN {
            let json = serde_json::to_string(variante).expect("serialize");
            let zurueck: Falltyp = serde_json::from_str(&json).expect("deserialize");
            assert_eq!(*variante, zurueck);
        }
    }

    #[test]
    fn json_repraesentation_entspricht_lastenheft() {
        let beispiele = [
            (Falltyp::Steckersolar, "\"Steckersolar\""),
            (Falltyp::PvNsOhneSpeicher, "\"PV_NS_OhneSpeicher\""),
            (Falltyp::PvNsMitSpeicher, "\"PV_NS_MitSpeicher\""),
            (Falltyp::PvAb135kW, "\"PV_Ab135kW\""),
            (Falltyp::Redispatch, "\"Redispatch\""),
            (Falltyp::Betreiberwechsel, "\"Betreiberwechsel\""),
        ];
        for (variante, erwartet) in beispiele {
            let json = serde_json::to_string(&variante).expect("serialize");
            assert_eq!(json, erwartet);
        }
    }
}
