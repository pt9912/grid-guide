# Trigger 013 — Rust-Bootstrap aus Coverage-Messung (Ausnahme)

**Status:** open
**Eroeffnet:** 2026-05-23
**Bezug:** [Lastenheft GG-NFA-COV-004 Teil 2](../../../../spec/lastenheft.md);
[ADR 0004 §2.4](../../adr/0004-quality-gates-and-coverage-tooling.md);
`Makefile` Target `coverage-rust`; `src-tauri/src/main.rs`.

---

## Beobachtung

`Makefile coverage-rust` schliesst `src/main.rs` per
`--ignore-filename-regex 'src/main\.rs$'` aus der Coverage-Messung
aus. Die Begruendung steht im Makefile-Kommentar:

> src/main.rs ist nur der Wry-Bootstrap (drei Zeilen) und kann ohne
> echtes Display nicht gecovert werden; die testbare Logik liegt in
> src/lib.rs

`src/main.rs` enthaelt aktuell ausschliesslich
`gridguide_lib::run().expect(...)`; `src/lib.rs::run()` ruft am Ende
`tauri::Builder::default().build(generate_context!()).run(...)` —
diese letzte Zeile startet den realen Wry-Event-Loop und ist ohne
GUI-Umgebung nicht ausfuehrbar. `configure()` (alles davor) ist via
`tauri::test::mock_builder` + `mock_context` korrekt abgedeckt
(siehe `lib.rs` Test `configure_baut_app_mit_invoke_handler`).

**Konflikt mit Lastenheft:** GG-NFA-COV-004 Teil 2 listet
„Boilerplate, Konfigurations- oder Wiring-Code" explizit als
**nicht** excludable. `src/main.rs` ist per Definition Wiring-Code.
ADR 0004 §2.4 verlangt zusaetzlich, dass Excludes „im jeweiligen
Konfig-File mit einzeiliger Begruendung kommentiert" sind; aktuell
steht die Begruendung im `Makefile`, nicht in einem
Coverage-Konfig-File.

## Trigger / Aktivierungsbedingung

Der Eintrag wandert nach `next/`, sobald **eine** der folgenden
Bedingungen eintritt:

- **Tauri Mock-Runtime kann `app.run()` synchron beenden.** Aktuell
  liefert `tauri::test::mock_runtime` ein `App<MockRuntime>`, dessen
  `.run(callback)`-Aufruf jedoch in den Event-Loop geht.
  Sobald die Mock-Runtime eine Variante anbietet, die nach einem
  konfigurierbaren Initial-Event ohne weitere Pumpen-Schleife
  beendet, ist der Bootstrap synthetisch testbar.
- **Headless-Display-Backend** (xvfb/wayfire/weston-mock) wird in
  der Test-Pipeline verfuegbar; dann kann `make coverage-rust` den
  echten Wry-Loop in einer Headless-Umgebung starten und die
  Bootstrap-Zeilen werden organisch erreicht.
- **Lastenheft-Bump:** GG-NFA-COV-004 Teil 2 wird formell um einen
  Carve-Out fuer „Plattform-Bootstrap-Code, dessen Run-Eintritt
  ausschliesslich in eine fremde Event-Loop fuehrt" erweitert.
  Dann ist der aktuelle Exclude regelkonform.

## Zu klaeren beim Aufloesen

- Ist `tauri::test::mock_runtime` in einer kommenden Tauri-2.x-
  Minor reif genug, dass `run()` und damit `main.rs` mit-getestet
  werden koennen?
- Falls die Test-Pipeline einen Headless-Display-Stack bekommt:
  passt der in den `container-gates`-Container, oder waere das ein
  separater `coverage-rust-headless`-Job?
- Sollen wir den Exclude vor der Aufloesung in eine
  `cargo-llvm-cov.toml` (oder `.config/coverage.toml`) verschieben,
  um ADR 0004 §2.4 formell zu erfuellen — auch wenn der Inhalt
  unveraendert bleibt?

## Akzeptanzkriterien Erst-Auswurf

- `Makefile coverage-rust` enthaelt **keinen**
  `--ignore-filename-regex`-Eintrag mehr, oder dieser steht in
  einem Coverage-Konfig-File mit Verweis auf den abloesenden ADR /
  Slice.
- `cargo llvm-cov` rapportiert `src/main.rs` mit messbarer Coverage
  (entweder durch Mock-Runtime-Test oder Headless-Display-Run).
- Dieser Trigger wandert nach `done/` mit Verweis auf den ADR /
  Slice, der die Aufloesung bewirkt hat.
