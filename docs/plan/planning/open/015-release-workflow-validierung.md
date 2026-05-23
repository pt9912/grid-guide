# Trigger 015 — Release-Workflow operativ validieren (V1)

**Status:** open
**Eroeffnet:** 2026-05-23
**Ablaufdatum:** V1-Release-Vorbereitung (kein fixes Datum; siehe
Trigger).
**Bezug:** [ADR 0005 §4.2](../../adr/0005-ci-release-tauri-action.md);
Lastenheft `GG-NFA-CICD-003`, `GG-NFA-CICD-004`,
`GG-NFA-INSTALL-002`; `.github/workflows/release.yml`.

---

## Beobachtung

ADR 0005 wurde in M1-Welle 7 von `Provisional` auf `Accepted`
gehoben. Der MVP-Accept-Vertrag (§4.1) ist erfuellt:
`gates.yml` laeuft auf allen drei Plattformen, der Linux-Job ist
gruen, `release.yml` existiert als `workflow_dispatch`-/Tag-Stub
mit SHA-gepinnter `tauri-action` und parst sauber.

Die operative Validierung des Release-Workflows (§4.2 der ADR)
ist **nicht** Teil des MVP — sie verlangt einen echten
Release-Tag, Signing-Secret-Operationen und einen Fork-PR. Diese
Voraussetzungen liegen explizit in V1
(`GG-NFA-INSTALL-002` signierte Bundles,
`GG-NFA-CICD-003` Release-Pipeline,
`GG-NFA-CICD-004` Secret-Handling).

## Trigger / Aktivierungsbedingung

Der Eintrag wandert nach `next/`, sobald **eine** der folgenden
Bedingungen eintritt:

- Ein V1-Slice (z. B. `V1-release-pipeline`) wandert nach
  `in-progress/` und referenziert diesen Trigger.
- Ein erster echter Release-Tag (`v0.x.0` oder spaeter) wird in
  Betracht gezogen — dann muss der Stub vor dem Tag-Push
  operativ validiert sein.
- Apple-Developer-Account oder Authenticode-Zertifikat werden
  beschafft (`GG-NFA-INSTALL-002`); die Signing-Secret-Pipeline
  ist Voraussetzung fuer beide.

## Zu erfuellende Items (gemaess ADR 0005 §4.2)

1. **Demo-Tag-Lauf**: Ein Tag wie `v0.0.1-test` loest
   `release.yml` aus; das Workflow erzeugt einen Release-Entwurf
   mit drei Bundles (`.AppImage` + `.deb` fuer Linux, `.dmg` fuer
   macOS, `.msi` fuer Windows). Im MVP duerfen die Bundles
   unsigniert sein.
2. **Secret-Masking-Demo**: Ein bewusst hinzugefuegtes
   Test-Secret in den Workflow-Inputs erscheint im Log
   ausschliesslich als `***`, nicht als Klartext.
3. **Fork-PR-Verhalten**: Ein PR aus einem Fork laeuft
   `gates.yml` durch und meldet sichtbar, dass Signing-Secrets
   nicht verfuegbar sind — kein Workflow-Abbruch aus diesem
   Grund.

## Akzeptanzkriterien Erst-Auswurf

- Alle drei Items aus §4.2 von ADR 0005 sind im
  Workflow-Run-Log nachweisbar (Run-URLs in der
  Closure-Notiz).
- `release.yml` ist nach dem Demo-Tag-Lauf optional von
  `workflow_dispatch`/`tag` auf den finalen Release-Trigger
  umgestellt (Detail-Entscheidung im V1-Slice).
- Dieser Trigger wandert nach `done/` mit Verweis auf den
  V1-Slice, der die Validierung vollzogen hat.
