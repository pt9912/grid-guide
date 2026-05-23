# ADR 0005 — CI/Release mit GitHub Actions + tauri-action

**Status:** Provisional
**Datum:** 2026-05-22
**Bezug:** [ADR 0001](0001-documentation-and-planning-structure.md),
[ADR 0003](0003-desktop-runtime-tauri.md),
[ADR 0004](0004-quality-gates-and-coverage-tooling.md),
[Lastenheft](../../../spec/lastenheft.md) (`GG-PE-003`,
`GG-NFA-INSTALL-001`, `GG-NFA-INSTALL-002`, `GG-NFA-INSTALL-004`,
`GG-NFA-INSTALL-005`, `GG-NFA-QG-001` bis `GG-NFA-QG-005`,
`GG-NFA-CICD-001` bis `GG-NFA-CICD-004`, `GG-NFA-SEC-001`)
**Aenderungstyp:** Greenfield-ADR. Konkretisiert die mit Lastenheft
v0.4.0 neu aufgenommenen `GG-NFA-CICD-*`-Anforderungen mit einer
konkreten CI-Plattform und Action-Wahl. Wird auf `Accepted` gehoben,
sobald ein Skelett-Repo den Workflow gruen ueber alle drei
Plattformen ausfuehrt (Spike-Vertrag in §4).

---

## 1. Kontext

Lastenheft v0.4.0 fordert:

- **Pipeline**: `make gates` und Container-Build je Push/PR
  (`GG-NFA-CICD-001`).
- **Plattform-Matrix**: Linux Pflicht, Windows/macOS Best-Effort
  (`GG-NFA-CICD-002`); `GG-PE-003` benennt dieselbe Aufteilung.
- **Release-Workflow**: V1, signierte Bundles bei Tag-Push
  (`GG-NFA-CICD-003`, `GG-NFA-INSTALL-002`).
- **Secret-Handling**: ohne Klartext-Lecks, ohne Fork-PR-Zugriff
  (`GG-NFA-CICD-004`).

Cross-Plattform-Bundles sind ueber `cargo build` alleine nicht
realistisch — Tauri verlangt die jeweils native Toolchain (WebKitGTK
auf Linux, WebView2 auf Windows, WebKit auf macOS). Eine
CI-Matrix mit nativen Runnern ist der pragmatische Weg.

[`tauri-apps/tauri-action`](https://github.com/tauri-apps/tauri-action)
ist die offizielle GitHub-Action des Tauri-Teams; sie kapselt
Toolchain-Setup, Frontend-Install (`pnpm`/`npm`), `tauri build` und
optional die Veroeffentlichung an einen GitHub-Release-Entwurf.

`grid-gym` hat einen Python-Stack ohne Tauri und nutzt deshalb keine
`tauri-action`; das CI-Pattern (matrix per Plattform, `make`-Gates)
folgt aber dem gleichen Modell.

---

## 2. Entscheidung

### 2.1 CI-Plattform

**GitHub Actions** ist die CI-Plattform.

Begruendung:

- Direkte Integration mit `tauri-action` (offizielles Tauri-Tooling).
- Native Runner fuer Linux, macOS und Windows ohne
  Self-Hosted-Aufwand.
- Reicht fuer den MVP-Scope; ein Wechsel auf GitLab CI oder
  Self-Hosted ist spaeter ueber Eigen-Workflow moeglich, ohne dass
  diese Entscheidung die Quality-Gates-Tooling-Wahl aus ADR 0004
  bricht.

### 2.2 Workflow-Struktur

Zwei Workflows unter `.github/workflows/`:

| Datei              | Trigger                          | Zweck                                                                 |
| ------------------ | -------------------------------- | --------------------------------------------------------------------- |
| `gates.yml`        | `push`, `pull_request`           | Plattform-Matrix `make gates` (siehe §2.3); kein Bundle-Upload.        |
| `release.yml`      | `push` auf Tag `v*.*.*`          | `make ci` plus `tauri-action` mit Bundle-Veroeffentlichung als Release-Entwurf. |

`release.yml` ist V1 (an `GG-NFA-CICD-003` gekoppelt). `gates.yml`
ist MVP.

### 2.3 Plattform-Matrix

```yaml
strategy:
  fail-fast: false
  matrix:
    include:
      - { runner: ubuntu-24.04,  platform: linux,   required: true  }
      - { runner: macos-latest,  platform: macos,   required: false }
      - { runner: windows-latest, platform: windows, required: false }
```

Begruendung Ubuntu-Version: `ubuntu-24.04` (Noble) liefert
`libwebkit2gtk-4.1-dev` und `libsoup-3.0-dev` aus dem Standard-
Repository — dieselben Pakete, die das Build-Container-Image
(Debian Bookworm, vgl. ADR 0004) nutzt. `ubuntu-22.04` (Jammy)
hat Webkit-4.1 nicht durchgaengig im Standard-Archiv und erzwingt
PPA-Workarounds; Konsistenz mit der Container-Linie ist wichtiger
als das laengere LTS-Fenster von Jammy.

`required: true` bedeutet: Linux-Job ist als „required check" in der
Branch-Protection-Regel hinterlegt; Windows-/macOS-Jobs sind
Best-Effort.

Plattformspezifische Vorinstallationen (Linux: `webkit2gtk-4.1`,
`libsoup-3.0`; macOS: Xcode-CLT; Windows: Visual-C++-Build-Tools)
sind im Workflow als eigener Schritt sichtbar und nicht in
`tauri-action` versteckt, damit Reproduktion lokal moeglich bleibt.

### 2.4 `tauri-action`-Einsatz

`tauri-action` wird nur im `release.yml`-Workflow eingesetzt. Im
`gates.yml`-Workflow rufen wir `make gates` direkt auf — die Action
ist fuer Build/Bundle-Schritte gedacht, nicht fuer das gesamte
Test-Tooling.

Im Release-Workflow (SHA-Pin gemaess Versions-Pin-Regel unten;
`<sha>` wird beim Skelett-Build durch den aktuellen Tauri-Action-
Release-SHA ersetzt):

```yaml
- uses: tauri-apps/tauri-action@<sha>  # tauri-action v0.x.x
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    TAURI_SIGNING_PRIVATE_KEY: ${{ secrets.TAURI_SIGNING_PRIVATE_KEY }}
    TAURI_SIGNING_PRIVATE_KEY_PASSWORD: ${{ secrets.TAURI_SIGNING_PRIVATE_KEY_PASSWORD }}
  with:
    tagName: ${{ github.ref_name }}
    releaseName: "GridGuide ${{ github.ref_name }}"
    releaseDraft: true
    prerelease: false
```

Versions-Pin: die Action wird auf einen SHA gepinnt, nicht auf
`@v0`-Floating-Tag (Dependabot-/Renovate-Pflege spaeter). Der
Kommentar nach dem SHA traegt die menschenlesbare Version.

### 2.5 Secret-Handling

- Alle Secrets liegen in GitHub Actions Secrets (Organisations- oder
  Repository-Scope), niemals im Repository.
- Signing-Secrets sind nur fuer `release.yml` sichtbar (per
  Environment-Scope `production`); `gates.yml` laeuft ohne sie.
- Pull-Requests aus Forks bekommen per Default keinen Secret-Zugriff
  (Standard-Verhalten von GitHub Actions, aktiv beibehalten — keine
  `pull_request_target`-Tricks).
- Workflow-Logs werden vor `Accept` einmal manuell auf Klartext-Lecks
  geprueft (Test-Secret-Run, siehe Spike-Vertrag §4).

### 2.6 Caching

- Cargo-Registry-Cache und Build-Cache per `Swatinem/rust-cache@v2`.
- Frontend-Lockfile-Cache per `actions/setup-node@v4`-`cache`-Option.
- Tauri-Bundle-Cache wird **nicht** ueber Plattformen geteilt
  (Cache-Invalidierung schwer kontrollierbar; Sicherheit > Speed).

---

## 3. Konsequenzen

Positiv:

- Linux-, macOS- und Windows-Bundles fallen mit minimalem
  Eigenaufwand an — die `tauri-action`-Matrix kapselt den
  Plattform-Spezifik.
- `gates.yml` und `release.yml` sind getrennt; ein gebrochener
  Release-Workflow blockiert keinen normalen Merge.
- Branch-Protection mit Linux als Required-Check spiegelt die
  Abnahmeregel aus `GG-PE-003`/`GG-NFA-CICD-002` 1:1.

Negativ:

- macOS-Runner sind in GitHub Actions teurer und langsamer als
  Linux. Bei haeufigem Push kann das Minuten- und Kostenbudget
  belasten; gegebenenfalls macOS auf `push` zu `main` einschraenken
  und auf PRs ueberspringen.
- `tauri-action` versteckt einige Plattform-Spezifika. Wir bilden
  die wichtigsten (System-Pakete, WebView-Setup) explizit ab, um
  lokal reproduzierbar zu bleiben (siehe §2.3).

Risiken:

- Floating `@v0`-Pin der Action koennte Breaking Changes
  einschleusen. Mitigation: SHA-Pin in §2.4.
- Signing-Secrets sind plattformspezifisch (`.dmg`-Notarization auf
  macOS, Authenticode auf Windows). Diese Komplexitaet bleibt fuer
  V1 (`GG-NFA-INSTALL-002`); im MVP werden unsignierte Bundles
  akzeptiert.

---

## 4. Spike-Vertrag (Validierung vor `Accepted`)

Diese ADR wechselt von `Provisional` auf `Accepted`, sobald ein
Skelett-Repo folgendes nachweist:

1. `gates.yml` laeuft auf allen drei Plattformen durch; der
   Linux-Job ist gruen und als Required-Check hinterlegt.
2. macOS- oder Windows-Job sind absichtlich rot gesetzt (z. B.
   plattformspezifischer Test bewusst broken) und der Workflow
   blockiert den Merge **nicht** — Best-Effort-Verhalten gemaess
   `GG-NFA-CICD-002` ist nachgewiesen.
3. Ein Demo-Tag (`v0.0.1-test`) loest `release.yml` aus, das einen
   Release-Entwurf mit drei Bundles (`.AppImage`, `.deb` fuer Linux;
   `.dmg` fuer macOS; `.msi` fuer Windows) erzeugt. Im MVP koennen die
   Bundles unsigniert sein.
4. Ein bewusst durchgereichtes Test-Secret erscheint im
   Workflow-Log nur als Maskierungs-Token (`***`), nicht im
   Klartext.
5. Ein PR aus einem Fork laeuft `gates.yml` durch und meldet
   sichtbar, dass Signing-Secrets nicht verfuegbar waren — kein
   Workflow-Fehler aus diesem Grund.

---

## 5. Alternativen

- **GitLab CI**: vergleichbarer Funktionsumfang, aber keine offizielle
  Tauri-Action; `tauri build`-Cross-Plattform muesste selbst gescriptet
  werden. Lohnt sich nur, wenn der Code ohnehin auf GitLab lebt.
- **Self-Hosted Runner**: gewinnt Plattform-/Hardware-Kontrolle, kostet
  Wartung. Erst sinnvoll, wenn macOS-Minuten ein Engpass werden.
- **`actions-rs/*` statt `Swatinem/rust-cache`**: deprecated und nicht
  mehr gepflegt.
- **Reines `cargo`+`tauri-cli` ohne `tauri-action`**: machbar, aber
  hoeherer Eigenaufwand fuer Bundle-Erzeugung und Release-Upload.
  `tauri-action` ist dafuer designt und vom Tauri-Team gepflegt.
- **Drone CI / Buildkite / Circle CI**: keiner bietet die direkte
  Integration mit dem offiziellen Tauri-Tooling.

---

## 6. Nicht Gegenstand dieser ADR

- Konkrete `make`-Target-Implementierung (in ADR 0004 dokumentiert).
- Code-Signing-Zertifikatsbeschaffung (Apple-Developer-Programm,
  Authenticode-Zertifikat) — operativ, nicht architektonisch.
- Dependabot/Renovate-Konfiguration fuer die Action-/Crate-Versionen
  (separater Folge-ADR oder Tooling-Setup).
- Telemetrie-/Status-Badges in der README.
- Build-Caching ueber Plattformen hinweg (bewusst ausgeschlossen,
  siehe §2.6).
