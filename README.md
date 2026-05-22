# GridGuide

Lokaler Tauri-Desktop-Assistent zur Vorbereitung vollstaendiger
Netz- und Behoerdenantraege fuer PV-, Speicher- und
Erzeugungsanlagen.

GridGuide ist **keine** Rechts-, Steuer- oder
Netzanschlussberatung. Er bereitet Einreichungspakete vor, ersetzt
aber keine Pruefung durch Netzbetreiber, Behoerden, Steuerberatung
oder fachkundige Elektroinstallateure (siehe
[`GG-LESE-003`](spec/lastenheft.md)).

## Status

Aktiv in Entwicklung — **M1 (Foundation, Build-Tooling und CI)**
laeuft. Siehe
[Roadmap](docs/plan/planning/in-progress/roadmap.md) und
[M1-Slice-Plan](docs/plan/planning/in-progress/M1-Slice-Plan.md).

## Quick-Start

Vorbedingungen werden in M1 nachgepflegt; bis dahin gilt:

```sh
# Wenn das Skelett-Repo aufgesetzt ist:
make gates       # alle Quality-Gates lokal ausfuehren
make ci          # gates + Bundle-Erzeugung
make fullbuild   # nur Linux-Bundle (AppImage + .deb)
```

Bis M1-Welle 3 (`Makefile`) existiert, sind die Targets noch nicht
bedienbar.

## Dokumentation

- **Lastenheft** (normative Anforderungen):
  [`spec/lastenheft.md`](spec/lastenheft.md) — aktuell v0.4.0,
  132 Anforderungen.
- **Architecture Decision Records**:
  [`docs/plan/adr/`](docs/plan/adr/) — Index in
  [`docs/plan/adr/README.md`](docs/plan/adr/README.md).
- **Roadmap und Planung**:
  [`docs/plan/planning/`](docs/plan/planning/) — Lebenszyklus
  open/next/in-progress/done.
- **Konventionen fuer Beitragende**: [`AGENTS.md`](AGENTS.md).
- **Quellen-Kataloge**:
  [`docs/catalogs/`](docs/catalogs/) — Seed-Quellen fuer Profile.

## Plattformen

Primaere Zielplattform fuer den MVP ist **Linux** (AppImage und
.deb). macOS und Windows werden im CI-Matrix-Build mitgefuehrt
(Best-Effort, kein MVP-Abnahmegegenstand). Siehe
[`GG-PE-003`](spec/lastenheft.md) und
[ADR 0005](docs/plan/adr/0005-ci-release-tauri-action.md).

## Lizenz

[MIT](LICENSE) — siehe
[`GG-LIC-001`](spec/lastenheft.md) und
[`GG-DEC-005`](spec/lastenheft.md).
