# syntax=docker/dockerfile:1.7
#
# GridGuide Build-Container.
# Siehe Lastenheft GG-NFA-INSTALL-001 (reproduzierbar), -004
# (Build-Werkzeug, nicht Runtime), -005 (Makefile-Konvention)
# und docs/plan/adr/0004 §2.6.
#
# Multi-Stage-Layout:
#   - pnpm-base        : Base = node:24.16-bookworm-slim mit pnpm via
#                        Corepack. Minimaler Boden fuer
#                        lockfile-only-Operationen (Pattern aus
#                        ../m-trace/Dockerfile).
#   - lock-refresh-tool: pnpm-base, dediziert fuer
#                        `pnpm install --lockfile-only` per
#                        `make lock-refresh`. Schreibt das Lockfile
#                        ueber Volume-Mount in den Host-Workspace,
#                        ohne dass Host-Node oder -node_modules
#                        existieren muessen.
#   - system-deps      : pnpm-base + apt-Pakete + Rust-Toolchain via
#                        rustup. Rust und Node mischen umgekehrt brach
#                        Corepacks Symlink-Layout (`Cannot find
#                        module './lib/corepack.cjs'`), daher Node als
#                        Basis.
#   - tools            : system-deps + cargo-Tools (cargo-llvm-cov,
#                        cargo-audit, cargo-modules, tauri-cli), je
#                        Tool eigener RUN fuer Layer-Cache.
#   - gates            : tools + Sourcen + Cargo-Fetch + Frontend-
#                        Install; CMD `make gates`.
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

ARG RUST_VERSION=1.95.0
ARG NODE_VERSION=24.16.0
ARG PNPM_VERSION=11.2.2
ARG CARGO_LLVM_COV_VERSION=0.8.7
ARG CARGO_AUDIT_VERSION=0.22.1
ARG CARGO_MODULES_VERSION=0.17.0
ARG TAURI_CLI_VERSION=2.11.2

# ============================================================
# Stage 1a: pnpm-base — Node + Corepack + pnpm, sonst nichts.
#
# Minimaler Boden fuer pnpm-only-Aufgaben (z. B. Lockfile-Refresh).
# Wird von system-deps und lock-refresh-tool gleichermassen
# verwendet, damit der pnpm-Stack genau einmal definiert ist.
# ============================================================
FROM node:${NODE_VERSION}-bookworm-slim AS pnpm-base

ARG PNPM_VERSION

RUN corepack enable \
    && corepack prepare "pnpm@${PNPM_VERSION}" --activate \
    && pnpm --version

# ============================================================
# Stage 1b: lock-refresh-tool — minimal pnpm-only-Image.
#
# Genutzt von `make lock-refresh`: COPY frontend-Manifeste in das
# Image, Entrypoint laesst pnpm `--lockfile-only` laufen und schreibt
# das frische pnpm-lock.yaml als Tar-Stream auf stdout zurueck. Der
# Host extrahiert per `| tar -x` ins frontend-Verzeichnis. Damit
# entfaellt der bisherige Host-Mount (und das damit verbundene
# UID-Pinning).
# ============================================================
FROM pnpm-base AS lock-refresh-tool

ENV XDG_CACHE_HOME=/tmp/.cache
WORKDIR /workspace

COPY frontend/package.json frontend/.npmrc /workspace/
COPY frontend/pnpm-lock.yaml* /workspace/
COPY scripts/docker-entrypoint-lock-refresh.sh /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/docker-entrypoint-lock-refresh.sh"]

# ============================================================
# Stage 1c: System-Dependencies (pnpm-base + Rust + apt)
# ============================================================
FROM pnpm-base AS system-deps

ARG RUST_VERSION

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

# pnpm bringt pnpm-base mit; hier nichts mehr noetig.

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

# cargo-audit liest seine Konfiguration (Advisory-Allowlist) aus
# $CARGO_HOME/audit.toml. Die kanonische Liste lebt im Repo unter
# src-tauri/audit.toml (siehe docs/plan/planning/open/012-rustsec-
# allowlist-revisit.md). Hier kopieren wir sie an die von
# cargo-audit erwartete Stelle, damit die Allowlist sowohl im
# Container als auch via Repo-Review nachvollziehbar bleibt.
COPY src-tauri/audit.toml /usr/local/cargo/audit.toml

ARG CARGO_MODULES_VERSION
RUN cargo install --locked --version "${CARGO_MODULES_VERSION}" cargo-modules

ARG TAURI_CLI_VERSION
RUN cargo install --locked --version "${TAURI_CLI_VERSION}" tauri-cli

# cargo-llvm-cov benoetigt die llvm-tools-preview-Komponente.
RUN rustup component add llvm-tools-preview

# ============================================================
# Stage 3: Gates
#
# Default-Entry: `make gates`. Reicht keine Artefakte heraus, der
# Exit-Code ist die Pass/Fail-Aussage. Wer Coverage-Reports oder das
# Bundle braucht, baut Stage `coverage-report` bzw. `ci-bundle` und
# extrahiert deren Tar-Stream aus stdout (siehe Makefile).
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
       fi \
    && touch /work/frontend/node_modules/.install-stamp

COPY . /work

# COPY ueberschreibt frontend/package.json mit der Host-Quelle und
# kann deren mtime juenger als den Install-Stamp setzen — dann wuerde
# die Makefile-Regel `install-frontend` erneut feuern. Den Stamp
# danach refreshen, damit `make gates` zur Laufzeit den Install
# ueberspringt.
RUN touch /work/frontend/node_modules/.install-stamp

CMD ["make", "gates"]

# ============================================================
# Stage 3b: coverage-report — gates + Coverage-Artefakt-Export
#
# Identisch zur gates-Stage; nur der ENTRYPOINT laeuft `make
# coverage` und schreibt /work/.coverage als Tar auf stdout. Wird
# vom Host via Pipe in das gewuenschte Zielverzeichnis extrahiert
# (siehe Makefile-Target `container-coverage-report`).
# ============================================================
FROM gates AS coverage-report

COPY scripts/docker-entrypoint-coverage-report.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint-coverage-report.sh"]
CMD []

# ============================================================
# Stage 3c: ci-bundle — `make ci` + Bundle/Coverage-Export
#
# Laeuft `make ci` (gates + bundle) und schreibt einen Tar-Stream
# mit dist/ (Bundle) und .coverage/ auf stdout. Wenn bundle.active
# in tauri.conf.json false ist, enthaelt der Tar nur .coverage/.
# ============================================================
FROM gates AS ci-bundle

COPY scripts/docker-entrypoint-ci-bundle.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint-ci-bundle.sh"]
CMD []
