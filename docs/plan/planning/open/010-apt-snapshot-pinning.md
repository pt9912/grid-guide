# Trigger 010 — ADR fuer apt-Snapshot-Pinning im Build-Container

**Status:** open
**Eroeffnet:** 2026-05-22
**Bezug:** [Review-Finding M9 (M1-W5)](../in-progress/M1-Slice-Plan.md);
`Dockerfile`; [ADR 0004 §4](../../adr/0004-quality-gates-and-coverage-tooling.md);
[Lastenheft](../../../../spec/lastenheft.md) (`GG-NFA-INSTALL-001`).

---

## Beobachtung

Der M1-Build-Container installiert apt-Pakete (`libwebkit2gtk-4.1-dev`,
`libssl-dev`, `libsoup-3.0-dev`, `libayatana-appindicator3-dev`,
`librsvg2-dev`, `libgtk-3-dev`, `patchelf`, `file`, `make`,
`ca-certificates`) ohne `=<version>`-Pin und ohne
`snapshot.debian.org`-Mirror. Damit ist die apt-Schicht **die**
verbleibende nicht-deterministische Quelle in der Build-Toolchain.

`GG-NFA-INSTALL-001` fordert vollstaendige Reproduzierbarkeit (bis
auf dokumentierte Zeitstempel/Signatur). Ohne Snapshot-Pin kann
`repro-check.sh` aus Gruenden FAILen, die nichts mit Source-
Determinismus zu tun haben (z. B. Bookworm-Security-Update
zwischen Lauf 1 und Lauf 2).

## Trigger / Aktivierungsbedingung

Der Eintrag wandert nach `next/`, sobald **eine** der folgenden
Bedingungen eintritt:

- `scripts/repro-check.sh` schlaegt erstmals fehl mit nachweisbarem
  apt-Drift als Ursache.
- M1-W5-Closure schliesst die uebrigen DoD-Items und apt-Pinning
  wird das einzige offene Repro-Hindernis.
- V1-Release-Vorbereitung (signierte Bundles, vollstaendige
  Build-Trail-Anforderung).

## Zu klaeren

- **Snapshot-Mirror-Wahl**: `snapshot.debian.org` ist offiziell,
  aber rate-limited. Alternativen: Spiegel-Repo auf eigener
  Infrastruktur, `debian-snapshot-archive`-Mirror oder ein
  Pinning per Manifest-Digest des Base-Images allein (impliziter
  Snapshot ueber Image-SHA).
- **Pin-Granularitaet**: jedes apt-Paket explizit `=<version>` oder
  nur Repo-Snapshot? Erstere bricht bei Sicherheits-Updates ohne
  Pin-Refresh; letztere ist toleranter.
- **`Acquire::Check-Valid-Until`**: Snapshot-Repos liefern Release-
  Daten in der Vergangenheit — apt muss das tolerieren.
- **Tools-Versions-Drift**: passt zu Trigger 006
  (Dependabot/Renovate) — wer aktualisiert den Snapshot-Stand?
- **Image-Groesse**: Snapshot-Mirror fuer libapt-Komponenten kann
  Image-Build deutlich verlangsamen (Downloads vom Snapshot-Server).
