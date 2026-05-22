#!/usr/bin/env bash
# Hexagonaler Architektur-Check fuer GridGuide.
#
# Siehe Lastenheft GG-ARCH-003 (Core-Isolation), GG-CC-002 (Adapter
# ohne Businesslogik), GG-CC-003 (Domain ohne Framework-Imports),
# GG-CC-004 (keine Modulzyklen) und docs/plan/adr/0004 §2.3.
#
# Regeln:
#   A) hexagon/core importiert keine Adapter-, Tauri-, PDF-, XLSX-,
#      OCR-, HTTP- oder LLM-Crates.
#   B) hexagon/ports/* enthalten nur Trait-/Typdefinitionen, keine
#      konkreten impl-Bloecke mit Methodenkoerper.
#   C) hexagon/ports/* importieren weder aus hexagon/adapters noch aus
#      hexagon/core. Ports sind reine Abstraktionen und damit
#      Dependency-Senke; das verhindert die typischen Zyklen.
#
# Echte Zyklen-Erkennung (Rule D in V1) soll ueber `cargo modules`
# laufen, sobald sich die Modulgraphen lohnen; siehe ADR 0004 §2.3.

set -eu
set -o pipefail

# Farben nur, wenn STDOUT ein TTY ist.
if [ -t 1 ]; then
    RED="\033[31m"
    GREEN="\033[32m"
    BOLD="\033[1m"
    RESET="\033[0m"
else
    RED=""; GREEN=""; BOLD=""; RESET=""
fi

VIOLATIONS=0

# Heuristik-Pattern.
#
# Rule A: verbotene Top-Level-Crates und Adapter-Imports in
# hexagon/core/**. tauri-build wird ausgeklammert (nur in build.rs).
RULE_A_PATTERN='^[[:space:]]*use[[:space:]]+(tauri::|crate::adapters|reqwest|ureq|lopdf|pdf_extract|calamine|leptonica_sys|tesseract_sys)'

# Rule B: konkrete impl-Bloecke in hexagon/ports/**. Erlaubt sind
# 'trait', 'struct', 'enum', 'type' Definitionen plus Re-Export-
# Module. impl-Bloecke (auch derive-Macros werden hier nicht
# getroffen, weil sie ueber #[derive(...)] generiert werden, nicht
# ueber 'impl').
RULE_B_PATTERN='^[[:space:]]*impl[[:space:]]'

# Rule C: hexagon/ports importiert aus hexagon/adapters oder
# hexagon/core. Beide sind verboten.
RULE_C_PATTERN='^[[:space:]]*use[[:space:]]+crate::(adapters|hexagon::adapters|hexagon::core)'

scan_rule() {
    local rule_id="$1"
    local pattern="$2"
    local path="$3"
    local desc="$4"

    if [ ! -d "$path" ]; then
        return 0
    fi

    local hits
    hits=$(grep -rEn --include='*.rs' "$pattern" "$path" 2>/dev/null || true)
    if [ -n "$hits" ]; then
        printf '%b[%s] %s%b\n' "$RED$BOLD" "$rule_id" "$desc" "$RESET"
        printf '%b  Pfad: %s%b\n' "$RED" "$path" "$RESET"
        echo "$hits" | sed 's/^/    /'
        VIOLATIONS=$((VIOLATIONS + 1))
    fi
}

# --- realer hexagon-Tree ------------------------------------------
SRC_HEXAGON="src-tauri/src/hexagon"

scan_rule "A" "$RULE_A_PATTERN" "$SRC_HEXAGON/core" \
    "hexagon/core importiert verbotene Crates (GG-ARCH-003/GG-CC-003)"

scan_rule "B" "$RULE_B_PATTERN" "$SRC_HEXAGON/ports" \
    "hexagon/ports/* enthalten konkrete impl-Bloecke (GG-CC-002)"

scan_rule "C" "$RULE_C_PATTERN" "$SRC_HEXAGON/ports" \
    "hexagon/ports/* importieren aus core oder adapters (GG-CC-004 Praevention)"

# --- optional: Test-Fixtures --------------------------------------
# Schaerft den Check selbst — wenn die Fixtures vorhanden sind und
# der Aufruf das aktiviert, MUESSEN sie rote Verstoesse melden,
# sonst ist der Check kaputt.
if [ "${ARCH_CHECK_FIXTURES:-off}" = "on" ]; then
    printf '%bARCH_CHECK_FIXTURES=on: zusaetzlich Test-Fixtures pruefen%b\n' \
        "$BOLD" "$RESET"

    FIXTURES="tests/arch-fixtures"

    scan_rule "A-FIXTURE" "$RULE_A_PATTERN" "$FIXTURES/core" \
        "FIXTURE: bewusster Verstoss gegen Rule A"
    scan_rule "B-FIXTURE" "$RULE_B_PATTERN" "$FIXTURES/ports" \
        "FIXTURE: bewusster Verstoss gegen Rule B"

    if [ $VIOLATIONS -lt 2 ]; then
        printf '%b[META] arch-check ist defekt — Fixtures sollten %d Verstoesse melden, gefunden: %d%b\n' \
            "$RED$BOLD" "2" "$VIOLATIONS" "$RESET"
        exit 2
    fi
fi

# --- Ergebnis -----------------------------------------------------
if [ $VIOLATIONS -eq 0 ]; then
    printf '%barch-check: keine Verstoesse%b\n' "$GREEN" "$RESET"
    exit 0
fi

printf '%barch-check: %d Verstoss(e)%b\n' "$RED$BOLD" "$VIOLATIONS" "$RESET"
exit 1
