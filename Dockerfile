# syntax=docker/dockerfile:1.7
#
# GridGuide Build-Container.
# Siehe Lastenheft GG-NFA-INSTALL-001 (reproduzierbar), -004
# (Build-Werkzeug, nicht Runtime), -005 (Makefile-Konvention)
# und docs/plan/adr/0004 §2.6.
#
# Multi-Stage-Layout:
#   - system-deps : Base = node:22.13-bookworm-slim
#                   (bringt Node + Corepack + npm/npx intakt).
#                   Rust-Toolchain wird via rustup-init nachinstalliert
#                   (Rust und Node von oben mischen umgekehrt brach
#                   Corepacks Symlink-Layout — `Cannot find module
#                   './lib/corepack.cjs'`). apt-Pakete fuer Tauri-2.x
#                   Linux-Build.
#   - tools       : alle cargo-Tools (cargo-llvm-cov, cargo-audit,
#                   cargo-modules, tauri-cli), je Tool eigener RUN
#                   fuer sauberen Layer-Cache.
#   - gates       : Sourcen + Cargo-Fetch + Frontend-Install;
#                   CMD ist `make gates`.
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

ARG RUST_VERSION=1.84.0
ARG NODE_VERSION=22.13
ARG PNPM_VERSION=9.15.0
ARG CARGO_LLVM_COV_VERSION=0.6.16
ARG CARGO_AUDIT_VERSION=0.21.0
ARG CARGO_MODULES_VERSION=0.17.0
ARG TAURI_CLI_VERSION=2.11.2

# ============================================================
# Stage 1: System-Dependencies (Node + Rust + apt + pnpm)
# ============================================================
FROM node:${NODE_VERSION}-bookworm-slim AS system-deps

ARG RUST_VERSION
ARG PNPM_VERSION

# Tauri-2.x-Linux-Build-Abhaengigkeiten + Rust-Compile-Tooling.
# libsoup-3.0-dev ist transitiv via webkit2gtk-4.1, wird aber
# explizit gelistet (M1-Slice-Plan §3 W5).
# libxdo-dev nur fuer global-shortcut/clipboard-Plugins — in M1
# nicht aktiviert; bewusst weggelassen.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        libwebkit2gtk-4.1-dev \
        libsoup-3.0-dev \
        libssl-dev \
        libayatana-appindicator3-dev \
        librsvg2-dev \
        libgtk-3-dev \
        patchelf \
        file \
        make \
    && rm -rf /var/lib/apt/lists/*

# Rust via rustup. Toolchain-Version aus ARG gepinnt; rustup
# installiert systemweit nach /usr/local/cargo + /usr/local/rustup.
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:${PATH}

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o /tmp/rustup-init.sh \
    && sh /tmp/rustup-init.sh -y --no-modify-path --profile minimal \
        --default-toolchain "${RUST_VERSION}" \
        --component rustfmt --component clippy \
    && rm /tmp/rustup-init.sh \
    && rustc --version \
    && cargo --version

# pnpm via Corepack, pinned auf die in frontend/package.json
# deklarierte `packageManager`-Version. Corepack ist im node-Image
# vorinstalliert.
RUN corepack enable \
    && corepack prepare "pnpm@${PNPM_VERSION}" --activate \
    && pnpm --version

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
