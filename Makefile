# ========== DOSYA: sentinel-data/Makefile ==========
.PHONY: fetch-data clean

fetch-data:
	@chmod +x scripts/fetch_binance_vision.sh
	@echo "🚀 HFT Eğitim Seti Hazırlanıyor (100k Tick)..."
	./scripts/fetch_binance_vision.sh