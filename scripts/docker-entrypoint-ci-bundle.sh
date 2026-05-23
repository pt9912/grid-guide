#!/usr/bin/env bash
# Container-Entrypoint fuer Stage `ci-bundle`.
# Siehe Lastenheft GG-NFA-INSTALL-004/-005 und ADR 0004 §2.6.
#
# Vertrag:
#   - Laeuft `make ci` (= gates + bundle).
#   - Make-Logs gehen nach stderr.
#   - Bei Erfolg: tar(1) auf stdout mit Top-Level-Verzeichnissen
#       dist/        (Inhalt von src-tauri/target/release/bundle)
#       .coverage/   (rust.lcov + frontend/coverage)
#   - Falls `tauri.conf.json` `bundle.active=false` hat, fehlt das
#     Bundle-Verzeichnis; der Lauf bleibt erfolgreich und der Tar
#     enthaelt nur .coverage/.
#
# Host-Aufruf:
#   docker run --rm <image>:ci-bundle | tar -C "$REPO_ROOT" -x

set -euo pipefail

cd /work

make ci 1>&2

STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT

# .coverage/ enthaelt Rust-LCOV (/work/.coverage/rust.lcov) UND
# Frontend-Coverage (vitest schreibt nach /work/frontend/coverage,
# nicht nach /work/.coverage). Beide in das Staging-.coverage-
# Verzeichnis legen, damit der Host beide Reports an einer Stelle
# vorfindet.
mkdir -p "$STAGING/.coverage"
if [ -d /work/.coverage ] && [ -n "$(ls -A /work/.coverage 2>/dev/null)" ]; then
    cp -r /work/.coverage/. "$STAGING/.coverage/"
fi
if [ -d /work/frontend/coverage ] && [ -n "$(ls -A /work/frontend/coverage 2>/dev/null)" ]; then
    mkdir -p "$STAGING/.coverage/frontend"
    cp -r /work/frontend/coverage/. "$STAGING/.coverage/frontend/"
fi

BUNDLE_SRC=/work/src-tauri/target/release/bundle
if [ -d "$BUNDLE_SRC" ] && [ -n "$(ls -A "$BUNDLE_SRC" 2>/dev/null)" ]; then
    mkdir -p "$STAGING/dist"
    cp -r "$BUNDLE_SRC"/. "$STAGING/dist/"
else
    echo "[ci-bundle] kein Bundle vorhanden (tauri.conf.json bundle.active=false?)" >&2
fi

tar -C "$STAGING" -c .
