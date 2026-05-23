# Konventionen fuer Beitragende

Dieses Dokument fasst die fuer alle Beitragenden (Menschen wie
AI-Assistenten) verbindlichen Konventionen zusammen. Es ist
absichtlich kurz und verweist auf das Lastenheft und die ADRs als
massgebliche Quellen.

## ASCII-Schreibweise

Alle Markdown- und Quellcode-Dokumente verwenden eine reine
ASCII-Schreibweise fuer Sprachzeichen. Deutsche Umlaute werden als
`ae`, `oe`, `ue` geschrieben, `ß` als `ss` (siehe
[`GG-LESE-007`](spec/lastenheft.md)).

Typografische Zeichen ausserhalb des ASCII-Bereichs (z. B. Em-Dash
`—`, Pfeile `→`, Box-Drawing in ASCII-Art-Diagrammen) sind erlaubt,
soweit sie keine Sprachzeichen ersetzen.

## Anforderungs- und ADR-IDs

Alle Anforderungen tragen `GG-<Bereich>-<NNN>`-Kennungen aus dem
Lastenheft (siehe [`GG-LESE-005`](spec/lastenheft.md)). Beitraege
referenzieren Anforderungen ueber diese IDs; Commit-Botschaften und
Pull-Request-Beschreibungen nennen die betroffenen IDs explizit.

Architektur-Entscheidungen liegen unter
[`docs/plan/adr/`](docs/plan/adr/) im MADR-aehnlichen Format.
Status-Werte: `Proposed`, `Provisional`, `Accepted`, `Rejected`,
`Withdrawn`, `Superseded`. Lebenszyklus, Aenderungsregeln und
Header-Schema sind in
[ADR 0001](docs/plan/adr/0001-documentation-and-planning-structure.md)
§2 festgelegt.

Wichtig: nach `Accepted` ist der Entscheidungstext einer ADR
**immutable** (ADR 0001 §2.3). Korrekturen kommen als neue ADR oder
als „Schaerfung ohne Supersedes" (ADR 0001 §2.4); die alte ADR
bleibt textlich unveraendert, nur die `Schaerfungen`-Spalte in
[`docs/plan/adr/README.md`](docs/plan/adr/README.md) wird gepflegt.

## Trigger- und Slice-Workflow

Offene Folgearbeiten und Trigger-Watch-Punkte liegen unter
[`docs/plan/planning/open/`](docs/plan/planning/open/). Ein Eintrag
durchlaeuft den Lebenszyklus

```text
open/ → next/ → in-progress/ → done/
                              ↘ archive/
```

gemaess ADR 0001 §2.1.

Aktive Slice-Plaene unter
[`in-progress/`](docs/plan/planning/in-progress/) muessen
Akzeptanzkriterien und einen Verifikationspfad enthalten (ADR 0001
§4). Geliefert wandert der Slice mit Closure-Notiz nach `done/`.

## Coverage- und Excludes-Politik

Coverage-Schwellen aus dem Lastenheft
([`GG-NFA-COV-001`](spec/lastenheft.md) 80 %,
[`GG-NFA-COV-002`](spec/lastenheft.md) 90 % auf kritischer
Domainlogik) werden nicht abgesenkt. Coverage-Excludes sind eng
gefasst (siehe
[`GG-NFA-COV-004`](spec/lastenheft.md) Teil 2): nur Daten- oder
Domain-Strukturen ohne eigenes Behavior duerfen ausgenommen werden.
Adapter, Use-Cases, Layout-Komponenten und Re-Exporte sind explizit
**nicht** excludable.

## Quality Gates

Lokal und in CI:

- `make gates` aggregiert lint, format, typecheck, Architektur-
  Check, Tests, Coverage und Dependency-Audit (siehe
  [`GG-NFA-INSTALL-005`](spec/lastenheft.md) und
  [ADR 0004](docs/plan/adr/0004-quality-gates-and-coverage-tooling.md)).
- `make ci` ergaenzt um Bundle-Erzeugung.
- `make container-gates` fuehrt `make gates` im pinned
  Build-Container aus
  ([`GG-NFA-INSTALL-004`](spec/lastenheft.md)).

Pre-commit-Hooks sind optional; die Gates muessen unabhaengig
reproduzierbar laufen.

## Branch-Protection

Aktiv ab M1-Welle 6 (siehe `.github/workflows/gates.yml`):

- Linux-Job aus `.github/workflows/gates.yml` ist Required-Check
  ([`GG-NFA-CICD-002`](spec/lastenheft.md)). Die Markierung als
  Required erfolgt in den Branch-Protection-Rules von GitHub
  (Repository-Settings → Branches → Rule `main`), nicht im
  Workflow selbst.
- macOS- und Windows-Jobs sind im MVP Best-Effort und blockieren
  den Merge nur bei plattformspezifischer Aenderung.
- Pull-Requests aus Forks erhalten keinen Secret-Zugriff
  (Standard-Verhalten von GitHub Actions, bewusst beibehalten —
  vgl. ADR 0005 §2.5).

## Beitragen

- Eine Aenderung pro Pull-Request; Subject im Imperativ und mit
  Bezug zu betroffenen Lastenheft-/ADR-IDs.
- Commits in der Welle-Konvention `M<N>-W<M>: <kurz>` wenn sie zu
  einer aktiven Slice-Welle gehoeren (z. B. `M1-W0: AGENTS.md`).
- Bei Lastenheft-Aenderungen: Versions-Bump im Header, Eintrag in
  der Traceability-Matrix (Kapitel 15) ergaenzen.
- Bei neuer ADR: Eintrag in
  [`docs/plan/adr/README.md`](docs/plan/adr/README.md) ergaenzen.

## Sprache der Doku

Doku, ADRs und Commit-Botschaften sind in **Deutsch**.
Code-Identifier (Funktionsnamen, Variablen, technische Felder) sind
in **Englisch** mit `snake_case` (Rust) bzw. `camelCase` (TS),
gemaess
[`GG-LESE-006`](spec/lastenheft.md). UI-nahe Bezeichner sind
deutsch (PascalCase fuer Vokabular-Werte, Klartext fuer Texte).
