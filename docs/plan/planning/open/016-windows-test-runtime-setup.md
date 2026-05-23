# Trigger 016 — Windows-Test-Runtime fuer make gates

**Status:** open
**Eroeffnet:** 2026-05-23
**Ablaufdatum:** keine harte Frist; aktiviert sich, sobald
Windows als Best-Effort nicht mehr ausreichend ist (siehe Trigger).
**Bezug:** [ADR 0005 §2.3](../../adr/0005-ci-release-tauri-action.md);
Lastenheft `GG-NFA-CICD-002` (Windows = Best-Effort im MVP);
`.github/workflows/gates.yml`.

---

## Beobachtung

`make gates` auf dem Windows-Runner (`windows-latest`) scheitert
in M1-W6 mit `STATUS_ENTRYPOINT_NOT_FOUND` (`0xc0000139`) beim
Start der Rust-Test-Binary `gridguide_lib-*.exe`. Symptom-Pfad:

```
error: test failed, to rerun pass `--lib`
process didn't exit successfully: ... (exit code: 0xc0000139,
STATUS_ENTRYPOINT_NOT_FOUND)
make: *** [Makefile:166: coverage-rust] Error 1
```

Hintergrund: Die Test-Binary linkt gegen die volle Tauri-2.x-
Windows-Toolchain (`webview2-com`, WebView2-Runtime-Bridge).
Bereits beim Programmstart sucht Windows die zugehoerigen DLLs
und meldet den Fehler, **bevor** ein einziger Test ausgefuehrt
wird. Der `configure_baut_app_mit_invoke_handler`-Test nutzt zwar
die Mock-Runtime aus `tauri::test`, das Linken passiert aber
unabhaengig davon.

Linux und macOS sind durchgehend gruen (Mock-Runtime laeuft
sauber). Windows ist gemaess ADR 0005 §2.3 Best-Effort; M1-DoD
ist mit gruenen Linux+macOS-Jobs erfuellt.

## Trigger / Aktivierungsbedingung

Der Eintrag wandert nach `next/`, sobald **eine** der folgenden
Bedingungen eintritt:

- Windows wird in einer kuenftigen Welle von Best-Effort auf
  Pflicht hochgestuft (z. B. fuer den V1-Release-Pfad, vgl.
  Trigger 015).
- Ein Beitragender will lokal Windows entwickeln und braucht
  einen lauffaehigen `make gates`-Pfad dort.
- Tauri 2.x veroeffentlicht eine offizielle Anleitung oder
  Anpassung, die das `0xc0000139`-Problem auf Standard-Runner
  ohne WebView2-Vorinstallation aufloest.

## Vermutete Aufloesungs-Pfade

Reihenfolge nach Aufwand:

1. **`webview2-loader.dll` neben die Test-EXE legen**:
   tauri-cli/tauri-build kopiert diese DLL in den Bundle-Pfad,
   nicht in `target/llvm-cov-target/.../deps/`. Ein
   Pre-Test-Schritt im Workflow koennte sie dorthin spiegeln.
2. **`Microsoft.WebView2`-Runtime via `winget` installieren**:
   `winget install --id Microsoft.EdgeWebView2Runtime` im
   Windows-Step von `gates.yml`. Nicht garantiert ausreichend
   (Runtime ist meist schon installiert, das Problem ist die
   loader-DLL).
3. **`cfg(not(target_os="windows"))` am Mock-App-Test**:
   schneller, kosmetischer Fix. Vermeidet die DLL-Suche, aber
   reduziert die effektive Rust-Coverage auf Windows.
4. **`xtask`-Skript**, das WebView2-DLLs in das `cargo
   llvm-cov`-Profil-Verzeichnis kopiert; Aufruf vor `cargo
   llvm-cov`.

## Akzeptanzkriterien Erst-Auswurf

- `gates (windows)` im GitHub-Actions-Workflow ist gruen.
- Coverage-Werte fuer Windows liegen in den Workflow-Artefakten
  bei oder ueber dem Linux-Stand (Schwelle 80 % Lines).
- Dieser Trigger wandert nach `done/` mit Verweis auf die
  Aufloesungs-Variante (1-4) und den zugehoerigen Commit.
