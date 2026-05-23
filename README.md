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

Aktiv in Entwicklung — **M1 (Foundation, Build-Tooling und CI)
abgeschlossen** (2026-05-23, alle sieben Wellen geliefert; Linux-
CI-Pflichtjob gruen, macOS gruen, Windows als Best-Effort offen
gemaess [Trigger 016](docs/plan/planning/open/016-windows-test-runtime-setup.md)).
M2 (Domain-Kern + Katalog-Seed) noch nicht aktiviert. Siehe
[Roadmap](docs/plan/planning/in-progress/roadmap.md),
[M1-Slice-Plan](docs/plan/planning/done/M1-Slice-Plan.md) und
[M1-Closure-Notiz](docs/plan/planning/done/M1-Slice-Plan-results.md).

## Quick-Start

Vorbedingung: **Docker** installiert (alle Build-/Test-Pfade laufen
im pinned Container). Node, pnpm, Rust und cargo-Tools werden im
Container bereitgestellt — auf dem Host nicht erforderlich.

```sh
# Lockfile generieren (einmalig oder nach Dependency-Aenderung):
make lock-refresh        # pnpm install --lockfile-only im Container

# Quality Gates lokal im Container:
make container-gates     # docker build + make gates im Container

# Voller CI-Lauf inkl. Bundle (extrahiert nach dist/):
make container-ci

# Reines Lint/Format/Test direkt (wenn Toolchains lokal vorhanden):
make gates               # alle Gates lokal
make ci                  # gates + Bundle
make fullbuild           # nur Linux-Bundle (AppImage + .deb)
make help                # vollstaendige Target-Liste
```

Reproduzierbarkeitsnachweis via:

```sh
bash scripts/repro-check.sh   # baut Container 2x, vergleicht Binary-Hash
```

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
