# Trigger 011 — ADR fuer vollstaendige Bundle-Reproduzierbarkeit

**Status:** open
**Eroeffnet:** 2026-05-22
**Bezug:** [Review-Finding H2 (M1-W5)](../in-progress/M1-Slice-Plan.md);
`scripts/repro-check.sh`; [Lastenheft](../../../../spec/lastenheft.md)
(`GG-NFA-INSTALL-001`, `GG-NFA-INSTALL-002`).

---

## Beobachtung

`scripts/repro-check.sh` prueft im M1-Stand nur die SHA-256 des
produktiven Rust-Binarys (`src-tauri/target/release/gridguide`).
Das deckt **nicht** die Reproduzierbarkeit des Tauri-Bundles ab
(AppImage, `.deb`), die `GG-NFA-INSTALL-001` woertlich verlangt:

> "erzeugt fuer denselben Quellstand auf demselben Referenzsystem
> dieselben **Bundle-Inhalte** bis auf bekannte nicht-deterministische
> Anteile (Zeitstempel, Signatur)."

Bundle-Reproduzierbarkeit hat zusaetzliche Drift-Quellen:

- AppImage-SquashFS-mtime (jede Datei traegt einen Zeitstempel).
- `.deb`-`md5sums`-Reihenfolge (haengt vom Filesystem-Iteration-
  Order ab).
- Eingebettetes Frontend (Vite-Asset-Hash-Suffixe, Build-ID).
- Tauri-Metadaten (Build-Timestamp im Manifest).

## Trigger / Aktivierungsbedingung

Der Eintrag wandert nach `next/`, sobald **eine** der folgenden
Bedingungen eintritt:

- `scripts/repro-check.sh` Binary-Repro laeuft erstmals gruen — dann
  wird Bundle-Repro die naechste Stufe.
- V1-Release-Vorbereitung (`GG-NFA-INSTALL-002` signierte
  Distribution).
- Externe Auditierungsanforderung (z. B. Lieferketten-Transparenz).

## Zu klaeren

- **SOURCE_DATE_EPOCH**: setzen vor `cargo tauri build`, damit
  Tauri-Manifest und Bundle-Komponenten deterministische Zeitstempel
  bekommen.
- **AppImage-SquashFS**: `mksquashfs`-Aufrufe brauchen
  `-no-exports -all-root -mkfs-time 0`-Aequivalente.
- **`.deb`-Reproduzierbarkeit**: `dpkg-deb` braucht
  `SOURCE_DATE_EPOCH` plus `--root-owner-group` plus sortierte
  Datei-Reihenfolge.
- **Vite-Asset-Hashes**: Vite haengt content-hashes an Asset-Namen;
  diese sind eigentlich deterministisch — Drift kommt nur durch
  Frontend-Source-Inhalt.
- **Tauri-2.x-Signaturen**: Unsigned Bundle ist M1; signiertes
  Bundle (V1) muss aus der Repro-Pruefung raus oder als
  "dokumentierter nicht-deterministischer Anteil" markiert sein.
- **Pruef-Strategie**: SHA-256 ueber gesamtes Bundle vs.
  `diffoscope` vs. unpacked-content-diff.

## Verhaeltnis zu Trigger 010

Trigger 010 (apt-Snapshot) ist Voraussetzung fuer Trigger 011 —
ohne deterministische Toolchain kann auch das Bundle nicht
deterministisch sein.
