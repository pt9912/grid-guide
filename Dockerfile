# syntax=docker/dockerfile:1.7
#
# GridGuide Build-Container.
# Siehe Lastenheft GG-NFA-INSTALL-001 (reproduzierbar), -004
# (Build-Werkzeug, nicht Runtime), -005 (Makefile-Konvention)
# und docs/plan/adr/0004 §2.6.
#
# Multi-Stage-Layout:
#   - system-deps : Base-Image + apt-Pakete + Node-Toolchain + pnpm.
#   - tools       : alle cargo-Tools (cargo-llvm-cov, cargo-audit,
#                   cargo-modules, tauri-cli) ueber `cargo install
#                   --locked --version <X.Y.Z>`.
#   - gates       : Sourcen + Frontend-Install; CMD ist `make gates`.
#
# Reproduzierbarkeit: alle Versionen sind ueber ARG gepinnt; bei
# Aenderung muss die Slice-Closure-Notiz in done/ aktualisiert
# werden. apt-Versionen folgen dem Stand des Base-Image-Tags;
# explizite `apt-get install pkg=<version>`-Pins kommen mit der
# Snapshot-Verifikation in M1-W5-Closure (siehe
# scripts/repro-check.sh).

ARG RUST_VERSION=1.84
ARG NODE_VERSION=22.13.0
ARG PNPM_VERSION=9.15.0
ARG CARGO_LLVM_COV_VERSION=0.6.16
ARG CARGO_AUDIT_VERSION=0.21.0
ARG CARGO_MODULES_VERSION=0.17.0
ARG TAURI_CLI_VERSION=2.11.2

# ============================================================
# Stage 1: System-Dependencies
# ============================================================
FROM rust:${RUST_VERSION}-bookworm AS system-deps

ARG NODE_VERSION
ARG PNPM_VERSION

# Tauri-2.x-Linux-Build-Abhaengigkeiten. Versionen folgen aktuell
# dem Bookworm-Stand des Base-Image; explizite `=<version>`-Pins
# werden mit M1-W5-Closure aus dem Snapshot-Verifikationsschritt
# nachgezogen (siehe scripts/repro-check.sh).
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libwebkit2gtk-4.1-dev \
        libssl-dev \
        libayatana-appindicator3-dev \
        librsvg2-dev \
        libgtk-3-dev \
        libxdo-dev \
        patchelf \
        file \
        make \
        ca-certificates \
        curl \
        xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Node-Toolchain: Binary-Tarball vom offiziellen Mirror, weil
# Bookworm-`nodejs` zu alt ist. Tarball-Pfad ist deterministisch.
RUN curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" \
        | tar -xJ -C /opt \
    && mv "/opt/node-v${NODE_VERSION}-linux-x64" /opt/node
ENV PATH="/opt/node/bin:${PATH}"

# pnpm via Corepack, pinned auf die in package.json deklarierte
# `packageManager`-Version. Corepack lehnt eine Abweichung ab.
RUN corepack enable \
    && corepack prepare "pnpm@${PNPM_VERSION}" --activate

# ============================================================
# Stage 2: Cargo-Tools
#
# Wird nur invalidiert, wenn sich die Tool-Versionen aendern —
# Source-Changes invalidieren nur die `gates`-Stage.
# ============================================================
FROM system-deps AS tools

ARG CARGO_LLVM_COV_VERSION
ARG CARGO_AUDIT_VERSION
ARG CARGO_MODULES_VERSION
ARG TAURI_CLI_VERSION

RUN cargo install --locked --version "${CARGO_LLVM_COV_VERSION}" cargo-llvm-cov \
    && cargo install --locked --version "${CARGO_AUDIT_VERSION}"    cargo-audit    \
    && cargo install --locked --version "${CARGO_MODULES_VERSION}"  cargo-modules  \
    && cargo install --locked --version "${TAURI_CLI_VERSION}"      tauri-cli

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

# Vorab nur Manifeste kopieren — dann pnpm-Install — dann Source.
# Damit invalidiert eine Source-Aenderung (ohne package.json-Change)
# das pnpm-Install-Layer nicht.
COPY frontend/package.json frontend/.npmrc /work/frontend/
RUN cd frontend && pnpm install

COPY . /work

CMD ["make", "gates"]
