# Trigger 012 — RustSec-Allowlist (Tauri Linux Stack) revisiten

**Status:** open
**Eroeffnet:** 2026-05-23
**Ablaufdatum:** 2026-11-23 (sechs Monate; harte Review-Pflicht
unabhaengig davon, ob die unten genannten Aktivierungsbedingungen
schon erfuellt sind — vgl. GG-NFA-QG-005 „Ausnahmen sind mit
Begruendung und Ablaufdatum im Repository hinterlegt").
**Bezug:** [Lastenheft GG-NFA-QG-005](../../../../spec/lastenheft.md)
(Security-Scan); `src-tauri/audit.toml`; `Makefile` Target
`dep-audit-rust`.

---

## Beobachtung

`make dep-audit-rust` (cargo-audit 0.22.1 gegen die aktuelle
RustSec-Advisory-DB) findet **17 unmaintained-Warnings**, alle
transitive Abhaengigkeiten von Tauri 2.11.2 unter Linux:

- **gtk-rs 0.18 Familie** (upstream nicht mehr gepflegt — Migration
  zu gtk-rs 0.20 / gtk4 noch nicht in Tauri/wry vollzogen):
  `atk`, `atk-sys`, `gdk`, `gdk-sys`, `gdkx11`, `gdkx11-sys`,
  `gdkwayland-sys`, `gtk`, `gtk-sys`, `gtk3-macros`, `glib` -
  RUSTSEC-2024-0411 bis -0420, -0429.
- **proc-macro-error** (RUSTSEC-2024-0370): transitiv via
  gtk-rs/Tauri-Macros.
- **unic-*** (RUSTSEC-2025-0075/-0080/-0081/-0098/-0100): transitiv
  via `idna`/`url` aus Tauri's URL-Handling.

Alle 17 sind in `src-tauri/audit.toml` als `[advisories].ignore`
gepflegt. Dadurch laeuft `make gates` durch, das Gate
`--deny unmaintained` bleibt aktiv und blockiert kuenftige neue
unmaintained-Funde.

## Trigger / Aktivierungsbedingung

Der Eintrag wandert nach `next/`, sobald **eine** der folgenden
Bedingungen eintritt:

- Tauri 2.x veroeffentlicht eine Minor-Version, die auf gtk-rs 0.20
  oder eine nachfolgende, gepflegte Linux-Toolkit-Schicht migriert
  (z. B. webkit2gtk-4.2 / libadwaita).
- Eine der gelisteten RUSTSEC-Warnungen eskaliert zu einer
  `unsound`/`vulnerability`-Klassifikation (dann sofortige
  Behandlung erforderlich, nicht erst beim Trigger).
- `cargo-modules`/`cargo-tree`-Analyse zeigt, dass eine
  Allowlist-Crate aus dem Dependency-Graph entfaellt (Bereinigung
  der Allowlist).

## Zu klaeren beim Aufloesen

- Welche Crates lassen sich nach dem Tauri-Update aus der Allowlist
  streichen?
- Bleibt der Pattern `audit.toml im Repo + Dockerfile-COPY nach
  $CARGO_HOME` der richtige Verteilweg, oder migrieren wir auf ein
  Format wie `deny.toml` (cargo-deny)?
- Wird in dem Zuge auch `--deny unmaintained` verschaerft (z. B.
  zusaetzlich `--deny warnings`)?

## Akzeptanzkriterien Erst-Auswurf

- `src-tauri/audit.toml` enthaelt nur noch RUSTSEC-IDs, fuer die ein
  klarer Trigger zur naechsten Bereinigung dokumentiert ist (oder
  ist leer).
- `make dep-audit-rust` laeuft mit unveraendertem `--deny`-Set
  gruen.
- Dieser Trigger wandert nach `done/` mit Verweis auf den ADR /
  Slice, der die Aufloesung bewirkt hat.
