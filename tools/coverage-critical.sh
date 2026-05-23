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
# aufnehmen, bei end_of_record die Datei gegen jedes PATTERN
# einzeln pruefen, Match-Zaehler pro PATTERN fuehren und nur bei
# Match in die Ergebnis-Tabelle ausgeben.
#
# Jedes PATTERN muss mindestens einmal matchen — sonst Exit 2 mit
# klarer Diagnose. Damit kann der Gate nicht stillschweigend auf
# eine Teilmenge der kritischen Module degradieren, wenn ein File
# umbenannt wird oder nicht kompiliert (Review-Finding F1 aus dem
# M2-W2-Review).
awk -v thresh="$THRESHOLD" -v patterns_str="$(IFS='|'; echo "${PATTERNS[*]}")" '
    BEGIN {
        n = split(patterns_str, pats, "|")
        for (i = 1; i <= n; i++) hits[i] = 0
        fail_threshold = 0
        printf("%-50s %8s %8s %8s\n", "File", "Lines", "Hit", "Cover%")
        printf("%-50s %8s %8s %8s\n", "----", "-----", "---", "------")
    }
    /^SF:/  { sf = substr($0, 4); next }
    /^LF:/  { lf = substr($0, 4) + 0; next }
    /^LH:/  { lh = substr($0, 4) + 0; next }
    /^end_of_record$/ {
        for (i = 1; i <= n; i++) {
            if (sf ~ pats[i]) {
                hits[i]++
                pct = (lf > 0) ? (lh / lf * 100.0) : 100.0
                status = (pct >= thresh) ? "OK" : "LOW"
                printf("%-50s %8d %8d %7.2f%% %s\n", sf, lf, lh, pct, status)
                if (pct < thresh) fail_threshold = 1
                break  # Jeder SF kann nur zu einem Pattern zugehoeren.
            }
        }
        sf=""; lf=0; lh=0
    }
    END {
        # Per-PATTERN-Verifizierung: jede gelistete Regel muss
        # mindestens ein File im LCOV gefunden haben.
        missing = 0
        for (i = 1; i <= n; i++) {
            if (hits[i] == 0) {
                printf("[coverage-critical] FAIL: PATTERN /%s/ matched kein File im LCOV\n", pats[i]) > "/dev/stderr"
                missing = 1
            }
        }
        if (missing) {
            print "[coverage-critical] Hinweis: PATTERN-Liste im Skript veraltet, oder" > "/dev/stderr"
            print "[coverage-critical] kritisches Modul nicht im Cov-Lauf enthalten."   > "/dev/stderr"
            exit 2
        }
        if (fail_threshold) {
            printf("[coverage-critical] FAIL: Mindestens ein kritisches Modul unter %d%%\n", thresh) > "/dev/stderr"
            exit 1
        }
        printf("[coverage-critical] PASS: alle kritischen Module >= %d%% Lines (%d/%d Patterns)\n", thresh, n, n)
        exit 0
    }
' "$LCOV"
