# ADR 0003 — Desktop-Runtime: Tauri 2.x

**Status:** Accepted
**Datum:** 2026-05-22
**Bezug:** [ADR 0001](0001-documentation-and-planning-structure.md),
[ADR 0002](0002-frontend-stack-sveltekit.md),
[Lastenheft](../../../spec/lastenheft.md) (`GG-MVP-001`, `GG-ARCH-001`,
`GG-ARCH-008`, `GG-PE-003`, `GG-NFA-INSTALL-001`, `GG-DATA-003`,
`GG-NFA-PERF-001`)
**Aenderungstyp:** Greenfield-ADR. Schliesst die Mindestversion-Festlegung
fuer Tauri, die in Lastenheft v0.3.1 noch inline in `GG-ARCH-008`
stand und mit v0.3.2 bewusst in einen ADR ausgelagert wurde.

---

## 1. Kontext

Das Lastenheft verlangt eine lokal startbare Desktop-App (`GG-MVP-001`)
mit Tauri als Desktop-Runtime (`GG-ARCH-001`, `GG-ARCH-008`) und
Paketierung als AppImage und .deb fuer Linux. Die konkrete
Tauri-Mindestversion wurde mit Lastenheft v0.3.2 aus `GG-ARCH-008`
ausgelagert (per ADR 0001 §2) und gehoert in diese ADR.

Weitere fuer die Wahl relevante Anforderungen:

- `GG-NFA-SEC-001`, `GG-NFA-SEC-002` (lokale Verarbeitung, explizite
  Einwilligung fuer externe Dienste).
- `GG-DATA-003` (Secrets nur ueber OS-Secret-Store).
- `GG-NFA-INSTALL-001` (reproduzierbarer Build mit `cargo build
  --locked`).
- `GG-NFA-PERF-001` (Antwortzeiten auf Referenz-Desktop-Hardware).

Bewertete Optionen:

- Tauri 2.x (gewaehlt).
- Electron.
- Native GTK-/Qt-App in Rust.
- Wails (Go-basiert).

---

## 2. Entscheidung

Die Desktop-Runtime ist **Tauri 2.x** mit Rust-Backend (`src-tauri/`).

- Mindestversion: **Tauri 2.11**.
- Konkrete Patch-Versionen werden in `Cargo.toml` und `Cargo.lock`
  festgelegt und sind nicht Bestandteil dieser ADR.
- Paketierung: AppImage und .deb fuer Linux. Sekundaerumgebungen (macOS,
  Windows) sind kein MVP-Abnahmegegenstand (`GG-PE-003`).
- Webview: System-Webview (WebKitGTK unter Linux). Die Auswahl der
  konkreten WebView-Bibliothek bleibt bei Tauri und wird hier nicht
  weiter eingeschraenkt.

---

## 3. Konsequenzen

Positiv:

- Tauri 2.x bietet ein stabiles Plugin-System (u. a. OS-Keychain-Zugriff),
  mit dem `GG-DATA-003` ohne Eigenimplementierung umsetzbar ist.
- Deutlich geringerer Speicher- und Disk-Footprint als Electron —
  relevant fuer `GG-NFA-PERF-001`.
- Rust-Backend passt zum hexagonalen Schnitt (`GG-ARCH-002` bis
  `GG-ARCH-006`); Tauri-Commands bleiben duenne Driving-Adapter
  (`GG-ARCH-004`).

Negativ:

- Plattformuebergreifende UI-Tests sind aufwendiger als bei Electron, da
  die WebView je Plattform unterschiedlich ist. Fuer den MVP ist nur
  Linux Abnahmegegenstand, das mildert die Last.
- Tauri 2.x ist juenger als Electron; einzelne Plugins koennen
  API-Bruch zwischen Minor-Versionen haben. Patch-Versionen werden
  daher per Lockfile gepinnt.

Risiken:

- WebKitGTK-Probleme (DRM-Cache, NVIDIA-Treiber) koennen unter Linux
  einzelne Nutzer treffen. Dokumentierte Workarounds werden in der
  Benutzerdokumentation gepflegt; sie blockieren die MVP-Abnahme
  nicht.

---

## 4. Alternativen

- **Electron**: groesstes Ecosystem, aber 100-200 MB Bundle und
  permanenter Chromium-Prozess — kollidiert mit `GG-NFA-PERF-001` und
  dem Anspruch eines schlanken lokalen Tools.
- **Native GTK/Qt (Rust)**: bestmoegliche Integration, aber hoher
  UI-Entwicklungsaufwand und keine direkte Wiederverwendung von
  SvelteKit (`GG-DEC-004`).
- **Wails**: vergleichbares Konzept wie Tauri, aber Go-Backend ist
  zusaetzliche Sprache neben der ohnehin gesetzten Web-Toolchain;
  keine Vorteile gegenueber Tauri.

---

## 5. Nicht Gegenstand dieser ADR

- Wahl der konkreten Tauri-Plugins (separate ADR bei Bedarf).
- macOS-/Windows-Paketierung (sekundaer, `GG-PE-003`).
- Updater- und Signaturmechanismus (`GG-NFA-INSTALL-002`,
  `GG-NFA-INSTALL-003` sind V1).
