# M1-Slice-Plan — Closure-Notiz

**Aktiviert:** 2026-05-22 (siehe `done/M1-Slice-Plan.md`).
**Abgeschlossen:** 2026-05-23 (M1-Welle 7).
**Bezug:** [`done/M1-Slice-Plan.md`](M1-Slice-Plan.md);
[Roadmap M1](../in-progress/roadmap.md#m1--foundation-build-tooling-und-ci);
[Lastenheft v0.4.0](../../../../spec/lastenheft.md).

Diese Notiz fasst den finalen Stand der M1-Wellen zusammen, mit
Datum und Anker-Commit-SHA pro Welle, sowie den offenen Punkten,
die nach M2+ wandern.

---

## Wellen-Ergebnistabelle

| Welle | Datum      | Anker-Commit (initial)                                | Lieferziel                                                              |
| ----- | ---------- | ----------------------------------------------------- | ----------------------------------------------------------------------- |
| W0    | 2026-05-22 | `38ae87d` M1-W0: Repo-Hygiene                         | `.editorconfig`, `.gitignore`, README-Skelett, Lizenz; Slice-Plan aktiv |
| W1    | 2026-05-22 | `d65ab71` M1-W1: Rust-Workspace + Hexagon-Layout      | `src-tauri/Cargo.toml`, `hexagon/{core,ports,adapters}` Modul-Stubs     |
| W2    | 2026-05-22 | `926349a` M1-W2: SvelteKit-Frontend + Tauri-Runtime   | `frontend/` mit SvelteKit-2.x, Tauri-2.x Builder mit `greet`-Command    |
| W3    | 2026-05-22 | `ae4c030` M1-W3: Makefile als zentraler Einstieg      | Makefile mit allen Pflichttargets (gates/ci/fullbuild/bundle/lint/…)    |
| W4    | 2026-05-22 | `96dba85` M1-W4: tools/arch-check.sh + Test-Fixtures  | Hexagonale Tabu-Regeln in `arch-check.sh`; Coverage-Tooling             |
| W5    | 2026-05-22 | `558164a` M1-W5: Multi-Stage Dockerfile               | Build-Container; `container-gates`/`container-ci`/`lock-refresh`        |
| W6    | 2026-05-23 | `68d3bd1` M1-W6: ADR 0005 §2.3 auf ubuntu-24.04       | `.github/workflows/gates.yml` + `release.yml`-Stub                      |
| W7    | 2026-05-23 | `3c8e378` M1-W7: spec/architecture.md-Skelett         | `architecture.md`, ADR 0004 + 0005 auf `Accepted`, Closure-Notiz        |

Pro Welle wurden zwischen initial und Closure mehrere Fix-/Review-
Commits angesammelt (Wellen 4-6 jeweils mit Review-Sweeps und
mehreren M1-W*-Fix-Commits); der Anker-Commit oben markiert den
Welle-Start, nicht das letzte Commit dieser Welle.

---

## DoD-Status (Roadmap M1)

Die sieben Hauptchecks aus Roadmap §3 (`M1 — Foundation,
Build-Tooling und CI`):

- [x] Rust-Workspace + hexagonales Modulgeruest (`GG-ARCH-002`).
- [x] SvelteKit-Frontend + Tauri-Integration (`GG-ARCH-008`, ADR 0002/0003).
- [x] Makefile mit Aggregat- und Subtargets (`GG-NFA-INSTALL-005`).
- [x] Architektur-Check + Coverage-Tooling (`GG-NFA-QG-003`, `GG-NFA-COV-001`).
- [x] Build-Container reproduzierbar (`GG-NFA-INSTALL-001/004`).
- [x] CI-Workflow + Plattform-Matrix (`GG-NFA-CICD-001/002`).
- [x] `spec/architecture.md`-Skelett + Provisional-ADRs auf `Accepted` (`GG-ARCH-007`, ADR 0004/0005).

---

## Verifikations-Nachweise

| Vertrag                                                    | Nachweis                                                                  |
| ---------------------------------------------------------- | ------------------------------------------------------------------------- |
| `make container-gates` gruen                               | Lokaler Lauf 2026-05-23 (Linux-Host); Coverage Rust ~94 % / FE ~94,73 %   |
| `make container-ci` produziert Bundle (`.deb` + `.AppImage`) | Lokaler Lauf 2026-05-23; `dist/deb/GridGuide_0.0.0_amd64.deb` 2,9 MB    |
| `scripts/repro-check.sh` exit=0                            | Zwei `--no-cache`-Builds, identischer SHA `9f073e26…930bb602`             |
| `make gates` im GitHub-Actions-Linux-Job gruen             | Run `26333004621` (Commit `9312418`); Linux ✓                             |
| macOS-Job durchgelaufen                                    | Run `26333004621`; macOS ✓                                                |
| Linux-Job als Required-Check                               | **Offen** in den GitHub-UI-Branch-Rules (manueller Schritt nach Closure)  |

---

## Offene Punkte (nach M2+ verschoben)

Aus den W5/W6-DoDs sind folgende Items deferred und stehen als
Trigger im `open/`-Verzeichnis bzw. wandern dorthin:

| Trigger | Inhalt                                                                            |
| ------- | --------------------------------------------------------------------------------- |
| 006     | Dependabot/Renovate-ADR (war schon vor M1 angelegt; in M2-Kickoff zu pruefen)     |
| 010     | apt-Snapshot-Pinning fuer voll-deterministischen Container-Build                  |
| 011     | Bundle-Reproduzierbarkeit (`.deb` + `.AppImage`) nach `GG-NFA-INSTALL-001`        |
| 012     | RustSec-Allowlist (`audit.toml`); Review bis 2026-11-23 oder beim naechsten Tauri-Update |
| 013     | `main.rs`-Coverage-Exception via `tauri::test::mock_runtime` ohne Wry-Event-Loop  |
| 015     | Release-Workflow operativ validieren (ADR 0005 §4.2)                              |
| 016     | Windows-Test-Runtime fuer `make gates` (`STATUS_ENTRYPOINT_NOT_FOUND`)            |

Trigger 014 in einer fruehen Fassung dieser Notiz war eine
Fehlbenennung — Dependabot/Renovate ist seit dem ADR-Trigger-Sweep
2026-05-22 als Trigger 006 dokumentiert. Es gibt keinen Trigger
014 im Repository.

---

## Aenderungen am Slice-Plan-Vertrag

- **ADR 0005 §4** wurde in M1-Welle 7 in MVP-Accept (§4.1) und
  V1-Validierung (§4.2) gegliedert (Schaerfung waehrend
  Provisional, daher nach ADR 0001 §2.3 zulaessig). Die
  V1-Validierungs-Items sind als Trigger 015 fortgefuehrt.
- **`audit.toml`** war urspruenglich nur per Dockerfile in
  `$CARGO_HOME` kopiert; in W6 zeigte sich, dass der nativ
  laufende CI-Cargo den Pfad nicht trifft. Der Makefile-Target
  `dep-audit-rust` spiegelt die Datei jetzt zur Laufzeit dorthin,
  was die Allowlist plattform- und runtime-unabhaengig macht.
- **Windows-Best-Effort-Status**: durchgehend rot bis zur
  Aufloesung von Trigger 016. M1-DoD ist davon unberuehrt, weil
  Lastenheft `GG-NFA-CICD-002` und ADR 0005 §2.3 Windows als
  Best-Effort definieren.

---

## Naechstes

M2 — Domain-Kern und Katalog-Seed (`Catalog`-Komponente, vgl.
`GG-AR-COMP-001`). Vorbedingungen sind mit M1-Closure erfuellt
(`spec/architecture.md` existiert, ADR 0004/0005 sind `Accepted`).
