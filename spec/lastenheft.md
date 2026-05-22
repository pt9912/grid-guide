# Lastenheft: `GridGuide` - Assistent fuer PV-, Speicher- und Erzeugungsanlagen-Antraege

| Dokument         | Lastenheft                                                                    |
| ---------------- | ----------------------------------------------------------------------------- |
| Projektname      | `GridGuide`                                                                   |
| Kurzbeschreibung | Desktop-Assistent zur Vorbereitung vollstaendiger Netz- und Behoerdenantraege |
| Zielplattform    | Tauri Desktop-App, lokale Dokumentverarbeitung                                |
| Hauptnutzer      | Installateure, Antragsteller, Projektentwickler                               |
| Version          | 0.4.0                                                                         |
| Status           | Entwurf                                                                       |
| Datum            | 2026-05-22                                                                    |

---

## 0. Lesehinweise

### GG-LESE-001 - Modalverben

In diesem Dokument haben Modalverben folgende Bedeutung:

- **muss** - verbindliche Anforderung fuer den zugeordneten Abnahmestand.
- **darf nicht** - ausdruecklich ausgeschlossen.
- **soll** - geplante Eigenschaft; Abweichungen muessen begruendet werden.
- **kann** - optionale Eigenschaft ohne Abnahmeverpflichtung.

Pluralformen (`muessen`, `sollen`, `koennen`, `duerfen nicht`) tragen
dieselbe Bedeutung wie ihre Singularform.

MVP-blockierend sind Anforderungen, die mit Prioritaet `MVP` gekennzeichnet sind
oder im Kapitel "MVP-Umfang" explizit genannt werden.

Die Kennung `GG` steht fuer GridGuide.

### GG-LESE-002 - Abnahme

Eine Anforderung gilt als erfuellt, wenn der zugeordnete Belegtyp vorliegt:

| Anforderungsklasse                  | Zulaessiger Beleg                                                                        |
| ----------------------------------- | ---------------------------------------------------------------------------------------- |
| Funktionale Anforderungen (`FA-*`)  | automatisierter Test oder reproduzierbarer manueller Test mit Demo-Artefakt              |
| Datenanforderungen (`DATA-*`)       | automatisierter Test (z. B. Schema-/Parsertest) oder reproduzierbares Demo-Artefakt      |
| KI-/Regelanforderungen (`AI-*`)     | reproduzierbares Demo-Artefakt (Prompt, Antwort) plus automatischer Test, wo moeglich    |
| Architektur (`ARCH-*`)              | dokumentierter Architekturentscheid (ADR) plus statischer Import-/Strukturcheck          |
| Prinzipien (`PRINC-*`)              | dokumentierter Architekturentscheid (ADR) plus, wo moeglich, statischer Check oder Lint-Regel |
| Code-Conventions (`CC-*`)           | Lint-/Format-/Architekturtest oder Review-Checkliste mit dokumentiertem Befehl           |
| Coverage (`NFA-COV-*`)              | Coverage-Report im Repository plus reproduzierbares Build-Target                         |
| Quality Gates (`NFA-QG-*`)          | dokumentiertes Gate-Skript (Build-Target oder CI-Job), das das Gate auswertet            |
| CI/CD (`NFA-CICD-*`)                | im Repository vorhandener CI-Workflow plus dokumentiertes Release-/Matrix-Verfahren      |
| Performance (`NFA-PERF-*`)          | reproduzierbares Messprotokoll oder Benchmark im Repository                              |
| Sicherheits-/Datenschutz (`NFA-SEC`, `NFA-LOG`) | automatisierter Test oder dokumentiertes Reviewprotokoll                      |
| Sonstige NFA (`NFA-*`)              | automatisierter Test oder reproduzierbarer manueller Test                                |
| Lizenz/Abnahme (`LIC-*`, `ACCEPT-*`)| im Repository vorhandenes Artefakt (Datei, Matrix, Beispielexport)                       |

Ein dokumentierter Architekturentscheid (ADR) allein genuegt nur fuer
`ARCH-*`-Anforderungen, nicht fuer `FA-*`, `DATA-*` oder `NFA-PERF-*`.

### GG-LESE-003 - Rechtliche Abgrenzung

GridGuide ist keine Rechts-, Steuer- oder Netzanschlussberatung. Er bereitet
Einreichungspakete vor, ersetzt aber keine Pruefung durch Netzbetreiber,
Behoerden, Steuerberatung oder fachkundige Elektroinstallateure.

### GG-LESE-004 - Verhaeltnis MVP-Kapitel zu Funktionalen Anforderungen

Kapitel 4 (MVP-Umfang) beschreibt den abnahmefaehigen MVP-Scope.

Kapitel 5 (Funktionale Anforderungen) ist die kanonische Quelle fuer die
einzelnen fachlichen Anforderungen mit Prioritaet `MVP` oder `V1`.

Wo Kapitel 4 und Kapitel 5 dieselbe Anforderung betreffen, ist die
MVP-Anforderung ein Verweis auf die FA-Anforderung. Im Konfliktfall gilt
Kapitel 5.

### GG-LESE-005 - ID-Schema

IDs folgen dem Muster `GG-<Bereich>-<NNN>` mit dreistelliger Nummer.
Bereiche umfassen `LESE`, `ZB`, `PE`, `PUE`, `MOD`, `MVP`, `FA-CAT`,
`FA-PROJ`, `FA-DOC`, `FA-VAL`, `FA-FILL`, `FA-EXPORT`, `FA-SRC`, `NONGOAL`,
`ARCH`, `PRINC`, `CC`, `DATA`, `AI`, `NFA-SEC`, `NFA-USE`, `NFA-MAINT`,
`NFA-TEST`, `NFA-COV`, `NFA-QG`, `NFA-CICD`, `NFA-PERF`, `NFA-INSTALL`,
`NFA-LOG`, `NFA-BACKUP`, `NFA-I18N`, `NFA-A11Y`, `LIC`, `ACCEPT`, `RISK`,
`ASSUMP`, `DEC`.

`DEC` bezeichnet getroffene MVP-Festlegungen, `ASSUMP` dokumentierte
Annahmen. Ein Bereich `OPEN` fuer noch nicht entschiedene Punkte kann bei
Bedarf in einer spaeteren Fassung ergaenzt werden.

### GG-LESE-006 - Identifier-Konvention fuer Vokabulare

In diesem Dokument gilt fuer Werte kontrollierter Vokabulare folgende
Sprachkonvention, um Code-Identifier und UI-Bezeichner sauber zu trennen:

- **Fachliche Vokabulare** (sichtbar in UI, Profilen, Exporten) verwenden
  deutsche PascalCase-Bezeichner. Beispiele: `Profiltyp`, `Anlagenart`,
  `Dokumenttyp`, `Falltyp`, `Katalogstatus` (siehe GG-DATA-004). Bei
  strukturierten Werten (z. B. `Falltyp`) sind Unterstriche als Segmenttrenner
  und etablierte technische Akronyme (z. B. `PV`, `NS` fuer Niederspannung,
  `kW`) zulaessig.
- **Technische Lifecycle-Felder** (intern, nicht UI-relevant) verwenden
  englische snake_case-Bezeichner. Beispiele: `extraction_method`, `status`
  (siehe GG-DATA-002).
- **Schweregrade von Warnungen** sind UI-nah und werden auf Deutsch gefuehrt
  (`info`, `warnung`, `fehler`).

Erweiterungen muessen sich an diese Konvention halten oder die Abweichung
begruenden.

### GG-LESE-007 - ASCII-Schreibweise

Das Dokument verwendet eine reine ASCII-Schreibweise fuer
Sprachzeichen. Deutsche Umlaute werden als `ae`, `oe`, `ue`
geschrieben, `ß` als `ss`. Diese Konvention gilt fuer alle Beitraege
und ist beim Lektorat zu beachten.

Typografische Zeichen ausserhalb des ASCII-Bereichs sind erlaubt,
soweit sie keine Sprachzeichen ersetzen:

- Em-Dash (`—`) als typografischer Gedankenstrich; die ASCII-Variante
  `--` ist gleichwertig zulaessig.
- Pfeile in Diagrammen (`→`, `↓`, `▶`).
- Unicode-Box-Drawing-Zeichen in ASCII-Art-Diagrammen.

Diese Klausel gilt sinngemaess auch fuer die Dokumente unter
`docs/plan/` (siehe ADR 0001 §2.5).

### GG-LESE-008 - Verhaeltnis zu einem Pflichtenheft

Das Dokument fixiert in Kapitel 7 (Architektur) bewusst auch Loesungsanteile
verbindlich (Tauri, hexagonale Struktur, Rust, SvelteKit, Paketformate). Es
ist damit groesser geschnitten als ein klassisches Lastenheft und nimmt
Teile eines Pflichtenhefts vorweg. Auftraggeber und Auftragnehmer fallen im
MVP zusammen; diese Festlegungen sind daher beabsichtigt und gelten als
Anforderungen mit Belegtyp `ARCH-*` gemaess GG-LESE-002.

---

## 1. Zielbestimmung

### GG-ZB-001 - Projektziel

`GridGuide` soll eine lokale Desktop-Anwendung werden, die Antragsteller,
Installateure und Projektentwickler bei der Vorbereitung vollstaendiger
Einreichungspakete fuer PV-, Speicher- und Erzeugungsanlagen unterstuetzt.

Die Anwendung soll oeffentliche PDF-/XLSX-Formulare, Katalogdaten,
Plausibilitaetsregeln und Dokumentanalyse kombinieren, um fehlende Angaben,
fehlende Nachweise und typische Fehler vor der Einreichung sichtbar zu machen.

### GG-ZB-002 - Produktvision

`GridGuide` soll sich wie ein fachlicher Vorpruefer fuer Netzanschluss-,
Inbetriebsetzungs-, Verguetungs-, Register- und Behoerdenprozesse verhalten.

Der Nutzer soll ein Projekt anlegen, Netzbetreiber oder Behoerde auswaehlen,
Dokumente hochladen, Hinweise erhalten und ein vorbereitetes Exportpaket fuer
Portal, PDF, XLSX, ZIP oder E-Mail erzeugen koennen.

### GG-ZB-003 - Repo-Beschreibung

```text
GridGuide: Local Tauri assistant for preparing PV, storage and grid-connection submission packages.
```

---

## 2. Produkteinsatz

### GG-PE-001 - Anwendungsbereich

Das Produkt soll fuer deutsche PV-, Speicher- und Erzeugungsanlagenprozesse
eingesetzt werden, insbesondere fuer:

- Netzanschluss und Anmeldung.
- Inbetriebsetzung und technische Nachweise.
- Messkonzept, Zaehlersetzung und Marktlokationen.
- Verguetung, Betreiberwechsel und steuernahe Angaben.
- Marktstammdatenregister und Bundesnetzagentur-Prozesse.
- Reifegradverfahren, Redispatch und verwandte Branchenprozesse.

### GG-PE-002 - Zielgruppen

Das Produkt richtet sich an:

- Elektroinstallateure.
- Anlagenbetreiber und Antragsteller.
- Projektentwickler fuer PV-, Speicher- und Erzeugungsanlagen.
- interne Backoffice-Teams von Installationsbetrieben.
- technische Berater, die Einreichungspakete vorbereiten.

### GG-PE-003 - Betriebsumgebung

Die primaere Betriebsumgebung muss sein:

- lokale Desktop-App auf Linux.
- Tauri als Desktop-Runtime.
- lokale Dateiverarbeitung fuer PDF, XLSX und ZIP.

Folgende Sekundaerumgebungen werden im CI-Matrix-Build mitgefuehrt
(Best-Effort, kein MVP-Abnahmegegenstand; siehe GG-NFA-CICD-002):

- macOS.
- Windows.

Optionaler Browser-Plugin- oder CLI-Betrieb kann spaeter ergaenzt
werden und ist ebenfalls kein MVP-Abnahmegegenstand.

### GG-PE-004 - Offline-Faehigkeit

Der MVP soll grundlegende Projektbearbeitung, Checklisten, lokale
Dokumentanalyse und Export ohne dauerhafte Online-Verbindung ermoeglichen.

Online-Zugriff kann fuer Link-/Versionspruefung, MaStR-nahe Validierungen oder
optionale LLM-Funktionen verwendet werden, darf aber nicht zwingend fuer die
lokale Demo-Abnahme sein. Direkte LLM-Anbindungen sind nicht Teil des MVP;
stattdessen muss der MVP KI-Prompts erzeugen koennen, die Nutzer manuell in
einem externen KI-System verwenden.

---

## 3. Produktuebersicht

### GG-PUE-001 - Grundfunktion

Das Produkt soll als Tauri-Desktop-App bereitgestellt werden.

Der Kernworkflow lautet:

```text
Projekt- und Stammdaten erfassen
↓
Netzbetreiber, Behoerde oder Register auswaehlen
↓
passende Formulare und Pflichtunterlagen ermitteln
↓
PDF/XLSX/Dokumente analysieren
↓
fehlende Angaben und Nachweise markieren
↓
Plausibilitaetscheck ausfuehren
↓
Exportpaket als ZIP oder Ordnerstruktur erstellen
```

Formularvorbefuellung und PDF-/XLSX-Ausgabe sind V1-Funktionen und nicht
Bestandteil des verbindlichen MVP-Kernworkflows.

### GG-PUE-002 - Hauptmodule

| Kennung    | Modul              | MVP-Umfang                                                                   | V1-Erweiterung                                 |
| ---------- | ------------------ | ---------------------------------------------------------------------------- | ---------------------------------------------- |
| GG-MOD-001 | Katalog            | Betreiber-, Behoerden-, Formular- und Quellenprofile                         | weitere Profile gemaess Katalogen              |
| GG-MOD-002 | Projektverwaltung  | Stammdaten, Anlagen, Speicher, Messkonzept, Nachweise                        | erweiterte Falltypen                           |
| GG-MOD-003 | Dokumentanalyse    | PDF-/XLSX-Lesen, Feldextraktion, Dokumentklassifikation textbasiert          | OCR fuer eingescannte Dokumente                |
| GG-MOD-004 | Validierung        | Pflichtfelder, Pflichtunterlagen, Plausibilitaetsregeln                      | profil- und versionsspezifische Regelvarianten |
| GG-MOD-005 | Formularbefuellung | nicht im MVP                                                                 | Vorbereitung ausfuellbarer PDF-/XLSX-Formulare |
| GG-MOD-006 | Export             | ZIP-/Ordner-/Checklisten-Export                                              | PDF-/XLSX-Ausgabe vorbefuellter Formulare      |
| GG-MOD-007 | Quellenmonitoring  | manuell gepflegte Profilversion und Abrufdatum                               | automatisierte Link- und Versionspruefung      |
| GG-MOD-008 | Tauri UI           | Projektstatus, Review-Ansicht, Korrektur und manuelle Bestaetigung           | Wizard- und Onboarding-Flows                   |
| GG-MOD-009 | Katalogseed        | Uebernahme kuratierter Startdaten aus `Katalog-pdf.md` und `Katalog-xlsx.md` | maschinenlesbare Profilversionierung           |

---

## 4. MVP-Umfang

Dieses Kapitel ist die Abnahmeklammer fuer den MVP. Jede MVP-Anforderung
verweist auf eine kanonische FA-Anforderung im Kapitel 5, soweit vorhanden.

### GG-MVP-001 - Lokale Desktop-App

Prioritaet: MVP

Der MVP muss als lokal startbare Tauri-Desktop-App bereitgestellt werden.

Akzeptanz: Die App kann auf einem Entwicklerrechner gestartet werden und zeigt
eine Projektuebersicht, Profilauswahl und einen Import-/Export-Workflow.

Verweis: GG-ARCH-001, GG-ARCH-002, GG-ARCH-008.

### GG-MVP-002 - Erstes Betreiberprofil

Prioritaet: MVP

Der MVP muss mindestens ein Betreiberprofil aus den Katalogdaten enthalten.
Der erste MVP-Abnahmestand verwendet `Westnetz` als festes Startprofil
(siehe GG-DEC-001).

Akzeptanz: Fuer ein ausgewaehltes Profil werden Formularlinks,
Portalhinweise, Pflichtfelder und Pflichtunterlagen angezeigt.

Verweis: GG-FA-CAT-001, GG-FA-CAT-003.

### GG-MVP-003 - Enger Falltyp

Prioritaet: MVP

Der MVP muss genau einen fachlichen Falltyp als End-to-End-Demo unterstuetzen:
eine PV-Anlage im Niederspannungsbereich mit installierter Leistung bis
**30 kWp**, **ohne Speicher** und mit **Ueberschusseinspeisung** fuer das
Startprofil `Westnetz` (siehe GG-DEC-002).

Akzeptanz: Der Falltyp ist dokumentiert und besitzt eine reproduzierbare
Demo-Datei oder Demo-Projektvorlage im Repository.

Verweis: GG-DEC-002, GG-DATA-004 (Vokabular `Falltyp`), GG-ACCEPT-001.

### GG-MVP-004 - Checkliste und Pflichtfelder

Prioritaet: MVP

Der MVP muss fuer das erste Profil und den ersten Falltyp eine Checkliste mit
Pflichtfeldern und Pflichtunterlagen erzeugen.

Akzeptanz: Fehlende Pflichtangaben und fehlende Dokumente werden im UI mit
Schweregrad (siehe GG-NFA-USE-001) sichtbar markiert.

Verweis: GG-FA-VAL-001, GG-FA-VAL-002, GG-FA-VAL-003.

### GG-MVP-005 - Dokumentimport

Prioritaet: MVP

Der MVP muss lokale PDF- und XLSX-Dateien importieren koennen.

Akzeptanz: Importierte Dateien erscheinen im Projekt, werden einem Dokumenttyp
zugeordnet und koennen fuer Validierung und Export referenziert werden.

Verweis: GG-FA-DOC-001.

### GG-MVP-006 - Feldextraktion

Prioritaet: MVP

Der MVP muss aus textbasierten PDF-/XLSX-Dokumenten zentrale Felder
automatisch extrahieren. Reine Manuelleingabe ohne Extraktionsversuch genuegt
fuer den Demo-Fall nicht.

Akzeptanz:

- Mindestens **Antragsteller, Anlagenbetreiber, Anlagenstandort, installierte
  Leistung, Anlagenart und Messkonzept** werden im Demo-Fall aus mindestens
  einem Dokument als Vorschlag extrahiert.
- Jeder uebernommene Wert traegt Herkunft (Quelldokument, Seite oder Blatt)
  und Bestaetigungsstatus gemaess GG-DATA-002.
- Felder, fuer die keine Extraktion gelingt, werden im UI als manuell zu
  pruefend markiert.

Verweis: GG-FA-DOC-001, GG-DATA-002, GG-FA-PROJ-001.

### GG-MVP-007 - Exportpaket

Prioritaet: MVP

Der MVP muss ein Exportpaket gemaess GG-FA-EXPORT-001 als ZIP oder
Ordnerstruktur erzeugen koennen.

Akzeptanz: siehe GG-FA-EXPORT-001. Vorbefuellte PDF-/XLSX-Formulare sind fuer
den MVP nicht erforderlich.

Verweis: GG-FA-EXPORT-001, GG-DEC-003.

### GG-MVP-008 - Keine Portalautomatisierung

Prioritaet: MVP

Der MVP darf keine automatische Einreichung in Netzbetreiberportale enthalten
oder durchfuehren.

Akzeptanz: Portal-only-Prozesse werden als Vorbereitungshilfe markiert; die
offizielle Einreichung bleibt Aufgabe des Nutzers.

Verweis: GG-FA-CAT-006, GG-NONGOAL-002, GG-RISK-002.

### GG-MVP-009 - Prompt-Erzeugung

Prioritaet: MVP

Der MVP muss einen strukturierten KI-Prompt gemaess GG-AI-002 erzeugen
koennen, ohne ein LLM direkt anzubinden.

Akzeptanz: siehe GG-AI-002 und GG-ACCEPT-004.

Verweis: GG-AI-001, GG-AI-002, GG-ACCEPT-004.

---

## 5. Funktionale Anforderungen

### GG-FA-CAT-001 - Katalogprofile

Prioritaet: MVP

Das Produkt muss Profile fuer Betreiber, Behoerden und Register verwalten
koennen.

MVP-Abgrenzung: Der MVP muss genau ein Netzbetreiberprofil produktiv
unterstuetzen. Weitere Profiltypen muessen im Datenmodell vorbereitet sein,
muessen aber nicht fachlich ausgepraegt sein.

Ein Profil muss mindestens enthalten:

- Name.
- Typ aus dem Vokabular `Profiltyp` (siehe GG-DATA-004).
- mindestens einen Formularlink (URL plus Anzeigename). Formularlinks
  koennen optional nach Formularfamilie gemaess GG-FA-CAT-008 gruppiert
  werden.
- Portalhinweise (Freitext, kann leer sein, falls keine Portalpflicht
  besteht).
- mindestens einen bekannten Falltyp aus dem Vokabular `Falltyp` (siehe
  GG-DATA-004) fuer Profile mit Katalogstatus `SehrGutErschlossen` oder
  `GutErschlossen`; fuer schwaecher erschlossene Profile optional.
- Profilversion gemaess GG-DATA-005.
- Quellkatalog aus dem Vokabular `Quellkatalog` (siehe GG-DATA-004).
- Zugangsart aus dem Vokabular `Zugangsart` (siehe GG-DATA-004).
- Nachnutzungsstatus aus dem Vokabular `Nachnutzungsstatus` (siehe
  GG-DATA-004).
- Katalogstatus aus dem Vokabular `Katalogstatus` (siehe GG-DATA-004).

### GG-FA-CAT-002 - Priorisierte Profile

Prioritaet: MVP fuer Westnetz; V1 fuer alle weiteren Quellen.

Das Produkt muss das Westnetz-Profil im MVP produktiv unterstuetzen und soll
die weiteren in der Tabelle gelisteten Profile in V1 unterstuetzen. Die
Spalte `Abnahmestand` ist der kanonische Auspraegungsstatus pro Profil. Die
Liste deckt dieselbe Quellen-Traegermenge ab wie GG-FA-CAT-004; die
Sortierung dort folgt der V1-internen Umsetzungsreihenfolge.

| Abnahmestand | Quelle                     |
| ------------ | -------------------------- |
| MVP          | Westnetz                   |
| V1           | Bayernwerk                 |
| V1           | Netze BW                   |
| V1           | N-ERGIE Netz               |
| V1           | SWM Infrastruktur          |
| V1           | 50Hertz                    |
| V1           | Amprion                    |
| V1           | TransnetBW                 |
| V1           | TenneT Germany             |
| V1           | Bundesnetzagentur          |
| V1           | Marktstammdatenregister    |
| V1           | Landesfinanzverwaltungen   |
| V1           | BDEW                       |
| V1           | netztransparenz.de         |
| V1           | 4-UE-NB-Reifegradverfahren |

### GG-FA-CAT-003 - Katalogbasierte Startprofile

Prioritaet: MVP

Das Produkt muss die Informationen aus `Katalog-pdf.md` und
`Katalog-xlsx.md` als initiale Seed-Datenquelle modellieren koennen.

Akzeptanz: Mindestens die im MVP ausgewaehlte Quelle wird aus einem
maschinenlesbaren Profil abgebildet, das auf die Katalogfundstelle
zurueckverweist.

### GG-FA-CAT-004 - PDF-Katalogprofile

Prioritaet: V1

Das Produkt soll die im PDF-Katalog priorisierten Quellen als Profile
unterstuetzen. Die Spalte `Reihenfolge` beschreibt die V1-interne
Umsetzungsreihenfolge und ist unabhaengig vom MVP/V1-Prioritaetsschema dieses
Dokuments (siehe GG-LESE-001). Die Traegermenge entspricht der Liste aus
GG-FA-CAT-002.

| Reihenfolge | Quelle                     | Kataloghinweis                                                    | Typischer Zugang              |
| ----------- | -------------------------- | ----------------------------------------------------------------- | ----------------------------- |
| 1           | Bayernwerk                 | Speicher, Verguetung, Messkonzepte, MS/HS                         | Portal + PDF                  |
| 2           | Westnetz                   | E.1/E.8/E.11, TAB-/VDE-Formulare, Abrechnung                      | PDF + Portal                  |
| 3           | Netze BW                   | PV ab 135 kW, Messkonzept, technische Aenderungen                 | PDF + Kundenportal            |
| 4           | N-ERGIE Netz               | E.2/E.3/E.8, Einspeiseart, Veraeusserungsform, Steckersolar       | PDF + Online-Service          |
| 5           | SWM Infrastruktur          | Erzeugungsanlagen, Inbetriebsetzung, Steuer-/Verguetungsformulare | PDF + Portale                 |
| 6           | 50Hertz                    | Reifegradverfahren, Netzanschlussdokumente, 4-UE-NB-Formulare     | PDF + XLSX + HTML             |
| 7           | Amprion                    | Onshore-EE-Prozess, Checkliste, NDA, Zeitplan, Vertragsmuster     | PDF + HTML                    |
| 8           | TransnetBW                 | Reifegrad-PDFs, BESS-Mustervertrag, TAB HoeS                      | PDF + XLSX + HTML             |
| 9           | TenneT Germany             | KraftNAV, Netzanschlussregeln, weniger oeffentliche Formulare     | PDF + gemeinsame 4-UE-NB-Doku |
| 10          | Bundesnetzagentur          | Registrierungshilfen, Ausschreibungs- und Zahlungsformulare       | PDF + Online-Register         |
| 11          | Marktstammdatenregister    | Online-Register, PDF-Registrierungshilfen                         | OnlineRegister + PDF          |
| 12          | BDEW                       | Redispatch, Ausfallarbeit, Branchenprozesse                       | PDF + Fachseiten              |
| 13          | Landesfinanzverwaltungen   | Bayern/NRW mit PV-PDFs, sonst ELSTER-/Formularindex               | PDF + ELSTER                  |
| 14          | netztransparenz.de         | EEG-/Redispatch-Sonderfaelle, Umsetzungshilfen                    | PDF + XLSX                    |
| 15          | 4-UE-NB-Reifegradverfahren | Gemeinsame UE-NB-Formulare F.1-F.6                                | PDF + XLSX                    |

### GG-FA-CAT-005 - XLSX-Katalogprofile

Prioritaet: V1

Das Produkt soll die im XLSX-Katalog identifizierten strukturierten Downloads
als eigene Formular- oder Hilfsdatei-Arten modellieren.

Wichtige XLSX-Gruppen:

- Reifegradverfahren F.1/F.6 bei 50Hertz, Amprion und TransnetBW.
- Bayernwerk und Westnetz fuer Redispatch, Marktlokationen, Kundenanlagen und
  Marktkommunikation.
- TransnetBW fuer Bilanzierungsgebiete und Lastreduktionsdaten.
- netztransparenz.de und BDEW fuer EEG-/Redispatch-Sonderfaelle und
  Umsetzungshilfen.
- MaStR-Hilfsdateien als Hilfsdaten, nicht als Einreichungsformular.

Akzeptanz: XLSX-Quellen werden nicht pauschal als klassische Antragsformulare
behandelt, sondern nach Zweck gemaess dem Vokabular `XlsxZweck` (siehe
GG-DATA-004) klassifiziert.

### GG-FA-CAT-006 - Portal-only- und Nicht-PDF-/Nicht-XLSX-Markierung

Prioritaet: MVP

Das Produkt muss markieren koennen, wenn ein Prozess im Katalog als
portalgefuehrt, online-only, ELSTER-first oder nicht oeffentlich verifizierbar
beschrieben ist.

Beispiele:

- kleine PV-Faelle bei mehreren VNB laufen haeufig portalgefuehrt.
- MaStR ist online-only; PDF-Dokumente sind Registrierungshilfen.
- Landesfinanzverwaltungen verweisen haeufig auf ELSTER.
- TenneT-XLSX fuer F.1/F.6 war im Katalog nicht oeffentlich verifiziert.

Akzeptanz: GridGuide zeigt fuer solche Faelle eine Vorbereitungshilfe und
ersetzt dabei nicht den offiziellen Einreichungsweg.

### GG-FA-CAT-007 - Lizenz- und Nachnutzungsstatus durchsetzen

Prioritaet: MVP

Zusaetzlich zur Speicherung gemaess GG-FA-CAT-001 muss das Produkt den
Nachnutzungsstatus pro Quelle in der UI und im Exportpaket sichtbar
durchsetzen.

Akzeptanz: Quellen ohne offene Lizenz werden im Profil und im Exportpaket als
"nur verlinken / nicht neu verteilen" markiert. Originalformulare ohne offene
Lizenz werden nicht in das Exportpaket kopiert (siehe GG-NONGOAL-004).

### GG-FA-CAT-008 - Formularfamilien aus den Katalogen

Prioritaet: V1

Das Produkt soll die Katalogfundstellen mindestens folgenden Formularfamilien
zuordnen koennen:

- Anmeldung und Netzanschluss.
- Inbetriebsetzung und technische Nachweise.
- Messkonzept, Zaehlung und Marktlokation.
- Verguetung, Einspeiseabrechnung und Betreiberwechsel.
- Steuernahe Angaben und Landesfinanzverwaltung.
- Reifegradverfahren F.1-F.6.
- Redispatch, Ausfallarbeit und Lastreduktion.
- MaStR- und Bundesnetzagentur-Hilfen.

### GG-FA-PROJ-001 - Projektanlage

Prioritaet: MVP

Das Produkt muss ein Projekt mit Stammdaten anlegen und bearbeiten koennen.

Mindestens zu erfassen sind:

- Antragsteller.
- Anlagenbetreiber.
- Anlagenstandort.
- Anlagenart aus dem Vokabular `Anlagenart` (siehe GG-DATA-004). Das
  Vorhandensein eines Speichers wird ausschliesslich ueber `Anlagenart`
  ausgedrueckt (z. B. `PVmitSpeicher` oder `Speicher`); eine separate
  Speicher-Flag wird nicht gefuehrt.
- installierte Leistung in kWp.
- Messkonzept (optionales Feld; verpflichtend, sobald der Falltyp ein
  Messkonzept verlangt, siehe GG-FA-VAL-003). Fuer den MVP-Demo-Falltyp
  `PV_NS_OhneSpeicher` ist `Messkonzept` Pflicht (siehe GG-DEC-002).
- Netzbetreiberprofil.
- Falltyp aus dem Vokabular `Falltyp` (siehe GG-DATA-004).

### GG-FA-PROJ-002 - Lokale Projektpersistenz

Prioritaet: MVP

Das Produkt muss Projekte lokal speichern und erneut laden koennen.

Akzeptanz: Ein Demo-Projekt kann geschlossen, erneut geoeffnet und danach mit
denselben Stammdaten, Dokumentreferenzen, Warnungen und Bestaetigungsstatus
weiterbearbeitet werden.

### GG-FA-DOC-001 - Dokumentzuordnung

Prioritaet: MVP

Das Produkt muss importierte Dokumente einem fachlichen Dokumenttyp aus dem
Vokabular `Dokumenttyp` zuordnen koennen (siehe GG-DATA-004).

Akzeptanz: Jedes importierte Dokument hat genau einen Dokumenttyp, einen
Bestaetigungsstatus (vorgeschlagen oder bestaetigt) und ist im Projekt
referenzierbar. Unklassifizierbare Dokumente werden auf `Unbekannt` gesetzt.

### GG-FA-VAL-001 - Pflichtfeldpruefung

Prioritaet: MVP

Das Produkt muss Pflichtfelder je Profil und Falltyp pruefen.

Akzeptanz: Fehlende Pflichtfelder erzeugen Warnungen mit betroffener Quelle,
Feldname, Schweregrad (siehe GG-NFA-USE-001) und Korrekturhinweis.

### GG-FA-VAL-002 - Pflichtunterlagenpruefung

Prioritaet: MVP

Das Produkt muss Pflichtunterlagen je Profil und Falltyp pruefen.

Akzeptanz: Fehlende Pflichtunterlagen werden in der Checkliste mit
Schweregrad als offen markiert.

### GG-FA-VAL-003 - Plausibilitaetsregeln

Prioritaet: MVP

Das Produkt muss regelbasierte Plausibilitaetspruefungen unterstuetzen.

MVP-Mindestmenge: Fuer den Demo-Falltyp `PV_NS_OhneSpeicher` (siehe
GG-DEC-002) muss mindestens **je eine Regel pro nachfolgendem Thema** aktiv
sein (insgesamt mindestens **fuenf Regeln**):

- Anlagenleistung fehlt oder widerspricht Formularangaben.
- Anlagenart und vorhandene Nachweise sind inkonsistent (z. B. Anlagenart
  `PVmitSpeicher`, aber kein Speichernachweis).
- Messkonzept ist fuer den Falltyp erforderlich, aber nicht zugeordnet.
- Zaehlerspezifische Angaben fehlen.
- Betreiber- und Antragstellerdaten sind unvollstaendig.

Weitere Regeln koennen ergaenzt werden; jede Regel muss gemaess GG-AI-003
deterministisch sein und gemaess GG-NFA-USE-001 nachvollziehbar warnen.

### GG-FA-FILL-001 - Formularvorbefuellung

Prioritaet: V1

Das Produkt soll aus Projektstammdaten und extrahierten Werten PDF- oder
XLSX-Formulare vorbefuellen koennen.

Akzeptanz: Der Nutzer kann vor dem Export alle automatisch gesetzten Werte
pruefen und manuell korrigieren.

### GG-FA-EXPORT-001 - Exportpaket

Prioritaet: MVP

Das Produkt muss ein Einreichungspaket als ZIP oder Ordnerstruktur exportieren
koennen.

Das Paket muss mindestens enthalten:

- Checkliste mit Schweregradangabe je offenem Punkt.
- Projektstammdaten gemaess GG-FA-PROJ-001.
- Warnungen und offene Punkte gemaess GG-FA-VAL-001 bis GG-FA-VAL-003.
- referenzierte nutzereigene Dokumente.
- Links auf offizielle Quellen anstelle kopierter Originalformulare ohne
  offene Lizenz (siehe GG-FA-CAT-007 und GG-NONGOAL-004). Dies betrifft
  die einzelnen Formularlinks gemaess GG-FA-CAT-001.
- Profilversion gemaess GG-DATA-005 (enthaelt `source_url` der
  Katalog-/Profilquelle und `retrieved_at` und dient als Quellennachweis
  fuer die verwendete Profilauspraegung).

Das Paket darf keine Inhalte gemaess GG-DATA-003 enthalten.

Override-Verhalten: Liegt mindestens eine Warnung mit Schweregrad `fehler`
vor, ist der Export gemaess GG-NFA-USE-001 standardmaessig gesperrt. Wird er
ueber die dort beschriebene Override-Bestaetigung dennoch erzeugt, muss das
Exportpaket im Manifest die Override-Bestaetigung (Zeitpunkt, betroffene
Warnungs-IDs) sichtbar dokumentieren und die betroffenen Fehler markieren.

### GG-FA-SRC-001 - Quellenstatus

Prioritaet: V1

Das Produkt soll Quellen mit Abrufdatum, Linkstatus und Version verwalten.

Akzeptanz: Jede Regel und jeder Formularmapper kann auf Quelle und
Profilversion zurueckgefuehrt werden.

---

## 6. Nicht-Ziele und Scope-Grenzen

### GG-NONGOAL-001 - Keine verbindliche Beratung

Das Produkt ist keine Rechts-, Steuer- oder Netzanschlussberatung.

### GG-NONGOAL-002 - Kein Ersatz fuer Betreiberportale

Das Produkt ersetzt keine Netzbetreiber-, Behoerden- oder Registerportale.

### GG-NONGOAL-003 - Keine Garantie auf Annahme

Das Produkt garantiert nicht, dass ein Netzbetreiber oder eine Behoerde ein
Einreichungspaket annimmt.

### GG-NONGOAL-004 - Keine Neuverteilung geschuetzter Formulare

Originalformulare ohne offene Nachnutzungslizenz duerfen nicht als
Projektbestandteil neu verteilt werden. Das Produkt soll solche Formulare
verlinken, beschreiben und feldseitig modellieren.

Nutzereigene Uploads duerfen im Exportpaket referenziert oder kopiert werden,
wenn sie aus dem lokalen Projektbestand des Nutzers stammen.

### GG-NONGOAL-005 - Keine verpflichtende Cloud

Der MVP darf keine Cloud-Plattform als zwingende Laufzeitumgebung voraussetzen.

---

## 7. Architektur

### GG-ARCH-001 - Tauri Desktop-App

Prioritaet: MVP

Das Produkt muss als Tauri-basierte Desktop-App konzipiert werden.

Akzeptanz: UI, Tauri-Commands und fachlicher Kern sind getrennt dokumentiert.

### GG-ARCH-002 - Hexagonale Architektur

Prioritaet: MVP

Das Produkt muss eine hexagonale Architektur verwenden.

Akzeptanz: Fachlicher Kern, Ports und Adapter sind im Repository strukturell
getrennt.

Zielstruktur:

```text
src-tauri/
└─ src/
   ├─ main.rs
   ├─ hexagon/
   │  ├─ core/
   │  └─ ports/
   │     ├─ driving/
   │     └─ driven/
   └─ adapters/
      ├─ driving/
      └─ driven/
```

### GG-ARCH-003 - Core-Isolation

Prioritaet: MVP

`hexagon/core` darf nicht direkt von Tauri, PDF-, XLSX-, OCR-, HTTP- oder
LLM-Bibliotheken abhaengen.

Akzeptanz: Ein Architekturtest oder statischer Importcheck weist nach, dass
`hexagon/core` keine Adapterpakete importiert.

### GG-ARCH-004 - Driving Adapter

Prioritaet: MVP

Tauri-Commands muessen als Adapter unter `adapters/driving` behandelt werden.

Akzeptanz: Tauri-Commands enthalten keine Plausibilitaetsregeln und rufen
Use-Cases ueber driving ports auf.

### GG-ARCH-005 - Kern zuerst moeglich

Prioritaet: MVP

Ein technischer Kern- oder CLI-Prototyp darf vor der vollstaendigen Tauri-UI
entstehen. Die MVP-Abnahme der Produktanwendung erfordert dennoch eine lokal
startbare Tauri-App gemaess GG-MVP-001 und GG-ARCH-001.

Akzeptanz: Der fachliche Kern ist ohne Tauri testbar; die MVP-Demo zeigt den
Kern ueber die Tauri-App.

### GG-ARCH-006 - Driven Adapter

Prioritaet: MVP

Alle implementierten PDF-, XLSX-, OCR-, Dateisystem-, Datenbank-, HTTP- und
LLM-Implementierungen muessen als driven adapter angebunden werden.

Akzeptanz: Externe Implementierungen werden ueber Ports aus
`hexagon/ports/driven` angesprochen.

### GG-ARCH-007 - Bounded Contexts

Prioritaet: MVP

Der fachliche Kern soll mindestens folgende Bounded Contexts unterscheiden:

- `Catalog`.
- `Project`.
- `Validation`.
- `Submission`.

Spaetere Contexts koennen `OcrExtraction`, `Mastr`, `Redispatch` und
`PortalAutomation` sein. `PortalAutomation` ist erst nach dem MVP relevant
(siehe GG-MVP-008).

### GG-ARCH-008 - Technologie-Stack

Prioritaet: MVP

Das Produkt muss folgenden Technologie-Stack verwenden:

- Backend des `src-tauri/`-Teils in **Rust** (aktuelle stabile Edition).
- **Tauri 2.x** als Desktop-Runtime.
- Frontend-Framework: **SvelteKit 2.x** im Single-Page-Modus (siehe
  GG-DEC-004). Abweichungen sind als Architekturentscheid zu dokumentieren.
- Paketierung als Tauri-Bundle fuer Linux (AppImage und .deb).
- Persistenz im MVP als lokale Dateien im Nutzerprofil; eine eingebettete
  Datenbank (z. B. SQLite) ist V1.

Konkrete Minor- und Patch-Versionsfestlegungen erfolgen in den Manifesten
(`Cargo.toml`, `package.json`) und in begleitenden ADRs, nicht im
Lastenheft; das Lastenheft schreibt nur die Major-Linie vor.

Belegende ADRs:

- `docs/plan/adr/0002-frontend-stack-sveltekit.md` - SvelteKit-Mindestversion.
- `docs/plan/adr/0003-desktop-runtime-tauri.md` - Tauri-Mindestversion.

Akzeptanz: Stack-Entscheidungen sind im Repository als ADR unter
`docs/plan/adr/` dokumentiert; Abweichungen sind begruendet.

### GG-PRINC-001 - SOLID-Prinzipien

Prioritaet: MVP

Das System muss nach SOLID-Prinzipien entwickelt werden.

Akzeptanz: Architekturentscheidungen und Code-Reviews pruefen
Einzelverantwortung, Erweiterbarkeit, Austauschbarkeit, kleine
Schnittstellen und Abhaengigkeiten gegen Abstraktionen fuer
geaenderte Kernmodule. Eine Belegmatrix in der Traceability
(Kapitel 15) verknuepft die Teilanforderungen GG-PRINC-002 bis
GG-PRINC-006 mit Architekturtests, Lint-Regeln oder Code-Review.

### GG-PRINC-002 - Einzelverantwortung (SRP)

Prioritaet: MVP

Module, Klassen und Tauri-Commands muessen eine klare Einzelverantwortung
besitzen.

Akzeptanz: Ein Modul hat einen fachlich benennbaren Grund fuer
Aenderungen. Vermischungen von Domainlogik, Persistenz, UI und
externer Integration werden durch Architekturtests, Code-Review oder
dokumentierte Ausnahme erkannt.

### GG-PRINC-003 - Offen fuer Erweiterung (OCP)

Prioritaet: MVP

Erweiterungen sollen ohne Aenderung bestehender Kernlogik moeglich
sein.

Akzeptanz: Neue Profile, Falltypen, Regeln und Adapter koennen ueber
definierte Ports, Registries oder Daten ergaenzt werden, ohne den
fachlichen Kern zu veraendern (siehe GG-ARCH-002, GG-NFA-MAINT-001).

### GG-PRINC-004 - Substituierbarkeit (LSP)

Prioritaet: MVP

Implementierungen muessen ueber ihre definierten Schnittstellen
austauschbar sein.

Akzeptanz: Mindestens ein Port des fachlichen Kerns hat im Test eine
alternative Implementierung, die ohne Aenderung der Domainlogik
eingesetzt werden kann.

### GG-PRINC-005 - Kleine Schnittstellen (ISP)

Prioritaet: MVP

Schnittstellen muessen klein und fachlich getrennt sein.

Akzeptanz: Ports fuer Persistenz, Dokumentanalyse (PDF, XLSX, OCR),
HTTP-Aufrufe, LLM-Aufrufe und UI-Steuerung sind getrennt
dokumentiert. Adapter implementieren nur die Ports, die sie fachlich
benoetigen.

### GG-PRINC-006 - Abhaengigkeiten gegen Abstraktionen (DIP)

Prioritaet: MVP

Abhaengigkeiten muessen gegen Abstraktionen gerichtet sein.

Akzeptanz: Domain-Module haengen nicht direkt von Infrastruktur-,
Framework-, Transport- oder Datenbankpaketen ab. Diese Regel wird
durch Architekturtests oder statische Importpruefungen validiert
(siehe GG-ARCH-003).

### GG-CC-001 - Kurze Funktionen

Prioritaet: MVP

Methoden und Funktionen sollen kurz und fokussiert sein.

Akzeptanz: Produktionscode ueberschreitet 30 logische Zeilen pro
Methode oder Funktion nur mit fachlicher Begruendung (z. B. klar
strukturierte Parser, Tabellen, generierter Code). Ein Lint-Befehl
weist Verstoesse aus.

### GG-CC-002 - Adapter ohne Businesslogik

Prioritaet: MVP

Infrastruktur-Adapter (driving und driven) duerfen keine Businesslogik
enthalten.

Akzeptanz: Adapter uebersetzen Protokolle, Datenformate und technische
Fehler in Ports und Domain-Typen. Fachliche Entscheidungen liegen im
Kern oder in Geraete- bzw. Profilmodellen (siehe GG-ARCH-004,
GG-ARCH-006).

### GG-CC-003 - Domain ohne Framework

Prioritaet: MVP

Domain-Module (`hexagon/core`) duerfen keine Framework-Abhaengigkeiten
enthalten.

Akzeptanz: Domain-Code importiert keine Tauri-, PDF-, XLSX-, OCR-,
HTTP- oder LLM-Bibliotheken. Verstoesse werden durch den
Importcheck aus GG-ARCH-003 gemeldet.

### GG-CC-004 - Keine Modulzyklen

Prioritaet: MVP

Module duerfen keine zyklischen Abhaengigkeiten besitzen.

Akzeptanz: Eine automatisierte Modul- oder Importanalyse meldet
Zyklen als Architekturverletzung und blockiert den Build (siehe
GG-NFA-QG-003).

### GG-CC-005 - Eindeutige fachliche Namen

Prioritaet: MVP

Fachliche Namen muessen eindeutig und sprechend sein.

Akzeptanz: Oeffentliche Typen, Ports, Commands, Events, Vokabulare
und Warnungen verwenden Begriffe aus Lastenheft, Datenmodell und
Profilen konsistent. Formale Konsistenz (Casing, Prefix) wird per
Linter geprueft, fachliche Bedeutung bleibt Code-Review.

### GG-CC-006 - Keine God-Utility-Klassen

Prioritaet: MVP

Statische Utility-God-Klassen duerfen nicht eingefuehrt werden.

Akzeptanz: Wiederverwendbare Logik wird fachlich verortet oder als
kleine, zweckgebundene Funktion bzw. Komponente implementiert.

### GG-CC-007 - Immutable Domain-Objekte

Prioritaet: MVP

Immutable Domain-Objekte sollen bevorzugt werden.

Akzeptanz: Events, Commands, Warnungen, Snapshots und
Profilauspraegungen sind unveraenderlich oder behandeln Mutation
explizit und lokal begrenzt.

### GG-CC-008 - Explizite Fehlerbehandlung

Prioritaet: MVP

Fehlerbehandlung muss explizit erfolgen.

Akzeptanz: Fehlerpfade liefern typisierte Fehler, Result-Typen oder
dokumentierte Exceptions. Fehler werden nicht stillschweigend
verschluckt und nicht nur ueber unklassifizierte Strings signalisiert.

---

## 8. Datenanforderungen

### GG-DATA-001 - Gemeinsames Datenmodell

Prioritaet: MVP

Das Produkt muss ein gemeinsames Datenmodell fuer wiederkehrende
Formularfelder bereitstellen.

Mindestens erforderlich sind:

- `applicant`.
- `operator`.
- `site`.
- `asset`.
- `metering`.
- `grid_profile`.
- `evidence`.
- `submission_package`.

Diese Feldnamen sind technische Identifier gemaess GG-LESE-006; zugehoerige
UI-Bezeichner werden separat in deutscher Sprache gefuehrt.

### GG-DATA-002 - Herkunft und Konfidenz

Prioritaet: MVP

Automatisch extrahierte oder vorgeschlagene Werte muessen Herkunft und Status
speichern.

Pflichtfelder pro Wert:

- `source_document`: Pfad oder ID des Quelldokuments.
- `source_location`: Seite (PDF) oder Blatt/Zelle (XLSX), soweit verfuegbar.
- `extraction_method`: einer aus `{manual, parser, ocr, llm, prompt_response}`.
- `status`: einer aus `{extracted, suggested, confirmed, rejected}`.
- `confidence`: Gleitkommawert in `[0.0, 1.0]` oder `null`, wenn nicht
  ermittelbar.
- `confirmed_by_user`: `true` oder `false`.

Akzeptanz: Werte mit `status = confirmed` haben `confirmed_by_user = true`.
Werte mit `extraction_method = manual` muessen `confidence = null` setzen
und tragen `status = confirmed` mit `confirmed_by_user = true` (die
manuelle Eingabe gilt als Bestaetigung). Bei anderen Extraktionsmethoden
ohne ermittelbare Konfidenz wird ebenfalls `confidence = null` gesetzt.

Erlaubte Status-Uebergaenge:

- Initial gesetzt durch Extraktion: `extracted` oder `suggested`.
- Initial gesetzt durch Nutzer: `confirmed` (bei `manual`).
- `extracted` darf nach `suggested`, `confirmed` oder `rejected` wechseln.
- `suggested` darf nach `confirmed` oder `rejected` wechseln.
- `confirmed` und `rejected` sind Endzustaende. Ein erneuter Wechsel
  erfordert einen neuen Wert mit eigener Herkunft.

### GG-DATA-003 - Secrets ausserhalb von Projektdaten

Prioritaet: MVP

Das Produkt darf keine API-Schluessel, Portalpasswoerter oder sonstige Secrets
in Projektdateien oder Exportpakete schreiben.

Soweit Secrets fuer optionale LLM- oder Online-Funktionen benoetigt werden,
muessen sie ueber den Secret-Store des Betriebssystems verwaltet werden:

- Linux: Secret Service (z. B. via libsecret/GNOME Keyring oder KWallet).
- macOS (Sekundaerumgebung gemaess GG-PE-003): Keychain.
- Windows (Sekundaerumgebung gemaess GG-PE-003): Windows Credential Manager.

Akzeptanz: Ein Export eines Demo-Projekts mit konfiguriertem LLM-Adapter
enthaelt keinen API-Schluessel; die Projektdatei enthaelt keinen Klartext-
Secret.

### GG-DATA-004 - Kontrollierte Vokabulare

Prioritaet: MVP

Das Produkt muss folgende kontrollierte Vokabulare als Enumerationen
bereitstellen. Erweiterungen sind als V1-Aenderung moeglich.

`Profiltyp`:

- `Netzbetreiber`.
- `Uebertragungsnetzbetreiber`.
- `Behoerde`.
- `Register`.
- `Branchenquelle`.

`Quellkatalog`:

- `PDF`.
- `XLSX`.
- `Beide`.

`Zugangsart`:

- `PDF`.
- `XLSX`.
- `Portal`.
- `HTML`.
- `OnlineRegister`.
- `ELSTER`.

`Nachnutzungsstatus`:

- `OffeneLizenz`.
- `KeineOffeneLizenzErsichtlich`.
- `Unbekannt`.
- `NurVerlinken`.

`Katalogstatus`:

- `SehrGutErschlossen`.
- `GutErschlossen`.
- `TeilweiseErschlossen`.
- `NichtVerifiziert`.

`Anlagenart`:

- `PV`.
- `PVmitSpeicher`.
- `Speicher`.
- `BHKW`.
- `Wind`.
- `Sonstige`.

`Falltyp` (MVP-Minimalmenge, V1-Erweiterungen moeglich):

- `Steckersolar`.
- `PV_NS_OhneSpeicher` (MVP-Demo, siehe GG-DEC-002).
- `PV_NS_MitSpeicher`.
- `PV_Ab135kW`.
- `Redispatch`.
- `Betreiberwechsel`.

`Dokumenttyp`:

- `Formular`.
- `Zertifikat`.
- `Datenblatt`.
- `Lageplan`.
- `Messkonzept`.
- `Inbetriebsetzungsprotokoll`.
- `Betreiberwechselformular`.
- `Steuerformular`.
- `Unbekannt`.

`XlsxZweck` (Klassifikation von XLSX-Quellen gemaess GG-FA-CAT-005):

- `Formular`.
- `Hilfsdatei`.
- `Stammdatendatei`.
- `RedispatchDatei`.
- `Branchenhilfe`.

### GG-DATA-005 - Profilversionierung

Prioritaet: MVP

Das Produkt muss pro Profil und Regelsatz eine `Profilversion` fuehren.

Pflichtfelder pro Profilversion:

- `version_id`: kalenderbasierter Bezeichner im Format `YYYY-MM-DD` (siehe
  unten).
- `retrieved_at`: ISO-Datum des letzten Quellenabrufs.
- `source_url`: URL der Katalog- oder Profilquelle, aus der die
  Profilversion abgeleitet wurde. `source_url` bezeichnet **nicht** die
  einzelnen Formularlinks aus GG-FA-CAT-001 - diese werden weiterhin als
  Liste am Profil gefuehrt.
- `notes`: optionaler Freitext.

`version_id` wird bewusst kalenderbasiert (`YYYY-MM-DD`) gefuehrt, da
katalogbasierte Profile keine semver-konforme Stabilitaetszusage geben und
das Abrufdatum die natuerliche Versionierungsachse ist.

Akzeptanz: Jede Warnung und jeder Eintrag im Exportpaket laesst sich auf eine
konkrete `Profilversion` zurueckfuehren.

---

## 9. KI-, OCR- und Regelanforderungen

### GG-AI-001 - KI als Vorschlagssystem

Prioritaet: MVP

KI-Ergebnisse muessen als Vorschlaege gekennzeichnet werden. Das gilt sowohl
fuer direkte LLM-Adapter, soweit vorhanden, als auch fuer Ergebnisse, die
Nutzer aus einem generierten Prompt manuell zurueckuebernehmen.

Akzeptanz: Kein KI-extrahierter Wert und kein Prompt-Ruecklauf wird ohne
manuelle Bestaetigung als finaler Exportwert verwendet.

### GG-AI-002 - Prompt-Erzeugung statt direkter KI-Anbindung

Prioritaet: MVP

Das Produkt muss eine KI-Betriebsart unterstuetzen, bei der kein LLM direkt
angebunden wird, sondern ein strukturierter Prompt erzeugt wird.

Der Prompt muss mindestens enthalten:

- Ziel der Analyse.
- relevante Projektdaten.
- relevante Formular- und Profilinformationen inklusive `Profilversion`.
- extrahierte Textausschnitte oder Feldlisten.
- klare Ausgabeanforderung fuer fehlende Felder, offene Unterlagen und
  Plausibilitaetswarnungen.
- Hinweis, keine Rechts-, Steuer- oder Netzanschlussberatung zu leisten.
- Anforderung an ein strukturiertes Antwortformat.

Das Antwortformat muss fuer die Rueckuebernahme geeignet sein. Fuer den MVP
ist mindestens eines der folgenden Formate zulaessig:

- JSON gemaess dem unten beschriebenen Schema.
- Markdown mit festen Abschnitten fuer fehlende Felder, fehlende Unterlagen,
  Plausibilitaetswarnungen, vorgeschlagene Werte und Rueckfragen, die sich
  auf dasselbe logische Schema abbilden lassen.

Die Promptschluessel und Antwortformat-Bezeichner sind technische
Schnittstellenidentifier gemaess GG-LESE-006.

JSON-Schema (informell, MVP-Mindestumfang):

```text
Antwort: Objekt mit Pflichtschluesseln
  missing_fields        : Liste<MissingField>
  missing_documents     : Liste<MissingDocument>
  plausibility_warnings : Liste<PlausibilityWarning>
  suggested_values      : Liste<SuggestedValue>
  questions             : Liste<String>

MissingField         : { field: String, reason: String? }
MissingDocument      : { document_type: String, reason: String? }
PlausibilityWarning  : { severity: "info"|"warnung"|"fehler",
                         field: String?, message: String }
SuggestedValue       : { field: String, value: String|Number|Boolean,
                         source_excerpt: String? }
```

Leere Listen sind zulaessig; fehlende Pflichtschluessel sind unzulaessig.
Eine maschinenlesbare Schemaspezifikation (z. B. JSON Schema) liegt als
Abnahmeartefakt gemaess GG-ACCEPT-004 im Repository.

Akzeptanz:

- Der Nutzer kann einen Prompt aus den aktuellen Projektdaten erzeugen und
  in die Zwischenablage kopieren.
- Vor dem Kopieren ist sichtbar, welche Projekt-, Dokument- und
  Profilinhalte im Prompt enthalten sind.
- Die Anwendung muss eine Eingabefunktion (z. B. ein Textfeld oder ein
  Datei-Import) bereitstellen, in die der Nutzer eine strukturierte Antwort
  im erwarteten Format (JSON oder Markdown gemaess Spezifikation oben)
  einfuegen kann. Aus dieser Antwort werden Feldvorschlaege gemaess
  GG-DATA-002 als `extraction_method = prompt_response` und
  `status = suggested` in das Projekt uebernommen; eine direkte
  LLM-Anbindung ist hierfuer nicht zulaessig.
- Nicht strukturierte Antworten duerfen angezeigt, aber nicht automatisch
  als Feldvorschlaege uebernommen werden.
- Kein Wert aus einem Prompt-Ruecklauf darf ohne Bestaetigung gemaess
  GG-AI-001 final werden.
- Ein Beispiel-Prompt und eine Beispiel-Antwort liegen als Abnahmeartefakt
  gemaess GG-ACCEPT-004 im Repository.

### GG-AI-003 - Deterministische Regeln

Prioritaet: MVP

Pflichtfeld-, Pflichtunterlagen- und Plausibilitaetspruefungen muessen als
deterministische Regeln modelliert werden.

Akzeptanz: Dieselben Projektdaten und dieselbe Profilversion erzeugen
dieselben Warnungen.

### GG-AI-004 - Direkte LLM-Anbindung optional

Prioritaet: V1

Das Produkt kann direkte LLM-Adapter unterstuetzen.

Akzeptanz: Direkte LLM-Adapter sind optional, konfigurierbar und senden Daten
nur nach expliziter Nutzerentscheidung an externe Dienste (siehe
GG-NFA-SEC-002).

### GG-AI-005 - OCR optional im MVP

Prioritaet: V1

OCR soll fuer eingescannte Dokumente unterstuetzt werden.

MVP-Abgrenzung: Der MVP kann mit textbasierten PDF-/XLSX-Dokumenten arbeiten.

---

## 10. Nichtfunktionale Anforderungen

### GG-NFA-SEC-001 - Lokale Verarbeitung

Prioritaet: MVP

Projekt- und Dokumentdaten muessen standardmaessig lokal verarbeitet werden.

Externe Dienste duerfen nur nach expliziter Nutzerentscheidung verwendet
werden.

### GG-NFA-SEC-002 - Datenschutz und Einwilligung

Prioritaet: MVP

Die Anwendung muss deutlich machen, welche Daten lokal verarbeitet werden und
welche Daten optional an externe Dienste gesendet werden.

Die Einwilligung muss pro externem Dienst (z. B. ein konkreter LLM-Anbieter,
ein konkreter Online-Pruefdienst) erfasst werden und folgende
Auswahlmoeglichkeiten bieten:

- einmalig erlauben.
- fuer diese Session erlauben.
- dauerhaft erlauben.
- ablehnen.

Bei der Prompt-Erzeugung muss vor dem Kopieren sichtbar sein, welche Inhalte
in den Prompt aufgenommen werden.

### GG-NFA-USE-001 - Nachvollziehbare Warnungen

Prioritaet: MVP

Jede Warnung muss fuer Nutzer verstaendlich sein.

Eine Warnung muss enthalten:

- Schweregrad aus `{info, warnung, fehler}`.
- betroffener Bereich.
- Ursache.
- empfohlene Korrektur.
- Quelle oder Regel, soweit vorhanden.

Akzeptanz: UI und Exportpaket gruppieren Warnungen nach Schweregrad. Solange
mindestens ein Punkt mit Schweregrad `fehler` offen ist, ist der Export
standardmaessig gesperrt. Der Nutzer kann den Export ueber eine explizite,
protokollierte Override-Bestaetigung dennoch erzeugen; das Exportpaket
markiert in diesem Fall alle Override-Fehler sichtbar. Override-Bestaetigungen
werden im lokalen Anwendungsprotokoll gemaess GG-NFA-LOG-001 sowie im
Exportpaket-Manifest dokumentiert (Zeitpunkt, betroffene Warnungs-IDs).

### GG-NFA-MAINT-001 - Erweiterbarkeit

Prioritaet: MVP

Neue Betreiberprofile, Formularversionen und Regeln muessen ohne Aenderung
der UI-Grundstruktur und ohne Aenderung am Code in `hexagon/core` ergaenzt
werden koennen. Profile und Regeln werden datengetrieben (z. B. als Datei im
Repository oder im Nutzerprofil) erweitert.

Akzeptanz: Das Hinzufuegen eines weiteren Betreiberprofils erfordert keine
Aenderung am UI-Layout oder am fachlichen Kern.

### GG-NFA-TEST-001 - Testbarkeit

Prioritaet: MVP

Validierungsregeln und Formularmapper muessen ohne Tauri-UI testbar sein.

### GG-NFA-PERF-001 - Antwortzeiten

Prioritaet: MVP

Auf einem Referenzsystem (4 Cores, 8 GB RAM, SSD) muessen folgende
Antwortzeiten eingehalten werden:

- Projekt oeffnen aus lokalem Bestand: <= 2 s.
- Import und Klassifikation eines textbasierten PDF bis 5 MB: <= 10 s.
- Import und Klassifikation eines textbasierten PDF bis 50 MB: <= 60 s.
- Import und Klassifikation eines textbasierten XLSX bis 20 MB: <= 30 s.
- Validierungslauf fuer das MVP-Demo-Projekt gemaess GG-ACCEPT-001: <= 3 s.
- Exportpaket fuer das MVP-Demo-Projekt erzeugen: <= 5 s.

Akzeptanz: Ein reproduzierbarer Benchmark oder ein Messprotokoll liegt im
Repository.

### GG-NFA-PERF-002 - Dateigrenzen

Prioritaet: MVP

Das Produkt muss PDF-Dateien bis **50 MB** und XLSX-Dateien bis **20 MB**
verarbeiten koennen. Groessere Dateien duerfen abgelehnt werden, muessen aber
mit einer verstaendlichen Fehlermeldung gemaess GG-NFA-USE-001 reagieren.

### GG-NFA-INSTALL-001 - Reproduzierbarer Build

Prioritaet: MVP

MVP-Builds muessen reproduzierbar sein. Reproduzierbarkeit bedeutet in diesem
Lastenheft:

- Rust-Abhaengigkeiten werden ueber `Cargo.lock` und `cargo build --locked`
  fixiert.
- Frontend-Abhaengigkeiten werden ueber ein eingechecktes Lockfile
  (z. B. `pnpm-lock.yaml` oder `package-lock.json`) fixiert.
- Der dokumentierte Build-Befehl benoetigt keine externen Secrets und
  erzeugt fuer denselben Quellstand auf demselben Referenzsystem dieselben
  Bundle-Inhalte bis auf bekannte nicht-deterministische Anteile
  (Zeitstempel, Signatur).

Akzeptanz: Ein Build-Befehl im Repository erzeugt ein Bundle ohne externe
Geheimnisse; zwei aufeinanderfolgende Builds auf demselben Referenzsystem
unterscheiden sich nur in den dokumentierten nicht-deterministischen
Anteilen.

### GG-NFA-INSTALL-002 - Signierte Distribution

Prioritaet: V1

Das Produkt soll als signiertes Tauri-Bundle fuer Linux (AppImage und .deb)
verteilt werden. MVP-Builds duerfen unsigniert sein.

Akzeptanz: V1-Builds werden signiert ausgeliefert; ein Signaturnachweis
liegt dem Release-Artefakt bei.

### GG-NFA-INSTALL-003 - Updates

Prioritaet: V1

Das Produkt soll einen optionalen Update-Mechanismus haben. Updates duerfen
nur nach Nutzerbestaetigung heruntergeladen werden (siehe GG-NFA-SEC-002).

### GG-NFA-INSTALL-004 - Build-Container

Prioritaet: MVP

Das Projekt muss einen containerisierten Build bereitstellen, der die
Anforderungen aus GG-NFA-INSTALL-001 (Reproduzierbarer Build) abdeckt.
Der Container ist ein Build- und Test-Werkzeug; er ist keine Laufzeit-
oder Deploymentumgebung (siehe GG-NONGOAL-005).

Mindestumfang:

- Ein `Dockerfile` (oder gleichwertige Container-Definition) im
  Repository startet von einer pinned Base-Image-Version und installiert
  Rust- und Frontend-Toolchain ueber gelockte Versionen.
- Build- und Testbefehle aus GG-NFA-INSTALL-005 laufen in diesem
  Container ohne externe Secrets.
- Das resultierende Tauri-Bundle ist nicht Bestandteil des Containers
  und wird als Build-Artefakt extrahiert.

Akzeptanz: Ein dokumentierter Befehl baut den Container und fuehrt
darin `make ci` (siehe GG-NFA-INSTALL-005) erfolgreich aus. Zwei
aufeinanderfolgende Builds auf demselben Referenzsystem unterscheiden
sich nur in den dokumentierten nicht-deterministischen Anteilen
gemaess GG-NFA-INSTALL-001.

### GG-NFA-INSTALL-005 - Makefile-Konvention

Prioritaet: MVP

Das Projekt muss ein `Makefile` als kanonischen Build-Einstiegspunkt
bereitstellen. Konkrete Tool-Aufrufe (cargo, pnpm/npm, tauri, lint,
typecheck, test-runner) werden hinter `make`-Targets gekapselt.

Pflichttargets fuer den MVP:

- `make gates` - Aggregator: lint, format-check, typecheck,
  Architekturtests, Unit- und Integrationstests, Coverage-Gates
  (siehe GG-NFA-COV-*), Dependency-Audit.
- `make ci` - vollstaendiger Pfad fuer CI-Lauf inklusive `gates` und
  Bundle-Erzeugung.
- `make fullbuild` - reproduzierbarer Build des Tauri-Bundles fuer
  Linux (AppImage und .deb).
- `make bundle` - Tauri-Bundle-Erzeugung (AppImage und .deb).
- `make lint`, `make typecheck`, `make test`, `make dep-audit` -
  Einzeltargets, die jeweils als Teilschritt von `gates` aufgerufen
  werden.

Akzeptanz: Die Targets sind im `Makefile` dokumentiert (Header oder
`make help`). Ein leerer Lauf `make gates` auf einem frischen Checkout
endet ohne externe Secrets und mit deterministischem Exitcode.

### GG-NFA-LOG-001 - Lokales Logging

Prioritaet: MVP

Das Produkt muss ein lokales Anwendungsprotokoll fuehren. Das Protokoll darf
keine personenbezogenen Projektdaten, keine Klartext-Secrets und keine
Inhalte aus importierten Dokumenten enthalten.

Das Logverzeichnis folgt der XDG Base Directory Specification:

- Linux: `$XDG_STATE_HOME/gridguide/` (Fallback `~/.local/state/gridguide/`).
- macOS und Windows (sekundaer, siehe GG-PE-003): plattformuebliches
  State-/AppData-Verzeichnis, dokumentiert je Plattform.

Akzeptanz: Der konkrete Pfad ist in `docs/architecture.md` oder in einer
ADR dokumentiert; ein Demo-Log enthaelt nur Ereignisse (z. B. "Projekt
geoeffnet"), keine Inhalte.

### GG-NFA-LOG-002 - Keine Telemetrie ohne Einwilligung

Prioritaet: MVP

Das Produkt darf ohne explizite Nutzerentscheidung gemaess GG-NFA-SEC-002
keine Telemetrie, Crash-Reports oder Nutzungsdaten an externe Dienste senden.

### GG-NFA-BACKUP-001 - Sicherung lokaler Projekte

Prioritaet: MVP

Das Produkt muss Projektdateien atomar speichern (Schreiben in eine
temporaere Datei, danach Rename), sodass ein Programmabbruch keine teilweise
geschriebene Projektdatei hinterlaesst.

### GG-NFA-BACKUP-002 - Export als Backup

Prioritaet: V1

Das Produkt soll eine "Projektsicherung exportieren"-Funktion anbieten, die
Projektdaten und referenzierte Dokumente in ein einzelnes Archiv buendelt.

### GG-NFA-I18N-001 - Sprache

Prioritaet: MVP

Die MVP-UI muss in deutscher Sprache verfuegbar sein. Weitere Sprachen sind
V1.

Akzeptanz: Alle MVP-relevanten UI-Texte sind in einer zentralen Ressource
gepflegt; Hartkodierungen in Komponenten werden in Tests oder per Linting
verhindert.

### GG-NFA-A11Y-001 - Basis-Barrierefreiheit

Prioritaet: V1

Das Produkt soll WCAG 2.1 AA fuer Kontraste, Tastaturbedienung und
Bildschirmleser-Beschriftung der Hauptansichten erreichen.

MVP-Mindestanforderung: Alle MVP-Hauptansichten muessen per Tastatur bedient
werden koennen.

Akzeptanz: Ein dokumentiertes manuelles Testprotokoll je MVP-Hauptansicht
weist die vollstaendige Tastaturbedienbarkeit nach (Fokusreihenfolge,
Aktivierung primaerer Aktionen, Schliessen modaler Dialoge). Das Protokoll
liegt im Repository und wird mit jeder MVP-Abnahme erneuert.

### GG-NFA-COV-001 - Gesamt-Testabdeckung

Prioritaet: MVP

Das Projekt soll eine Mindest-Line-Coverage von **80 Prozent** ueber
den Produktionscode erreichen. Zielwert fuer spaetere Releases ist
90 Prozent.

Akzeptanz: Ein Coverage-Report im Repository weist die
Gesamt-Coverage aus. Abweichungen werden in der Closure-Notiz des
zugehoerigen Slice (siehe ADR 0001 §2.1) dokumentiert.

### GG-NFA-COV-002 - Kritische Domainlogik

Prioritaet: MVP

Kritischer Domaincode muss mindestens **90 Prozent** Line-Coverage
erreichen.

Kritisch im Sinne dieser Anforderung sind:

- Pflichtfeld-, Pflichtunterlagen- und Plausibilitaetsregeln
  (`hexagon/core`-Module fuer GG-FA-VAL-001 bis GG-FA-VAL-003).
- Dokumentklassifikation und Feldextraktion (GG-FA-DOC-001,
  GG-MVP-006).
- Profil- und Profilversionsverwaltung (GG-FA-CAT-001, GG-DATA-005).
- Exportpaket-Erzeugung (GG-FA-EXPORT-001).
- Prompt-Erzeugung und Antwort-Rueckuebernahme (GG-AI-002).

Akzeptanz: Der Coverage-Report weist diese Module separat aus. Ein
Build-Gate (siehe GG-NFA-QG-001) blockiert bei Unterschreitung.

### GG-NFA-COV-003 - Branch-Coverage

Prioritaet: V1

Das Projekt soll mindestens 70 Prozent Branch-Coverage ueber den
Produktionscode erreichen.

Akzeptanz: Der Coverage-Report weist Branch-Coverage separat aus.

### GG-NFA-COV-004 - Keine kuenstliche Coverage

Prioritaet: MVP

Coverage darf nicht kuenstlich erzeugt werden.

Akzeptanz: Tests ohne fachliche Assertion, reine Getter-/Setter-
Ausfuehrung und Snapshots ohne Verhaltenspruefung gelten nicht als
Qualitaetsnachweis. Code-Review weist solche Tests zurueck oder
markiert sie explizit als reine Smoke-Tests ausserhalb der
Coverage-Schwelle.

### GG-NFA-QG-001 - Coverage-Gate

Prioritaet: MVP

Der Build muss bei unterschrittener Coverage-Schwelle (siehe
GG-NFA-COV-001, GG-NFA-COV-002) fehlschlagen.

Akzeptanz: Ein dokumentiertes Build-Target (siehe GG-NFA-INSTALL-005)
bricht bei Unterschreitung mit nicht-erfolgreichem Exitcode ab.
Ausnahmen muessen begruendet und in der Slice-Closure dokumentiert
sein.

### GG-NFA-QG-002 - Test-Gate

Prioritaet: MVP

Der Build darf bei fehlschlagenden Tests nicht erfolgreich sein.

Akzeptanz: Unit-, Integrations- und Architekturtests liefern einen
nicht erfolgreichen Exitcode, wenn sie fehlschlagen, und blockieren
`make gates` bzw. `make ci`.

### GG-NFA-QG-003 - Architektur-Gate

Prioritaet: MVP

Der Build darf bei Architekturverletzungen nicht erfolgreich sein.

Akzeptanz: Verletzungen von GG-ARCH-003 (Core-Isolation), GG-CC-003
(Domain ohne Framework) und GG-CC-004 (keine Modulzyklen) werden
durch automatisierte Importchecks oder Architekturtests erkannt und
blockieren den Build.

### GG-NFA-QG-004 - Statische-Analyse-Gate

Prioritaet: MVP

Der Build soll bei statischen Analysefehlern (Lint, Format,
Typecheck) fehlschlagen.

Akzeptanz: `make lint`, `make typecheck` und `make gates` liefern bei
Verstoessen einen nicht erfolgreichen Exitcode. Severity-Schwelle
ist im Toolingkonfigurationsfile dokumentiert.

### GG-NFA-QG-005 - Dependency-Security-Gate

Prioritaet: MVP

Der Build muss bei kritischen oder hohen Security-Findings in
Abhaengigkeiten ohne dokumentierte Ausnahme fehlschlagen.

Akzeptanz: `make dep-audit` (siehe GG-NFA-INSTALL-005) liefert
Severity, betroffene Komponente und ggf. dokumentierte Ausnahme.
Kritische und hohe Befunde blockieren `make gates`. Ausnahmen sind
mit Begruendung und Ablaufdatum im Repository hinterlegt.

### GG-NFA-CICD-001 - Automatisierte Pipeline

Prioritaet: MVP

Das Projekt muss eine automatisierte CI-Pipeline bereitstellen, die
bei jedem Push und Pull-Request laeuft.

Die Pipeline muss mindestens ausfuehren:

- `make gates` (siehe GG-NFA-INSTALL-005, GG-NFA-QG-001 bis
  GG-NFA-QG-005),
- den containerisierten Build aus GG-NFA-INSTALL-004,
- Veroeffentlichung der Coverage- und Test-Reports als
  CI-Artefakte.

Akzeptanz: Ein dokumentierter CI-Workflow im Repository erzeugt fuer
jeden Push einen `make gates`-Lauf mit gruenem oder rotem Status. Der
gewaehlte CI-Anbieter ist im begleitenden ADR dokumentiert.

### GG-NFA-CICD-002 - Plattform-Matrix

Prioritaet: MVP (Linux als Pflichtcheck, macOS und Windows als
Best-Effort); V1 (macOS und Windows als Pflichtcheck).

Die CI-Pipeline muss `make gates` und einen Bundle-Build fuer Linux
ausfuehren und ihn als Pflichtcheck (Required Check) fuehren. Sie
muss dieselben Schritte fuer Windows und macOS im MVP als
Best-Effort mitlaufen lassen; voller Pflichtcheck-Status fuer macOS
und Windows ist V1.

Best-Effort bedeutet im MVP:

- Fehlschlag eines macOS- oder Windows-Build-Jobs blockiert den
  Merge nur, wenn die Aenderung explizit eine plattformspezifische
  Funktion betrifft.
- Plattformspezifische Test-Skips sind erlaubt und werden im
  CI-Workflow dokumentiert.

Akzeptanz: Die CI-Workflow-Datei definiert eine Plattform-Matrix mit
mindestens `linux`, `macos`, `windows`. Der Linux-Job ist
Pflichtcheck; macOS- und Windows-Jobs sind im MVP als Best-Effort
markiert. Quelle des Bundle-Builds ist die Tauri-Toolchain auf der
jeweils nativen Plattform.

### GG-NFA-CICD-003 - Release-Workflow

Prioritaet: V1

Das Projekt soll einen Release-Workflow bereitstellen, der bei einem
versionierten Tag (z. B. `v0.1.0`) signierte Bundles fuer alle
unterstuetzten Plattformen erzeugt und als Release-Artefakt
veroeffentlicht.

Akzeptanz: Ein Tag-Push erzeugt einen Release-Entwurf mit Bundles
gemaess GG-NFA-INSTALL-002. Der Workflow ist im Repository
dokumentiert und nutzt nur Secrets, die in GG-NFA-CICD-004
geregelten Schutz erfuellen.

### GG-NFA-CICD-004 - Secret-Handling

Prioritaet: MVP fuer Build, V1 fuer Signing.

CI-Secrets (Signaturschluessel, optionale Tokens, API-Zugaenge)
duerfen nicht im Repository, in Logs oder in Artefakten erscheinen.

Mindestanforderungen:

- Secrets werden ausschliesslich ueber den Secret-Store des
  CI-Anbieters verwaltet.
- Workflow-Logs maskieren Secret-Werte und werden vor
  Veroeffentlichung auf Klartext-Lecks geprueft.
- Pull-Requests aus Forks haben keinen Zugriff auf Signing-Secrets;
  Workflows fuer Forks laufen ohne Secrets durch.

Akzeptanz: Der CI-Workflow weist die Secret-Quelle (Variablenname
und Speicherort) je Job aus. Ein Demo-Run mit einem absichtlich
durchgereichten Test-Secret zeigt im Log nur den Maskierungs-Token
und nicht den Klartext.

---

## 11. Lizenz und Veroeffentlichung

### GG-LIC-001 - Open Source

Prioritaet: MVP

GridGuide muss unter einer OSI-anerkannten Open-Source-Lizenz veroeffentlicht
werden. Gewaehlte Lizenz ist **MIT** (siehe GG-DEC-005).

Akzeptanz: Eine `LICENSE`-Datei mit dem gewaehlten Lizenztext liegt im
Repository.

### GG-LIC-002 - Drittquellen

Prioritaet: MVP

Drittquellen (Katalogdaten, Formularreferenzen) muessen mit Nennung des
Nachnutzungsstatus gemaess GG-DATA-004 dokumentiert sein. Quellen ohne offene
Lizenz duerfen nur verlinkt, nicht neu verteilt werden (siehe
GG-NONGOAL-004 und GG-FA-CAT-007).

---

## 12. Abnahmeartefakte

### GG-ACCEPT-001 - Demo-Projekt

Prioritaet: MVP

Das Repository muss ein Demo-Projekt fuer den ersten Betreiber und Falltyp
enthalten.

### GG-ACCEPT-002 - Beispiel-Export

Prioritaet: MVP

Das Repository muss ein Beispiel-Exportpaket oder einen reproduzierbaren
Exporttest enthalten.

### GG-ACCEPT-003 - Requirements-Matrix

Prioritaet: MVP

Das Repository muss eine minimale Requirements-Matrix enthalten, die
MVP-Anforderungen, Status und Test-/Demo-Artefakte verknuepft.

Der Status eines Eintrags wird aus dem Vokabular `RequirementStatus`
gewaehlt:

- `geplant`: Anforderung ist bekannt, Umsetzung noch nicht begonnen.
- `in_arbeit`: Umsetzung laeuft, kein Nachweis verfuegbar.
- `umgesetzt`: Umsetzung abgeschlossen, Nachweis verfuegbar, Abnahme
  ausstehend.
- `abgenommen`: Nachweis liegt vor und wurde gemaess GG-LESE-002 anerkannt.

Akzeptanz: Fuer jede MVP-Anforderung ist genau ein Status aus diesem
Vokabular und ein geplanter oder vorhandener Nachweis dokumentiert.

### GG-ACCEPT-004 - Beispiel-Prompt und Beispiel-Antwort

Prioritaet: MVP

Das Repository muss einen Beispiel-Prompt gemaess GG-AI-002 sowie eine
strukturierte Beispiel-Antwort (JSON oder Markdown) enthalten.

Akzeptanz: Ein reproduzierbares Skript oder ein Test erzeugt aus dem
MVP-Demo-Projekt den Beispiel-Prompt. Die Beispiel-Antwort laesst sich in das
Demo-Projekt zurueckspielen, ohne dass Werte ohne Bestaetigung gemaess
GG-AI-001 final werden.

---

## 13. Risiken und Annahmen

Dieses Kapitel listet zuerst die identifizierten Risiken (`GG-RISK-*`) und
anschliessend die zugrundeliegenden Annahmen (`GG-ASSUMP-*`).

### GG-RISK-001 - Aendernde Formularquellen

Formularlinks und Versionen koennen sich aendern.

Gegenmassnahme: Quellenmonitoring, Abrufdatum und Profilversionen werden als
Kernbestandteil des Systems behandelt (siehe GG-DATA-005, GG-FA-SRC-001).

### GG-RISK-002 - Portal-only-Prozesse

Einige Prozesse sind nicht vollstaendig aus oeffentlichen Formularen
rekonstruierbar.

Gegenmassnahme: Portal-only-Prozesse werden sichtbar markiert und nicht als
automatisiert geloest dargestellt (siehe GG-FA-CAT-006).

### GG-RISK-003 - Lizenzlage

Viele Originalformulare weisen keine offene Nachnutzungslizenz aus.

Gegenmassnahme: Originalformulare werden verlinkt und beschrieben, aber nicht
ungeprueft neu verteilt (siehe GG-NONGOAL-004, GG-FA-CAT-007, GG-LIC-002).

### GG-RISK-004 - Falsche Extraktion

OCR-, Parser-, Prompt- und LLM-Ergebnisse koennen falsch sein.

Gegenmassnahme: Automatische Werte bleiben Vorschlaege und muessen vor dem
Export bestaetigt werden (siehe GG-AI-001, GG-DATA-002).

### GG-RISK-005 - Scope-Wachstum

Die Anzahl der Betreiber, Formulare und Sonderfaelle kann schnell wachsen.

Gegenmassnahme: Der MVP startet mit einem Betreiberprofil, einem Falltyp und
einem Exportpaket (siehe GG-DEC-001 bis GG-DEC-003).

### GG-ASSUMP-001 - Deutsche Prozesse im Fokus

Der MVP arbeitet ausschliesslich mit deutschen Netzanschluss-, Verguetungs-
und Registerprozessen. Grenzueberschreitende oder nicht-deutsche Verfahren
sind nicht Teil des Scopes.

### GG-ASSUMP-002 - Nutzer mit Fachkenntnis

Es wird angenommen, dass Nutzer einen elektrotechnischen oder fachlichen
Hintergrund haben (z. B. Installateur, Projektentwickler, Antragsteller mit
Vorkenntnissen). GridGuide ersetzt keine Schulung und keine Beratung.

### GG-ASSUMP-003 - Oeffentliche Quellen als Grundlage

Es wird angenommen, dass die im PDF- und XLSX-Katalog gelisteten Quellen
oeffentlich zugaenglich sind und ihre Strukturen sich nicht grundlegend
aendern, bevor sie ueber GG-FA-SRC-001 ueberwacht werden.

### GG-ASSUMP-004 - Lokale Verarbeitung ist ausreichend

Es wird angenommen, dass die zu verarbeitenden Projektdokumente auf einem
Referenzsystem gemaess GG-NFA-PERF-001 lokal verarbeitet werden koennen,
ohne dass eine zentrale Server-Infrastruktur erforderlich ist.

### GG-ASSUMP-005 - Nutzer betreibt eigene KI extern

Fuer den MVP wird angenommen, dass Nutzer einen externen KI-Dienst (z. B.
einen Chat-Assistenten) selbst betreiben oder beauftragen, falls sie die
Prompt-Erzeugung gemaess GG-AI-002 nutzen wollen. GridGuide stellt keinen
KI-Dienst bereit und uebernimmt keine Verantwortung fuer dessen Antworten.

---

## 14. Getroffene MVP-Entscheidungen

### GG-DEC-001 - Erstes Profil

Status: entschieden

Der MVP startet mit `Westnetz` als erstem Netzbetreiberprofil.

### GG-DEC-002 - Erster Falltyp

Status: entschieden

Der MVP startet mit dem Falltyp `PV_NS_OhneSpeicher`: PV-Anlage im
Niederspannungsbereich bis 30 kWp ohne Speicher mit Ueberschusseinspeisung.
Fuer diesen Falltyp ist ein `Messkonzept` Pflichtangabe und
Pflichtunterlage (siehe GG-FA-PROJ-001, GG-FA-VAL-003, GG-MVP-006).

### GG-DEC-003 - Erster Output

Status: entschieden

Der MVP erzeugt zuerst ein ZIP- oder Ordner-Exportpaket mit Checkliste,
Projektstammdaten, Warnungen, Quellen-/Profilversion und referenzierten
Dokumenten oder Links. Vorbefuellte PDF-/XLSX-Formulare bleiben V1.

### GG-DEC-004 - Frontend-Stack

Status: entschieden

Der MVP verwendet SvelteKit im Single-Page-Modus als Frontend (siehe
GG-ARCH-008 und `docs/plan/adr/0002-frontend-stack-sveltekit.md`).

### GG-DEC-005 - Open-Source-Lizenz

Status: entschieden

GridGuide wird unter der MIT-Lizenz veroeffentlicht (siehe GG-LIC-001).

---

## 15. Traceability

Die Matrix deckt alle bisher vergebenen Anforderungs-IDs ab. Jede neue
Anforderung muss bei ihrer Aufnahme einer Themenzeile zugeordnet werden.

| Thema                       | Lastenheft-Anforderungen                                                 |
| --------------------------- | ------------------------------------------------------------------------ |
| Katalogbasierter Scope      | GG-FA-CAT-001 bis GG-FA-CAT-008                                          |
| Lokale Tauri-App            | GG-MVP-001, GG-ARCH-001, GG-ARCH-008                                     |
| Hexagonale Architektur      | GG-ARCH-002 bis GG-ARCH-006                                              |
| DDD-Zuschnitt               | GG-ARCH-007, GG-DATA-001                                                 |
| Projektpersistenz           | GG-FA-PROJ-001, GG-FA-PROJ-002, GG-NFA-BACKUP-001, GG-NFA-BACKUP-002     |
| Dokumentanalyse             | GG-MVP-005, GG-MVP-006, GG-FA-DOC-001                                    |
| Checklisten und Validierung | GG-MVP-004, GG-FA-VAL-001 bis GG-FA-VAL-003, GG-NFA-USE-001              |
| Exportpaket                 | GG-MVP-007, GG-FA-EXPORT-001, GG-FA-FILL-001                             |
| KI als Vorschlagssystem     | GG-MVP-009, GG-AI-001 bis GG-AI-005, GG-DATA-002, GG-ACCEPT-004          |
| Portal-only-Abgrenzung      | GG-MVP-008, GG-FA-CAT-006, GG-NONGOAL-002, GG-RISK-002                   |
| Lizenz-/Nachnutzungsstatus  | GG-FA-CAT-007, GG-NONGOAL-004, GG-LIC-001, GG-LIC-002, GG-RISK-003       |
| Lokale Verarbeitung         | GG-NFA-SEC-001, GG-NFA-SEC-002, GG-NFA-LOG-001, GG-NFA-LOG-002           |
| Performance und Betrieb     | GG-NFA-PERF-001, GG-NFA-PERF-002, GG-NFA-INSTALL-001 bis GG-NFA-INSTALL-005 |
| Build- und Test-Tooling     | GG-NFA-INSTALL-004, GG-NFA-INSTALL-005 (ADR 0004)                        |
| Erweiterbarkeit und Tests   | GG-NFA-MAINT-001, GG-NFA-TEST-001                                        |
| SOLID und Code-Conventions  | GG-PRINC-001 bis GG-PRINC-006, GG-CC-001 bis GG-CC-008                   |
| Testabdeckung               | GG-NFA-COV-001 bis GG-NFA-COV-004 (ADR 0004)                             |
| Quality Gates               | GG-NFA-QG-001 bis GG-NFA-QG-005 (ADR 0004)                               |
| CI/CD und Release           | GG-NFA-CICD-001 bis GG-NFA-CICD-004 (ADR 0005), GG-PE-003                |
| Sprache und Barrierefreiheit| GG-NFA-I18N-001, GG-NFA-A11Y-001                                         |
| Quellenstatus               | GG-FA-SRC-001, GG-DATA-005, GG-RISK-001                                  |
| Vokabulare und Datenmodell  | GG-DATA-001 bis GG-DATA-005                                              |
| Demo-Artefakte              | GG-ACCEPT-001 bis GG-ACCEPT-004                                          |
| MVP-Entscheidungen          | GG-DEC-001 bis GG-DEC-005                                                |
| Annahmen                    | GG-ASSUMP-001 bis GG-ASSUMP-005                                          |

---

## 16. Glossar

| Begriff            | Bedeutung                                                                            |
| ------------------ | ------------------------------------------------------------------------------------ |
| Betreiberprofil    | Konfiguration fuer Netzbetreiber, Behoerde, Register oder Branchenquelle             |
| Falltyp            | fachlicher Prozess wie Steckersolar, Speicher, PV ab 135 kW oder Redispatch          |
| Demo-Falltyp       | Der im MVP verbindlich umgesetzte Falltyp `PV_NS_OhneSpeicher` (siehe GG-DEC-002)   |
| Formularfamilie    | Gruppe fachlich verwandter Formulare wie Anmeldung, Inbetriebsetzung oder Verguetung |
| Katalogseed        | kuratierter Startdatensatz aus `Katalog-pdf.md` und `Katalog-xlsx.md`                |
| Pflichtunterlage   | Dokument, das fuer ein Profil und einen Falltyp erforderlich ist                     |
| Nachnutzungsstatus | Hinweis, ob eine Quelle offen nutzbar, unbekannt oder nur zu verlinken ist           |
| Portal-only        | Prozess, der offiziell ueber ein Portal laeuft und nicht durch PDF ersetzt wird      |
| Vorbereitungshilfe | Funktion, die einen portalgefuehrten Prozess unterstuetzt, ohne ihn zu ersetzen      |
| Einreichungspaket  | Export aus Checkliste, Stammdaten, Formularen, Nachweisen und Warnungen              |
| Profilversion      | Versionierte Auspraegung eines Profils gemaess GG-DATA-005                           |
| Schweregrad        | Klassifikation einer Warnung in `info`, `warnung`, `fehler` (siehe GG-NFA-USE-001)   |
| Override-Bestaetigung | explizite, protokollierte Nutzerentscheidung, einen Export trotz `fehler` zu erzeugen (siehe GG-NFA-USE-001) |
| RequirementStatus  | Vokabular fuer den Status eines Anforderungseintrags (siehe GG-ACCEPT-003)           |
| Driving Adapter    | Adapter, der Nutzer- oder API-Anfragen in den Hexagon-Kern bringt                    |
| Driven Adapter     | Adapter, ueber den der Hexagon-Kern externe Technik nutzt (PDF, XLSX, Dateisystem, HTTP, LLM) |
