#!/usr/bin/env bash
# Container-Entrypoint fuer Stage `coverage-report`.
# Siehe Lastenheft GG-NFA-COV-001..002 und ADR 0004 §2.6.
#
# Vertrag:
#   - Laeuft `make coverage` (Rust + Frontend).
#   - Make-Logs gehen nach stderr.
#   - Bei Erfolg: tar(1) auf stdout mit Top-Level-Eintraegen
#       rust.lcov   (cargo-llvm-cov LCOV-Output, aus /work/.coverage)
#       frontend/   (Vitest-Reporter-Output, aus /work/frontend/coverage)
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

# Rust- und Frontend-Coverage liegen an verschiedenen Stellen
# (Makefile coverage-rust schreibt nach /work/.coverage/rust.lcov,
# vitest schreibt sein Reporter-Output nach /work/frontend/coverage).
# Wir staging-en beide in eine gemeinsame Baumstruktur, damit der Host
# `tar -C .coverage -x` einfach extrahieren kann.
STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT

if [ -d /work/.coverage ] && [ -n "$(ls -A /work/.coverage 2>/dev/null)" ]; then
    cp -r /work/.coverage/. "$STAGING/"
fi

if [ -d /work/frontend/coverage ] && [ -n "$(ls -A /work/frontend/coverage 2>/dev/null)" ]; then
    mkdir -p "$STAGING/frontend"
    cp -r /work/frontend/coverage/. "$STAGING/frontend/"
fi

tar -C "$STAGING" -c .
