#!/usr/bin/env bash
# Container-Entrypoint fuer Stage `coverage-report`.
# Siehe Lastenheft GG-NFA-COV-001..002 und ADR 0004 §2.6.
#
# Vertrag:
#   - Laeuft `make coverage` (Rust + Frontend).
#   - Make-Logs gehen nach stderr.
#   - Bei Erfolg: tar(1) des Inhalts von /work/.coverage auf stdout.
#   - Exit-Code wird durchgereicht (Pipefail im Host-Makefile sichert
#     Abbruch, falls coverage scheitert).
#
# Host-Aufruf:
#   docker run --rm <image>:coverage-report | tar -C .coverage -x

set -euo pipefail

cd /work

# Make schreibt regulaere Statusausgaben nach stdout. Wir leiten alles
# nach stderr um, damit stdout exklusiv fuer den Tar-Stream bleibt.
make coverage 1>&2

# Inhalt von .coverage (rust.lcov + frontend/coverage) packen, ohne
# einleitendes `.coverage/`-Verzeichnis, damit der Host frei waehlen
# kann, wohin er extrahiert.
tar -C /work/.coverage -c .
