# Trigger 002 — ADR fuer Projekt-Datei-Schema

**Status:** open
**Eroeffnet:** 2026-05-22
**Bezug:** [Roadmap M3](../in-progress/roadmap.md#m3--projekt-lifecycle-und-persistenz);
[Lastenheft](../../../../spec/lastenheft.md) (`GG-FA-PROJ-002`,
`GG-NFA-BACKUP-001`, `GG-DATA-001`, `GG-DATA-005`).

---

## Beobachtung

`GG-FA-PROJ-002` und `GG-NFA-BACKUP-001` fordern lokale, atomar
geschriebene Projektdateien. Lastenheft v0.4.0 schreibt aber kein
konkretes Dateiformat vor (JSON vs. TOML vs. SQLite ist erst V1).
Roadmap M3 erwartet beim Slice-Start einen Folge-ADR fuer die
Format-Wahl.

## Trigger / Aktivierungsbedingung

Der Eintrag wandert nach `next/`, sobald M3 in `in-progress/`
geht — spaetestens, wenn ein Slice-Plan unter
`docs/plan/planning/next/M3-projekt-lifecycle.md` skizziert wird.

## Zu klaeren

- Format (JSON, TOML, RON, SQLite, …) und Begruendung gegenueber
  Reproduzierbarkeit, menschlicher Lesbarkeit, Migrationsaufwand.
- Schema-Versionierung (analog `Profilversion` aus `GG-DATA-005`).
- Migrationsstrategie bei Format-/Schema-Aenderungen zwischen
  Releases.
- Verhaeltnis zu kuenftiger SQLite-Persistenz (V1, siehe
  `GG-ARCH-008`).
- Lokalisation: Projekt-Datei-Pfad relativ zu
  `$XDG_DATA_HOME/gridguide/` (analog zum Log-Pfad in
  `GG-NFA-LOG-001`).
