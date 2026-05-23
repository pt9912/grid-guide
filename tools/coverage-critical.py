#!/usr/bin/env python3
"""coverage-critical — prueft die 90-%-Schwelle aus
Lastenheft GG-NFA-COV-002 auf den als kritisch markierten
hexagon/core/-Modulen.

Konvention (ersetzt die hartkodierte PATTERN-Liste der awk-Variante):
Module sind kritisch, wenn ihr Modul-Doc-Kommentar (Top-of-File,
`//`-Kommentar) die Phrase `Kritischer Domaincode gemaess
GG-NFA-COV-002` enthaelt. Damit veraltet die kritische Liste
nicht durch Datei-Umbenennungen oder neue Module — sie wird beim
Lauf aus dem Quellbaum gelesen.

Der gewaehlte Marker ist bewusst die volle Phrase, nicht nur der
Lastenheft-Tag `GG-NFA-COV-002`: dadurch werden Policy-Erwaehnungen
(z. B. `domain/mod.rs` erklaert das Schwellen-Schema fuer den Leser,
ist aber selbst nicht-kritisch und enthaelt keinen ausfuehrbaren
Code) korrekt von realen Markierungen unterschieden.

Discovery-Mechanismen, in Reihenfolge:
  1. tree-sitter-rust: parst jede `.rs`-Datei und sucht den Marker
     in `line_comment`-Nodes auf Top-Level. Stabilstes Verfahren,
     weil String-Literale und ineinander geschachtelte Kommentare
     korrekt unterschieden werden.
  2. Regex-Fallback: scannt die ersten 50 Zeilen jeder Datei nach
     `// ... GG-NFA-COV-002`. Wird nur aktiv, wenn `tree_sitter`
     und `tree_sitter_rust` nicht importierbar sind (lokale
     Ausfuehrung ohne Build-Container).

Exit-Codes:
  0 — alle kritischen Module >= Schwelle.
  1 — mindestens ein kritisches Modul unter der Schwelle.
  2 — Setup-Fehler (kein Marker gefunden, kritisches File fehlt im
      LCOV, LCOV-Pfad nicht lesbar).

Siehe auch:
  - ADR 0004 §2.4 (Vorgabe `cargo llvm-cov --fail-under-lines 90`)
  - docs/plan/planning/open/017-coverage-critical-mechanism.md
    (dokumentiert die Implementierungs-Abweichung)
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

CRITICAL_MARKER = "Kritischer Domaincode gemaess GG-NFA-COV-002"
"""Phrase, die im Modul-Kommentar das File als kritisch markiert.
Bewusste Wahl: lang genug, um nicht aus Versehen in einem Policy-
Block zu landen, und kurz genug, dass ein Reviewer sie ohne
Tooling im Code wiederfindet. Eingefuehrt in M2-W2."""


def discover_critical_files(source_root: Path) -> tuple[list[Path], str]:
    """Liefert die Liste der als kritisch markierten Source-Files
    plus den Namen des verwendeten Discovery-Mechanismus."""
    try:
        return _discover_with_treesitter(source_root), "tree-sitter"
    except ImportError:
        return _discover_with_regex(source_root), "regex-fallback"


def _discover_with_treesitter(source_root: Path) -> list[Path]:
    import tree_sitter
    import tree_sitter_rust

    language = tree_sitter.Language(tree_sitter_rust.language())
    parser = tree_sitter.Parser(language)
    critical: list[Path] = []
    marker_bytes = CRITICAL_MARKER.encode("utf-8")
    for rs in sorted(source_root.rglob("*.rs")):
        tree = parser.parse(rs.read_bytes())
        for node in tree.root_node.children:
            if node.type == "line_comment" and marker_bytes in node.text:
                critical.append(rs)
                break
    return critical


def _discover_with_regex(source_root: Path) -> list[Path]:
    critical: list[Path] = []
    for rs in sorted(source_root.rglob("*.rs")):
        with rs.open(encoding="utf-8") as fh:
            for index, line in enumerate(fh):
                if index > 50:
                    break
                stripped = line.lstrip()
                if stripped.startswith("//") and CRITICAL_MARKER in stripped:
                    critical.append(rs)
                    break
    return critical


def parse_lcov(path: Path) -> dict[str, tuple[int, int]]:
    """Liest die SF/LF/LH-Records aus einem LCOV-File und liefert
    pro Source-File ein `(lines_found, lines_hit)`-Paar."""
    coverage: dict[str, tuple[int, int]] = {}
    sf: str | None = None
    lf = 0
    lh = 0
    for line in path.read_text(encoding="utf-8").splitlines():
        if line.startswith("SF:"):
            sf = line[3:]
        elif line.startswith("LF:"):
            lf = int(line[3:])
        elif line.startswith("LH:"):
            lh = int(line[3:])
        elif line == "end_of_record":
            if sf is not None:
                coverage[sf] = (lf, lh)
            sf, lf, lh = None, 0, 0
    return coverage


def match_lcov_entry(
    critical: Path, coverage: dict[str, tuple[int, int]]
) -> tuple[str, int, int] | None:
    """Findet zu einem kritischen Source-File den passenden
    LCOV-Eintrag. LCOV-Pfade sind container-absolut
    (`/work/src-tauri/...`); wir matchen per `endswith` mit dem
    relativen Pfad aus `discover_critical_files`."""
    relative = critical.as_posix()
    for sf, (lf, lh) in coverage.items():
        if sf.endswith(relative) or relative in sf:
            return sf, lf, lh
    return None


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "lcov",
        nargs="?",
        default=".coverage/rust.lcov",
        help="LCOV-Eingabedatei (Default: .coverage/rust.lcov).",
    )
    parser.add_argument(
        "--source-root",
        default="src-tauri/src",
        help="Wurzelverzeichnis fuer das .rs-Walking.",
    )
    parser.add_argument(
        "--threshold",
        type=float,
        default=90.0,
        help="Mindest-Line-Coverage in Prozent (Default: 90).",
    )
    args = parser.parse_args()

    source_root = Path(args.source_root)
    if not source_root.is_dir():
        print(
            f"[coverage-critical] FAIL: Source-Root nicht gefunden: {source_root}",
            file=sys.stderr,
        )
        return 2

    lcov_path = Path(args.lcov)
    if not lcov_path.is_file():
        print(
            f"[coverage-critical] FAIL: LCOV-Datei nicht lesbar: {lcov_path}",
            file=sys.stderr,
        )
        print(
            "[coverage-critical] Tipp: zuerst `make coverage-rust` laufen lassen.",
            file=sys.stderr,
        )
        return 2

    critical, mechanism = discover_critical_files(source_root)
    if not critical:
        print(
            f"[coverage-critical] FAIL: kein File mit Marker '{CRITICAL_MARKER}' "
            f"in {source_root} gefunden (Mechanismus: {mechanism}).",
            file=sys.stderr,
        )
        return 2

    coverage = parse_lcov(lcov_path)

    print(f"{'File':<60} {'Lines':>8} {'Hit':>8} {'Cover%':>8}")
    print(f"{'----':<60} {'-----':>8} {'---':>8} {'------':>8}")

    failed: list[tuple[str, float]] = []
    not_found: list[Path] = []
    for source in critical:
        entry = match_lcov_entry(source, coverage)
        if entry is None:
            not_found.append(source)
            continue
        sf, lf, lh = entry
        pct = (lh / lf * 100.0) if lf > 0 else 100.0
        status = "OK" if pct >= args.threshold else "LOW"
        print(f"{sf:<60} {lf:>8} {lh:>8} {pct:>7.2f}% {status}")
        if pct < args.threshold:
            failed.append((sf, pct))

    if not_found:
        for source in not_found:
            print(
                f"[coverage-critical] FAIL: kritisches File nicht im LCOV: {source}",
                file=sys.stderr,
            )
        print(
            "[coverage-critical] Hinweis: Coverage-Lauf hat dieses Modul nicht "
            "erfasst (z. B. wegen --ignore-filename-regex oder Build-Excludes).",
            file=sys.stderr,
        )
        return 2

    if failed:
        for sf, pct in failed:
            print(
                f"[coverage-critical] FAIL: {sf} bei {pct:.2f}% < {args.threshold:.0f}%",
                file=sys.stderr,
            )
        return 1

    print(
        f"[coverage-critical] PASS: alle {len(critical)} kritischen Module "
        f">= {args.threshold:.0f}% Lines (Discovery via {mechanism})."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
