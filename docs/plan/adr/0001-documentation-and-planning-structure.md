# ADR 0001 — Dokumentations- und Planungsstruktur

**Status:** Accepted
**Datum:** 2026-05-22
**Bezug:** [Lastenheft](../../../spec/lastenheft.md)
**Aenderungstyp:** Greenfield-ADR. Fasst Dokumentationsstruktur und
ADR-Lifecycle in einer ADR zusammen, weil das Projekt keine
vorbelastete ADR-Historie hat. Das `grid-gym`-Schwesterprojekt
verteilt dieselben Inhalte auf zwei ADRs (`grid-gym` ADR 0001 und
ADR 0006); `grid-guide` zieht beide zusammen und uebernimmt direkt
die `grid-gym`-Konventionen.

---

## 1. Kontext

`GridGuide` startet in der Anforderungsphase. Neben dem Lastenheft
braucht das Projekt eine stabile Dokumentationsstruktur fuer:

- normative Spezifikation,
- Architekturentscheidungen,
- Roadmap und Umsetzungsslices,
- offene Folgearbeiten und Trigger-Watch-Punkte,
- anwender- und betreibernahe Erklaerungen,
- archivierte Skizzen.

Die Struktur soll klein genug fuer den Projektstart bleiben, aber
spaeter Meilensteine, weitere ADRs und Umsetzungsslices aufnehmen
koennen. Sie spiegelt bewusst die `grid-gym`-Struktur, damit Beitragende
zwischen beiden Projekten ohne Reibung wechseln koennen.

Lastenheft `GG-LESE-002` benennt fuer Anforderungen vom Typ `ARCH-*`
einen dokumentierten Architekturentscheid (ADR) als zulaessigen Beleg;
diese ADR legt fest, wo solche ADRs liegen und welchen Lebenszyklus sie
durchlaufen.

---

## 2. Entscheidung

### 2.1 Verzeichnisstruktur

| Pfad                                 | Zweck                                                                |
| ------------------------------------ | -------------------------------------------------------------------- |
| `spec/`                              | normative Produkt- und Architekturvorgaben (Lastenheft, ggf. weitere) |
| `docs/catalogs/`                     | Seed-Quellen fuer Profile (Katalog-PDF/XLSX-Notizen)                 |
| `docs/plan/adr/`                     | Architecture Decision Records                                        |
| `docs/plan/planning/open/`           | Trigger-Watch, offene Folgearbeiten, Vorabklaerungen                 |
| `docs/plan/planning/next/`           | konkret geplante, aber noch nicht aktive Arbeit (Scope-Skizze)       |
| `docs/plan/planning/in-progress/`    | aktive Roadmap, laufende Slice-Plaene                                |
| `docs/plan/planning/done/`           | abgeschlossene Plaene und Closure-Notizen                            |
| `docs/user/`                         | anwender- und betreibernahe Dokumentation, Runbooks                  |
| `docs/archive/`                      | verworfene oder historische Ideenskizzen                             |

ADR-Dateinamen folgen dem Schema `NNNN-kurz-titel.md` (vierstellige
Nummer, fortlaufend, nicht wiederverwendet).

Lebenszyklus eines Plan-Eintrags:
`open/` (Trigger entsteht) → `next/` (Scope skizziert) →
`in-progress/` (Slice aktiv) → `done/` (geliefert). Wird ein Eintrag
verworfen, wandert er nach `docs/archive/`.

### 2.2 ADR-Lifecycle

ADRs in `docs/plan/adr/` durchlaufen den folgenden Lebenszyklus:

| Status        | Bedeutung | Wirkung |
| ------------- | --------- | ------- |
| `Proposed`    | Empfehlung formuliert, **kein** Beschluss. Optionen und Bewertungskriterien sind dokumentiert. | Keine normative Wirkung. Abhaengige Dokumente duerfen hoechstens als Entwurf verweisen. |
| `Provisional` | Projektowner traegt die Empfehlung mit; ein begrenzter Validierungs-Spike laeuft, dessen Vertrag in der ADR steht. | Eingeschraenkte Wirkung. Abhaengige Dokumente duerfen auf den laufenden Spike verweisen, aber keine Lastenheft-Anforderung als geschlossen markieren. |
| `Accepted`    | Beschluss steht. Falls die ADR einen Validierungs-Spike enthielt, ist dieser nachweisbar abgeschlossen. | Volle Wirkung. Abhaengige Dokumente werden gepflegt; offene Punkte duerfen als geschlossen markiert werden. |
| `Rejected`    | ADR wird nach Review oder Owner-Entscheid bewusst nicht uebernommen. Negativentscheidung und Begruendung bleiben dauerhaft in der ADR. | Normative Schluss-Verweise werden entfernt; Folge-ADRs duerfen die Ablehnungsgruende referenzieren. |
| `Withdrawn`   | Autor oder Owner zieht den Vorschlag vor Beschluss zurueck. Keine Negativentscheidung. | Laufende Hinweis-Verweise werden entfernt; der Vorschlag bleibt historisch sichtbar, bindet aber nicht. |
| `Superseded`  | ADR war akzeptiert, ist aber durch eine spaetere ADR abgeloest. | Historisch. Abhaengige Dokumente verweisen auf die Nachfolge-ADR. |

Erlaubte Uebergaenge:

```text
                Proposed
                  │  │
        ┌─────────┘  └─────────┐
        ▼                      ▼
    Provisional             Rejected / Withdrawn
        │
        ├──▶ Accepted ──▶ Superseded
        │
        └──▶ Rejected / Withdrawn
```

`Provisional` ist optional. Eine ADR ohne Validierungsbedarf darf
direkt `Proposed → Accepted` springen.

### 2.3 Aenderungsregeln

Nach `Accepted` ist der Entscheidungstext immutable. Fachliche
Aenderungen kommen als neue ADR, die die bestehende ADR ersetzt oder
schaerft.

Zulaessig bleiben nur Metadaten-Aenderungen an der alten ADR:

- Statuswechsel auf `Superseded`,
- `Status geaendert am`,
- `Superseded by`,
- kurzer Hinweis im Header, dass die ADR historisch ist.

Keine zulaessige Metadaten-Aenderung sind neue Begruendungen, neue
Regeln, erweiterte Scope-Definitionen oder korrigierte Konsequenzen.
Solche Inhalte gehoeren in die Nachfolge-ADR.

### 2.4 Schaerfung ohne Supersedes

Eine spaetere ADR darf eine fruehere `Accepted`-ADR an einer
abgegrenzten Stelle praezisieren, ohne sie abzuloesen. Voraussetzungen:

- Die Folge-ADR benennt im Header `Aenderungstyp: Schaerfung von ADR
  NNNN §X.Y` und beschreibt nur die abgegrenzte Stelle.
- Der urspruengliche Entscheidungstext bleibt textlich unveraendert.
- Die "Schaerfungen"-Spalte in `docs/plan/adr/README.md` der **alten**
  ADR wird aktualisiert; die Folge-ADR ist verbindlich, der
  Original-Text historisch fuer die geschaerfte Stelle.

### 2.5 Header-Schema

Jede ADR fuehrt im Header:

- `Status`: Lifecycle-Status aus §2.2.
- `Datum`: Erstellungsdatum.
- `Bezug`: Verweise auf andere ADRs, Lastenheft, Spezifikationen.
- `Aenderungstyp` (optional): z. B. `Greenfield`, `Schaerfung von ADR
  NNNN §X`, `Supersedes ADR NNNN`.
- `Status geaendert am`: Pflicht bei jedem Statuswechsel nach
  Erstellung.
- `Letzte inhaltliche Aenderung`: Pflicht bei inhaltlichen Aenderungen
  vor `Accepted`; nach `Accepted` nicht mehr im abgeloesten Text.
- `Superseded by`: Pflicht bei Status `Superseded`.

---

## 3. Konsequenzen

- Das Lastenheft (`spec/lastenheft.md`) bleibt die Quelle fuer
  fachliche Anforderungen (`GG-*`-Kennungen).
- ADRs dokumentieren **Entscheidungen**, nicht laufende Diskussionen.
  Offene Punkte wandern bei Entscheidung in einen ADR und werden im
  Lastenheft mit ADR-Verweis als geschlossen markiert.
- Roadmap-Dokumente in `in-progress/` verfolgen Status, Reihenfolge und
  Abnahmeschnitte; sie liefern spaeter die Meilenstein-Marker.
- Offene Trigger bleiben in `open/` sichtbar, statt in abgeschlossenen
  Plaenen versteckt zu werden.
- `docs/user/` ist explizit getrennt von Plaenen; Runbooks und
  Bedienanleitungen sind keine Architekturartefakte.
- `docs/archive/` ist explizit getrennt von `done/`: archiviert =
  verworfen oder ueberholt; done = umgesetzt.
- Operative Artefakte (Code, Manifeste, CI) folgen dem ADR-Status: bei
  `Proposed`/`Provisional` nur als Spike/Prototyp erlaubt; bei
  `Accepted` verbindliche Projektkonvention.

---

## 4. Pflege-Regeln

- Neue technische Entscheidungen erhalten eine ADR, wenn sie
  langfristige Auswirkungen haben oder einen offenen Punkt im
  Lastenheft schliessen.
- Jeder Plan in `in-progress/` muss Akzeptanzkriterien und einen
  Verifikationspfad enthalten.
- Abgeschlossene Plaene wandern nach `done/` mit kurzer Closure-Notiz
  (was wurde geliefert, was bleibt offen).
- Offene Trigger bleiben in `open/`, bis sie zu einem skizzierten Scope
  werden (→ `next/`), direkt aktiviert (→ `in-progress/`) oder verworfen
  (→ `archive/`).
- Neue ADRs werden in `docs/plan/adr/README.md` in der Aktive-ADRs-Tabelle
  ergaenzt. Bei Schaerfung oder Ablösung wird die "Schaerfungen"-Spalte
  der **alten** ADR aktualisiert; die alte ADR selbst bleibt textlich
  unveraendert (per §2.3).

---

## 5. Nicht Gegenstand dieser ADR

- Wahl der Programmiersprache, des Frontend- oder Desktop-Stacks
  (jeweils eigene ADR; siehe ADR 0002, ADR 0003).
- Konkrete Pfade fuer Test-Artefakte, Container-Images oder
  Release-Pipelines.
- Inhalt von `docs/user/` oder `docs/archive/`.
