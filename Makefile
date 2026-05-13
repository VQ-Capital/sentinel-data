.PHONY: build clean help install run
.DEFAULT_GOAL := help

# ========= CONFIG =========
BIN := ./target/release/sentinel

# ========= COLORS =========
GREEN  := \033[0;32m
YELLOW := \033[0;33m
BLUE   := \033[0;34m
CYAN   := \033[0;36m
RESET  := \033[0m

# ========= BASE =========
all: check lint build

setup:
	rustup update
	rustup component add clippy rustfmt

check:
	@echo "🔍 Checking code for compilation errors..."
	cargo check

fix:
	@echo "🔧 Auto-fixing issues..."
	cargo clippy --fix --allow-dirty -- -D warnings
	cargo fix --allow-dirty
	find . -path ./target -prune -o -name "*.rs" -exec sed -i 's/[[:space:]]*$$//' {} +
	cargo fmt

lint:
	@echo "🧹 Running linter and formatter (check mode)..."
	cargo fmt -- --check
	cargo clippy -- -D warnings

# ========= CORE =========
build:
	@echo "${BLUE}🔨 Derleniyor...${RESET}"
	@cargo build --release
	@echo "${GREEN}✅ Tamamlandı${RESET}"

# ========= GENERIC RUN =========
run: build
	@$(BIN) $(ARGS)

# ========= SHORTCUTS =========

quick:
	@$(MAKE) run ARGS="--symbols BTCUSDT --days 1 --limit 10000 --output BTCUSDT_QUICK_1D"
	@$(MAKE) run ARGS="--symbols ETHUSDT --days 1 --limit 10000 --output ETHUSDT_QUICK_1D"
	@$(MAKE) run ARGS="--symbols SOLUSDT --days 1 --limit 10000 --output SOLUSDT_QUICK_1D"

single:
	@$(MAKE) run ARGS="--symbols BTCUSDT --days 1 --output BTCUSDT_1D"
	@$(MAKE) run ARGS="--symbols ETHUSDT --days 1 --output ETHUSDT_1D"
	@$(MAKE) run ARGS="--symbols SOLUSDT --days 1 --output SOLUSDT_1D"

week:
	@$(MAKE) run ARGS="--symbols BTCUSDT --days 7 --output BTCUSDT_7D"
	@$(MAKE) run ARGS="--symbols ETHUSDT --days 7 --output ETHUSDT_7D"
	@$(MAKE) run ARGS="--symbols SOLUSDT --days 7 --output SOLUSDT_7D"

month:
	@$(MAKE) run ARGS="--symbols BTCUSDT --days 30 --output BTCUSDT_30D"
	@$(MAKE) run ARGS="--symbols ETHUSDT --days 30 --output ETHUSDT_30D"
	@$(MAKE) run ARGS="--symbols SOLUSDT --days 30 --output SOLUSDT_30D"

MONTH ?= 01
YEAR ?= 2026
SYMBOL ?= BTCUSDT

run-month:
	@START=$(YEAR)-$(MONTH)-01; \
	END=$$(date -d "$$START +1 month -1 day" +%Y-%m-%d); \
	$(MAKE) run ARGS="--symbols $(SYMBOL) --start $$START --end $$END --output $(SYMBOL)_$(MONTH)_$(YEAR)"

# ========= CLEAN =========
clean:
	@echo "${YELLOW}🧹 Temizleniyor...${RESET}"
	@rm -rf datasets/*.csv datasets/*.zip
	@cargo clean
	@echo "${GREEN}✅ Tamamlandı${RESET}"

# ========= HELP =========
help:
	@echo ""
	@echo "${CYAN}Sentinel Data Makefile${RESET}"
	@echo ""
	@echo "${GREEN}Komutlar:${RESET}"
	@echo "  make build"
	@echo "  make install"
	@echo ""
	@echo "  make single      (1 gün)"
	@echo "  make week        (7 gün)"
	@echo "  make month       (30 gün)"
	@echo "  make quick       (limitli test)"
	@echo ""
	@echo "	 make run-month MONTH=01 YEAR=2026 SYMBOL=BTCUSDT"
	@echo "	 make run-month MONTH=02 YEAR=2026 SYMBOL=BTCUSDT"
	@echo "	 make run-month MONTH=03 YEAR=2026 SYMBOL=BTCUSDT"
	@echo "	 make run-month MONTH=04 YEAR=2026 SYMBOL=BTCUSDT"
	@echo "	 make run-month MONTH=05 YEAR=2026 SYMBOL=BTCUSDT"
	@echo ""
	@echo "	 make --symbols BTCUSDT --start 2026-01-01 --end 2026-01-31 --output BTCUSDT_01_2026"
	@echo "	 make --symbols BTCUSDT --start 2026-02-01 --end 2026-03-28 --output BTCUSDT_02_2026"
	@echo "	 make --symbols BTCUSDT --start 2026-03-01 --end 2026-03-31 --output BTCUSDT_03_2026"
	@echo "	 make --symbols BTCUSDT --start 2026-04-01 --end 2026-04-30 --output BTCUSDT_04_2026"
	@echo "	 make --symbols BTCUSDT --start 2026-05-01 --end 2026-05-31 --output BTCUSDT_05_2026"			
	@echo ""
	@echo "${GREEN}Custom:${RESET}"
	@echo "  make run ARGS=\"--symbols BTCUSDT --days 3\""
	@echo ""