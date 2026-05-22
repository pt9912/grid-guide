# Trigger 004 — ADR fuer PDF-/XLSX-Library-Wahl

**Status:** open
**Eroeffnet:** 2026-05-22
**Bezug:** [Roadmap M5](../in-progress/roadmap.md#m5--dokumentimport-und-feldextraktion);
[Lastenheft](../../../../spec/lastenheft.md) (`GG-MVP-005`, `GG-MVP-006`,
`GG-FA-DOC-001`, `GG-NFA-PERF-001`, `GG-NFA-PERF-002`).

---

## Beobachtung

Roadmap M5 erwartet PDF-Reader-Adapter (Kandidaten: `lopdf`,
`pdf-extract`) und einen XLSX-Reader-Adapter (Kandidat: `calamine`).
Die endgueltige Library-Wahl beeinflusst:

- Bundle-Groesse des Tauri-Bundles (`GG-NFA-PERF-001`-Antwortzeiten,
  AppImage-Footprint).
- Genauigkeit der Feldextraktion (`GG-MVP-006` verlangt sechs
  Demo-Felder).
- Lizenzkompatibilitaet mit MIT (`GG-LIC-001`).
- Verarbeitung grosser Dateien (`GG-NFA-PERF-002`: 50 MB PDF, 20 MB
  XLSX).

## Trigger / Aktivierungsbedingung

Der Eintrag wandert nach `next/`, sobald M5 in `in-progress/`
geht — oder frueher, falls bereits in M3/M4 ein experimenteller
Reader fuer Demo-Daten gebaut werden soll.

## Zu klaeren

- PDF-Reader: `lopdf` (umfangreich, mehr Features) vs. `pdf-extract`
  (leichter, nur Textextraktion) vs. `pdfium-render` (Bindings zu
  Chromium-PDFium, mehr Genauigkeit, Bundle-Groesse).
- XLSX-Reader: `calamine` (read-only, schnell, MIT) als
  Default-Annahme; Begruendung dokumentieren.
- OCR-Fallback (V1, `GG-AI-005`): wird die PDF-Library so gewaehlt,
  dass OCR-Integration einfach bleibt (z. B. via `tesseract-rs`)?
- Performance-Benchmark fuer `GG-NFA-PERF-001`-Zielwerte als
  Akzeptanzkriterium der ADR.
- Lizenzpruefung jeder Kandidaten-Crate gegen `GG-LIC-001` und
  `GG-NFA-QG-005` (Dependency-Security-Gate).
