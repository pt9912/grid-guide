# Trigger 007 — ADR fuer E2E-Test-Stack

**Status:** open
**Eroeffnet:** 2026-05-22
**Bezug:** [ADR 0004 §6](../../adr/0004-quality-gates-and-coverage-tooling.md);
[Lastenheft](../../../../spec/lastenheft.md) (`GG-NFA-A11Y-001`,
`GG-NFA-QG-002`, `GG-NFA-CICD-002`).

---

## Beobachtung

Der MVP deckt `GG-NFA-A11Y-001` ueber ein manuelles
Tastatur-Testprotokoll je Hauptansicht ab. Volle WCAG 2.1 AA
(V1-Anspruch derselben Anforderung) braucht systematische
E2E-Tests fuer Tastaturbedienung, Screenreader-Beschriftung,
Kontraste und Fokus-Reihenfolge.

ADR 0004 §6 hat den E2E-Test-Stack bewusst ausgeklammert
(„Folge-ADR, sobald E2E-Anforderungen ueber `GG-NFA-A11Y-001`
hinaus aufkommen"). M6 (UI-Slice) wird zwar manuelle
Tastatur-Pruefungen liefern, aber kein automatisiertes E2E-Setup.

## Trigger / Aktivierungsbedingung

Der Eintrag wandert nach `next/`, sobald **eine** der folgenden
Bedingungen eintritt:

- V1-Planung von `GG-NFA-A11Y-001` startet (volle WCAG 2.1 AA).
- Ein UI-Slice nach M6 fuehrt einen Workflow ein, der manuell nicht
  mehr handhabbar ist (z. B. mehrstufige Wizards).
- Regressionsmeldungen aus dem manuellen MVP-Testprotokoll machen
  systematische Automatisierung erforderlich.

## Zu klaeren

- Test-Runner: Playwright vs. Cypress vs. WebdriverIO.
- **Tauri-Spezifik**: Tauri-Apps sind keine reinen Web-Apps;
  Tauri stellt einen `tauri-driver` (WebDriver-Protokoll) bereit.
  Wahl muss damit kompatibel sein (Playwright ueber Chrome-DevTools-
  Protokoll funktioniert nicht direkt mit Tauri/WebKitGTK).
- Accessibility-spezifisches Tooling: `axe-core`, `pa11y`,
  Lighthouse-Accessibility. Integration in den E2E-Runner.
- CI-Integration: nur Linux (`GG-NFA-CICD-002` MVP-Pflichtcheck)
  oder Matrix? `tauri-driver` ist plattformabhaengig.
- Headless-Faehigkeit: Tauri-Driver braucht einen Display-Server;
  in CI ueber `xvfb` o. ae.
- Verhaeltnis zum Quality-Gate (`GG-NFA-QG-002`): E2E-Lauf als
  separates Target `make e2e` oder Teil von `make gates`?
- Aufwand vs. Nutzen: E2E-Tests sind teurer als Unit-/Integration-
  Tests; muss eine Mindest-Coverage definiert werden?
