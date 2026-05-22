# Trigger 006 — ADR fuer Dependabot/Renovate-Konfiguration

**Status:** open
**Eroeffnet:** 2026-05-22
**Bezug:** [ADR 0005 §6](../../adr/0005-ci-release-tauri-action.md);
[Lastenheft](../../../../spec/lastenheft.md) (`GG-NFA-INSTALL-001`,
`GG-NFA-QG-005`, `GG-NFA-CICD-001`).

---

## Beobachtung

Mit M1 entstehen vier voneinander getrennte gepinnte Dependency-
Welten, die alle laufende Sicherheits-Updates brauchen:

- Rust-Crates (`Cargo.lock`, `cargo install`-Tools mit
  `--version`-Pins).
- Frontend-Pakete (`pnpm-lock.yaml` bzw. `package-lock.json`).
- GitHub-Actions (SHA-Pins gemaess ADR 0005 §2.4).
- Docker-Base-Images und `apt`-Pakete (gemaess M1-Slice-Plan §3
  Welle 5).

Ohne automatisierte Update-Pflege drifften Security-Patches
auseinander, und das `make dep-audit`-Gate aus `GG-NFA-QG-005`
beginnt im Laufe der Zeit zu blockieren. ADR 0005 §6 hat die
konkrete Tool-Wahl bewusst ausgeklammert (`Dependabot/Renovate
Konfiguration` als „separater Folge-ADR oder Tooling-Setup").

## Trigger / Aktivierungsbedingung

Der Eintrag wandert nach `next/`, sobald M1 in `done/` gewandert
ist (alle vier Dependency-Welten existieren dann) — spaetestens
vor V1-Release.

## Zu klaeren

- Dependabot vs. Renovate (beide sind auf GitHub kostenlos):
  - Dependabot: einfacher, in GitHub eingebaut, breite
    Ecosystem-Abdeckung.
  - Renovate: feiner konfigurierbar, besseres Grouping, eigener
    App-Install.
- Update-Kadenz: taeglich, woechentlich, oder nur bei
  Security-Advisories.
- Auto-Merge-Politik: nur Patches, nur Dev-Dependencies, nur nach
  gruenem `gates.yml`?
- Scope: welche Ecosysteme werden abgedeckt (Cargo, npm, GitHub
  Actions, Docker)? `apt`-Pakete im Dockerfile sind weder von
  Dependabot noch Renovate direkt unterstuetzt — separater Pfad
  noetig (z. B. wiederkehrende manuelle Pruefung oder eigenes
  Skript).
- Verhaeltnis zum Dependency-Security-Gate (`GG-NFA-QG-005`,
  `make dep-audit`): sollen automatische PRs erst nach `dep-audit`-
  Gruen erstellt werden, oder umgekehrt?
- Verhaeltnis zur Reproduzierbarkeit (`GG-NFA-INSTALL-001`): jede
  Update-PR aendert Lockfiles; Re-Builds nach Merge muessen die
  Reproduzierbarkeit weiter erfuellen.
- Pflege der Tool-Versionen aus dem Dockerfile (`cargo
  install`-Tools): manuelle Versions-Pflege bleibt, oder eigene
  Renovate-Regel mit `regexManager` schreiben.
