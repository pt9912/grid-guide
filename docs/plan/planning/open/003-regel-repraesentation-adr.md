# Trigger 003 — ADR fuer Regel-Repraesentation

**Status:** open
**Eroeffnet:** 2026-05-22
**Bezug:** [Roadmap M4](../in-progress/roadmap.md#m4--validierung-und-checkliste);
[Lastenheft](../../../../spec/lastenheft.md) (`GG-FA-VAL-001`,
`GG-FA-VAL-002`, `GG-FA-VAL-003`, `GG-AI-003`, `GG-NFA-MAINT-001`).

---

## Beobachtung

Roadmap M4 erwartet eine deterministische Regel-Engine fuer
Pflichtfelder, Pflichtunterlagen und Plausibilitaet. Lastenheft v0.4.0
nennt fuer den Demo-Falltyp `PV_NS_OhneSpeicher` mindestens fuenf
Regeln, sagt aber nicht, ob diese als Code (Rust-Funktionen) oder als
Daten (z. B. deklarative YAML-/RON-Regeln) gefuehrt werden.

`GG-NFA-MAINT-001` verlangt, dass neue Regeln ohne Aenderung am Kern
ergaenzt werden koennen. Das spricht eher fuer eine datengetriebene
Form.

## Trigger / Aktivierungsbedingung

Der Eintrag wandert nach `next/`, sobald M4 in `in-progress/`
geht oder sobald M2-Code beginnt, Profil- und Falltyp-Strukturen
auszupraegen (Pflichtfeld-/Pflichtunterlagen-Listen sind erste
Pseudo-Regeln im Datenmodell).

## Zu klaeren

- Repraesentation: Rust-Code, deklaratives Datenformat oder Hybrid
  (Datenmodell + Code-Regeln fuer Plausibilitaet).
- Determinismus-Vertrag: wie wird `GG-AI-003` (gleiche Eingabe →
  gleiche Warnungen) getestet (Property-Tests, Snapshot-Tests,
  Determinism-Marker)?
- Versionierung: gelten Regeln pro `Profilversion` oder uebergreifend?
- Erweiterbarkeit: wie wird `GG-NFA-MAINT-001` ohne Recompile
  realisiert (Hot-Reload, separate Konfig, Plugin)?
- Verhaeltnis zur Override-Bestaetigung (`GG-NFA-USE-001`): welche
  Regeln duerfen `fehler`-Schweregrad ausloesen?
