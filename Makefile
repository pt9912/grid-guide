# GridGuide build orchestration.
# Siehe Lastenheft GG-NFA-INSTALL-005 und docs/plan/adr/0004.
#
# Pflichttargets (Lastenheft): gates, ci, fullbuild, bundle, lint,
# typecheck, test, dep-audit. Hier zusaetzlich: arch-check, coverage,
# format-check, container-gates, clean — plus pro Stack ein
# *-rust- und *-frontend-Subtarget gemaess ADR 0004 §2.1/§2.2.

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

# Tool-Bins; per Environment ueberschreibbar (z. B. im Build-Container).
PNPM   ?= pnpm
CARGO  ?= cargo
DOCKER ?= docker

FRONTEND_DIR := frontend
TAURI_DIR    := src-tauri
TOOLS_DIR    := tools

CONTAINER_IMAGE := gridguide-gates
COVERAGE_DIR    := .coverage

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

.PHONY: gates
gates: format-check lint typecheck test coverage arch-check dep-audit ## Alle Quality Gates (lokal + CI)

.PHONY: ci
ci: gates bundle ## Voller CI-Lauf: gates + Bundle

.PHONY: fullbuild
fullbuild: ## Reproduzierbarer Linux-Bundle (AppImage + .deb)
	cd $(TAURI_DIR) && $(CARGO) tauri build --bundles deb,appimage

.PHONY: bundle
bundle: ## Tauri-Bundle gemaess aktiver Targets in tauri.conf.json
	cd $(TAURI_DIR) && $(CARGO) tauri build

# ============================================================
# Format (GG-NFA-QG-004)
# ============================================================

.PHONY: format-check format-check-rust format-check-frontend
format-check: format-check-rust format-check-frontend ## Format-Check beider Stacks

format-check-rust:
	cd $(TAURI_DIR) && $(CARGO) fmt --all -- --check

format-check-frontend:
	cd $(FRONTEND_DIR) && $(PNPM) run format:check

# ============================================================
# Lint (GG-NFA-QG-004)
# ============================================================

.PHONY: lint lint-rust lint-frontend
lint: lint-rust lint-frontend ## Lint beider Stacks

lint-rust:
	cd $(TAURI_DIR) && $(CARGO) clippy --all-targets --locked -- -D warnings

lint-frontend:
	cd $(FRONTEND_DIR) && $(PNPM) run lint

# ============================================================
# Typecheck (GG-NFA-QG-004)
# ============================================================

.PHONY: typecheck typecheck-rust typecheck-frontend
typecheck: typecheck-rust typecheck-frontend ## Typecheck beider Stacks

typecheck-rust:
	cd $(TAURI_DIR) && $(CARGO) check --locked --all-targets

typecheck-frontend:
	cd $(FRONTEND_DIR) && $(PNPM) run check

# ============================================================
# Test (GG-NFA-QG-002)
# ============================================================

.PHONY: test test-rust test-frontend
test: test-rust test-frontend ## Unit-Tests beider Stacks

test-rust:
	cd $(TAURI_DIR) && $(CARGO) test --locked

test-frontend:
	cd $(FRONTEND_DIR) && $(PNPM) run test

# ============================================================
# Coverage (GG-NFA-COV-001..002, GG-NFA-QG-001)
# ============================================================

.PHONY: coverage coverage-rust coverage-frontend coverage-critical
coverage: coverage-rust coverage-frontend coverage-critical ## Coverage beider Stacks + kritische Module

coverage-rust:
	@mkdir -p $(COVERAGE_DIR)
	cd $(TAURI_DIR) && $(CARGO) llvm-cov --locked \
		--lcov --output-path ../$(COVERAGE_DIR)/rust.lcov \
		--fail-under-lines 80

coverage-frontend:
	@mkdir -p $(COVERAGE_DIR)
	cd $(FRONTEND_DIR) && $(PNPM) run test:coverage

coverage-critical: ## 90% auf kritischer Domainlogik (GG-NFA-COV-002; M1-Stub)
	@echo "M1-Stub: kritische Module gemaess GG-NFA-COV-002 entstehen mit M2."
	@echo "Aktiver Check folgt mit M2-Welle 'Domain-Kern und Katalog-Seed'."

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
# ============================================================

.PHONY: dep-audit dep-audit-rust dep-audit-frontend
dep-audit: dep-audit-rust dep-audit-frontend ## Security-Scan beider Stacks

dep-audit-rust:
	cd $(TAURI_DIR) && $(CARGO) audit --deny warnings

dep-audit-frontend:
	cd $(FRONTEND_DIR) && $(PNPM) audit --prod

# ============================================================
# Container-Variante (GG-NFA-INSTALL-004)
# ============================================================

.PHONY: container-gates
container-gates: ## make gates im pinned Build-Container ausfuehren
	@if [ -f Dockerfile ]; then \
		$(DOCKER) build --pull -t $(CONTAINER_IMAGE) . && \
		mkdir -p $(COVERAGE_DIR) && \
		$(DOCKER) run --rm \
			-v "$(CURDIR)/$(COVERAGE_DIR):/work/$(COVERAGE_DIR)" \
			$(CONTAINER_IMAGE) make gates; \
	else \
		echo "M1-W3-Stub: Dockerfile entsteht in M1-Welle 5."; \
	fi

# ============================================================
# Pflege
# ============================================================

.PHONY: clean
clean: ## Build-Artefakte loeschen (target/, build/, .svelte-kit/, coverage/)
	rm -rf $(TAURI_DIR)/target \
		$(FRONTEND_DIR)/build \
		$(FRONTEND_DIR)/.svelte-kit \
		$(FRONTEND_DIR)/coverage \
		$(COVERAGE_DIR)
