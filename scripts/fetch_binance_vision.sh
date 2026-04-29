#!/bin/bash
# ========== DOSYA: sentinel-data/scripts/fetch_binance_vision.sh ==========
set -e

# Manuel Tanımlar
S_SYMBOL="BTCUSDT"
S_DATE="2024-04-20"
S_OUT="datasets/test_data.csv"

URL="https://data.binance.vision/data/spot/daily/aggTrades/${S_SYMBOL}/${S_SYMBOL}-aggTrades-${S_DATE}.zip"
ZIP="datasets/temp.zip"
CSV_IN="${S_SYMBOL}-aggTrades-${S_DATE}.csv"

echo "📡 İndiriliyor: $S_DATE"
curl -s -L -o $ZIP $URL

echo "📦 Arşiv açılıyor..."
unzip -q -o $ZIP -d datasets/

echo "⚙️ Veri işleniyor: 1.000.000 satır ayıklanıyor..."
# Değişken karmaşasını önlemek için rakamı doğrudan yazıyoruz
echo "agg_trade_id,price,qty,first_trade_id,last_trade_id,time,is_buyer_maker,is_best_match" > $S_OUT
head -n 1000000 "datasets/$CSV_IN" >> $S_OUT # <-- 1M yaptık

echo "✅ BAŞARILI: $S_OUT hazır. Satır sayısı: $(wc -l < $S_OUT)"
