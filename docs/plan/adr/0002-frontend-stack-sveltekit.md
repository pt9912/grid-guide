# ADR 0002 — Frontend-Stack: SvelteKit 2.x (SPA)

**Status:** Accepted
**Datum:** 2026-05-22
**Letzte inhaltliche Aenderung:** 2026-05-22 — SOLID-Bezug ergaenzt;
parallel zur Aufnahme von `GG-PRINC-*` und `GG-CC-*` in Lastenheft
v0.4.0 (kein Wechsel der Entscheidung, nur Verbindungspunkte zu den
neuen Anforderungen sichtbar gemacht).
**Bezug:** [ADR 0001](0001-documentation-and-planning-structure.md),
[Lastenheft](../../../spec/lastenheft.md) (`GG-ARCH-008`,
`GG-DEC-004`, `GG-NFA-A11Y-001`, `GG-NFA-I18N-001`,
`GG-NFA-MAINT-001`, `GG-PRINC-002`, `GG-PRINC-003`, `GG-PRINC-005`,
`GG-CC-001`, `GG-CC-007`)
**Aenderungstyp:** Greenfield-ADR. Schliesst die Mindestversion-Festlegung
fuer SvelteKit, die in Lastenheft v0.3.1 noch inline in `GG-ARCH-008`
stand und mit v0.3.2 bewusst in einen ADR ausgelagert wurde.

---

## 1. Kontext

Das Lastenheft fordert eine lokale Tauri-Desktop-App (`GG-MVP-001`,
`GG-ARCH-001`) und ueberlaesst dem ADR die Wahl des konkreten
Frontend-Frameworks innerhalb der Major-Linie. `GG-DEC-004` hat
SvelteKit als Frontend gesetzt; die Minor-Versionsfestlegung wurde mit
Lastenheft v0.3.2 aus `GG-ARCH-008` ausgelagert (per ADR 0001 §2).

Anforderungen, die das Frontend beruehren:

- `GG-MVP-001`, `GG-ARCH-001` (Tauri-App).
- `GG-NFA-A11Y-001` (Tastaturbedienbarkeit der MVP-Hauptansichten).
- `GG-NFA-I18N-001` (Deutsche UI, zentrale Textressourcen).
- `GG-NFA-MAINT-001` (Erweiterbarkeit ohne Aenderung am Kern).
- `GG-NFA-PERF-001` (Antwortzeiten auf Referenz-Desktop-Hardware).

Bewertete Optionen:

- SvelteKit 2.x im SPA-Modus (gewaehlt).
- React + Vite.
- SolidJS + Vite.
- Vanilla TypeScript ohne Framework.

---

## 2. Entscheidung

Das Frontend wird mit **SvelteKit 2.x** im **Single-Page-Modus** (kein
SSR, kein Adapter mit Node-Runtime) realisiert.

- Mindestversion: **SvelteKit 2.60** und **Svelte 5.x**.
- Konkrete Patch-Versionen werden in `package.json` und Lockfile
  festgelegt und sind nicht Bestandteil dieser ADR.
- Build erfolgt zu statischen Assets, die Tauri direkt ausliefert; es
  gibt zur Laufzeit keinen Node-Server.

---

## 3. Konsequenzen

Positiv:

- Sehr geringe Bundle-Groesse, schnelle Startzeit innerhalb von Tauri.
- Reaktivitaet (`$state`/`$derived` in Svelte 5) reduziert Boilerplate
  gegenueber React-basierten Stacks.
- Zentrale Textressource fuer Lokalisierung (`GG-NFA-I18N-001`) ist mit
  bestehenden Bibliotheken einfach umsetzbar.

Negativ:

- Kleinere Community und engerer Pool an UI-Komponentenbibliotheken als
  bei React.
- Svelte 5 ist relativ neu; Mustervorlagen aelterer Tutorials sind
  nicht ohne Anpassung uebertragbar.

Risiken:

- Wenn der SPA-Modus fuer einen Use-Case nicht ausreicht (z. B.
  Onboarding-Routen mit Praeloading), muss der Adapter ueberprueft
  werden; ein Wechsel auf einen anderen statischen Adapter ist
  moeglich, ohne den Stack zu verlassen.

Bezug zu SOLID (siehe `GG-PRINC-001..006`):

- **SRP (`GG-PRINC-002`)**: SvelteKit-Routen kapseln je einen
  fachlichen Use-Case (Projektuebersicht, Profilauswahl, Review,
  Export). Komponenten teilen Rendering und Interaktion entlang der
  Routen, nicht entlang technischer Layer; ein Use-Case-Wechsel
  beruehrt eine Route, nicht das gesamte UI.
- **OCP (`GG-PRINC-003`)**: Neue Falltypen oder Profile fuegen
  weitere Eintraege in den datengetriebenen Profilkatalog hinzu
  (siehe `GG-NFA-MAINT-001`); die Routen-/Komponentenstruktur muss
  dafuer nicht geaendert werden.
- **ISP (`GG-PRINC-005`)**: SvelteKit-Stores werden je Bounded
  Context (Catalog, Project, Validation, Submission, siehe
  `GG-ARCH-007`) getrennt gehalten; eine Komponente abonniert nur die
  Stores, die sie fachlich braucht.
- **Kurze Funktionen / Immutable (`GG-CC-001`, `GG-CC-007`)**:
  Svelte 5 `$state`/`$derived` und Stores erlauben kleinen,
  fokussierten Komponentencode mit klar lokalisierter Mutation.

---

## 4. Alternativen

- **React + Vite**: groesseres Ecosystem, aber groesseres Bundle und
  mehr Boilerplate, ohne klaren Vorteil unter `GG-NFA-PERF-001`.
- **SolidJS + Vite**: aehnliche Performance wie Svelte, aber kleinere
  Community und weniger reife Form-/Routing-Loesungen als SvelteKit.
- **Vanilla TypeScript**: minimale Abhaengigkeiten, aber zu viel
  Eigenbau-Aufwand fuer Forms und Routing im MVP-Zeitrahmen.

---

## 5. Nicht Gegenstand dieser ADR

- Wahl konkreter UI-Komponentenbibliotheken oder Designsystem.
- Test-Strategie fuer das Frontend (separate ADR bei Bedarf).
- Bundler-/Vite-Plugin-Auswahl jenseits der SvelteKit-Defaults.
