# Trigger 001 — Skelett fuer `spec/architecture.md` anlegen

**Status:** open
**Eroeffnet:** 2026-05-22
**Bezug:** [ADR 0001](../../adr/0001-documentation-and-planning-structure.md)
§2.1; `grid-gym/spec/architecture.md` als Referenzformat.

---

## Beobachtung

`spec/architecture.md` existiert in `grid-gym`, aber nicht in
`grid-guide`. Mehrere Anforderungen und ADRs verweisen implizit oder
explizit auf eine Architektur-Spezifikation (z. B. `GG-ARCH-002`
hexagonale Zielstruktur, `GG-ARCH-007` Bounded Contexts,
`GG-NFA-LOG-001` Pfad-Dokumentation, ADR 0004 `tools/arch-check.sh`).
Solange `architecture.md` fehlt, leben diese Inhalte verteilt in
Lastenheft und ADRs.

## Trigger / Aktivierungsbedingung

Der Eintrag wandert nach `next/`, sobald **mindestens eine** der
folgenden Bedingungen eintritt:

- Ein erster Code-Slice (z. B. `M1-mvp-kern`) wandert nach
  `in-progress/`.
- Eine ADR muss eine `GG-AR-COMP-*`-, `GG-AR-PORT-*`- oder
  `GG-AR-TABU-*`-Kennung referenzieren (z. B. ADR 0004 erweitert den
  `arch-check.sh`-Vertrag).
- Ein zweiter Mitwirkender wuenscht eine konsolidierte Architektur-
  Uebersicht jenseits von Lastenheft + ADRs.

## Skizze des Erst-Inhalts

Wenn der Trigger ausloest, soll `spec/architecture.md` initial
mindestens enthalten:

- **Schichten- und Komponenten-Modell** (`GG-AR-COMP-*`): Catalog,
  Project, Validation, Submission (siehe `GG-ARCH-007`); spaeter
  OcrExtraction, Mastr, Redispatch, PortalAutomation.
- **Ports** (`GG-AR-PORT-DRV-*`, `GG-AR-PORT-DRN-*`): driving
  (Tauri-Commands, CLI) und driven (PDF-/XLSX-Reader, Dateisystem,
  HTTP, OS-Secret-Store, optionaler LLM-Adapter).
- **Tabus** (`GG-AR-TABU-*`): die Verbotsregeln aus `GG-ARCH-003`,
  `GG-CC-003`, `GG-CC-004` als pruefbare Contracts.
- **Acceptance Contracts** (`AC-*`): formale Vertrage, gegen die der
  `arch-check.sh`-Aufruf aus ADR 0004 prueft.
- **Offene Punkte** (`GG-AR-OPEN-*`): Slots fuer noch nicht
  entschiedene Designfragen; jeder geschlossene Punkt wird durch eine
  ADR aufgeloest und im Lastenheft als entschieden markiert.

## Nicht-Aktivierung

Vor dem Trigger soll keine `architecture.md` angelegt werden — sie
wuerde nur Inhalte aus Lastenheft und ADRs umkopieren und mit dem
ersten Code-Skelett ohnehin umgeschrieben werden muessen.

---

## Closure

**Abgeschlossen:** 2026-05-23 (M1-Welle 7).
**Geliefert:** `spec/architecture.md`-Skelett mit den vier
Pflichtsektionen (`GG-AR-COMP-*` Komponenten,
`GG-AR-PORT-DRV-*`/`GG-AR-PORT-DRN-*` Ports,
`GG-AR-TABU-001..003` Tabus, `GG-AR-OPEN-*` Slots) plus
`AC-*`-Acceptance-Contracts.

**Bleibt offen / Folgearbeit:** Die Komponenten-Stubs erhalten
ihre Use-Cases und Domain-Modelle in M2..M7; jeder
`GG-AR-OPEN-*`-Slot loest sich durch eine eigene ADR auf
(siehe Trigger-Liste in `architecture.md` §7).
