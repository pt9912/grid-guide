# ADR-Index — grid-guide

Lebende Uebersicht ueber alle ADRs, ihren Status und die
Vorrang-/Schaerfungs-Beziehungen zwischen ihnen. Diese Datei ist
**kein** ADR-Entscheidungstext — sie ist eine Service-Notiz fuer
Reviewer, damit Drift zwischen Accepted-Texten (die per
[`ADR 0001`](0001-documentation-and-planning-structure.md) §2.3
immutable sind) und nachgelagerten Folge-ADRs sichtbar bleibt.

Reihenfolge: aufsteigend nach ADR-Nummer. Eine ADR mit Schaerfung
durch eine Folge-ADR traegt eine Spalte „Schaerfungen" mit
Verweisen — die Folge-ADR ist verbindlich, der Original-Text
historisch fuer die geschaerfte Stelle.

---

## Aktive ADRs

| ADR  | Titel                                                                                | Status      | Datum      | Schaerfungen / Folge-ADRs |
| ---- | ------------------------------------------------------------------------------------ | ----------- | ---------- | ------------------------- |
| 0001 | [Dokumentations- und Planungsstruktur](0001-documentation-and-planning-structure.md) | Accepted    | 2026-05-22 | —                         |
| 0002 | [Frontend-Stack: SvelteKit 2.x (SPA)](0002-frontend-stack-sveltekit.md)              | Accepted    | 2026-05-22 | —                         |
| 0003 | [Desktop-Runtime: Tauri 2.x](0003-desktop-runtime-tauri.md)                          | Accepted    | 2026-05-22 | —                         |
| 0004 | [Quality-Gates- und Coverage-Tooling](0004-quality-gates-and-coverage-tooling.md)    | Provisional | 2026-05-22 | Spike-Vertrag in §4; wechselt auf Accepted nach Skelett-Build. |
| 0005 | [CI/Release mit GitHub Actions + tauri-action](0005-ci-release-tauri-action.md)      | Provisional | 2026-05-22 | Spike-Vertrag in §4; wechselt auf Accepted nach Workflow-Validierung. |

---

## Lese-Reihenfolge bei Drift

Wenn Code, Tests oder Slice-Plaene auf einen Vertrag referenzieren,
der in einer aelteren `Accepted`-ADR steht, **immer pruefen, ob eine
Folge-ADR in der „Schaerfungen"-Spalte oben die Stelle schaerft.** Im
Zweifel:

1. Folge-ADR lesen — sie traegt die maßgebliche Fassung.
2. Original-ADR-Stelle bleibt historisch (kein Edit per
   [`ADR 0001`](0001-documentation-and-planning-structure.md) §2.3).
3. Code- und Modul-Docstrings zitieren beide ADRs ueber den
   `ADR NNNN`-Tag.

---

## Konvention

- Neuer ADR-Eintrag in dieser Tabelle ist Pflicht bei jeder neuen ADR.
  Reihenfolge: aufsteigend nach Nummer.
- Wenn eine ADR eine andere abloest oder schaerft, wird die
  „Schaerfungen"-Spalte der **alten** ADR aktualisiert. Die alte ADR
  selbst bleibt textlich unveraendert (per
  [`ADR 0001`](0001-documentation-and-planning-structure.md) §2.3).
- Statuswechsel (z. B. `Provisional → Accepted`) werden in der
  ADR-Datei selbst dokumentiert (Header-Pflichtfelder per
  [`ADR 0001`](0001-documentation-and-planning-structure.md) §2.5);
  diese Tabelle reflektiert sie.
