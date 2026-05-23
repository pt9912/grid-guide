// `Document` — Metadaten eines an einen Antrag angehangenen
// Dokuments. Siehe Lastenheft `GG-DATA-001` (`evidence`),
// `GG-MVP-005`/`GG-FA-DOC-001` (Dokumentanalyse).
//
// M2 enthaelt nur die Metadaten-Form (`dateiname`, `typ`); Bytes
// und Extraktion sind M4+.

use serde::{Deserialize, Serialize};

use super::ValidationError;
use crate::hexagon::core::vocab::Dokumenttyp;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct Document {
    dateiname: String,
    typ: Dokumenttyp,
}

impl Document {
    pub fn try_new(dateiname: String, typ: Dokumenttyp) -> Result<Self, ValidationError> {
        if dateiname.trim().is_empty() {
            return Err(ValidationError::EmptyField { field: "dateiname" });
        }
        Ok(Self { dateiname, typ })
    }

    pub fn dateiname(&self) -> &str {
        &self.dateiname
    }
    pub fn typ(&self) -> Dokumenttyp {
        self.typ
    }
}

#[cfg(test)]
mod tests {
    use super::{Document, Dokumenttyp, ValidationError};

    #[test]
    fn happy_path() {
        let d = Document::try_new("lageplan.pdf".into(), Dokumenttyp::Lageplan).expect("baut");
        assert_eq!(d.dateiname(), "lageplan.pdf");
        assert_eq!(d.typ(), Dokumenttyp::Lageplan);
    }

    #[test]
    fn leerer_dateiname_abgelehnt() {
        let err = Document::try_new("  ".into(), Dokumenttyp::Unbekannt).unwrap_err();
        assert!(matches!(
            err,
            ValidationError::EmptyField { field: "dateiname" }
        ));
    }

    #[test]
    fn serde_round_trip() {
        let d = Document::try_new("a.pdf".into(), Dokumenttyp::Datenblatt).expect("baut");
        let json = serde_json::to_string(&d).expect("ser");
        let zurueck: Document = serde_json::from_str(&json).expect("de");
        assert_eq!(d, zurueck);
    }
}
