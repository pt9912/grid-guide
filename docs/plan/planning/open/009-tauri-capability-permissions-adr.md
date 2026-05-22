# Trigger 009 — ADR fuer Tauri-Capability-Permissions

**Status:** open
**Eroeffnet:** 2026-05-22
**Bezug:** [Review-Finding L9 (M1-W4)](../in-progress/M1-Slice-Plan.md);
`src-tauri/capabilities/default.json`;
[Lastenheft](../../../../spec/lastenheft.md) (`GG-NFA-SEC-001`,
`GG-PRINC-005` Kleine Schnittstellen, `GG-DATA-003`).

---

## Beobachtung

`src-tauri/capabilities/default.json` haengt am M1-Skelett mit der
Permission `core:default`. Das ist die breitest mögliche Tauri-2.x-
Core-Permission-Surface und umfasst Window-, Event-, Path-
Permissions. Fuer M1 ok, weil die App keinen ausgehenden Filesystem-
/Netzwerk-/Shell-Zugriff hat. Sobald Adapter (M3 Persistenz, M5
PDF-Reader, optional LLM/MaStR-HTTP) dazukommen, ist `core:default`
zu weit gefasst und verletzt das ISP-Prinzip aus `GG-PRINC-005`.

## Trigger / Aktivierungsbedingung

Der Eintrag wandert nach `next/`, sobald **eine** der folgenden
Bedingungen eintritt:

- M3 (Projekt-Lifecycle) beginnt — Dateisystem-Zugriff via
  `fs:allow-*`-Permissions.
- Ein Plugin mit Netz-/Shell-Zugriff wird verdrahtet
  (z. B. `http:` fuer optionalen LLM-Adapter, `shell:` fuer
  externes Tooling).
- `GG-DATA-003` (OS-Secret-Store) wird mit `tauri-plugin-stronghold`
  o. ae. konkret umgesetzt.

## Zu klaeren

- Pro Adapter ein eigenes Capability-File oder pro Window/Use-Case?
- Default-Pfad-Allow-Liste fuer Projekt-Verzeichnis vs. dynamischer
  User-Auswahl-Dialog.
- Tauri-2.x-Capabilities-File-Layout
  (`capabilities/<name>.json` mit `windows`/`permissions`).
- Granularitaet der Permissions: `fs:allow-read-text-file` vs.
  weitere?
- Verhaeltnis zur CSP-ADR (Trigger 008) — beide regeln
  Sicherheitseigenschaften des WebViews.
- Test-Strategie fuer Capability-Drift (Snapshot-Tests gegen
  `gen/schemas/desktop-schema.json`?).
