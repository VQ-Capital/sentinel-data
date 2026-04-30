# 📊 Sentinel Data v2.0

**Binance Vision’dan yüksek hacimli HFT verisi çeken, Rust ile yazılmış performans odaklı veri aracı.**

[![Rust](https://img.shields.io/badge/rust-1.70%2B-orange)](https://www.rust-lang.org/)
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](LICENSE)

---

## 🚀 Quick Start

```bash
# Derle
make build

# Tek coin, son 1 gün
make single-single
````

veya direkt:

```bash
./target/release/sentinel --symbols BTCUSDT --days 1
```

---

## ⚡ Temel Kullanım

```bash
# Çoklu coin, son 7 gün
sentinel --symbols BTCUSDT,ETHUSDT,SOLUSDT --days 7

# Tarih aralığı ile backtest
sentinel --symbols BTCUSDT,ETHUSDT --start 2026-04-20 --end 2026-04-29

# Limitli veri (hızlı test)
sentinel --symbols BTCUSDT --days 1 --limit 10000
```

---

## 🎯 Özellikler

* ⚡ **Yüksek performans** (Rust + streaming I/O)
* 🧠 **Backtest odaklı** (tarih aralığı & multi-asset)
* 📦 **Büyük veri dostu** (RAM’e yüklenmeden işlem)
* 🔧 **CLI-first tasarım** (script & pipeline uyumlu)
* 📊 **Okunaklı çıktı** (1.2M / 340K formatı)

---

## 📦 Kurulum

```bash
make install
```

Sonrasında:

```bash
sentinel --symbols BTCUSDT --days 3
```

---

## ⚙️ Parametreler

| Parametre   | Açıklama                         |
| ----------- | -------------------------------- |
| `--symbols` | Coin listesi (`BTCUSDT,ETHUSDT`) |
| `--days`    | Son N gün                        |
| `--start`   | Başlangıç tarihi                 |
| `--end`     | Bitiş tarihi                     |
| `--limit`   | Maksimum satır                   |
| `--output`  | Çıktı dosya adı                  |

---

## 📊 Çıktı

* Format: CSV (aggTrades)
* Konum: `datasets/`
* Örnek:

```csv
agg_trade_id,price,qty,first_trade_id,last_trade_id,time,is_buyer_maker,is_best_match
12345678,67890.12,0.001,12345670,12345685,1682755200000,true,true
```

---

## ⚠️ Notlar

* Binance Vision verileri **1 gün gecikmeli** yayınlanır
* Veri yoksa işlem atlanır (pipeline kırılmaz)
* `--limit` yoksa tüm veri çekilir

---

## 🧹 Temizlik

```bash
make clean
make clean-datasets
```

---

## 📁 Proje Yapısı

```
sentinel-data/
├── src/
├── datasets/
├── Cargo.toml
├── Makefile
└── README.md
```

---

## 📜 Lisans

This project is licensed under the GNU AGPL v3.
