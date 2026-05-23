// `Profile` — Katalogprofil eines Netzbetreibers/Behoerde/Registers.
// Siehe Lastenheft `GG-FA-CAT-001` (Pflichtfelder eines Profils).
//
// Kritischer Domaincode gemaess GG-NFA-COV-002 (Profil- und
// Profilversionsverwaltung); 90 %-Line-Coverage-Schwelle gilt.

use serde::{Deserialize, Serialize};

use super::{Formularlink, Profilversion, ValidationError};
use crate::hexagon::core::vocab::{
    FalltypId, Katalogstatus, Nachnutzungsstatus, Profiltyp, Quellkatalog, Zugangsart,
};

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct Profile {
    name: String,
    profiltyp: Profiltyp,
    formularlinks: Vec<Formularlink>,
    portalhinweise: String,
    bekannte_falltypen: Vec<FalltypId>,
    aktuelle_version: Profilversion,
    quellkatalog: Quellkatalog,
    zugangsart: Vec<Zugangsart>,
    nachnutzungsstatus: Nachnutzungsstatus,
    katalogstatus: Katalogstatus,
}

impl Profile {
    /// Konstruktor mit Validierung gemaess GG-FA-CAT-001.
    ///
    /// Pflichtinvarianten:
    ///   - `name` nicht leer.
    ///   - `formularlinks` mindestens ein Eintrag.
    ///   - `zugangsart` mindestens ein Eintrag (Lastenheft: "aus
    ///     dem Vokabular `Zugangsart`" — Liste, weil eine Quelle
    ///     mehrere Zugangsarten kombinieren kann).
    ///   - `bekannte_falltypen` nicht leer, wenn `katalogstatus`
    ///     `SehrGutErschlossen` oder `GutErschlossen` ist; sonst
    ///     optional.
    #[allow(clippy::too_many_arguments)]
    pub fn try_new(
        name: String,
        profiltyp: Profiltyp,
        formularlinks: Vec<Formularlink>,
        portalhinweise: String,
        bekannte_falltypen: Vec<FalltypId>,
        aktuelle_version: Profilversion,
        quellkatalog: Quellkatalog,
        zugangsart: Vec<Zugangsart>,
        nachnutzungsstatus: Nachnutzungsstatus,
        katalogstatus: Katalogstatus,
    ) -> Result<Self, ValidationError> {
        if name.trim().is_empty() {
            return Err(ValidationError::EmptyField { field: "name" });
        }
        if formularlinks.is_empty() {
            return Err(ValidationError::EmptyCollection {
                field: "formularlinks",
            });
        }
        if zugangsart.is_empty() {
            return Err(ValidationError::EmptyCollection {
                field: "zugangsart",
            });
        }
        let braucht_falltypen = matches!(
            katalogstatus,
            Katalogstatus::SehrGutErschlossen | Katalogstatus::GutErschlossen
        );
        if braucht_falltypen && bekannte_falltypen.is_empty() {
            return Err(ValidationError::Inkonsistenz {
                field: "bekannte_falltypen",
                reason: "darf bei SehrGutErschlossen/GutErschlossen nicht leer sein",
            });
        }
        Ok(Self {
            name,
            profiltyp,
            formularlinks,
            portalhinweise,
            bekannte_falltypen,
            aktuelle_version,
            quellkatalog,
            zugangsart,
            nachnutzungsstatus,
            katalogstatus,
        })
    }

    pub fn name(&self) -> &str {
        &self.name
    }
    pub fn profiltyp(&self) -> Profiltyp {
        self.profiltyp
    }
    pub fn formularlinks(&self) -> &[Formularlink] {
        &self.formularlinks
    }
    pub fn portalhinweise(&self) -> &str {
        &self.portalhinweise
    }
    pub fn bekannte_falltypen(&self) -> &[FalltypId] {
        &self.bekannte_falltypen
    }
    pub fn aktuelle_version(&self) -> &Profilversion {
        &self.aktuelle_version
    }
    pub fn quellkatalog(&self) -> Quellkatalog {
        self.quellkatalog
    }
    pub fn zugangsart(&self) -> &[Zugangsart] {
        &self.zugangsart
    }
    pub fn nachnutzungsstatus(&self) -> Nachnutzungsstatus {
        self.nachnutzungsstatus
    }
    pub fn katalogstatus(&self) -> Katalogstatus {
        self.katalogstatus
    }
}

#[cfg(test)]
mod tests {
    use super::{
        FalltypId, Formularlink, Katalogstatus, Nachnutzungsstatus, Profile, Profiltyp,
        Profilversion, Quellkatalog, ValidationError, Zugangsart,
    };

    fn version() -> Profilversion {
        Profilversion::try_new(
            "2026-05-23".into(),
            "2026-05-23".into(),
            "https://example.de".into(),
            None,
        )
        .expect("version baut")
    }

    fn link() -> Formularlink {
        Formularlink::try_new("https://example.de/f".into(), "Formular".into(), None)
            .expect("link baut")
    }

    fn baue(katalogstatus: Katalogstatus, bekannte: Vec<FalltypId>) -> Profile {
        Profile::try_new(
            "Westnetz".into(),
            Profiltyp::Netzbetreiber,
            vec![link()],
            String::new(),
            bekannte,
            version(),
            Quellkatalog::Beide,
            vec![Zugangsart::Pdf],
            Nachnutzungsstatus::Unbekannt,
            katalogstatus,
            // try_new aufruf-args werden direkt durchgereicht
        )
        .expect("happy-path baut")
    }

    #[test]
    fn happy_path_gut_erschlossen_mit_falltypen() {
        let profil = baue(
            Katalogstatus::GutErschlossen,
            vec![FalltypId::PvNsOhneSpeicher],
        );
        assert_eq!(profil.name(), "Westnetz");
        assert_eq!(profil.profiltyp(), Profiltyp::Netzbetreiber);
        assert_eq!(profil.formularlinks().len(), 1);
        assert_eq!(profil.portalhinweise(), "");
        assert_eq!(profil.bekannte_falltypen().len(), 1);
        assert_eq!(profil.quellkatalog(), Quellkatalog::Beide);
        assert_eq!(profil.zugangsart(), &[Zugangsart::Pdf]);
        assert_eq!(profil.nachnutzungsstatus(), Nachnutzungsstatus::Unbekannt);
        assert_eq!(profil.katalogstatus(), Katalogstatus::GutErschlossen);
        assert_eq!(profil.aktuelle_version().version_id(), "2026-05-23");
    }

    #[test]
    fn schwach_erschlossen_darf_falltypen_leer_lassen() {
        let profil = baue(Katalogstatus::NichtVerifiziert, vec![]);
        assert!(profil.bekannte_falltypen().is_empty());
    }

    #[test]
    fn name_leer_abgelehnt() {
        let err = Profile::try_new(
            "   ".into(),
            Profiltyp::Netzbetreiber,
            vec![link()],
            String::new(),
            vec![FalltypId::PvNsOhneSpeicher],
            version(),
            Quellkatalog::Beide,
            vec![Zugangsart::Pdf],
            Nachnutzungsstatus::Unbekannt,
            Katalogstatus::GutErschlossen,
        )
        .unwrap_err();
        assert!(matches!(err, ValidationError::EmptyField { field: "name" }));
    }

    #[test]
    fn formularlinks_leer_abgelehnt() {
        let err = Profile::try_new(
            "X".into(),
            Profiltyp::Netzbetreiber,
            vec![],
            String::new(),
            vec![FalltypId::PvNsOhneSpeicher],
            version(),
            Quellkatalog::Beide,
            vec![Zugangsart::Pdf],
            Nachnutzungsstatus::Unbekannt,
            Katalogstatus::GutErschlossen,
        )
        .unwrap_err();
        assert!(matches!(
            err,
            ValidationError::EmptyCollection {
                field: "formularlinks"
            }
        ));
    }

    #[test]
    fn zugangsart_leer_abgelehnt() {
        let err = Profile::try_new(
            "X".into(),
            Profiltyp::Netzbetreiber,
            vec![link()],
            String::new(),
            vec![FalltypId::PvNsOhneSpeicher],
            version(),
            Quellkatalog::Beide,
            vec![],
            Nachnutzungsstatus::Unbekannt,
            Katalogstatus::GutErschlossen,
        )
        .unwrap_err();
        assert!(matches!(
            err,
            ValidationError::EmptyCollection {
                field: "zugangsart"
            }
        ));
    }

    #[test]
    fn bekannte_falltypen_pflicht_bei_sehrgut_und_gut() {
        for status in [
            Katalogstatus::SehrGutErschlossen,
            Katalogstatus::GutErschlossen,
        ] {
            let err = Profile::try_new(
                "X".into(),
                Profiltyp::Netzbetreiber,
                vec![link()],
                String::new(),
                vec![],
                version(),
                Quellkatalog::Beide,
                vec![Zugangsart::Pdf],
                Nachnutzungsstatus::Unbekannt,
                status,
            )
            .unwrap_err();
            assert!(matches!(
                err,
                ValidationError::Inkonsistenz {
                    field: "bekannte_falltypen",
                    ..
                }
            ));
        }
    }

    #[test]
    fn serde_round_trip() {
        let profil = baue(
            Katalogstatus::GutErschlossen,
            vec![FalltypId::PvNsOhneSpeicher],
        );
        let json = serde_json::to_string(&profil).expect("serialize");
        let zurueck: Profile = serde_json::from_str(&json).expect("deserialize");
        assert_eq!(profil, zurueck);
    }
}
