# Trigger 005 — ADR fuer Frontend-State-Management

**Status:** open
**Eroeffnet:** 2026-05-22
**Bezug:** [Roadmap M6](../in-progress/roadmap.md#m6--ui--und-tauri-integration);
[ADR 0002 §3](../../adr/0002-frontend-stack-sveltekit.md);
[Lastenheft](../../../../spec/lastenheft.md) (`GG-ARCH-007`,
`GG-PRINC-005`, `GG-MOD-008`, `GG-NFA-I18N-001`).

---

## Beobachtung

ADR 0002 §3 (SOLID-Bezug, ISP) sagt bereits, dass SvelteKit-Stores
je Bounded Context (Catalog, Project, Validation, Submission) getrennt
gefuehrt werden sollen. Konkrete Form ist offen:

- Svelte-5-Runes (`$state`/`$derived`) auf Modulebene,
- klassische Svelte-Stores (`writable`/`readable`/`derived`),
- externe Bibliothek (z. B. `nanostores`, `xstate` fuer
  Zustandsmaschinen).

Roadmap M6 erwartet die Entscheidung beim Slice-Start, weil sie das
gesamte UI-Layout praegt.

## Trigger / Aktivierungsbedingung

Der Eintrag wandert nach `next/`, sobald M6 in `in-progress/`
geht — oder frueher, sobald in M2/M3 erste Tauri-Commands
SvelteKit-Stores bedienen muessen (Project-Lifecycle-UI).

## Zu klaeren

- Pro Bounded Context ein Store oder Sub-Store-Hierarchie?
- Bridging Tauri-Commands ↔ Store: via `invoke(...)` direkt im Store
  oder ueber eine Service-Schicht?
- Optimistische Updates vs. Round-Trip nach Tauri (`GG-NFA-PERF-001`).
- Hot-Reload und Dev-Tools (Svelte-Inspector vs. eigenes Debug-UI).
- Verhaeltnis zur zentralen Textressource aus `GG-NFA-I18N-001`
  (sind Uebersetzungen Teil des Stores oder separat?).
- Persistenz von UI-Zustand (z. B. zuletzt geoeffnete Projekte) —
  Verhaeltnis zur Projekt-Datei-Persistenz aus Trigger 002.
