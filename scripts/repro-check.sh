#!/usr/bin/env bash
# Reproduzierbarkeits-Check fuer GridGuide gemaess GG-NFA-INSTALL-001
# und ADR 0004 §4-Punkt 4.
#
# Strategie: den Build-Container aus Dockerfile zweimal frisch bauen,
# innen jeweils das produktive Rust-Binary kompilieren und dessen
# SHA-256 vergleichen.
#
# Erwartung: identische Hashes. Wenn nicht, liegt im Build eine
# nicht-deterministische Quelle (z. B. Zeitstempel-getriggerte
# Pfade, Build-ID, /tmp-Inhalte, Crate-Reihenfolge), die wir
# auf docs/plan/planning/open/ als Trigger eroeffnen muessen.
#
# Voraussetzungen: Docker laeuft lokal. Dauert je nach Cache-Status
# 5-30 min, weil Stage `tools` zwei mal die cargo-Tools baut.

set -euo pipefail

IMAGE_TAG="gridguide-repro-check"
RESULT_DIR="$(mktemp -d)"
trap 'rm -rf "$RESULT_DIR"' EXIT

# Build-Befehl, der im Container laeuft. Hashe das produktive
# Rust-Binary nach einem `cargo build --release --locked`-Lauf —
# inklusive build.rs (tauri_build) der das gebaute Frontend
# einbettet.
INNER_BUILD='
    set -eu
    cd /work/frontend
    pnpm build
    cd /work/src-tauri
    cargo build --release --locked --bin gridguide
    sha256sum target/release/gridguide
'

build_and_hash() {
    local run="$1"
    echo "=========================================================="
    echo " Lauf ${run}: Container bauen (--pull, ohne Cache)"
    echo "=========================================================="
    docker build --pull --no-cache -t "${IMAGE_TAG}:${run}" "$(dirname "$0")/.."

    echo "=========================================================="
    echo " Lauf ${run}: Binary erzeugen und Hash berechnen"
    echo "=========================================================="
    docker run --rm "${IMAGE_TAG}:${run}" sh -c "${INNER_BUILD}" \
        | tee "${RESULT_DIR}/run-${run}.txt"
}

build_and_hash 1
build_and_hash 2

# Hashes extrahieren (sha256sum-Output: '<hash>  <pfad>').
hash1=$(awk '{print $1}' "${RESULT_DIR}/run-1.txt" | tail -n1)
hash2=$(awk '{print $1}' "${RESULT_DIR}/run-2.txt" | tail -n1)

echo
echo "=========================================================="
echo " Ergebnis"
echo "=========================================================="
echo "Lauf 1: ${hash1}"
echo "Lauf 2: ${hash2}"

if [ "${hash1}" = "${hash2}" ]; then
    echo "PASS: identische Hashes — Build ist reproduzierbar."
    exit 0
fi

echo "FAIL: Hashes unterscheiden sich. Build ist NICHT reproduzierbar."
echo
echo "Naechste Schritte:"
echo "  1. diff der Bin-Inhalte (z. B. via 'strings' oder 'objdump')"
echo "     um die abweichende Region zu lokalisieren."
echo "  2. Trigger in docs/plan/planning/open/ eroeffnen, der die"
echo "     nicht-deterministische Quelle dokumentiert."
echo "  3. M1-W5-Closure-Notiz auf 'Reproduzierbarkeit offen'"
echo "     verschieben, bis Quelle eliminiert ist."
exit 1
