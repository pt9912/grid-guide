// `Project` — minimale Datenstruktur eines Antragsprojekts.
// Siehe Lastenheft `GG-FA-PROJ-001` (Projekt-Anlage),
// `GG-FA-PROJ-002` (Lifecycle - in M3).
//
// M2 enthaelt nur das Skelett: Name, gewaehlter Falltyp, gewaehltes
// Profil. Formularwerte (`GG-DATA-001`/-002) sowie Lifecycle-
// Verhalten kommen in M3+.

use serde::{Deserialize, Serialize};

use super::ValidationError;
use crate::hexagon::core::vocab::FalltypId;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct Project {
    name: String,
    falltyp_id: FalltypId,
    profil_name: String,
}

impl Project {
    pub fn try_new(
        name: String,
        falltyp_id: FalltypId,
        profil_name: String,
    ) -> Result<Self, ValidationError> {
        if name.trim().is_empty() {
            return Err(ValidationError::EmptyField { field: "name" });
        }
        if profil_name.trim().is_empty() {
            return Err(ValidationError::EmptyField {
                field: "profil_name",
            });
        }
        Ok(Self {
            name,
            falltyp_id,
            profil_name,
        })
    }

    pub fn name(&self) -> &str {
        &self.name
    }
    pub fn falltyp_id(&self) -> FalltypId {
        self.falltyp_id
    }
    pub fn profil_name(&self) -> &str {
        &self.profil_name
    }
}

#[cfg(test)]
mod tests {
    use super::{FalltypId, Project, ValidationError};

    #[test]
    fn happy_path() {
        let p = Project::try_new(
            "Antrag #1".into(),
            FalltypId::PvNsOhneSpeicher,
            "Westnetz".into(),
        )
        .expect("baut");
        assert_eq!(p.name(), "Antrag #1");
        assert_eq!(p.falltyp_id(), FalltypId::PvNsOhneSpeicher);
        assert_eq!(p.profil_name(), "Westnetz");
    }

    #[test]
    fn leerer_name_abgelehnt() {
        let err =
            Project::try_new("  ".into(), FalltypId::PvNsOhneSpeicher, "X".into()).unwrap_err();
        assert!(matches!(err, ValidationError::EmptyField { field: "name" }));
    }

    #[test]
    fn leerer_profil_name_abgelehnt() {
        let err = Project::try_new("Antrag".into(), FalltypId::PvNsOhneSpeicher, String::new())
            .unwrap_err();
        assert!(matches!(
            err,
            ValidationError::EmptyField {
                field: "profil_name"
            }
        ));
    }

    #[test]
    fn serde_round_trip() {
        let p = Project::try_new("A".into(), FalltypId::Steckersolar, "P".into()).expect("baut");
        let json = serde_json::to_string(&p).expect("ser");
        let zurueck: Project = serde_json::from_str(&json).expect("de");
        assert_eq!(p, zurueck);
    }
}
