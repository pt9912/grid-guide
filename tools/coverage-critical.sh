#!/usr/bin/env bash
# coverage-critical — prueft die 90-%-Schwelle aus
# Lastenheft GG-NFA-COV-002 auf den als kritisch deklarierten
# hexagon/core/-Pfaden.
#
# Vertrag:
#   - Liest die LCOV-Datei aus $1 (Default: .coverage/rust.lcov).
#   - Filtert die SF/LF/LH-Records auf die Liste kritischer Pfade
#     unten.
#   - Pro kritischem File: berechnet `hit / found * 100` Lines.
#   - Schlaegt mit Exit-Code 1 fehl, wenn mindestens eine Datei
#     unter dem Schwellwert (Default 90, ueberschreibbar via
#     CRITICAL_THRESHOLD) liegt.
#   - Sonst Exit 0 mit Ergebnis-Tabelle.
#
# Kritische Pfade gemaess GG-NFA-COV-002:
#   - Profil-/Profilversionsverwaltung (GG-FA-CAT-001, GG-DATA-005)
#       -> hexagon/core/domain/profile.rs
#       -> hexagon/core/domain/profilversion.rs
#   - Pflichtfeld-/Pflichtunterlagen-Regeln
#     (GG-FA-VAL-001..003)
#       -> hexagon/core/domain/falltyp.rs
#
# Weitere kritische Pfade (Dokumentklassifikation, Exportpaket,
# Prompt-Erzeugung) kommen mit M4+M5+M7 hinzu und werden hier
# dann zur PATTERN-Liste ergaenzt.

set -euo pipefail

LCOV="${1:-.coverage/rust.lcov}"
THRESHOLD="${CRITICAL_THRESHOLD:-90}"

if [ ! -r "$LCOV" ]; then
    echo "[coverage-critical] FAIL: LCOV-Datei nicht lesbar: $LCOV" >&2
    echo "[coverage-critical] Tipp: zuerst 'make coverage-rust' laufen lassen." >&2
    exit 2
fi

# Verlaengerbare PATTERN-Liste: ein POSIX-ERE pro Zeile, das den
# absoluten oder relativen Pfad im SF-Record matcht. Ergaenzen,
# wenn neue Module die GG-NFA-COV-002-Liste erweitern.
PATTERNS=(
    'hexagon/core/domain/profile\.rs$'
    'hexagon/core/domain/profilversion\.rs$'
    'hexagon/core/domain/falltyp\.rs$'
)

# Awk-Parser: pro SF-Record speichern, bei LF/LH die Zahlen
# aufnehmen, bei end_of_record die Datei gegen alle PATTERNS
# pruefen und nur bei Match in die Ergebnis-Tabelle ausgeben.
awk -v thresh="$THRESHOLD" -v patterns="$(IFS='|'; echo "${PATTERNS[*]}")" '
    BEGIN {
        any = 0
        fail = 0
        printf("%-50s %8s %8s %8s\n", "File", "Lines", "Hit", "Cover%")
        printf("%-50s %8s %8s %8s\n", "----", "-----", "---", "------")
    }
    /^SF:/  { sf = substr($0, 4); next }
    /^LF:/  { lf = substr($0, 4) + 0; next }
    /^LH:/  { lh = substr($0, 4) + 0; next }
    /^end_of_record$/ {
        if (sf ~ patterns) {
            any = 1
            pct = (lf > 0) ? (lh / lf * 100.0) : 100.0
            status = (pct >= thresh) ? "OK" : "LOW"
            printf("%-50s %8d %8d %7.2f%% %s\n", sf, lf, lh, pct, status)
            if (pct < thresh) fail = 1
        }
        sf=""; lf=0; lh=0
    }
    END {
        if (!any) {
            print "[coverage-critical] FAIL: kein kritisches Modul im LCOV gefunden." > "/dev/stderr"
            print "[coverage-critical] Pruefe PATTERN-Liste im Skript gegen die" > "/dev/stderr"
            print "[coverage-critical] Pfade in .coverage/rust.lcov."             > "/dev/stderr"
            exit 2
        }
        if (fail) {
            printf("[coverage-critical] FAIL: Mindestens ein kritisches Modul unter %d%%\n", thresh) > "/dev/stderr"
            exit 1
        }
        printf("[coverage-critical] PASS: alle kritischen Module >= %d%% Lines\n", thresh)
        exit 0
    }
' "$LCOV"
