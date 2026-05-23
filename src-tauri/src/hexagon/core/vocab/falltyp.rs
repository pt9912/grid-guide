// `FalltypId` — Kennung fuer die MVP-Minimalmenge der unterstuetzten
// Antragsfaelle. Siehe Lastenheft `GG-DATA-004`, Block `Falltyp`.
//
// Naming-Abweichung von der vocab/-Konvention: Lastenheft nennt das
// Vokabular `Falltyp`. Wir reservieren diesen Namen aber fuer die
// fachliche Entitaet `domain::Falltyp` (M2-W2 — Struct mit
// Pflichtfeld- und Pflichtunterlagen-Liste). Damit beide ohne
// Kollision koexistieren, traegt das Vokabular-Enum den
// DDD-typischen Suffix `Id`. Serde-Repraesentation bleibt
// unveraendert ("PV_NS_OhneSpeicher" etc.), GG-DATA-004 ist also
// fachlich identisch erfuellt.
//
// V1-Erweiterungen sind ausdruecklich vorgesehen; jede neue
// `FalltypId` braucht eine passende Pflichtfeld-/
// Pflichtunterlagenliste im `seed`-Modul.

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum FalltypId {
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
    use super::FalltypId;

    const ALLE_VARIANTEN: &[FalltypId] = &[
        FalltypId::Steckersolar,
        FalltypId::PvNsOhneSpeicher,
        FalltypId::PvNsMitSpeicher,
        FalltypId::PvAb135kW,
        FalltypId::Redispatch,
        FalltypId::Betreiberwechsel,
    ];

    #[test]
    fn round_trip_alle_varianten() {
        for variante in ALLE_VARIANTEN {
            let json = serde_json::to_string(variante).expect("serialize");
            let zurueck: FalltypId = serde_json::from_str(&json).expect("deserialize");
            assert_eq!(*variante, zurueck);
        }
    }

    #[test]
    fn json_repraesentation_entspricht_lastenheft() {
        let beispiele = [
            (FalltypId::Steckersolar, "\"Steckersolar\""),
            (FalltypId::PvNsOhneSpeicher, "\"PV_NS_OhneSpeicher\""),
            (FalltypId::PvNsMitSpeicher, "\"PV_NS_MitSpeicher\""),
            (FalltypId::PvAb135kW, "\"PV_Ab135kW\""),
            (FalltypId::Redispatch, "\"Redispatch\""),
            (FalltypId::Betreiberwechsel, "\"Betreiberwechsel\""),
        ];
        for (variante, erwartet) in beispiele {
            let json = serde_json::to_string(&variante).expect("serialize");
            assert_eq!(json, erwartet);
        }
    }
}
