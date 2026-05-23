// `Profiltyp` — Kontrolliertes Vokabular fuer Profil-Quellen.
// Siehe Lastenheft `GG-DATA-004`, Block `Profiltyp`.

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum Profiltyp {
    Netzbetreiber,
    Uebertragungsnetzbetreiber,
    Behoerde,
    Register,
    Branchenquelle,
}

#[cfg(test)]
mod tests {
    use super::Profiltyp;

    const ALLE_VARIANTEN: &[Profiltyp] = &[
        Profiltyp::Netzbetreiber,
        Profiltyp::Uebertragungsnetzbetreiber,
        Profiltyp::Behoerde,
        Profiltyp::Register,
        Profiltyp::Branchenquelle,
    ];

    #[test]
    fn round_trip_alle_varianten() {
        for variante in ALLE_VARIANTEN {
            let json = serde_json::to_string(variante).expect("serialize darf nicht scheitern");
            let zurueck: Profiltyp =
                serde_json::from_str(&json).expect("deserialize darf nicht scheitern");
            assert_eq!(*variante, zurueck, "round-trip muss verlustfrei sein");
        }
    }

    #[test]
    fn json_repraesentation_entspricht_lastenheft() {
        // Lastenheft GG-DATA-004 schreibt die Variantennamen woertlich
        // vor; der Test fixiert diesen Vertrag fuer Profiltyp.
        let beispiele = [
            (Profiltyp::Netzbetreiber, "\"Netzbetreiber\""),
            (
                Profiltyp::Uebertragungsnetzbetreiber,
                "\"Uebertragungsnetzbetreiber\"",
            ),
            (Profiltyp::Behoerde, "\"Behoerde\""),
            (Profiltyp::Register, "\"Register\""),
            (Profiltyp::Branchenquelle, "\"Branchenquelle\""),
        ];
        for (variante, erwartet) in beispiele {
            let json = serde_json::to_string(&variante).expect("serialize");
            assert_eq!(json, erwartet);
        }
    }
}
