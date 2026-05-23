# Roadmap — grid-guide

**Status:** Aktiv — Spezifikationsphase abgeschlossen, **M1 `Done`**
(Closure 2026-05-23). M2 noch nicht aktiviert.
**Stand:** 2026-05-23 (Lastenheft v0.4.0; ADRs 0001..0005
`Accepted`; `spec/architecture.md`-Skelett vorhanden; M1-Closure-
Notiz unter
[`done/M1-Slice-Plan-results.md`](../done/M1-Slice-Plan-results.md)).
**Bezug:** [Lastenheft](../../../../spec/lastenheft.md);
[ADR-Index](../../adr/README.md);
[`spec/architecture.md`](../../../../spec/architecture.md).

---

## 1. Zweck

Diese Roadmap fuehrt die Meilensteine, die sich aus dem Lastenheft
ergeben. Sie ist die Quelle fuer die Status-Spalte der
Requirements-Matrix gemaess `GG-ACCEPT-003` und nennt fuer jeden
Meilenstein die Lastenheft-IDs, die mit ihm abgenommen werden.

Spec-/Architektur-Entscheidungen liegen aktuell verteilt in
Lastenheft und ADRs (siehe [ADR-Index](../../adr/README.md)). Eine
konsolidierte `spec/architecture.md` entsteht in M1, sobald das erste
Code-Skelett `GG-AR-*`-Kennungen einfordert (siehe Trigger 001).

---

## 2. Konvention

- Meilensteine werden fortlaufend numeriert (`M1`, `M2`, …).
- Jeder Meilenstein hat:
  - **Lieferziel** (was wird umgesetzt),
  - **Lastenheft-IDs** (`GG-*`),
  - **ADR-Pointer** (welche ADRs gelten oder werden geschaerft),
  - **DoD-Checkliste** (einzeln pruefbar),
  - **Status** (`Pending` / `In Progress` / `Done`).
- Abgeschlossene Meilensteine wandern als Closure-Notiz nach
  `docs/plan/planning/done/`.
- Detail-Slice-Plaene fuer kommende Meilensteine wandern bei
  Aktivierung nach `docs/plan/planning/next/` (Scope-Skizze) und
  spaeter `in-progress/` (aktiv).
- DoD-Checkboxen werden nicht in der Roadmap abgehakt, solange der
  Meilenstein offen ist — die Closure-Notiz in `done/` traegt den
  finalen Stand.
- V1-Themen sind in §4 separat gefuehrt und nicht Teil des
  MVP-Pfades.

---

## 3. Meilensteine (MVP-Pfad)

### M1 — Foundation, Build-Tooling und CI

**Slice-Plan:** [`done/M1-Slice-Plan.md`](../done/M1-Slice-Plan.md)
+ [`done/M1-Slice-Plan-results.md`](../done/M1-Slice-Plan-results.md)
(abgeschlossen 2026-05-23; alle sieben Wellen geliefert; Linux-
CI-Pflichtjob gruen, macOS gruen, Windows als Best-Effort rot mit
[Trigger 016](../open/016-windows-test-runtime-setup.md) zur
Diagnose; `scripts/repro-check.sh` PASS).

- **Lieferziel:** lokales Repo-Skelett, mit dem `make gates` lokal
  und in CI gruen laeuft.
  - `src-tauri/` mit minimaler `main.rs` (kein fachlicher Code).
  - `frontend/` mit SvelteKit-Skelett (Startseite "Hello GridGuide"
    plus Tastaturfokus-Demo).
  - `Makefile` mit allen Pflichttargets aus `GG-NFA-INSTALL-005`.
  - `Dockerfile` mit Build-Stage (`GG-NFA-INSTALL-004`).
  - `.github/workflows/gates.yml` mit Linux+macOS+Windows-Matrix.
  - `tools/arch-check.sh` als Stub, der initiale Tabu-Regeln aus
    `GG-ARCH-003` / `GG-CC-003` / `GG-CC-004` durchsetzt.
  - `spec/architecture.md`-Skelett (siehe Trigger 001) mit
    Komponenten-, Port- und Tabu-Stubs.
- **Lastenheft-IDs:** `GG-MVP-001` (nur Skelett-Teil: lokal startbare
  Tauri-App ohne fachlichen Inhalt; volle Abnahme der
  `GG-MVP-001`-Akzeptanz mit UI-Inhalt erfolgt mit M6/M7),
  `GG-ARCH-001..008`,
  `GG-PRINC-001..006`, `GG-CC-001..008`, `GG-NFA-INSTALL-001`,
  `GG-NFA-INSTALL-004`, `GG-NFA-INSTALL-005`, `GG-NFA-COV-001..004`
  (Skelett erfuellt Schwellen mangels Logik trivial; gilt als
  validiert sobald M2-Domain-Code die Schwellen weiterhin haelt
  bzw. uebertrifft),
  `GG-NFA-QG-001..005`, `GG-NFA-CICD-001`, `GG-NFA-CICD-002`,
  `GG-NFA-CICD-004`.
- **ADR-Pointer:** Validiert die Spike-Vertraege aus
  [`ADR 0004`](../../adr/0004-quality-gates-and-coverage-tooling.md) §4
  und [`ADR 0005`](../../adr/0005-ci-release-tauri-action.md) §4 →
  beide ADRs wechseln auf `Accepted`. Schliesst Trigger 001
  (architecture.md).
- **DoD-Checkliste:**
  - [x] `src-tauri/` und `frontend/` starten lokal als Tauri-Dev-Build.
  - [x] `make gates` lokal gruen ohne externe Secrets, < 5 min auf
        Referenz-Hardware.
  - [x] `tools/arch-check.sh` meldet zwei kuenstlich eingebaute
        Tabu-Verletzungen rot.
  - [x] `.github/workflows/gates.yml` Linux-Job gruen; macOS-Job
        gruen, Windows-Job rot als Best-Effort
        ([Trigger 016](../open/016-windows-test-runtime-setup.md)).
  - [x] `make container-gates` baut den Build-Container und fuehrt
        `make gates` darin gruen aus.
  - [x] `spec/architecture.md`-Skelett checkt initiale `GG-AR-COMP-*`,
        `GG-AR-PORT-*` und `GG-AR-TABU-*`-Stubs.
  - [x] ADR 0004 und ADR 0005 auf `Accepted` gehoben; Schaerfungs-
        Spalte in `docs/plan/adr/README.md` aktualisiert.
- **Status:** `Done` (abgeschlossen 2026-05-23; Closure-Notiz unter
  [`done/M1-Slice-Plan-results.md`](../done/M1-Slice-Plan-results.md)).

### M2 — Domain-Kern und Katalog-Seed

- **Lieferziel:** Datenmodell und Vokabulare im hexagonalen Kern,
  plus erstes Profil und erster Falltyp als Seed.
  - `hexagon/core/domain` mit `Project`, `Profile`, `Falltyp`,
    `Document`, `Warning`, `Profilversion` als immutable Strukturen
    (`GG-CC-007`).
  - Enums fuer alle `GG-DATA-004`-Vokabulare (`Profiltyp`,
    `Quellkatalog`, `Zugangsart`, `Nachnutzungsstatus`,
    `Katalogstatus`, `Anlagenart`, `Falltyp`, `Dokumenttyp`,
    `XlsxZweck`).
  - Westnetz-Profil als Seed-Datensatz (`GG-DEC-001`,
    `GG-FA-CAT-003`).
  - Falltyp `PV_NS_OhneSpeicher` (`GG-DEC-002`) als Datenstruktur
    mit Pflichtfeld- und Pflichtunterlagen-Liste.
- **Lastenheft-IDs:** `GG-MVP-002`, `GG-MVP-003`, `GG-DATA-001..005`,
  `GG-FA-CAT-001`, `GG-FA-CAT-003`, `GG-FA-CAT-006`, `GG-FA-CAT-007`,
  `GG-FA-PROJ-001` (Datenmodell-Teil; Lifecycle in M3).
- **ADR-Pointer:** `GG-NFA-COV-002` greift erstmals auf produktiven
  Code; die kritische 90 %-Schwelle wird mit M2-Tests validiert.
- **DoD-Checkliste:**
  - [ ] Alle `GG-DATA-004`-Vokabulare als Enums vorhanden und
        getestet.
  - [ ] Westnetz-Seed liegt als maschinenlesbare Datei vor und wird
        beim Test geladen.
  - [ ] `PV_NS_OhneSpeicher`-Falltyp ist mit Pflichtfeld- und
        Pflichtunterlagen-Liste hinterlegt.
  - [ ] Coverage: Profil- und Profilversionsmodule ≥ 90 % gemaess
        `GG-NFA-COV-002` (kritische Domainlogik); restliche
        M2-Module (Project, Falltyp, Document, Warning) ≥ 80 %
        gemaess `GG-NFA-COV-001`.
  - [ ] Architektur-Check meldet keine Domain-zu-Adapter-Imports
        (`GG-CC-003`).
- **Status:** `Pending`.

### M3 — Projekt-Lifecycle und Persistenz

- **Lieferziel:** Projektdateien lokal anlegen, oeffnen, speichern,
  schliessen — inkl. atomarer Schreibvorgaenge und Logging.
  - Use-Case-Ports und -Implementierungen unter
    `hexagon/core/use_cases` fuer `create_project`,
    `open_project`, `save_project`, `close_project`.
  - Driven Adapter fuer Dateisystem-Persistenz; atomare Speicherung
    via Temp-Datei + Rename (`GG-NFA-BACKUP-001`).
  - Lokales Logging via `tracing` o. ae., XDG-konformer Pfad
    (`GG-NFA-LOG-001`).
  - Secret-Store-Adapter-Skelett (`GG-DATA-003`), noch ohne
    LLM-Anbindung.
- **Lastenheft-IDs:** `GG-FA-PROJ-002`, `GG-NFA-BACKUP-001`,
  `GG-NFA-LOG-001`, `GG-NFA-LOG-002`, `GG-NFA-SEC-001`,
  `GG-NFA-SEC-002` (Einwilligungs-Skelett), `GG-DATA-003`.
- **ADR-Pointer:** Persistenz ist im MVP Dateisystem; SQLite ist V1
  (siehe `GG-ARCH-008`). Folge-ADR fuer Datei-Schema empfehlenswert
  bei M3-Start.
- **DoD-Checkliste:**
  - [ ] Demo-Projekt kann geschlossen, erneut geoeffnet und mit
        denselben Stammdaten weiterbearbeitet werden.
  - [ ] Abbruch waehrend `save_project` hinterlaesst keine
        teilweise geschriebene Datei.
  - [ ] Log-Verzeichnis liegt unter `$XDG_STATE_HOME/gridguide/`
        und enthaelt keine Projektdaten und keine Secrets.
- **Status:** `Pending`.

### M4 — Validierung und Checkliste

- **Lieferziel:** deterministische Regel-Engine fuer Pflichtfelder,
  Pflichtunterlagen und Plausibilitaet; Schweregrad-System mit
  Override.
  - Pflichtfeldpruefung je Profil/Falltyp (`GG-FA-VAL-001`).
  - Pflichtunterlagenpruefung (`GG-FA-VAL-002`).
  - Mindestens fuenf Plausibilitaetsregeln fuer
    `PV_NS_OhneSpeicher` (`GG-FA-VAL-003`).
  - Schweregrad-Struktur `{info, warnung, fehler}` mit
    Override-Mechanismus (`GG-NFA-USE-001`).
  - Deterministische Regelausfuehrung (`GG-AI-003`).
- **Lastenheft-IDs:** `GG-MVP-004`, `GG-FA-VAL-001..003`,
  `GG-NFA-USE-001`, `GG-AI-003`.
- **ADR-Pointer:** Folge-ADR fuer Regel-Repraesentation
  (datengetrieben vs. Code) erwartet — Trigger bei M4-Start.
- **DoD-Checkliste:**
  - [ ] Mindestens fuenf Regeln fuer `PV_NS_OhneSpeicher` aktiv und
        getestet.
  - [ ] Dieselben Projektdaten + dieselbe Profilversion erzeugen
        deterministisch dieselben Warnungen.
  - [ ] Override-Bestaetigung wird im lokalen Log und im
        Export-Manifest dokumentiert (Verifikation erfolgt mit M7).
- **Status:** `Pending`.

### M5 — Dokumentimport und Feldextraktion

- **Lieferziel:** lokale PDF-/XLSX-Dateien importieren, Dokumenttyp
  zuordnen, zentrale Felder extrahieren.
  - PDF-Reader-Adapter (z. B. `lopdf` oder `pdf-extract`) und
    XLSX-Reader-Adapter (z. B. `calamine`).
  - Dokumentklassifikation textbasiert (`GG-FA-DOC-001`).
  - Extraktion von Antragsteller, Anlagenbetreiber, Anlagenstandort,
    installierte Leistung, Anlagenart, Messkonzept
    (`GG-MVP-006`).
  - Herkunft/Konfidenz/Status je extrahiertem Wert
    (`GG-DATA-002`).
- **Lastenheft-IDs:** `GG-MVP-005`, `GG-MVP-006`, `GG-FA-DOC-001`,
  `GG-DATA-002`.
- **ADR-Pointer:** Folge-ADR fuer PDF-/XLSX-Library-Wahl
  (Trade-off Genauigkeit vs. Bundle-Groesse) erwartet — Trigger bei
  M5-Start.
- **DoD-Checkliste:**
  - [ ] Demo-PDF und Demo-XLSX werden importiert und einem Typ aus
        `Dokumenttyp` zugeordnet.
  - [ ] Mindestens sechs Felder werden im Demo-Fall extrahiert; jeder
        Wert traegt `extraction_method`, `source_document`,
        `source_location` und `status`.
  - [ ] Felder ohne erfolgreiche Extraktion werden im UI als
        "manuell zu pruefen" markiert (UI-Verifikation in M6).
- **Status:** `Pending`.

### M6 — UI- und Tauri-Integration

- **Lieferziel:** vollstaendige UI-Schicht ueber den fachlichen Kern;
  alle MVP-Hauptansichten per Tastatur bedienbar.
  - Tauri-Commands als duenne driving Adapter (`GG-ARCH-004`,
    `GG-CC-002`).
  - SvelteKit-Routen pro Use-Case (Projektuebersicht,
    Profilauswahl, Review, Korrektur, Export-Vorschau).
  - Zentrale Textressource fuer deutsche UI (`GG-NFA-I18N-001`).
  - Tastaturbedienbarkeit aller MVP-Hauptansichten
    (`GG-NFA-A11Y-001` MVP-Minimum) inkl. Testprotokoll.
- **Lastenheft-IDs:** `GG-MVP-001` (volle Akzeptanz: UI zeigt
  Projektuebersicht, Profilauswahl und Import-/Export-Workflow;
  Skelett-Teil bereits in M1 geliefert), `GG-MOD-008`,
  `GG-ARCH-004`, `GG-NFA-I18N-001`, `GG-NFA-A11Y-001`.
- **ADR-Pointer:** Folge-ADR fuer State-Management im Frontend
  (Stores pro Bounded Context) empfehlenswert.
- **DoD-Checkliste:**
  - [ ] Demo-Projekt kann End-to-End durch die UI bearbeitet werden.
  - [ ] Alle MVP-Hauptansichten per Tastatur bedienbar; Testprotokoll
        im Repository.
  - [ ] Keine hartkodierten UI-Texte ausserhalb der zentralen
        Textressource (Lint oder Test).
- **Status:** `Pending`.

### M7 — Export und Prompt-Erzeugung

- **Lieferziel:** Exportpaket erzeugen, Prompt erzeugen und Antwort
  zurueckspielen.
  - ZIP-/Ordner-Export mit Checkliste, Projektstammdaten,
    Warnungen, Profilversion, referenzierten Dokumenten und Links
    auf Originalquellen (`GG-FA-EXPORT-001`).
  - Override-Manifest bei `fehler`-Warnungen (`GG-NFA-USE-001`).
  - Strukturierter KI-Prompt mit definierten Schluesseln und
    Antwortschema gemaess `GG-AI-002`.
  - Antwort-Rueckuebernahme als `extraction_method =
    prompt_response`, `status = suggested`.
- **Lastenheft-IDs:** `GG-MVP-007`, `GG-MVP-008`, `GG-MVP-009`,
  `GG-FA-EXPORT-001`, `GG-AI-001`, `GG-AI-002`.
- **ADR-Pointer:** ADR 0001 §2 verlangt JSON-Schema-Artefakt fuer
  `GG-AI-002`; in M7 zu liefern.
- **DoD-Checkliste:**
  - [ ] Demo-Exportpaket enthaelt alle Pflichtbestandteile aus
        `GG-FA-EXPORT-001`.
  - [ ] Exportpaket ohne Originalformulare ohne offene Lizenz
        (`GG-FA-CAT-007`, `GG-NONGOAL-004`).
  - [ ] Prompt-Erzeugung kopiert in die Zwischenablage und zeigt
        zuvor sichtbar, welche Inhalte enthalten sind.
  - [ ] Antwort-Rueckuebernahme uebernimmt strukturierte Werte als
        Vorschlaege; unstrukturierte Antworten werden angezeigt, aber
        nicht uebernommen.
- **Status:** `Pending`.

### M8 — MVP-Abnahme

- **Lieferziel:** Demo-Artefakte, Requirements-Matrix,
  Performance-Benchmark, MVP-Abschluss-Review.
  - Demo-Projekt fuer Westnetz + `PV_NS_OhneSpeicher`
    (`GG-ACCEPT-001`).
  - Beispiel-Exportpaket oder reproduzierbarer Export-Test
    (`GG-ACCEPT-002`).
  - Requirements-Matrix mit Status und Nachweis je
    MVP-Anforderung (`GG-ACCEPT-003`).
  - Beispiel-Prompt und Beispiel-Antwort (`GG-ACCEPT-004`).
  - Performance-Benchmark gegen `GG-NFA-PERF-001`-Zielwerte.
  - Closure-Review aller MVP-Anforderungen inkl. Open-Trigger.
- **Lastenheft-IDs:** `GG-NFA-PERF-001`, `GG-NFA-PERF-002`,
  `GG-ACCEPT-001..004`.
- **ADR-Pointer:** keine neuen Entscheidungen erwartet; offene
  Provisional-ADRs (sofern noch vorhanden) werden geschlossen.
- **DoD-Checkliste:**
  - [ ] Alle MVP-Anforderungen in der Requirements-Matrix tragen
        `abgenommen`.
  - [ ] Performance-Benchmark erfuellt alle Zielwerte aus
        `GG-NFA-PERF-001`; Messprotokoll im Repository.
  - [ ] Closure-Notiz fuer M8 in `done/` mit Liste der offenen
        V1-Themen.
- **Status:** `Pending`.

---

## 4. V1-Ausblick (nicht Teil des MVP-Pfades)

Themen, die nach M8 in eigenen Meilensteinen entstehen koennen:

- **OCR fuer eingescannte Dokumente** (`GG-AI-005`).
- **Direkte LLM-Anbindung** (`GG-AI-004`).
- **Formularvorbefuellung** (`GG-FA-FILL-001`, `GG-MOD-005`) plus
  **vorbefuellter PDF-/XLSX-Export** (`GG-MOD-006`-V1-Erweiterung).
- **Weitere Betreiberprofile** (`GG-FA-CAT-002`, `GG-FA-CAT-004`,
  `GG-FA-CAT-005`).
- **SQLite-Persistenz** statt Dateisystem (`GG-ARCH-008`).
- **Signierte Distribution + Updater** (`GG-NFA-INSTALL-002`,
  `GG-NFA-INSTALL-003`).
- **Volle WCAG 2.1 AA** (`GG-NFA-A11Y-001` V1).
- **Branch-Coverage 70 %** (`GG-NFA-COV-003`).
- **Release-Workflow mit signierten Bundles**
  (`GG-NFA-CICD-003`).
- **Quellenmonitoring mit Linkpruefung** (`GG-FA-SRC-001`,
  `GG-MOD-007`).
- **macOS und Windows als Erstklass-Plattformen** (heute
  Best-Effort gemaess `GG-NFA-CICD-002`).
- **SBOM-Erzeugung** (Software Bill of Materials) — heute keine
  Lastenheft-Anforderung; vor V1-Release fuer Lieferketten-
  Transparenz erwaegen.
- **Telemetrie- und Status-Badges in der README** — operative
  Komfortfunktion, kein ADR-Material; zusammen mit
  V1-Release-Workflow.

---

## 5. Vorbedingungen

Geschlossen:

- **ADR 0001** (`Accepted`) — Dokumentationsstruktur und
  ADR-Lifecycle.
- **ADR 0002** (`Accepted`) — Frontend-Stack SvelteKit 2.x.
- **ADR 0003** (`Accepted`) — Desktop-Runtime Tauri 2.x.
- **ADR 0004** (`Accepted` seit M1-W7) — Quality-Gates- und
  Coverage-Tooling. Spike-Vertrag §4 erfuellt: `make
  container-gates`-Run gruen, Rust-Coverage ~94 % Lines, Frontend-
  Coverage ~94,73 % Lines.
- **ADR 0005** (`Accepted` seit M1-W7) — CI/Release mit GitHub
  Actions + `tauri-action`. Spike-Vertrag §4 in MVP-Accept (§4.1)
  + V1-Validierung (§4.2) gegliedert; MVP-Anteil erfuellt
  (Linux-Pflichtjob gruen, macOS gruen, Windows Best-Effort).
  V1-Validierungs-Items unter
  [Trigger 015](../open/015-release-workflow-validierung.md).
- **Trigger 001** (`Done` seit M1-W7) —
  [`spec/architecture.md`-Skelett](../../../../spec/architecture.md)
  vorhanden; Trigger in
  [`done/`](../done/001-architecture-md-skeleton.md).
- **Lastenheft v0.4.0** — Anforderungsstand fuer M1..M8.

Im Laufe von M1 neu eroeffnet (Review- und Build-Findings):

- **Trigger 002-005** (`open`) — Folge-ADRs fuer M3-M6
  (Datei-Schema, Regel-Repraesentation, PDF-/XLSX-Library,
  Frontend-State-Management).
- **Trigger 006-007** (`open`) — Dependabot/Renovate-Konfig,
  E2E-Test-Stack.
- **Trigger 008-009** (`open`) — Tauri-CSP-Policy,
  Tauri-Capability-Permissions.
- **Trigger 010-011** (`open`) — apt-Snapshot-Pinning,
  Bundle-Reproduzierbarkeit (beide aus M1-W5-Review).
