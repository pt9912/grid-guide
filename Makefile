# GridGuide build orchestration.
# Siehe Lastenheft GG-NFA-INSTALL-005 und docs/plan/adr/0004.
#
# Pflichttargets (Lastenheft): gates, ci, fullbuild, bundle, lint,
# typecheck, test, dep-audit. Hier zusaetzlich: arch-check, coverage,
# format-check, container-gates, install-frontend, clean — plus pro
# Stack ein *-rust- und *-frontend-Subtarget gemaess ADR 0004
# §2.1/§2.2.
#
# Konvention: alle Pfade sind $(CURDIR)-relativ, damit das Makefile
# robust ist gegen Aufrufe aus Subdirs (z. B. `make -C src-tauri`).
# Pre-Install-Schutz fuer Frontend (install-frontend-Stamp) verhindert
# kryptische 'command not found'-Fehler beim ersten make gates.

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

# Tool-Bins; per Environment ueberschreibbar (z. B. im Build-Container).
PNPM   ?= pnpm
CARGO  ?= cargo
DOCKER ?= docker

FRONTEND_DIR := $(CURDIR)/frontend
TAURI_DIR    := $(CURDIR)/src-tauri
TOOLS_DIR    := $(CURDIR)/tools

FRONTEND_INSTALL_STAMP := $(FRONTEND_DIR)/node_modules/.install-stamp
CONTAINER_IMAGE        := gridguide-gates
COVERAGE_DIR           := $(CURDIR)/.coverage

.DEFAULT_GOAL := help

# ============================================================
# Help (auto-generiert aus Target-Kommentaren mit '##')
# ============================================================

.PHONY: help
help: ## Liste aller Targets mit Kurzbeschreibung
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z][a-zA-Z0-9_-]*:.*?## / { \
		printf "  \033[36m%-26s\033[0m %s\n", $$1, $$2 \
	}' $(MAKEFILE_LIST)

# ============================================================
# Aggregat-Targets (Pflicht gemaess GG-NFA-INSTALL-005)
# ============================================================

# `coverage` subsummiert `test` (cargo llvm-cov und vitest --coverage
# fahren die Tests selbst aus). `gates` ruft deshalb `coverage`, nicht
# `test`, um Doppelausfuehrung zu vermeiden. `make test` bleibt fuer
# schnelle lokale TDD-Loops als eigenes Einstiegstarget verfuegbar.
.PHONY: gates
gates: format-check lint typecheck coverage arch-check dep-audit ## Alle Quality Gates (lokal + CI)

.PHONY: ci
ci: gates bundle ## Voller CI-Lauf: gates + Bundle

.PHONY: fullbuild
fullbuild: install-frontend ## Reproduzierbarer Linux-Bundle (AppImage + .deb)
	cd $(TAURI_DIR) && $(CARGO) tauri build --bundles deb,appimage

.PHONY: bundle
bundle: install-frontend ## Tauri-Bundle gemaess aktiver Targets in tauri.conf.json
	cd $(TAURI_DIR) && $(CARGO) tauri build

# ============================================================
# Pre-Install (verhindert 'command not found' im Frontend)
# ============================================================

.PHONY: install-frontend
install-frontend: $(FRONTEND_INSTALL_STAMP) ## Frontend-Dependencies idempotent installieren

# Stamp wird neu erstellt, wenn package.json oder das Lockfile sich
# aendert. Das Lockfile existiert vor M1-W5 noch nicht; bis dahin
# wird `pnpm install` (ohne --frozen-lockfile) genutzt. Nach W5 muss
# der Aufruf auf --frozen-lockfile umgestellt werden.
$(FRONTEND_INSTALL_STAMP): $(FRONTEND_DIR)/package.json
	@if [ -f $(FRONTEND_DIR)/pnpm-lock.yaml ]; then \
		cd $(FRONTEND_DIR) && $(PNPM) install --frozen-lockfile; \
	else \
		cd $(FRONTEND_DIR) && $(PNPM) install; \
	fi
	@mkdir -p $(dir $@)
	@touch $@

# ============================================================
# Format (GG-NFA-QG-004)
# ============================================================

.PHONY: format-check format-check-rust format-check-frontend
format-check: format-check-rust format-check-frontend ## Format-Check beider Stacks

format-check-rust:
	cd $(TAURI_DIR) && $(CARGO) fmt --all -- --check

format-check-frontend: install-frontend
	cd $(FRONTEND_DIR) && $(PNPM) run format:check

# ============================================================
# Lint (GG-NFA-QG-004)
# ============================================================

.PHONY: lint lint-rust lint-frontend
lint: lint-rust lint-frontend ## Lint beider Stacks

lint-rust:
	cd $(TAURI_DIR) && $(CARGO) clippy --all-targets --locked -- -D warnings

lint-frontend: install-frontend
	cd $(FRONTEND_DIR) && $(PNPM) run lint

# ============================================================
# Typecheck (GG-NFA-QG-004)
# ============================================================

.PHONY: typecheck typecheck-rust typecheck-frontend
typecheck: typecheck-rust typecheck-frontend ## Typecheck beider Stacks

typecheck-rust:
	cd $(TAURI_DIR) && $(CARGO) check --locked --all-targets

typecheck-frontend: install-frontend
	cd $(FRONTEND_DIR) && $(PNPM) run check

# ============================================================
# Test (GG-NFA-QG-002)
#
# `test` ist Subset von `coverage` (beide fahren die Test-Suite).
# Wird von `gates` NICHT mehr aufgerufen, um Doppelausfuehrung zu
# vermeiden — `coverage` subsummiert. Lokale TDD-Loops nutzen
# weiterhin `make test` direkt.
# ============================================================

.PHONY: test test-rust test-frontend
test: test-rust test-frontend ## Unit-Tests beider Stacks (Schnellpfad ohne Coverage)

test-rust:
	cd $(TAURI_DIR) && $(CARGO) test --locked

test-frontend: install-frontend
	cd $(FRONTEND_DIR) && $(PNPM) run test

# ============================================================
# Coverage (GG-NFA-COV-001..002, GG-NFA-QG-001)
#
# Branch-Coverage (GG-NFA-COV-003) ist V1; --fail-under-branches=70
# wird dann via ADR-Schaerfung ergaenzt, sobald die Schwelle gegated
# wird.
# ============================================================

.PHONY: coverage coverage-rust coverage-frontend coverage-critical
coverage: coverage-rust coverage-frontend coverage-critical ## Coverage beider Stacks + kritische Module

coverage-rust:
	@mkdir -p $(COVERAGE_DIR)
	cd $(TAURI_DIR) && $(CARGO) llvm-cov --locked \
		--lcov --output-path $(COVERAGE_DIR)/rust.lcov \
		--fail-under-lines 80

coverage-frontend: install-frontend
	@mkdir -p $(COVERAGE_DIR)
	cd $(FRONTEND_DIR) && $(PNPM) run test:coverage

coverage-critical: ## 90% kritische Domainlogik (GG-NFA-COV-002; M1: hexagon/core leer -> NO-OP-PASS)
	@echo "[coverage-critical] M1-NO-OP: hexagon/core/ ist leer. Aktiv ab M2 ('Domain-Kern und Katalog-Seed')."
	@echo "[coverage-critical] STATUS: PASS-NO-OP"

# ============================================================
# Architektur-Check (GG-NFA-QG-003)
# ============================================================

.PHONY: arch-check
arch-check: ## Hexagonale Tabu-Regeln durchsetzen
	@if [ -x $(TOOLS_DIR)/arch-check.sh ]; then \
		$(TOOLS_DIR)/arch-check.sh; \
	else \
		echo "M1-W3-Stub: tools/arch-check.sh entsteht in M1-Welle 4."; \
	fi

# ============================================================
# Dependency-Audit (GG-NFA-QG-005)
#
# cargo-audit-Flags explizit ausgeschrieben (statt --deny warnings),
# weil die "warnings"-Kurzform versionsabhaengig ist. Wir verbieten
# alle vier Severity-Kinds, die das Tool kennt.
# ============================================================

.PHONY: dep-audit dep-audit-rust dep-audit-frontend
dep-audit: dep-audit-rust dep-audit-frontend ## Security-Scan beider Stacks

dep-audit-rust:
	cd $(TAURI_DIR) && $(CARGO) audit \
		--deny unmaintained \
		--deny unsound \
		--deny yanked \
		--deny notice

dep-audit-frontend: install-frontend
	cd $(FRONTEND_DIR) && $(PNPM) audit --prod

# ============================================================
# Container-Variante (GG-NFA-INSTALL-004)
# ============================================================

.PHONY: container-gates
container-gates: ## make gates im pinned Build-Container ausfuehren
	@if [ -f $(CURDIR)/Dockerfile ]; then \
		$(DOCKER) build --pull -t $(CONTAINER_IMAGE) $(CURDIR) && \
		mkdir -p $(COVERAGE_DIR) && \
		$(DOCKER) run --rm \
			-v "$(COVERAGE_DIR):/work/.coverage" \
			$(CONTAINER_IMAGE) make gates; \
	else \
		echo "M1-W3-Stub: Dockerfile entsteht in M1-Welle 5."; \
	fi

# ============================================================
# Pflege
# ============================================================

.PHONY: clean
clean: ## Build-Artefakte loeschen (target/, build/, .svelte-kit/, coverage/, install-stamp)
	rm -rf $(TAURI_DIR)/target \
		$(FRONTEND_DIR)/build \
		$(FRONTEND_DIR)/.svelte-kit \
		$(FRONTEND_DIR)/coverage \
		$(FRONTEND_INSTALL_STAMP) \
		$(COVERAGE_DIR)
