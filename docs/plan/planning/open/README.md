# Offene Trigger-Watch-Punkte

Dieses Verzeichnis sammelt Trigger, offene Folgearbeiten und Vorab-
klaerungen, die noch keinen konkreten Scope haben.

Lebenszyklus eines Eintrags (siehe
[`ADR 0001`](../../adr/0001-documentation-and-planning-structure.md) §2.1):

```text
open/  →  next/  →  in-progress/  →  done/
                                   ↘ archive/
```

Konvention:

- Dateiname `NNN-kurz-titel.md` mit dreistelliger Nummer.
- Jeder Eintrag beschreibt Trigger, Beobachtung und
  Aktivierungsbedingung (was muss passieren, damit der Eintrag nach
  `next/` wandert?).
- Eintraege bleiben hier, bis sie aktiviert oder verworfen werden.
