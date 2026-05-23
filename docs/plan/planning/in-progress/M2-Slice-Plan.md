# M2-Slice-Plan — Domain-Kern und Katalog-Seed

**Status:** In Progress (aktiviert 2026-05-23 mit Welle 0;
Wellen 0/1/2 abgeschlossen; Welle 3 Westnetz-Seed steht aus).
**Eroeffnet:** 2026-05-23
**Aktiviert:** 2026-05-23
**Bezug:** [Roadmap M2](roadmap.md#m2--domain-kern-und-katalog-seed);
[ADR 0001](../../adr/0001-documentation-and-planning-structure.md);
[`spec/architecture.md`](../../../../spec/architecture.md) §3 (`GG-AR-COMP-001` Catalog,
`GG-AR-COMP-002` Project);
[Lastenheft](../../../../spec/lastenheft.md) v0.4.0.

---

## 1. Ziel

Domain-Datenmodell und Seed-Daten im hexagonalen Kern aufbauen,
ohne Use-Cases oder Adapter (die folgen in M3+). Ergebnis ist
eine in-Memory-Wissensbasis, deren Domain-Strukturen vollständig als
unveraenderliche Rust-Strukturen vorliegen. `Catalog` wird als
Aggregate aus den Seed-Daten aufgebaut und enthaelt initial das erste
Profil (Westnetz) sowie den ersten Falltyp (`PV_NS_OhneSpeicher`).

`Project` als Domain-Entitaet kommt mit M2 als reine
Datenstruktur (kein Persistenz-Verhalten — das ist M3). Damit ist
das M2-Ergebnis allein lauffaehig (in Tests), aber noch nicht
nutzbar.

---

## 2. Vorbedingungen

Aus [M1-Closure](../done/M1-Slice-Plan-results.md) geschlossen:

- `make gates` lauft gruen (Container + CI).
- `tools/arch-check.sh` durchsetzt `GG-AR-TABU-001..003`.
- ADR 0004 + 0005 sind `Accepted`.
- `spec/architecture.md` enthaelt das Skelett mit
  `GG-AR-COMP-*`-Stubs.

Offen, **muessen vor M2-Aktivierung adressiert werden**:

- Trigger 006 (Dependabot/Renovate-ADR) bleibt offen, aber im
  M2-Aktivierungs-Moment muss eine Statusbestimmung vorgenommen
  werden (Aktiviert? Weiter deferred?).

Offen, **werden in M2 geschlossen**:

- Coverage-Critical-Schwelle aus GG-NFA-COV-002 (90 %) wird
  erstmals nicht-trivial: in M1 war `coverage-critical` ein
  NO-OP, weil `hexagon/core/` leer war.
- Erste Reifeprobe fuer `GG-AR-TABU-001..003` an echtem
  Domain-Code (nicht nur Stubs).

Offen, **werden in M2 NICHT geschlossen** (nur dokumentiert):

- Trigger 002 (Datei-Schema-ADR) wandert mit M3-Aktivierung nach
  `next/`. M2 nutzt In-Memory-Seed; persistente Form ist M3.

---

## 3. Wellen

M2 ist in sechs Wellen aufgeteilt; jede Welle endet mit einem
gruenen `make gates`. Reihenfolge ist bewusst:
Vokabulare → Strukturen → Seed → Falltyp → Closure.

### Welle 0 — Slice-Aktivierung

- **Lieferziel:** Plan wandert nach `in-progress/`, Roadmap M2
  wird auf `In Progress` gesetzt, Trigger 006 wird auf
  `next/` oder weiter `open/` entschieden.
- **DoD:**
  - [ ] `docs/plan/planning/in-progress/M2-Slice-Plan.md`.
  - [ ] Roadmap §3 M2-Status auf `In Progress` mit aktivierungs-
        Datum.
  - [ ] Trigger 006 explizit gepruefft (entweder in M2-W0
        aktiviert oder mit neuem Trigger-Hinweis offen
        gelassen).

### Welle 1 — Vokabular-Enums (`GG-DATA-004`)

- **Lieferziel:** alle neun Vokabulare als Rust-Enums in
  `src-tauri/src/hexagon/core/vocab/`. Strikt `#[derive(Debug, Clone,
  Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]`.
- **Enums:** `Profiltyp`, `Quellkatalog`, `Zugangsart`,
  `Nachnutzungsstatus`, `Katalogstatus`, `Anlagenart`,
  `Falltyp`, `Dokumenttyp`, `XlsxZweck`.
- **Lastenheft-IDs:** `GG-DATA-004`, `GG-CC-007` (Immutable).
- **DoD:**
  - [ ] Neun Enums mit allen Varianten gemaess Lastenheft.
  - [ ] Pro Enum mindestens ein Round-Trip-Test
        (`serde_json`-Parse + Re-Emit).
  - [ ] `cargo clippy --all-targets --locked -- -D warnings`
        gruen ohne `allow`-Eintraege auf den neuen Modulen.
  - [ ] Rust-Coverage auf den Enum-Modulen ≥ 80 %
        (`GG-NFA-COV-001`).

### Welle 2 — Domain-Strukturen

- **Lieferziel:** immutable Strukturen unter
  `hexagon/core/domain/`:
  - `Profile`, `Profilversion` (kritisch — 90 %-Schwelle).
  - `Falltyp` (kritisch).
  - `Project`, `Document`, `Warning`.
  Alle als `#[derive(Debug, Clone, PartialEq, Eq, Serialize,
  Deserialize)]`, keine `pub`-Felder mit Mutation; Builder-/
  Konstruktorfunktionen geben `Result<Self, ValidationError>`
  zurueck.
- **Lastenheft-IDs:** `GG-DATA-001` bis `GG-DATA-005`,
  `GG-MVP-002`, `GG-CC-007`.
- **DoD:**
  - [ ] Strukturen mit dokumentierten Pflichtfeldern und
        Invarianten.
  - [ ] Konstruktoren validieren am Bau (`new`/`try_new`).
  - [ ] Profile-/Profilversionsmodule erreichen ≥ 90 % Lines
        (`GG-NFA-COV-002`), restliche Module ≥ 80 %.
  - [ ] `make coverage-critical` ist kein NO-OP mehr und
        prueft die 90 %-Schwelle auf den als kritisch
        deklarierten Pfaden.

### Welle 3 — Westnetz-Seed (`GG-DEC-001`)

- **Lieferziel:** das Westnetz-Profil als Seed-Datensatz unter
  `hexagon/core/seed/westnetz.rs` (Rust-Konstante mit
  `Profile::try_new`-Aufruf) plus Smoke-Test, der den Seed laedt
  und gegen `Profile`-Invarianten prueft. Das Modul liefert einen
  gueltigen `Profile`-Seed, der in den M2-`Catalog`-Aufbau
  integriert wird. Persistente Datei-Form ist M3 — hier ausschliesslich
  In-Memory.
- **Lastenheft-IDs:** `GG-DEC-001`, `GG-FA-CAT-003`,
  `GG-FA-CAT-006`, `GG-FA-CAT-007`.
- **DoD:**
- [ ] Seed-Funktion fuer Westnetz liefert ein gueltiges
      `Profile` zurueck.
  - [ ] Test belegt: Profiltyp = Netzbetreiber, Quellkatalog =
        Westnetz, Nachnutzungsstatus dokumentiert, Anlagenart-
        Liste enthaelt mindestens `PV_NS_OhneSpeicher`-
        Voraussetzung.
  - [ ] Seed-Modul ≥ 80 % Coverage (keine kritische 90 %-
        Anforderung, da Boilerplate-Konstanten).

### Welle 4 — Falltyp `PV_NS_OhneSpeicher` (`GG-DEC-002`)

- **Lieferziel:** der erste MVP-Falltyp als Datenstruktur unter
  `hexagon/core/seed/pv_ns_ohne_speicher.rs`, mit
  Pflichtfeld-Liste und Pflichtunterlagen-Liste gemaess
  Westnetz-Katalog.
- **Lastenheft-IDs:** `GG-DEC-002`, `GG-MVP-003`, `GG-FA-CAT-006`.
- **DoD:**
- [ ] `seed_pv_ns_ohne_speicher()` liefert ein
      gueltiges `Falltyp`-Objekt.
  - [ ] Pflichtfelder und Pflichtunterlagen sind als Vec/Set
        mit Enum-Werten hinterlegt — keine String-Listen.
  - [ ] Cross-Check-Test: `Falltyp::pflichtdokumente` ueberlappt
        mit `Profile::erlaubte_dokumenttypen`.
  - [ ] Falltyp-Modul erreicht ≥ 90 % Lines (kritisch).

### Welle 5 — Closure und Vorbereitung M3

- **Lieferziel:** Coverage-Critical-Schwelle 90 % ist
  durchgesetzt, M2-DoD ist gruen, Closure-Notiz verfasst, ggf.
  Triggers 002 (Datei-Schema-ADR) und 003 (Regel-Repraesentation)
  nach `next/` verschoben, weil M3 ihre Aktivierung erfordert.
- **DoD:**
  - [ ] `make gates` gruen ohne Coverage-Excludes ausserhalb der
        in M1 etablierten Liste.
  - [ ] `done/M2-Slice-Plan-results.md` mit Welle-Tabelle.
  - [ ] Roadmap §3 M2-Status auf `Done`.
  - [ ] `done/M2-Slice-Plan.md` (verschoben aus `in-progress/`).
  - [ ] Triggers 002 und 003 nach `next/` (sofern M3 bald folgt;
        sonst bleiben sie offen).

---

## 4. Akzeptanz (Slice-Ebene)

Deckungsgleich mit der Roadmap-M2-DoD. Zusaetzlich Slice-
spezifisch:

- Jede Welle hat genau einen Welle-Anker-Commit (M1-Konvention
  aus AGENTS.md).
- Coverage-Schwellen werden in M2 **nicht abgesenkt**, um sie zu
  erreichen (`GG-NFA-COV-004` Teil 1); jede neue Domain-Klasse
  bekommt ihre eigenen Tests.

---

## 5. Offene Punkte und Risiken

| Item                                       | Wirkung                                                                          | Mitigation                                                            |
| ------------------------------------------ | -------------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| Vokabular-Variantenliste unklar bei XlsxZweck | Welle 1 stockt, Falltyp-DoD nicht abnehmbar                                       | Lastenheft `GG-DATA-004` zitieren, Liste 1:1 uebernehmen              |
| Westnetz-Seed-Inhalt nicht kuratiert       | Welle 3 baut Stub-Seed ohne Faktentreue                                          | `docs/catalogs/Katalog-pdf.md` und `Katalog-xlsx.md` als Quelle      |
| Falltyp-Pflichtdokumente-Abdeckung         | Welle 4 schreibt Wunschliste statt Katalog-Stand                                 | Quellverweis im Code-Kommentar; Trigger fuer Audit nach M3-Persistenz |
| Coverage-Critical-Regex unklar             | `coverage-critical` blockiert oder unterscheidet nicht                           | Welle 0 oder W2 definiert den Pfad-Filter; ADR-Schaerfung 0004 §2.4   |
| Trigger 002 (Datei-Schema) blockiert M3    | nicht M2-relevant, aber M3 muss Trigger 002 vor Start aktivieren                 | In W5-Closure als Vorbedingung fuer M3 notieren                       |

---

## 6. Anti-Scope

Folgendes ist explizit **nicht** Teil von M2 — Verschiebung in
spaetere Slices:

- Persistenz (Lese/Schreib-Adapter) — M3.
- Use-Cases (Project anlegen/oeffnen/speichern) — M3.
- Validierungs-Engine (Pflichtfeld-Checks gegen ein konkretes
  Projekt) — M4.
- UI-Bindung (Tauri-Commands fuer Catalog/Profile) — M5 oder M6.
- LLM-/OCR-Adapter — V1.
