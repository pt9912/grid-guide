// `Falltyp` — Konfiguration eines fachlichen Antragsfalls.
// Siehe Lastenheft `GG-DATA-004` (Vokabular `Falltyp`) und
// `GG-FA-VAL-001..003` (Pflichtfelder, Pflichtunterlagen,
// Plausibilitaetsregeln).
//
// Kritischer Domaincode gemaess GG-NFA-COV-002 (Pflichtfeld-/
// Pflichtunterlagen-Regeln); 90 %-Line-Coverage-Schwelle gilt.

use serde::{Deserialize, Serialize};

use super::ValidationError;
use crate::hexagon::core::vocab::{Dokumenttyp, FalltypId};

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct Falltyp {
    id: FalltypId,
    pflichtfelder: Vec<String>,
    pflichtunterlagen: Vec<Dokumenttyp>,
}

impl Falltyp {
    /// Konstruktor mit Validierung.
    ///
    /// Pflichtinvarianten:
    ///   - `pflichtfelder` nicht leer (jeder MVP-Falltyp benoetigt
    ///     mindestens ein Pflichtfeld).
    ///   - `pflichtunterlagen` darf leer sein (z. B. Steckersolar
    ///     ohne Pflichtdokumente moeglich).
    ///   - Keine Duplikate in `pflichtunterlagen`.
    pub fn try_new(
        id: FalltypId,
        pflichtfelder: Vec<String>,
        pflichtunterlagen: Vec<Dokumenttyp>,
    ) -> Result<Self, ValidationError> {
        if pflichtfelder.is_empty() {
            return Err(ValidationError::EmptyCollection {
                field: "pflichtfelder",
            });
        }
        if pflichtfelder.iter().any(|f| f.trim().is_empty()) {
            return Err(ValidationError::EmptyField {
                field: "pflichtfelder",
            });
        }
        if hat_duplikate(&pflichtunterlagen) {
            return Err(ValidationError::Inkonsistenz {
                field: "pflichtunterlagen",
                reason: "Duplikate sind nicht erlaubt",
            });
        }
        Ok(Self {
            id,
            pflichtfelder,
            pflichtunterlagen,
        })
    }

    pub fn id(&self) -> FalltypId {
        self.id
    }
    pub fn pflichtfelder(&self) -> &[String] {
        &self.pflichtfelder
    }
    pub fn pflichtunterlagen(&self) -> &[Dokumenttyp] {
        &self.pflichtunterlagen
    }
}

fn hat_duplikate<T: Eq + std::hash::Hash>(xs: &[T]) -> bool {
    let mut seen = std::collections::HashSet::with_capacity(xs.len());
    !xs.iter().all(|x| seen.insert(x))
}

#[cfg(test)]
mod tests {
    use super::{hat_duplikate, Dokumenttyp, Falltyp, FalltypId, ValidationError};

    fn baue() -> Falltyp {
        Falltyp::try_new(
            FalltypId::PvNsOhneSpeicher,
            vec!["applicant".into(), "site".into()],
            vec![Dokumenttyp::Lageplan, Dokumenttyp::Datenblatt],
        )
        .expect("happy-path baut")
    }

    #[test]
    fn happy_path() {
        let f = baue();
        assert_eq!(f.id(), FalltypId::PvNsOhneSpeicher);
        assert_eq!(f.pflichtfelder(), &["applicant".to_string(), "site".into()]);
        assert_eq!(
            f.pflichtunterlagen(),
            &[Dokumenttyp::Lageplan, Dokumenttyp::Datenblatt]
        );
    }

    #[test]
    fn pflichtunterlagen_duerfen_leer_sein() {
        let f = Falltyp::try_new(FalltypId::Steckersolar, vec!["applicant".into()], vec![])
            .expect("baut");
        assert!(f.pflichtunterlagen().is_empty());
    }

    #[test]
    fn leere_pflichtfelder_abgelehnt() {
        let err = Falltyp::try_new(FalltypId::PvNsOhneSpeicher, vec![], vec![]).unwrap_err();
        assert!(matches!(
            err,
            ValidationError::EmptyCollection {
                field: "pflichtfelder"
            }
        ));
    }

    #[test]
    fn pflichtfeld_mit_leerem_string_abgelehnt() {
        let err = Falltyp::try_new(
            FalltypId::PvNsOhneSpeicher,
            vec!["applicant".into(), "  ".into()],
            vec![],
        )
        .unwrap_err();
        assert!(matches!(
            err,
            ValidationError::EmptyField {
                field: "pflichtfelder"
            }
        ));
    }

    #[test]
    fn doppelte_pflichtunterlagen_abgelehnt() {
        let err = Falltyp::try_new(
            FalltypId::PvNsOhneSpeicher,
            vec!["applicant".into()],
            vec![Dokumenttyp::Lageplan, Dokumenttyp::Lageplan],
        )
        .unwrap_err();
        assert!(matches!(
            err,
            ValidationError::Inkonsistenz {
                field: "pflichtunterlagen",
                ..
            }
        ));
    }

    #[test]
    fn serde_round_trip() {
        let f = baue();
        let json = serde_json::to_string(&f).expect("serialize");
        let zurueck: Falltyp = serde_json::from_str(&json).expect("deserialize");
        assert_eq!(f, zurueck);
    }

    #[test]
    fn hat_duplikate_helper() {
        assert!(!hat_duplikate::<&str>(&[]));
        assert!(!hat_duplikate(&["a", "b", "c"]));
        assert!(hat_duplikate(&["a", "b", "a"]));
    }
}
