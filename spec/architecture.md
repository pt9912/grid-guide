# Architektur: grid-guide

**Projektname:** grid-guide
**Dokumenttyp:** Architekturbeschreibung
**Format:** Markdown
**Version:** 0.1.0
**Status:** Skelett (M1-W7)
**Bezug:** [`lastenheft.md`](lastenheft.md);
[ADR 0001](../docs/plan/adr/0001-documentation-and-planning-structure.md)
§2.1;
[ADR 0003](../docs/plan/adr/0003-desktop-runtime-tauri.md);
[ADR 0004](../docs/plan/adr/0004-quality-gates-and-coverage-tooling.md)
§2.3 (arch-check-Vertrag).

---

## 1. Zweck

Dieses Dokument ergaenzt das Lastenheft. Es uebersetzt die
`GG-ARCH-*`-Anforderungen in benannte Komponenten, Ports und
maschinenpruefbare Tabus. Architekturkomponenten tragen
`GG-AR-*`-Kennungen, damit Code, Tests und Folge-ADRs sie zitieren
koennen.

Das Skelett entsteht in M1-Welle 7 und ist absichtlich knapp: das
Lastenheft und die ADRs bleiben die maßgeblichen Quellen; dieses
Dokument konsolidiert nur die strukturelle Sicht. Inhalte werden
fortgeschrieben, sobald Bounded Contexts in M2..M7 tatsaechlich
Code bekommen.

Nicht Gegenstand:

- Konkrete Modul-Versionen oder API-Pfade (liegen im Code und in
  ADR 0003/0004).
- Roadmap-Meilensteine — siehe
  [`docs/plan/planning/in-progress/roadmap.md`](../docs/plan/planning/in-progress/roadmap.md).
- Datenformat-Entscheidungen (offene Trigger
  [002](../docs/plan/planning/open/002-datei-schema-adr.md) und
  [003](../docs/plan/planning/open/003-regel-repraesentation-adr.md)).

---

## 2. Architekturprinzipien

| Kennung     | Prinzip                                                                                       | Bezug                                          |
| ----------- | --------------------------------------------------------------------------------------------- | ---------------------------------------------- |
| GG-AR-P-001 | Tauri-Desktop-App mit Rust-Kern und SvelteKit-Frontend                                        | GG-ARCH-001, GG-ARCH-008                       |
| GG-AR-P-002 | Hexagonale Architektur fuer den Domain-Kern (Ports & Adapters)                                | GG-ARCH-002                                    |
| GG-AR-P-003 | Core-Isolation: Kern kennt weder Adapter noch Frameworks; Imports zeigen nach innen           | GG-ARCH-003, GG-CC-003                         |
| GG-AR-P-004 | Driving-Adapter rufen Use-Cases auf; Tauri-Commands sind Driving-Adapter                      | GG-ARCH-004                                    |
| GG-AR-P-005 | Driven-Adapter implementieren Domain-Ports (z. B. PDF/XLSX-Reader, Dateisystem, HTTP)         | GG-ARCH-006                                    |
| GG-AR-P-006 | Bounded Contexts werden organisch nach Domaene aufgeteilt, nicht nach technischer Schicht     | GG-ARCH-007                                    |
| GG-AR-P-007 | Architektur-Tabus werden per Build-Test erzwungen (`tools/arch-check.sh`)                     | GG-NFA-QG-003, ADR 0004 §2.3                   |
| GG-AR-P-008 | Lokale Persistenz im MVP als Dateien im Nutzerprofil; SQLite ist V1                           | GG-ARCH-008, GG-DATA-001                       |

---

## 3. Komponenten (`GG-AR-COMP-*`)

Die Komponenten leiten sich aus `GG-ARCH-007` (Bounded Contexts) ab.
Sie sind in M1 noch Stubs (Modulgeruest in `src-tauri/src/hexagon/`),
bekommen ihre Use-Cases und Domain-Modelle in M2..M7.

| Kennung        | Komponente          | Status M1 | Bezug                                 |
| -------------- | ------------------- | --------- | ------------------------------------- |
| GG-AR-COMP-001 | `Catalog`           | Stub      | GG-ARCH-007; M2 (Domain-Kern + Seed)  |
| GG-AR-COMP-002 | `Project`           | Stub      | GG-ARCH-007; M3 (Projekt-Lifecycle)   |
| GG-AR-COMP-003 | `Validation`        | Stub      | GG-ARCH-007; M4 (Regel-Engine)        |
| GG-AR-COMP-004 | `Submission`        | Stub      | GG-ARCH-007; M5 (Antrags-Erzeugung)   |
| GG-AR-COMP-005 | `OcrExtraction`     | Spaeter   | Optional (Trigger spaeter)            |
| GG-AR-COMP-006 | `Mastr`             | Spaeter   | Optional (Trigger spaeter)            |
| GG-AR-COMP-007 | `Redispatch`        | Spaeter   | Optional (Trigger spaeter)            |
| GG-AR-COMP-008 | `PortalAutomation`  | Post-MVP  | GG-MVP-008                            |

---

## 4. Ports

Ports liegen unter `src-tauri/src/hexagon/ports/`. Driving-Ports werden
von Adaptern aufgerufen; Driven-Ports werden von Adaptern erfuellt.

### 4.1 Driving (`GG-AR-PORT-DRV-*`)

| Kennung           | Port-Stub             | Status M1 | Bezug                                 |
| ----------------- | --------------------- | --------- | ------------------------------------- |
| GG-AR-PORT-DRV-001 | `TauriCommandPort`   | Stub      | GG-ARCH-004; Tauri 2.x #[command]     |
| GG-AR-PORT-DRV-002 | `CliPort`            | Stub      | GG-ARCH-004; CLI-Adapter (V1)         |

### 4.2 Driven (`GG-AR-PORT-DRN-*`)

| Kennung            | Port-Stub             | Status M1 | Bezug                                 |
| ------------------ | --------------------- | --------- | ------------------------------------- |
| GG-AR-PORT-DRN-001 | `ProjectStoragePort` | Stub      | GG-FA-PROJ-002, Trigger 002           |
| GG-AR-PORT-DRN-002 | `PdfReaderPort`      | Stub      | GG-FA-IMPORT-*, Trigger 004           |
| GG-AR-PORT-DRN-003 | `XlsxReaderPort`     | Stub      | GG-FA-IMPORT-*, Trigger 004           |
| GG-AR-PORT-DRN-004 | `HttpPort`           | Stub      | GG-FA-SUBMIT-* (V1)                   |
| GG-AR-PORT-DRN-005 | `SecretStorePort`    | Stub      | GG-NFA-SEC-* (OS-Secret-Store)        |
| GG-AR-PORT-DRN-006 | `LlmAdapterPort`     | Optional  | KANN-Anforderung                      |

---

## 5. Tabus (`GG-AR-TABU-*`)

Die folgenden Regeln werden maschinell durch `tools/arch-check.sh`
erzwungen (Aufruf via `make arch-check` bzw. `make gates`). Bei
Verstoss bricht `make gates` ab.

| Kennung         | Regel                                                                                       | Bezug                                          |
| --------------- | ------------------------------------------------------------------------------------------- | ---------------------------------------------- |
| GG-AR-TABU-001  | `hexagon/core/**` importiert keine Adapter-/Tauri-/PDF-/XLSX-/HTTP-/OCR-/LLM-Crates         | GG-ARCH-003, GG-CC-003; arch-check Rule A      |
| GG-AR-TABU-002  | `hexagon/ports/**` enthaelt **keine** `impl`-Bloecke (auch nicht `impl Default`)            | GG-CC-002, GG-CC-003; arch-check Rule B        |
| GG-AR-TABU-003  | `hexagon/ports/**` importiert weder aus `hexagon/adapters` noch aus `hexagon/core`          | GG-CC-004 (keine Modulzyklen); arch-check Rule C |

Modulzyklen-Erkennung jenseits dieser Tabus (Rule D) ist V1 und wird
ueber `cargo modules` realisiert (siehe ADR 0004 §2.3).

---

## 6. Acceptance Contracts (`AC-*`)

Maschinenpruefbare Vertraege, die `make gates` durchsetzt. Sie
spiegeln die Tabus aus §5 plus die Quality-Gates aus ADR 0004.

| Kennung   | Vertrag                                                                                   | Bezug                                       |
| --------- | ----------------------------------------------------------------------------------------- | ------------------------------------------- |
| AC-001    | `tools/arch-check.sh` exit=0 ueber alle Files in `src-tauri/src/hexagon/`                 | GG-AR-TABU-001..003; ADR 0004 §2.3          |
| AC-002    | `cargo llvm-cov --fail-under-lines 80` exit=0 (Rust-Coverage)                             | GG-NFA-COV-001, GG-NFA-QG-001               |
| AC-003    | `vitest run --coverage` exit=0 mit `lines/functions/statements >= 80`                     | GG-NFA-COV-001, GG-NFA-QG-001               |
| AC-004    | `cargo clippy --all-targets --locked -- -D warnings` exit=0                               | GG-NFA-QG-004                               |
| AC-005    | `cargo audit --deny unmaintained --deny unsound --deny yanked` exit=0 mit Allowlist       | GG-NFA-QG-005; Open-Item 012                |
| AC-006    | `cargo fmt --all -- --check` + `pnpm run format:check` exit=0                             | GG-NFA-QG-004                               |

---

## 7. Offene Architektur-Punkte (`GG-AR-OPEN-*`)

| Kennung         | Offener Punkt                                                                | Trigger                                      |
| --------------- | ---------------------------------------------------------------------------- | -------------------------------------------- |
| GG-AR-OPEN-001  | Projekt-Datei-Schema (JSON/TOML/SQLite)                                      | [Trigger 002](../docs/plan/planning/open/002-datei-schema-adr.md) |
| GG-AR-OPEN-002  | Regel-Repraesentation (DSL vs. Code vs. JSON-Schema)                         | [Trigger 003](../docs/plan/planning/open/003-regel-repraesentation-adr.md) |
| GG-AR-OPEN-003  | PDF/XLSX-Bibliothekswahl                                                     | [Trigger 004](../docs/plan/planning/open/004-pdf-xlsx-library-adr.md) |
| GG-AR-OPEN-004  | Frontend-State-Management (Stores vs. Runes vs. Library)                     | [Trigger 005](../docs/plan/planning/open/005-frontend-state-management-adr.md) |
| GG-AR-OPEN-005  | Dependency-Update-Automation                                                 | [Trigger 006](../docs/plan/planning/open/006-dependency-update-automation-adr.md) |
| GG-AR-OPEN-006  | E2E-Test-Stack                                                               | [Trigger 007](../docs/plan/planning/open/007-e2e-test-stack-adr.md) |
| GG-AR-OPEN-007  | Tauri-CSP-Policy                                                             | [Trigger 008](../docs/plan/planning/open/008-tauri-csp-policy-adr.md) |
| GG-AR-OPEN-008  | Tauri-Capability-Permissions                                                 | [Trigger 009](../docs/plan/planning/open/009-tauri-capability-permissions-adr.md) |
| GG-AR-OPEN-009  | Modulzyklen-Erkennung Rule D (cargo modules)                                 | ADR 0004 §2.3 (V1)                           |
| GG-AR-OPEN-010  | Branch-Coverage-Gate auf 70 % heben                                          | GG-NFA-COV-003 (V1)                          |

Jeder geschlossene Punkt wird per ADR aufgeloest und im Lastenheft
sowie hier als `umgesetzt` markiert; der zugehoerige Trigger
wandert nach `docs/plan/planning/done/`.
