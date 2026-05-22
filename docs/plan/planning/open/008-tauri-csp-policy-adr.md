# Trigger 008 — ADR fuer Tauri-CSP-Policy

**Status:** open
**Eroeffnet:** 2026-05-22
**Bezug:** [Review-Finding L4 (M1-W4)](../in-progress/M1-Slice-Plan.md);
`src-tauri/tauri.conf.json`;
[Lastenheft](../../../../spec/lastenheft.md) (`GG-NFA-SEC-001`,
`GG-NFA-SEC-002`).

---

## Beobachtung

`tauri.conf.json` setzt aktuell `app.security.csp = null` — das
deaktiviert die Content-Security-Policy fuer den eingebetteten
WebView vollstaendig. Fuer das M1-Skelett ist das akzeptabel
(keine fremden Inhalte, kein externes Embedding), aber spaetestens
mit M3 (Dokumentimport) oder M5 (Feldextraktion mit
PDF-Reader-Outputs) muss die CSP-Policy verbindlich entschieden
werden, um `GG-NFA-SEC-001` und `GG-NFA-SEC-002` einzuhalten.

## Trigger / Aktivierungsbedingung

Der Eintrag wandert nach `next/`, sobald **eine** der folgenden
Bedingungen eintritt:

- M3 (Projekt-Lifecycle und Persistenz) beginnt — sobald Inhalte
  aus geladenen Dokumenten in den WebView fliessen.
- Ein Plugin mit Netzzugriff (optionaler LLM-Adapter, MaStR-
  Validierung) wird verdrahtet.
- Penetrationstest-Vorbereitung vor V1-Release.

## Zu klaeren

- Welche Quellen sind erlaubt? Default-Empfehlung: `'self'` plus
  `tauri:` und `tauri-localhost:`-Schema.
- Wie wird die Policy je Window granuliert (Tauri-2.x-Capabilities-
  System ergaenzt CSP)?
- Sind Inline-Scripts/Styles fuer SvelteKit-Hydration erforderlich,
  und wenn ja: `nonce`-basierte Loesung oder `'unsafe-inline'`-
  Trade-off?
- CSP-Reporting (Report-Only-Mode in Entwicklung, Enforce in
  Production) — Setup-Konvention.
- Verhaeltnis zur Capabilities-ADR (Trigger 009).
