# ADR 0004 — Quality-Gates- und Coverage-Tooling

**Status:** Accepted
**Datum:** 2026-05-22
**Status geaendert am:** 2026-05-23 (M1-Welle 7). Spike-Vertrag
aus §4 nachgewiesen mit `make container-gates` und
`make container-ci` gegen den gepinten Build-Container: alle
Gates gruen, Rust-Coverage ~94 % Lines, Frontend-Coverage
~94,73 % Lines, deb+AppImage-Bundle erfolgreich extrahiert
(siehe Commits 9c328b1..a96c091 und M1-Closure-Notiz).
**Bezug:** [ADR 0001](0001-documentation-and-planning-structure.md),
[ADR 0002](0002-frontend-stack-sveltekit.md),
[ADR 0003](0003-desktop-runtime-tauri.md),
[Lastenheft](../../../spec/lastenheft.md) (`GG-NFA-INSTALL-001`,
`GG-NFA-INSTALL-004`, `GG-NFA-INSTALL-005`, `GG-NFA-COV-001` bis
`GG-NFA-COV-004`, `GG-NFA-QG-001` bis `GG-NFA-QG-005`, `GG-CC-004`,
`GG-PRINC-006`)
**Aenderungstyp:** Greenfield-ADR. Konkretisiert die in Lastenheft v0.4.0
neu aufgenommenen Coverage- und Quality-Gates-Anforderungen mit
konkreten Tool-Wahlen und Build-Target-Mapping. Da noch kein Code
existiert, ist die ADR `Provisional`; sie wird mit dem Spike-Vertrag
in §4 validiert und auf `Accepted` gehoben, sobald ein Skelett-Build
die festgelegten Schwellen unter dem Tooling erreicht.

---

## 1. Kontext

Lastenheft v0.4.0 fordert:

- **Coverage**: 80 % gesamt (`GG-NFA-COV-001`), 90 % auf kritischer
  Domainlogik (`GG-NFA-COV-002`), 70 % Branch in V1
  (`GG-NFA-COV-003`), keine kuenstliche Coverage (`GG-NFA-COV-004`).
- **Quality Gates**: Coverage-, Test-, Architektur-,
  Statische-Analyse- und Dependency-Security-Gates
  (`GG-NFA-QG-001..005`).
- **Build-Tooling**: `Makefile` mit Pflichttargets `gates`, `ci`,
  `fullbuild`, `bundle`, `lint`, `typecheck`, `test`, `dep-audit`
  (`GG-NFA-INSTALL-005`); containerisierter Build
  (`GG-NFA-INSTALL-004`).

Das Lastenheft sagt **was** geprueft wird; diese ADR sagt **wie** —
welches Tool je Anforderung, wie zwei Stacks (Rust + SvelteKit)
zusammengefuehrt werden, wie der Architektur-Check fuer die
hexagonale Trennung (`GG-ARCH-003`, `GG-CC-003`, `GG-CC-004`)
umgesetzt wird.

`grid-gym` hat fuer einen reinen Python-Stack ein vergleichbares
Tooling (Ruff, mypy, Pyright, pytest-cov, custom arch-check); die
Auswahl hier folgt derselben Logik fuer einen Rust-/Frontend-Stack.

---

## 2. Entscheidung

### 2.1 Rust-Backend (`src-tauri/`)

| Aspekt           | Tool                                          | Pflicht-Target           |
| ---------------- | --------------------------------------------- | ------------------------ |
| Test-Runner      | `cargo test` (optional `cargo nextest`)       | `make test-rust`         |
| Coverage         | `cargo llvm-cov` (LLVM-Source-Coverage)       | `make coverage-rust`     |
| Lint             | `cargo clippy --all-targets -- -D warnings`   | `make lint-rust`         |
| Format-Check     | `cargo fmt --check`                           | `make format-check-rust` |
| Typecheck        | implizit ueber `cargo check --locked`         | `make typecheck-rust`    |
| Dependency-Audit | `cargo audit` (RustSec-Advisory-DB)           | `make dep-audit-rust`    |

`cargo llvm-cov` wird `cargo-tarpaulin` vorgezogen, weil es
LLVM-Source-basiert misst (genauer fuer `async`-Code und Inlining)
und einen `--fail-under`-Schalter mitbringt, der direkt fuer
`GG-NFA-QG-001` taugt.

### 2.2 SvelteKit-Frontend

| Aspekt           | Tool                                                                  | Pflicht-Target               |
| ---------------- | --------------------------------------------------------------------- | ---------------------------- |
| Test-Runner      | `vitest run`                                                          | `make test-frontend`         |
| Coverage         | `vitest run --coverage` (V8-Backend)                                  | `make coverage-frontend`     |
| Komponententests | `@testing-library/svelte`                                             | innerhalb `vitest`           |
| Lint             | `eslint .` mit Svelte-Plugin                                          | `make lint-frontend`         |
| Format-Check     | `prettier --check .`                                                  | `make format-check-frontend` |
| Typecheck        | `svelte-check --tsconfig tsconfig.json --fail-on-warnings`            | `make typecheck-frontend`    |
| Dependency-Audit | `pnpm audit --prod` (oder `npm audit --omit=dev` je nach Paketmanager) | `make dep-audit-frontend`    |

E2E-Tests (Playwright o. ae.) sind nicht Gegenstand dieser ADR; sie
sind im MVP nicht zwingend (`GG-NFA-A11Y-001` deckt manuelle
Tastatur-Tests ab).

### 2.3 Architektur-Check

Die hexagonale Trennung aus `GG-ARCH-003`, `GG-CC-003` und `GG-CC-004`
wird ueber ein Skript unter `tools/arch-check.sh` validiert.
Mindestpruefungen:

- `hexagon/core` importiert keine Adapter-, Tauri-, PDF-, XLSX-,
  OCR-, HTTP- oder LLM-Crates.
- `hexagon/ports/driven` und `hexagon/ports/driving` enthalten nur
  Trait-/Typdefinitionen, keine konkreten Implementierungen.
- Keine zyklischen Modulabhaengigkeiten innerhalb `hexagon/`.

Konkretes Tool: vorzugsweise `cargo modules` (Importgraph) plus ein
kurzes Shell-/Rust-Skript, das die Regelverletzungen als nicht-Null
Exitcode meldet. Das Skript blockiert `make gates`.

Pflicht-Target: `make arch-check`.

### 2.4 Coverage-Schwellen-Mapping

| Lastenheft-Anforderung          | Schwelle | Wirkung                                                                 |
| ------------------------------- | -------- | ----------------------------------------------------------------------- |
| `GG-NFA-COV-001` (Gesamt)       | 80 %     | Rust: `cargo llvm-cov --fail-under-lines 80`. Frontend: `vitest run --coverage` mit `coverage.thresholds.lines = 80` in `vitest.config.ts` (vitest hat keinen CLI-`--fail-under`-Schalter; Schwellen sind Config-getrieben). |
| `GG-NFA-COV-002` (kritisch)     | 90 %     | Separates Target `make coverage-critical`: laeuft `cargo llvm-cov` nur auf den in `GG-NFA-COV-002` genannten Modulen mit `--fail-under-lines 90`. |
| `GG-NFA-COV-003` (Branch, V1)   | 70 %     | V1, nicht MVP-blockierend. Rust: `cargo llvm-cov --fail-under-branches 70`. Frontend: `coverage.thresholds.branches = 70` in `vitest.config.ts`. |
| `GG-NFA-COV-004` (keine kuenstliche) | —   | Wird ueber Code-Review erzwungen, nicht ueber Tooling.                  |

Die zwei Stacks werden **nicht** in einem gemeinsamen Coverage-Wert
zusammengefuehrt, weil sie unterschiedliche Runtimes messen. Jedes
Stack-Target gated unabhaengig; `make gates` schlaegt fehl, wenn
**ein** Stack die Schwelle reisst.

Excludes folgen der engen Excludes-Politik aus
`GG-NFA-COV-004`-Teil 2 (nur Daten-/Domain-Strukturen ohne eigenes
Behavior). Jeder Exclude steht im jeweiligen Konfig-File mit
einzeiliger Begruendung; Re-Export-Module, Layout-Komponenten,
Adapter und Use-Cases sind explizit **nicht** excludable.

### 2.5 Quality-Gates-Mapping

| Lastenheft-Anforderung           | Build-Schritt in `make gates`                              |
| -------------------------------- | ---------------------------------------------------------- |
| `GG-NFA-QG-001` (Coverage)       | `make coverage-rust` + `make coverage-frontend` + `make coverage-critical` |
| `GG-NFA-QG-002` (Tests)          | `make test-rust` + `make test-frontend`                    |
| `GG-NFA-QG-003` (Architektur)    | `make arch-check`                                          |
| `GG-NFA-QG-004` (statische Analyse) | `make lint-rust` + `make lint-frontend` + `make format-check-*` + `make typecheck-*` |
| `GG-NFA-QG-005` (Dependency-Security) | `make dep-audit-rust` + `make dep-audit-frontend`     |

`make gates` ist der Aggregator und entspricht dem CI-gruenen
Zustand. `make ci` fuegt `make gates` und `make bundle` zu einem
vollstaendigen CI-Lauf zusammen. `make fullbuild` baut ausschliesslich
das reproduzierbare Tauri-Bundle fuer Linux (AppImage und .deb) ohne
Gate-Lauf und ist fuer manuelle Release-Vorbereitung gedacht; alle
drei Targets sind Pflicht gemaess `GG-NFA-INSTALL-005`.

### 2.6 Container-Build

Der Build-Container aus `GG-NFA-INSTALL-004` enthaelt alle in §2.1
und §2.2 genannten Tools auf pinned Versionen. Pflicht-Target:
`make container-gates` baut den Container und fuehrt darin `make
gates` aus. Ergebnis-Artefakte (Coverage-Reports, JUnit-XML,
SBOM-Entwurf) werden ueber ein gemountetes Volume in den Host
extrahiert.

---

## 3. Konsequenzen

Positiv:

- Jede Quality-Gates-Anforderung aus dem Lastenheft hat ein
  konkretes, lokal reproduzierbares Build-Target. CI ist damit eine
  duenne Schicht ueber `make gates` (entspricht der grid-gym-Praxis).
- Coverage-Tools sind pro Stack klein und gut etabliert; keine
  Eigenentwicklung.
- Architektur-Check bleibt ein eigenes Modul, das unabhaengig von
  Coverage-Tooling erweiterbar ist (z. B. spaeter um weitere
  AC-Contracts analog grid-gym).

Negativ:

- Zwei Coverage-Toolketten (LLVM + V8) bedeuten zwei Report-Formate;
  ein Aggregat-Dashboard braucht Eigenarbeit.
- `cargo llvm-cov` benoetigt eine passende LLVM-Toolchain im
  Build-Container, was die Container-Image-Groesse erhoeht.
- `svelte-check --fail-on-warnings` neigt zu false positives bei
  Svelte-5-Runes-Patterns; ggf. einzelne Warnungen per `tsconfig`
  oder `svelte-check`-Ausnahmeliste downgraden.

Risiken:

- Wenn `cargo llvm-cov` unter Tauri 2.x WebView-Tests Probleme
  macht (Rust-/JS-Bridge-Coverage), faellt die Coverage-Messung auf
  reine Rust-Unit-Tests zurueck. Das ist akzeptabel, weil
  WebView-Bridges Adapter-Code sind (`GG-CC-002`) und Coverage-Pflicht
  primaer den Kern trifft (`GG-NFA-COV-002`).

---

## 4. Spike-Vertrag (Validierung vor `Accepted`)

Diese ADR wechselt von `Provisional` auf `Accepted`, sobald ein
Skelett-Build folgendes nachweist:

1. `make gates` laeuft lokal ohne externe Secrets in unter 5 Minuten
   auf dem Referenzsystem aus `GG-NFA-PERF-001`.
2. Der Skelett-Build erreicht `GG-NFA-COV-001` (80 %) und
   `GG-NFA-COV-002` (90 % auf den genannten kritischen Modulen). Falls
   die Schwellen mit Skelett-Code nicht erreichbar sind (zu wenig
   Logik), wird der Skelett-Code so erweitert, dass die Schwellen
   greifen — die Schwellen selbst werden nicht abgesenkt.
3. Der Architektur-Check meldet zwei kuenstlich eingebaute
   Verletzungen (Test-Fixture) und blockiert `make gates`.
4. `make container-gates` baut den Container und fuehrt `make gates`
   darin erfolgreich aus; zwei aufeinanderfolgende Laeufe
   unterscheiden sich nur in den dokumentierten
   nicht-deterministischen Anteilen (`GG-NFA-INSTALL-001`).

---

## 5. Alternativen

- **`cargo tarpaulin` statt `cargo llvm-cov`**: aelter, ungenauer bei
  Inlining/`async`, kein eingebauter `--fail-under`-Schalter.
- **`jest` statt `vitest`** im Frontend: deutlich langsamer in
  Vite-/SvelteKit-Setups, keine native Svelte-5-Unterstuetzung.
- **Sammlung aller Lints in `pre-commit`** statt `make gates`:
  `pre-commit` ist Entwickler-Komfort; das gate muss reproduzierbar
  ausserhalb laufen, sonst sind CI-Resultate nicht vergleichbar.
- **Eigenes Architektur-Test-Framework** (z. B. analog
  `archunit-rs`): zusaetzliche Komplexitaet ohne klaren Mehrwert
  gegenueber einem 100-Zeilen-Skript fuer den MVP-Scope.
- **Sonar/CodeClimate** als externes Aggregat: zieht eine
  Cloud-Abhaengigkeit ein, die `GG-NFA-SEC-001` (lokale Verarbeitung)
  unnoetig belastet. Bei Bedarf spaeter als optionale Ergaenzung.

---

## 6. Nicht Gegenstand dieser ADR

- CI-System-Wahl (GitHub Actions / GitLab CI / lokal). CI ist eine
  duenne Schicht ueber `make gates`; die Wahl gehoert in einen
  separaten ADR oder in ein Build-Setup-Dokument.
- E2E-Test-Stack (Playwright o. ae.) — Folge-ADR, sobald
  E2E-Anforderungen ueber `GG-NFA-A11Y-001` hinaus aufkommen.
- SBOM-Erzeugung in der Tiefe (`GG-NFA-INSTALL-001` deckt
  reproduzierbaren Build ab; SBOM ist Folgearbeit).
- Coverage-Aggregat-Dashboard ueber beide Stacks.
