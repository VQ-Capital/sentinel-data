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

single:
	@$(MAKE) run ARGS="--symbols BTCUSDT --days 1 --output BTCUSDT_1d"
	@$(MAKE) run ARGS="--symbols ETHUSDT --days 1 --output ETHUSDT_1d"
	@$(MAKE) run ARGS="--symbols SOLUSDT --days 1 --output SOLUSDT_1d"

week:
	@$(MAKE) run ARGS="--symbols BTCUSDT --days 7 --output BTCUSDT_7d"
	@$(MAKE) run ARGS="--symbols ETHUSDT --days 7 --output ETHUSDT_7d"
	@$(MAKE) run ARGS="--symbols SOLUSDT --days 7 --output SOLUSDT_7d"

multi:
	@$(MAKE) run ARGS="--symbols BTCUSDT,ETHUSDT,SOLUSDT --days 1 --output multi_1d"

backtest:
	@$(MAKE) run ARGS="--symbols BTCUSDT,ETHUSDT,SOLUSDT --days 7 --output multi_7d"

quick:
	@$(MAKE) run ARGS="--symbols BTCUSDT --days 1 --limit 10000 --output btcusdt_quick_1d"
	@$(MAKE) run ARGS="--symbols ETHUSDT --days 1 --limit 10000 --output ethusdt_quick_1d"
	@$(MAKE) run ARGS="--symbols SOLUSDT --days 1 --limit 10000 --output solusdt_quick_1d"

month:
	@$(MAKE) run ARGS="--symbols BTCUSDT,ETHUSDT,SOLUSDT --days 30 --output multi_30d"

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
	@echo "  make single      (BTC, 1 gün)"
	@echo "  make week        (BTC, 7 gün)"
	@echo "  make multi       (BTC,ETH,SOL)"
	@echo "  make backtest    (7 gün multi)"
	@echo "  make month       (30 gün)"
	@echo "  make quick       (limitli test)"
	@echo ""
	@echo "${GREEN}Custom:${RESET}"
	@echo "  make run ARGS=\"--symbols BTCUSDT --days 3\""
	@echo ""