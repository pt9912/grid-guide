// `Formularlink` — Linkangabe zu einem Antragsformular eines Profils.
// Siehe Lastenheft `GG-FA-CAT-001` (Pflicht: mind. ein Formularlink
// mit URL + Anzeigename; optional gruppiert nach `GG-FA-CAT-008`-
// Formularfamilie).

use serde::{Deserialize, Serialize};

use super::ValidationError;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct Formularlink {
    url: String,
    anzeigename: String,
    formularfamilie: Option<String>,
}

impl Formularlink {
    pub fn try_new(
        url: String,
        anzeigename: String,
        formularfamilie: Option<String>,
    ) -> Result<Self, ValidationError> {
        if url.trim().is_empty() {
            return Err(ValidationError::EmptyField { field: "url" });
        }
        if anzeigename.trim().is_empty() {
            return Err(ValidationError::EmptyField {
                field: "anzeigename",
            });
        }
        Ok(Self {
            url,
            anzeigename,
            formularfamilie,
        })
    }

    pub fn url(&self) -> &str {
        &self.url
    }
    pub fn anzeigename(&self) -> &str {
        &self.anzeigename
    }
    pub fn formularfamilie(&self) -> Option<&str> {
        self.formularfamilie.as_deref()
    }
}

#[cfg(test)]
mod tests {
    use super::{Formularlink, ValidationError};

    #[test]
    fn happy_path() {
        let link = Formularlink::try_new(
            "https://example.de/formular".into(),
            "Antragsformular".into(),
            Some("PV-Familie".into()),
        )
        .expect("baut");
        assert_eq!(link.url(), "https://example.de/formular");
        assert_eq!(link.anzeigename(), "Antragsformular");
        assert_eq!(link.formularfamilie(), Some("PV-Familie"));
    }

    #[test]
    fn leere_url_abgelehnt() {
        let err = Formularlink::try_new(String::new(), "x".into(), None).unwrap_err();
        assert!(matches!(err, ValidationError::EmptyField { field: "url" }));
    }

    #[test]
    fn leerer_anzeigename_abgelehnt() {
        let err = Formularlink::try_new("https://x".into(), "  ".into(), None).unwrap_err();
        assert!(matches!(
            err,
            ValidationError::EmptyField {
                field: "anzeigename"
            }
        ));
    }

    #[test]
    fn formularfamilie_optional() {
        let link = Formularlink::try_new("https://x".into(), "y".into(), None).expect("baut");
        assert_eq!(link.formularfamilie(), None);
    }
}
