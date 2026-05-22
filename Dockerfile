# syntax=docker/dockerfile:1.7
#
# GridGuide Build-Container.
# Siehe Lastenheft GG-NFA-INSTALL-001 (reproduzierbar), -004
# (Build-Werkzeug, nicht Runtime), -005 (Makefile-Konvention)
# und docs/plan/adr/0004 §2.6.
#
# Multi-Stage-Layout:
#   - node-source : offizielles node:22.13-bookworm-slim als
#                   Quelle fuer Node + Corepack. Wir kopieren nur
#                   /usr/local heraus, statt einen Tarball mit
#                   manuellem SHA-256 zu verifizieren (Docker Hub
#                   Manifest-Digest deckt das ab).
#   - system-deps : Base = rust:1.84-bookworm + apt-Pakete +
#                   Node aus node-source + pnpm via Corepack.
#   - tools       : alle cargo-Tools (cargo-llvm-cov, cargo-audit,
#                   cargo-modules, tauri-cli), je Tool eigener RUN
#                   fuer sauberen Layer-Cache.
#   - gates       : Sourcen + Frontend-Install; CMD ist `make gates`.
#
# Reproduzierbarkeit: alle Versionen sind ueber ARG gepinnt; bei
# Aenderung muss die Slice-Closure-Notiz in done/ aktualisiert
# werden. apt-Versionen folgen aktuell dem Stand des Base-Image-
# Tags — vollstaendige Snapshot-Reproduzierbarkeit ist offenes
# M1-Closure-Item (siehe docs/plan/planning/open/010-apt-snapshot-pinning.md).
#
# pnpm-Sync: ARG PNPM_VERSION muss synchron zum packageManager-Feld
# in frontend/package.json gepflegt werden. Beim Bump beide Stellen
# updaten.

ARG RUST_VERSION=1.84
ARG NODE_VERSION=22.13
ARG PNPM_VERSION=9.15.0
ARG CARGO_LLVM_COV_VERSION=0.6.16
ARG CARGO_AUDIT_VERSION=0.21.0
ARG CARGO_MODULES_VERSION=0.17.0
ARG TAURI_CLI_VERSION=2.11.2

# ============================================================
# Stage 0: Node-Quelle aus offiziellem Image
# ============================================================
FROM node:${NODE_VERSION}-bookworm-slim AS node-source

# ============================================================
# Stage 1: System-Dependencies
# ============================================================
FROM rust:${RUST_VERSION}-bookworm AS system-deps

ARG PNPM_VERSION

# Tauri-2.x-Linux-Build-Abhaengigkeiten gemaess Tauri-Docs fuer
# Bookworm. libsoup-3.0-dev ist transitiv via webkit2gtk-4.1, wird
# aber explizit gelistet (M1-Slice-Plan §3 W5).
# libxdo-dev nur fuer global-shortcut/clipboard-Plugins — in M1
# nicht aktiviert; bewusst weggelassen.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libwebkit2gtk-4.1-dev \
        libsoup-3.0-dev \
        libssl-dev \
        libayatana-appindicator3-dev \
        librsvg2-dev \
        libgtk-3-dev \
        patchelf \
        file \
        make \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Node-Toolchain aus offiziellem node:bookworm-slim-Image kopieren.
# Beide Basen sind Debian Bookworm -> dynamisches Linking
# kompatibel. Vermeidet manuellen Tarball-Hash (H5-Review-Finding).
COPY --from=node-source /usr/local/bin/node                    /usr/local/bin/node
COPY --from=node-source /usr/local/bin/npm                     /usr/local/bin/npm
COPY --from=node-source /usr/local/bin/npx                     /usr/local/bin/npx
COPY --from=node-source /usr/local/bin/corepack                /usr/local/bin/corepack
COPY --from=node-source /usr/local/lib/node_modules            /usr/local/lib/node_modules
COPY --from=node-source /usr/local/include/node                /usr/local/include/node

# pnpm via Corepack, pinned auf die in frontend/package.json
# deklarierte `packageManager`-Version.
RUN corepack enable \
    && corepack prepare "pnpm@${PNPM_VERSION}" --activate

# ============================================================
# Stage 2: Cargo-Tools
#
# Pro Tool ein eigener RUN, damit ein Versions-Bump nicht den
# gesamten Tool-Cache invalidiert (H4-Review-Finding).
# ============================================================
FROM system-deps AS tools

ARG CARGO_LLVM_COV_VERSION
RUN cargo install --locked --version "${CARGO_LLVM_COV_VERSION}" cargo-llvm-cov

ARG CARGO_AUDIT_VERSION
RUN cargo install --locked --version "${CARGO_AUDIT_VERSION}" cargo-audit

ARG CARGO_MODULES_VERSION
RUN cargo install --locked --version "${CARGO_MODULES_VERSION}" cargo-modules

ARG TAURI_CLI_VERSION
RUN cargo install --locked --version "${TAURI_CLI_VERSION}" tauri-cli

# cargo-llvm-cov benoetigt die llvm-tools-preview-Komponente.
RUN rustup component add llvm-tools-preview

# ============================================================
# Stage 3: Gates
#
# Default-Entry: `make gates`. Coverage-Output liegt unter
# /work/.coverage und wird vom Host via Volume-Mount eingesammelt
# (siehe Makefile-Target `container-gates`).
# ============================================================
FROM tools AS gates

WORKDIR /work

# Cargo-Deps vorgewaermt: nur Manifeste + Stub-main.rs kopieren,
# `cargo fetch --locked` laufen lassen, dann Stub wieder loeschen.
# Damit ueberleben Source-Aenderungen den Cargo-Layer-Cache
# (M8-Review-Finding).
COPY src-tauri/Cargo.toml /work/src-tauri/
RUN mkdir -p /work/src-tauri/src \
    && echo 'fn main() {}' > /work/src-tauri/src/main.rs \
    && cd /work/src-tauri && cargo fetch \
    && rm -rf /work/src-tauri/src

# pnpm-Deps vorgewaermt: nur package.json + .npmrc + (optional)
# Lockfile kopieren, dann install. Wenn pnpm-lock.yaml fehlt
# (M1-Stand), faellt der Befehl auf `pnpm install` zurueck — sobald
# Welle 5 das Lockfile committed hat, ist `--frozen-lockfile`
# verbindlich (H3-Review-Finding).
COPY frontend/package.json frontend/.npmrc /work/frontend/
COPY frontend/pnpm-lock.yaml* /work/frontend/
RUN cd /work/frontend \
    && if [ -f pnpm-lock.yaml ]; then \
         pnpm install --frozen-lockfile; \
       else \
         echo "WARN: pnpm-lock.yaml fehlt — fallback auf pnpm install ohne Lock"; \
         pnpm install; \
       fi

COPY . /work

CMD ["make", "gates"]
