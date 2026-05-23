# Trigger 017 — `coverage-critical`-Implementierung weicht von ADR 0004 §2.4 ab

**Status:** open
**Eroeffnet:** 2026-05-23
**Ablaufdatum:** Naechster ADR-Sweep (V1-Vorbereitung); spaetestens
sobald `cargo-llvm-cov` ein File-Include-Pattern unterstuetzt.
**Bezug:** [ADR 0004 §2.4](../../adr/0004-quality-gates-and-coverage-tooling.md);
[ADR 0001 §2.3](../../adr/0001-documentation-and-planning-structure.md)
(Immutability von Accepted-Texten);
`tools/coverage-critical.sh`; `Makefile` Target
`coverage-critical`.

---

## Beobachtung

ADR 0004 §2.4 schreibt fuer `GG-NFA-COV-002` woertlich:

> "Separates Target `make coverage-critical`: laeuft `cargo
> llvm-cov` nur auf den in `GG-NFA-COV-002` genannten Modulen mit
> `--fail-under-lines 90`."

Die in M2-W2 (Commit `9f9db52`) gelieferte Implementierung
folgt **nicht** dieser Wortwahl: statt einem direkten
`cargo llvm-cov`-Aufruf mit File-Include-Pattern liest
`tools/coverage-critical.sh` den vollstaendigen LCOV-Output von
`coverage-rust` und parst ihn mit awk pro Datei. Der Effekt ist
identisch (kritische Pfade werden gegen 90 %-Lines gegated), die
Mechanik aber abweichend.

Hintergrund der Abweichung: `cargo-llvm-cov 0.8.7` hat **kein**
`--include-source-pattern`-Flag (nur `--ignore-filename-regex`,
also Exclude). Eine direkte Umsetzung der ADR-Wortwahl haette
einen Inverse-Regex erfordert (`.*` matchen, dann die kritischen
Pfade exkludieren); Rust-`regex` unterstuetzt aber kein
Lookaround. Ein post-hoc LCOV-Filter ist die zugaenglichste
Variante und wird auch von externen Tools wie `lcov-summary`
nutzbar.

ADR 0004 ist seit M1-W7 `Accepted` und damit per ADR 0001 §2.3
textlich immutable. Implementierungs-Abweichungen muessen daher
entweder als Folge-ADR-Schaerfung oder als offener Trigger
sichtbar bleiben (vgl. Praezedenzfall
[Trigger 013](013-rust-bootstrap-coverage-exception.md), der die
`main.rs`-Coverage-Exclude-Abweichung dokumentiert).

## Trigger / Aktivierungsbedingung

Der Eintrag wandert nach `next/`, sobald **eine** der folgenden
Bedingungen eintritt:

- `cargo-llvm-cov` bekommt ein `--include-source-pattern` /
  `--only-files-matching` o.ae.-Flag, das Inverse-Regex
  ueberfluessig macht.
- Ein V1-Slice fuer Coverage-Tooling-Reife wandert nach
  `in-progress/` und ueberprueft die Gesamt-Coverage-Mechanik
  (gemeinsam mit `GG-NFA-COV-003` Branch-Coverage-Uplift).
- Eine Folge-ADR ("ADR 0006 — Coverage-Critical via LCOV-Filter")
  wird erforderlich, weil eine weitere Mechanik-Abweichung
  hinzukommt (z. B. Branch-Coverage-Gate per `lcov_branch_*` etc).

## Zu klaeren beim Aufloesen

- Folge-ADR oder Folge-Aenderung in ADR 0004? Bei einer
  Folge-ADR muss `docs/plan/adr/README.md` die Schaerfungs-Spalte
  auf 0004 mit dem Verweis fuellen.
- Bleibt der awk-Filter, oder wird auf `cargo llvm-cov` mit
  File-Include umgestellt (falls upstream verfuegbar)?
- Soll die PATTERN-Liste in `coverage-critical.sh` formell aus
  der `architecture.md` `AC-002`-Definition gespeist werden, statt
  im Skript fest verdrahtet?

## Akzeptanzkriterien Erst-Auswurf

- ADR-Stand und Implementierungs-Stand sind konsistent
  (entweder Schaerfung registriert oder Implementierung
  angepasst).
- Dieser Trigger wandert nach `done/` mit Verweis auf den
  Aufloesungs-Commit.
