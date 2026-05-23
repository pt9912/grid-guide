// `Warning` — Validierungs-Hinweis aus der Regel-Engine.
// Siehe Lastenheft `GG-FA-VAL-001..003` (Pflichtfeld-,
// Pflichtunterlagen- und Plausibilitaetsregeln).
//
// M2 liefert nur die Datenstruktur; die Erzeugung erfolgt in
// M4 (Regel-Engine).

use serde::{Deserialize, Serialize};

use super::ValidationError;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum WarningLevel {
    Info,
    Warn,
    Error,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct Warning {
    level: WarningLevel,
    nachricht: String,
    bezogen_auf: Option<String>,
}

impl Warning {
    pub fn try_new(
        level: WarningLevel,
        nachricht: String,
        bezogen_auf: Option<String>,
    ) -> Result<Self, ValidationError> {
        if nachricht.trim().is_empty() {
            return Err(ValidationError::EmptyField { field: "nachricht" });
        }
        Ok(Self {
            level,
            nachricht,
            bezogen_auf,
        })
    }

    pub fn level(&self) -> WarningLevel {
        self.level
    }
    pub fn nachricht(&self) -> &str {
        &self.nachricht
    }
    pub fn bezogen_auf(&self) -> Option<&str> {
        self.bezogen_auf.as_deref()
    }
}

#[cfg(test)]
mod tests {
    use super::{ValidationError, Warning, WarningLevel};

    #[test]
    fn happy_path() {
        let w = Warning::try_new(
            WarningLevel::Warn,
            "Pflichtfeld fehlt".into(),
            Some("site".into()),
        )
        .expect("baut");
        assert_eq!(w.level(), WarningLevel::Warn);
        assert_eq!(w.nachricht(), "Pflichtfeld fehlt");
        assert_eq!(w.bezogen_auf(), Some("site"));
    }

    #[test]
    fn bezogen_auf_optional() {
        let w = Warning::try_new(WarningLevel::Info, "info".into(), None).expect("baut");
        assert_eq!(w.bezogen_auf(), None);
    }

    #[test]
    fn leere_nachricht_abgelehnt() {
        let err = Warning::try_new(WarningLevel::Error, "   ".into(), None).unwrap_err();
        assert!(matches!(
            err,
            ValidationError::EmptyField { field: "nachricht" }
        ));
    }

    #[test]
    fn level_round_trip() {
        for lvl in [WarningLevel::Info, WarningLevel::Warn, WarningLevel::Error] {
            let json = serde_json::to_string(&lvl).expect("ser");
            let zurueck: WarningLevel = serde_json::from_str(&json).expect("de");
            assert_eq!(lvl, zurueck);
        }
    }
}
