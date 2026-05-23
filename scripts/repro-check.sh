#!/usr/bin/env bash
# Reproduzierbarkeits-Check fuer GridGuide gemaess GG-NFA-INSTALL-001
# und ADR 0004 §4-Punkt 4.
#
# Aktueller Scope (M1):
#   Pruefen, ob das produktive Rust-Binary (`src-tauri/target/release/
#   gridguide` nach `pnpm build` + `cargo build --release --locked
#   --bin gridguide`) zwischen zwei Container-Builds identisch ist.
#
# Aus dem Scope (deferred-Trigger):
#   GG-NFA-INSTALL-001 fordert Bundle-Reproduzierbarkeit, nicht nur
#   Binary. Bundle-Repro setzt voraus, dass `tauri.conf.json` mit
#   `bundle.active = true` baut und SOURCE_DATE_EPOCH gesetzt ist —
#   siehe Trigger 011-bundle-reproducibility.md (offen).
#
# Voraussetzungen:
#   - Docker lokal verfuegbar.
#   - `pnpm-lock.yaml` und `Cargo.lock` sind eingecheckt (sonst
#     scheitert `--frozen-lockfile`/`--locked` mit klarer Meldung).
#
# Laufzeit:
#   20-60 min pro Lauf, weil `--no-cache` die vier `cargo install`-
#   Tool-Builds wiederholt. Insgesamt also 40-120 min.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

IMAGE_TAG="gridguide-repro-check"
RESULT_DIR="$(mktemp -d)"
KEEP_IMAGES="${KEEP_IMAGES:-0}"

cleanup() {
    rm -rf "$RESULT_DIR"
    if [ "${KEEP_IMAGES}" = "0" ]; then
        docker rmi -f "${IMAGE_TAG}:1" "${IMAGE_TAG}:2" >/dev/null 2>&1 || true
    fi
}
trap cleanup EXIT INT TERM

build_and_hash() {
    local run="$1"
    echo "=========================================================="
    echo " Lauf ${run}: Container bauen (--pull --no-cache --target gates)"
    echo "=========================================================="
    # --target gates explizit, weil das Dockerfile nach gates noch
    # die Stages coverage-report und ci-bundle definiert. Ohne
    # --target waehlt Docker den letzten Stage (ci-bundle), und
    # dessen ENTRYPOINT verschluckt unseren sha256sum-Aufruf.
    docker build --pull --no-cache --target gates \
        -t "${IMAGE_TAG}:${run}" "${REPO_ROOT}"

    echo "=========================================================="
    echo " Lauf ${run}: Binary erzeugen, Build-Log unterdruecken,"
    echo " nur sha256sum auf stdout zurueckspielen"
    echo "=========================================================="
    # Build-Output landet im Container in /tmp/build.log. Nur die
    # sha256sum-Zeile geht auf stdout — damit ist die Hash-Extraktion
    # robust gegen Vite-/cargo-Logaenderungen (H6-Review-Finding).
    #
    # bash statt sh, weil das Image (node:bookworm-slim) /bin/sh =
    # dash bereitstellt; dash kennt `set -o pipefail` nicht. bash
    # ist via build-essential im gates-Stage installiert.
    docker run --rm "${IMAGE_TAG}:${run}" bash -c '
        set -euo pipefail
        {
            cd /work/frontend
            pnpm build
            cd /work/src-tauri
            cargo build --release --locked --bin gridguide
        } >/tmp/build.log 2>&1
        sha256sum /work/src-tauri/target/release/gridguide
    ' | tee "${RESULT_DIR}/run-${run}.txt"
}

build_and_hash 1
build_and_hash 2

# Robuste Hash-Extraktion: filter auf 64-Hex-Char-Zeilen.
hash1=$(grep -E '^[0-9a-f]{64}[[:space:]]' "${RESULT_DIR}/run-1.txt" | tail -n1 | awk '{print $1}')
hash2=$(grep -E '^[0-9a-f]{64}[[:space:]]' "${RESULT_DIR}/run-2.txt" | tail -n1 | awk '{print $1}')

echo
echo "=========================================================="
echo " Ergebnis"
echo "=========================================================="
echo "Lauf 1: ${hash1:-<kein Hash extrahiert>}"
echo "Lauf 2: ${hash2:-<kein Hash extrahiert>}"

if [ -z "${hash1}" ] || [ -z "${hash2}" ]; then
    echo "FAIL: konnte Hash aus mindestens einem Lauf nicht extrahieren."
    echo "  Pruefe ${RESULT_DIR}/run-{1,2}.txt fuer Build-Fehler."
    exit 2
fi

if [ "${hash1}" = "${hash2}" ]; then
    echo "PASS: identische Hashes — Binary ist reproduzierbar."
    echo "Hinweis: Bundle-Reproduzierbarkeit (gemaess"
    echo "GG-NFA-INSTALL-001) ist davon NICHT abgedeckt — siehe"
    echo "docs/plan/planning/open/011-bundle-reproducibility.md."
    exit 0
fi

echo "FAIL: Hashes unterscheiden sich. Binary ist NICHT reproduzierbar."
echo
echo "Naechste Schritte:"
echo "  1. diff der Bin-Inhalte (z. B. via 'strings' oder 'objdump')"
echo "     um die abweichende Region zu lokalisieren."
echo "  2. Trigger in docs/plan/planning/open/ eroeffnen, der die"
echo "     nicht-deterministische Quelle dokumentiert."
echo "  3. M1-W5-Closure-Notiz auf 'Reproduzierbarkeit offen'"
echo "     verschieben, bis Quelle eliminiert ist."
exit 1
