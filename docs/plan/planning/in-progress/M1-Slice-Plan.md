# M1-Slice-Plan — Foundation, Build-Tooling und CI

**Status:** In Progress (aktiviert 2026-05-22; Welle 0 laeuft).
**Eroeffnet:** 2026-05-22
**Aktiviert:** 2026-05-22
**Bezug:** [Roadmap M1](roadmap.md#m1--foundation-build-tooling-und-ci);
[ADR 0001](../../adr/0001-documentation-and-planning-structure.md);
[ADR 0002](../../adr/0002-frontend-stack-sveltekit.md);
[ADR 0003](../../adr/0003-desktop-runtime-tauri.md);
[ADR 0004](../../adr/0004-quality-gates-and-coverage-tooling.md) §4
(Spike-Vertrag);
[ADR 0005](../../adr/0005-ci-release-tauri-action.md) §4
(Spike-Vertrag);
[Trigger 001 — architecture.md-Skelett](../open/001-architecture-md-skeleton.md);
[Lastenheft](../../../../spec/lastenheft.md) v0.4.0.

---

## 1. Ziel

Ein Repo-Skelett, mit dem `make gates` lokal und in CI gruen laeuft,
das den hexagonalen Layout-Vertrag aus `GG-ARCH-002` strukturell
nachweist, und das die Provisional-ADRs 0004 (Quality-Gates-Tooling)
und 0005 (CI/Release) ueber ihre Spike-Vertraege auf `Accepted`
hebt.

Der Slice liefert noch **keinen fachlichen Code** — Domain, Profile,
Falltyp, UI-Inhalt folgen in M2..M7. Das M1-Ergebnis ist eine
„Hello GridGuide"-Tauri-App plus vollstaendige Build- und
CI-Klammer.

---

## 2. Vorbedingungen

Aus [Roadmap §5](../in-progress/roadmap.md#5-vorbedingungen) bereits
geschlossen:

- ADR 0001 (`Accepted`) — Dokumentations- und Planungsstruktur.
- ADR 0002 (`Accepted`) — Frontend-Stack SvelteKit 2.x.
- ADR 0003 (`Accepted`) — Desktop-Runtime Tauri 2.x.
- Lastenheft v0.4.0.

Offen, **werden mit M1 geschlossen**:

- ADR 0004 (`Provisional`) — Spike-Vertrag in §4.
- ADR 0005 (`Provisional`) — Spike-Vertrag in §4.
- Trigger 001 (`open`) — `spec/architecture.md`-Skelett.

---

## 3. Wellen

M1 wird in acht Wellen aufgeteilt. Jede Welle endet mit einem
gruenen Teilcheck; das Slice gilt als komplett, wenn alle Wellen
gruen sind und die Roadmap-M1-DoD-Checkliste vollstaendig
abgehakt ist.

### Welle 0 — Repo-Hygiene

- **Lieferziel:** Repo enthaelt die ueblichen Hygiene-Dateien.
- **Schritte:**
  - `.editorconfig` (Tabs/Spaces, Encoding, EOL).
  - `.gitignore` fuer Rust + Node + Tauri (`target/`, `node_modules/`,
    `dist/`, `.svelte-kit/`, `src-tauri/target/`, IDE-Ordner).
  - `README.md` mit Kurzbeschreibung, Quick-Start (`make gates`),
    Hinweis auf Lastenheft + ADR-Index.
  - `AGENTS.md` mit ASCII-Konvention (`GG-LESE-007`), ADR-Lifecycle
    (ADR 0001 §2.2-2.4), Trigger-Workflow (ADR 0001 §2.1).
- **Verifikation:** `git status` clean; `cat README.md` zeigt
  Quick-Start.

### Welle 1 — Rust-Workspace und hexagonales Layout

- **Lieferziel:** `src-tauri/` mit cargo-Workspace und
  Hexagon-Layout-Stubs.
- **Schritte:**
  - `src-tauri/Cargo.toml` als Workspace-Root.
  - `src-tauri/src/main.rs` mit minimaler Tauri-App (1 Befehl
    `greet(name) -> String`).
  - Verzeichnisstruktur gemaess `GG-ARCH-002`:
    - `src-tauri/src/hexagon/core/` (leer, `mod.rs`).
    - `src-tauri/src/hexagon/ports/driving/` (leer, `mod.rs`).
    - `src-tauri/src/hexagon/ports/driven/` (leer, `mod.rs`).
    - `src-tauri/src/adapters/driving/` (leer, `mod.rs`).
    - `src-tauri/src/adapters/driven/` (leer, `mod.rs`).
  - `Cargo.lock` eingecheckt.
- **Verifikation:** `cargo build --locked` gruen; `cargo test`
  gruen (auch ohne Tests).

### Welle 2 — SvelteKit-Frontend und Tauri-Integration

- **Lieferziel:** `frontend/` mit SvelteKit-Skelett, das in Tauri
  gerendert wird.
- **Schritte:**
  - `frontend/package.json` mit SvelteKit 2.x + Svelte 5.x
    (Mindestversionen aus ADR 0002).
  - `frontend/svelte.config.js` mit `@sveltejs/adapter-static`
    (SPA-Modus).
  - `frontend/vite.config.ts` mit Tauri-kompatiblen Build-Settings.
  - `frontend/src/routes/+page.svelte`: Hello-Seite mit
    Tastaturfokus-Demo (ein Button, ein Eingabefeld, sichtbarer
    Fokusring fuer `GG-NFA-A11Y-001`-MVP-Vorbereitung).
  - `frontend/src/app.html` mit `lang="de"` (`GG-NFA-I18N-001`).
  - `src-tauri/tauri.conf.json`: Frontend-Build aus `frontend/build`,
    AppName `GridGuide`, Window-Titel deutsch.
  - `pnpm-lock.yaml` (oder `package-lock.json`) eingecheckt.
- **Verifikation:**
  - Primaer (headless-faehig, CI-tauglich): `pnpm install` (oder
    `npm ci`); `pnpm tauri build` erzeugt ein Bundle ohne Fehler;
    der erzeugte AppImage/`.deb` startet wenigstens als
    Smoke-Test (Prozess startet, Fenster oeffnet sich, Prozess
    beendet sich sauber).
  - Optional (manuell, lokal mit Display-Server): `pnpm tauri dev`
    zeigt das Fenster mit Hello-Seite und sichtbarem Tastaturfokus.
    Dieser Schritt ist kein Pflicht-Verifikationsbaustein, weil er
    in headless Umgebungen (CI, Container) nicht reproduzierbar
    ist.

### Welle 3 — Makefile mit allen Pflichttargets

- **Lieferziel:** `Makefile` als zentraler Build-Einstiegspunkt
  gemaess `GG-NFA-INSTALL-005`.
- **Schritte:**
  - `Makefile` mit Targets `gates`, `ci`, `fullbuild`, `bundle`,
    `lint`, `typecheck`, `test`, `dep-audit` und den Per-Stack-Sub-
    Targets aus ADR 0004 §2.1/§2.2 (`-rust` / `-frontend`).
  - `make help` zeigt eine Liste aller Targets mit
    Einzeilen-Beschreibung.
  - Erstes `make gates` ruft die Sub-Targets in dieser Reihenfolge
    auf: `format-check-* → lint-* → typecheck-* → test-* →
    coverage-* → arch-check → dep-audit-*`.
- **Verifikation:** `make help` zeigt mindestens die acht
  Pflichttargets; `make test-rust` und `make test-frontend` laufen
  jeweils gruen (auch ohne fachliche Tests).

### Welle 4 — Architektur-Check und Coverage-Tooling

- **Lieferziel:** `tools/arch-check.sh` aktiv; Coverage-Setup
  fuer Rust + Frontend funktioniert.
- **Schritte:**
  - `tools/arch-check.sh`:
    - Regel A: `hexagon/core` darf keine Adapter-Crates importieren.
    - Regel B: `hexagon/ports/*` enthalten nur Trait-/Typdefinitionen.
    - Regel C: keine zyklischen Modulabhaengigkeiten in `hexagon/`.
    - Nicht-Null-Exitcode bei Verstoss.
  - Zwei kuenstliche Verstoesse als Test-Fixtures
    (`tests/arch-fixtures/`) — sollen vom Script rot gemeldet werden;
    Default-Lauf laeuft ohne sie.
  - `cargo llvm-cov` als Dev-Dependency; `make coverage-rust` mit
    `--fail-under-lines 80` gemaess Lastenheft `GG-NFA-COV-001`.
  - `vitest run --coverage` mit `coverage.thresholds.lines = 80`
    in `vitest.config.ts`.
  - `make coverage-critical` als Stub (zeigt im Skelett, dass das
    Target existiert, ohne kritische Module zu pruefen — diese
    kommen in M2).
  - **Skelett-Coverage-Strategie** (siehe ADR 0004 §4-Punkt 2):
    Die 80-%-Schwelle wird nicht abgesenkt. Stattdessen wird das
    Skelett so geformt, dass es sie erreicht — primaer ueber Tests,
    nicht ueber Excludes.
  - **Excludes-Politik** (eng gefasst):
    - Erlaubt sind Excludes ausschliesslich fuer reine Daten- oder
      Domain-Strukturen ohne Behavior — Rust-`struct`/`enum`-
      Definitionen in `hexagon/core/domain`, deren Logik
      vollstaendig aus `derive`-Makros besteht (z. B.
      `#[derive(Debug, Clone, PartialEq)]`) und die keine eigenen
      `impl`-Methoden tragen.
    - **Nicht erlaubt** sind Excludes fuer Re-Export-`mod.rs`,
      Layout-Komponenten, Boilerplate, Adapter, Use-Cases oder
      sonstigen Behavior-tragenden Code. Diese sind testbar und
      muessen getestet werden.
    - Begruendung: Lastenheft `GG-NFA-COV-004` verbietet kuenstliche
      Coverage. Datenklassen ohne Behavior haben keine pruefbare
      Logik (Tests waeren Trivialitaeten); Re-Exporte und Layouts
      koennen sehr wohl getestet werden (Render-Smoke,
      Build-Compilation) und sind damit Pflicht-Coverage-Basis.
  - **Konkreter Plan fuer M1-Skelett:**
    - Rust: `greet`-Command aus Welle 1 erhaelt einen Unit-Test, der
      die Funktion vollstaendig ausuebt. Leere `mod.rs` mit
      ausschliesslich `pub mod x;`-Zeilen tragen 0 executable lines
      und beeinflussen die Coverage-Basis nicht (kein Exclude
      notwendig).
    - Frontend: `+page.svelte` aus Welle 2 erhaelt einen
      Komponententest via `@testing-library/svelte` (Render-Smoke
      plus Button-Click-Pfad).
    - Falls die 80-%-Schwelle mit diesem Mindestumfang nicht
      erreichbar ist, wird der Skelett-Code mit weiteren einfachen,
      fachlich begruendeten Tests erweitert — gemaess ADR 0004
      §4-Punkt 2.
- **Verifikation:** `make arch-check` gruen im Default; mit
  `ARCH_CHECK_FIXTURES=on make arch-check` rot. `make coverage-rust`
  und `make coverage-frontend` gruen mit `--fail-under-lines 80` bzw.
  `coverage.thresholds.lines = 80`. Coverage-Excludes sind im jeweils
  zugehoerigen Konfig-File dokumentiert und im Coverage-Report als
  „excluded files"-Sektion sichtbar.

### Welle 5 — Build-Container

- **Lieferziel:** `Dockerfile` baut den vollstaendigen Build-
  Container; `make container-gates` laeuft darin `make gates`.
- **Schritte:**
  - `Dockerfile` Multi-Stage mit durchgehend gepinnten Versionen
    (ohne `latest`-Tags, ohne unversionierte `cargo install`-Aufrufe):
    - Base auf konkreter Rust-Toolchain-Version
      (z. B. `rust:1.84-bookworm`); Node-Version per
      `actions/setup-node`-Aequivalent in der Frontend-Stage
      (z. B. `node:22.13-bookworm-slim`); pnpm via `corepack
      enable pnpm@<version>` pinned.
    - Stage `build-deps`: `apt-get install` mit
      `--no-install-recommends` und expliziten Versionen
      (`webkit2gtk-4.1=<version>`, `libsoup-3.0=<version>`,
      `libappindicator3-1=<version>`, `libssl-dev=<version>`).
      Versionen entstammen dem Debian-Bookworm-Snapshot, der ueber
      `snapshot.debian.org` oder eine eingefrorene Mirror-URL
      angesprochen wird.
    - Stage `tools`: `cargo install --locked --version <X.Y.Z>
      cargo-llvm-cov`, gleiches Muster fuer `cargo-audit` und
      `cargo-modules`. Konkrete Versionen stehen in einer
      `Dockerfile`-internen Variable oder in einer
      `tools.versions`-Datei im Repo, damit Updates ueber eine Stelle
      laufen.
    - Stage `gates`: Source kopieren, `make gates` ausfuehren.
  - `make container-gates`: `docker build --pull -t gridguide-gates
    --build-arg ...` plus Lauf mit `-v
    "$PWD/.coverage:/work/.coverage"` zum Extrahieren der Reports.
    `--pull` stellt sicher, dass die Base-Image-SHA mit dem Tag
    uebereinstimmt.
  - Reproduzierbarkeitsnachweis: ein dokumentierter Befehl
    (`scripts/repro-check.sh` oder analog) baut den Container zweimal
    nacheinander und diff't die resultierenden Image-Hashes minus
    der bekannten nicht-deterministischen Anteile gemaess
    `GG-NFA-INSTALL-001`.
- **Verifikation:** `make container-gates` gruen; Coverage-Reports
  liegen nach dem Lauf in `.coverage/`. Reproduzierbarkeitstest:
  zwei aufeinanderfolgende Laeufe unterscheiden sich nur in
  Zeitstempeln.

### Welle 6 — GitHub-Actions-CI-Matrix

- **Lieferziel:** `.github/workflows/gates.yml` mit Linux+macOS+
  Windows-Matrix; `release.yml` als Stub.
- **Schritte:**
  - `gates.yml`:
    - Trigger `push` und `pull_request`.
    - Matrix `linux/macos/windows` gemaess ADR 0005 §2.3.
    - Plattformspezifische Vorinstallation (Linux: System-Pakete;
      macOS: Xcode-CLT; Windows: Visual-C++-Build-Tools).
    - `Swatinem/rust-cache@v2` plus `actions/setup-node@v4` Cache.
    - `make gates` als Hauptschritt.
    - Coverage-Upload als Workflow-Artefakt.
    - Linux-Job ist `required` in der Branch-Protection.
  - `release.yml` als Stub (`workflow_dispatch`-Only im MVP):
    - Plattform-Matrix wie `gates.yml`.
    - `tauri-action@<sha>` (siehe ADR 0005 §2.4); Release-Entwurf
      mit drei Bundles. Im MVP-Stub: unsigniert.
  - Branch-Protection-Hinweis in `AGENTS.md` ergaenzen.
- **Verifikation:** `gates.yml` durchlaeuft alle drei Plattformen;
  Linux gruen (Pflichtcheck), macOS/Windows gruen oder
  best-effort-rot. `release.yml` per `workflow_dispatch` erzeugt
  einen Release-Entwurf mit drei Bundles.

### Welle 7 — Architecture.md-Skelett und ADR-Closure

- **Lieferziel:** `spec/architecture.md` als initiales Skelett;
  ADR 0004 und ADR 0005 auf `Accepted` gehoben; M1-Closure-Notiz
  vorbereitet.
- **Schritte:**
  - `spec/architecture.md` Skelett gemaess
    [Trigger 001](../open/001-architecture-md-skeleton.md):
    - §1 `GG-AR-COMP-*` Komponenten-Liste (Catalog, Project,
      Validation, Submission als Stubs).
    - §2 `GG-AR-PORT-DRV-*` und `GG-AR-PORT-DRN-*` als Stubs
      (Namen, kein Vertrag).
    - §3 `GG-AR-TABU-001..003` mit den drei Regeln aus
      `tools/arch-check.sh`.
    - §4 `GG-AR-OPEN-*` Slots (offen).
  - Trigger 001 wandert nach `done/` mit Closure-Notiz.
  - ADR 0004 Status `Provisional → Accepted`; Header-Pflichtfelder
    (`Status geaendert am`) gesetzt. Schaerfungs-Spalte in
    `docs/plan/adr/README.md` bleibt leer.
  - ADR 0005 Status `Provisional → Accepted`; Header-Pflichtfelder
    gesetzt.
  - M1-Closure-Notiz unter `done/M1-Slice-Plan-results.md`
    (Welle-Tabelle mit Datum + Commit-SHA pro Welle).
  - Lastenheft Requirements-Matrix (`GG-ACCEPT-003`) aktualisieren:
    M1-Anforderungen auf `umgesetzt`.

- **Verifikation:** `spec/architecture.md` existiert und enthaelt
  die vier Sektionen; ADR-README-Index zeigt 0004 und 0005 als
  `Accepted`; Trigger 001 ist nach `done/` verschoben; M1-Plan
  selbst wandert nach `done/` (Slice abgeschlossen).

---

## 4. Akzeptanz (Slice-Ebene)

Identisch mit der M1-DoD-Checkliste aus
[Roadmap M1](../in-progress/roadmap.md#m1--foundation-build-tooling-und-ci).
Alle sieben Checkboxen muessen gruen sein, bevor der Slice nach
`done/` wandert.

Zusaetzlich (Slice-spezifisch):

- Jede Welle hat einen eigenen Commit (oder eine kleine Commit-Folge)
  mit klarem Subject-Prefix `M1-W<N>: …`.
- Die `release.yml`-Stub ist nicht `required`; sie blockiert keinen
  Merge.
- Die `AGENTS.md` ist Teil von Welle 0 und enthaelt mindestens:
  ASCII-Regel, ADR-Lifecycle-Hinweis, Trigger-Workflow-Hinweis,
  Branch-Protection-Hinweis (nach Welle 6 ergaenzt).

---

## 5. Risiken und Mitigation

- **`cargo llvm-cov` braucht LLVM-Toolchain im Container** —
  Image-Groesse waechst (siehe ADR 0004 §3 Negativ). Mitigation:
  Multi-Stage-Dockerfile, sodass `tools`-Stage nicht in `gates`-Stage
  landet.
- **macOS-Runner-Minuten in GitHub Actions sind teuer** — Mitigation:
  macOS im MVP auf `push` zu `main` und Pull-Requests beschraenken,
  nicht auf jedem Force-Push (siehe ADR 0005 §3).
- **`svelte-check --fail-on-warnings` false positives** mit Svelte-5-
  Runes-Patterns. Mitigation: betroffene Warnungen per `tsconfig`
  oder Ausnahmeliste downgraden (siehe ADR 0004 §3 Negativ).
- **WebKitGTK-Versionspruefung** unter Linux kann je Ubuntu-Version
  abweichen. Mitigation: Ubuntu-22.04 als CI-Default; lokale
  Entwickler folgen `AGENTS.md`-Hinweis.
- **ADR-0001-Immutabilitaet** (§2.3): jede Aenderung an ADR 0004/0005
  ueber `Status`/`Status geaendert am` hinaus erfordert
  Schaerfungs-ADR. Mitigation: in Welle 7 nur Metadaten setzen, keine
  inhaltlichen Korrekturen.

---

## 6. Aufwand und Reihenfolge

Grobe Schaetzung (ein Entwickler, ohne Unterbrechungen):

| Welle | Beschreibung                          | Aufwand |
| ----- | ------------------------------------- | ------- |
| 0     | Repo-Hygiene                          | 0.5 Tag |
| 1     | Rust-Workspace + Hexagon-Layout       | 1.0 Tag |
| 2     | SvelteKit + Tauri-Integration         | 1.5 Tag |
| 3     | Makefile                              | 0.5 Tag |
| 4     | Arch-Check + Coverage                 | 1.5 Tag |
| 5     | Build-Container                       | 1.0 Tag |
| 6     | GitHub-Actions-Matrix                 | 1.5 Tag |
| 7     | architecture.md + ADR-Closure         | 0.5 Tag |

Summe: ~8 Tage. Reihenfolge ist linear (jede Welle baut auf der
vorigen); Welle 4 kann optional parallel zu Welle 5 starten.

---

## 7. Aktivierungs-Checkliste (vor Wechsel nach `in-progress/`)

- [ ] Owner zugewiesen.
- [ ] Repository-Schreibrechte fuer Owner.
- [ ] GitHub-Repo existiert (`grid-guide` oder analog) mit
      Branch-Protection-Vorbereitung.
- [ ] CI-Minuten-Budget bekannt (relevant fuer Welle 6 macOS).
- [ ] Entwickler-Setup-Dokument in `docs/user/` skizziert (oder
      bewusst nach M1 verschoben).
