# 📊 sentinel-data (The HFT Gym)

**Rol:** Sistemin optimizasyonu için gereken ham borsa verilerini hazırlar.

## 📁 Dataset Yapısı
- `datasets/test_data.csv`: Optimizer tarafından kullanılan aktif eğitim verisi. (Git'e eklenmez!)

## 🛠️ Veri Hazırlama Talimatı
Eğer yeni bir veriyle (Örn: 2025 verisi) sistemi eğitmek isterseniz:
1. `Makefile` içindeki tarih veya sembolü güncelleyin.
2. `make fetch-halving` komutunu çalıştırın.

Bu komut otomatik olarak:
- Binance Vision'dan ham veriyi indirir.
- `True/False` büyük harf hatalarını tolere edecek başlıkları (Headers) ekler.
- İlk 100.000 satırı (HFT için yeterli örneklem) kırpar.