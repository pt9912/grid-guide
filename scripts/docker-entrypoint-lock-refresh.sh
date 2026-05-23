#!/usr/bin/env bash
# Container-Entrypoint fuer Stage `lock-refresh-tool`.
# Siehe Lastenheft GG-NFA-INSTALL-005 und ADR 0004 §2.6.
#
# Vertrag:
#   - Erwartet, dass /workspace package.json (+ .npmrc) enthaelt.
#     Bislang wurde der Host-Workspace gemountet; ab dieser Variante
#     kopieren wir die Quellen ueber das Image (Dockerfile-COPY in
#     der Stage) und schreiben das frische Lockfile als Tar-Stream
#     auf stdout zurueck.
#   - pnpm-Logs gehen nach stderr.
#   - stdout enthaelt ausschliesslich `tar -c pnpm-lock.yaml`.
#
# Host-Aufruf:
#   docker run --rm <image>:lock-refresh-tool | tar -C frontend -x

set -euo pipefail

cd /workspace

pnpm install \
    --lockfile-only \
    --ignore-scripts \
    --store-dir /tmp/.pnpm-store \
    1>&2

tar -c pnpm-lock.yaml
