use chrono::{Duration, Local, NaiveDate};
use std::fs::File;
use std::io::{Read, Write};
use zip::ZipArchive;

fn main() {
    let args: Vec<String> = std::env::args().collect();

    let mut symbols = vec!["BTCUSDT".to_string()];
    let mut start_date = None;
    let mut end_date = None;
    let mut days_back = None;
    let mut output_name = "dataset".to_string();
    let mut row_limit = None;

    let mut i = 1;
    while i < args.len() {
        match args[i].as_str() {
            "--symbols" | "-s" => {
                i += 1;
                symbols = args[i].split(',').map(|s| s.to_string()).collect();
            }
            "--start" => {
                i += 1;
                start_date = Some(args[i].clone());
            }
            "--end" => {
                i += 1;
                end_date = Some(args[i].clone());
            }
            "--days" | "-d" => {
                i += 1;
                days_back = Some(args[i].parse::<i64>().unwrap_or(3));
            }
            "--limit" | "-l" => {
                i += 1;
                row_limit = Some(args[i].parse::<usize>().unwrap_or(500000));
            }
            "--output" | "-o" => {
                i += 1;
                output_name = args[i].clone();
            }
            "--help" | "-h" => {
                print_help();
                return;
            }
            _ => {
                println!("❌ Bilinmeyen parametre: {}", args[i]);
                print_help();
                return;
            }
        }
        i += 1;
    }

    let dates: Vec<String> = if let (Some(start), Some(end)) = (start_date, end_date) {
        date_range(&start, &end)
    } else if let Some(days) = days_back {
        last_n_days(days)
    } else {
        last_n_days(1)
    };

    println!("\n╔══════════════════════════════════════════════════════════════╗");
    println!("║                    🎯 SENTINEL DATA v2.0                      ║");
    println!("╚══════════════════════════════════════════════════════════════╝\n");

    println!("📊 KONFIGÜRASYON:");
    println!("   ├─ Semboller: {}", symbols.join(", "));
    println!(
        "   ├─ Tarih aralığı: {} - {}",
        dates.first().unwrap_or(&"?".to_string()),
        dates.last().unwrap_or(&"?".to_string())
    );
    println!("   ├─ Toplam gün: {}", dates.len());
    match row_limit {
        Some(limit) => println!(
            "   ├─ Satır limiti: {} (her sembol/gün için)",
            format_number(limit)
        ),
        None => println!("   ├─ Satır limiti: ♾️  (tüm veri)"),
    }
    println!("   └─ Çıktı dosyası: {}\n", output_name);

    println!("════════════════════════════════════════════════════════════════\n");

    // let output_file = format!("datasets/{}_{}.csv", output_name, get_date_string());
    let output_file = format!("datasets/{}.csv", output_name);

    let mut grand_total = 0;
    let mut total_files = 0;

    for symbol in &symbols {
        for date in &dates {
            println!("🔍 {} | {}", symbol, date);
            match download_and_extract(symbol, date, &output_file, row_limit) {
                Ok(row_count) => {
                    if row_count > 0 {
                        grand_total += row_count;
                        total_files += 1;
                        println!("   ✅ {} satır eklendi", format_number(row_count));
                    }
                }
                Err(e) => {
                    println!("   ⚠️  {}", e);
                }
            }
            println!();
        }
    }

    println!("════════════════════════════════════════════════════════════════");
    println!("\n📊 ÖZET:");
    println!("   ├─ Başarılı dosya sayısı: {}", total_files);
    println!("   ├─ Toplam satır: {}", format_number(grand_total));
    println!("   └─ Çıktı: {}", output_file);
    println!("\n✅ İşlem tamamlandı! 🚀\n");
}

fn print_help() {
    println!("\n╔══════════════════════════════════════════════════════════════╗");
    println!("║                    📖 SENTINEL DATA HELP                     ║");
    println!("╚══════════════════════════════════════════════════════════════╝");
    println!("\nKULLANIM:");
    println!("  sentinel [PARAMETRELER]\n");
    println!("PARAMETRELER:");
    println!("  --symbols, -s    : Coin listesi (virgülle ayrılmış)");
    println!("                     Örnek: --symbols BTCUSDT,ETHUSDT");
    println!("  --start          : Başlangıç tarihi (YYYY-MM-DD)");
    println!("  --end            : Bitiş tarihi (YYYY-MM-DD)");
    println!("  --days, -d       : Son N gün");
    println!("  --limit, -l      : Maksimum satır sayısı (varsayılan: limitsiz)");
    println!("  --output, -o     : Çıktı dosyası adı");
    println!("  --help, -h       : Bu yardım");
    println!("\nÖRNEKLER:");
    println!("  ┌─────────────────────────────────────────────────────────┐");
    println!("  │ 1️⃣  Tek coin, tek gün (tüm veri):                       │");
    println!("  │    sentinel --symbols BTCUSDT --days 1                  │");
    println!("  ├─────────────────────────────────────────────────────────┤");
    println!("  │ 2️⃣  Tek coin, çoklu gün (limitli):                      │");
    println!("  │    sentinel --symbols BTCUSDT --start 2026-04-27 \\      │");
    println!("  │              --end 2026-04-29 --limit 100000            │");
    println!("  ├─────────────────────────────────────────────────────────┤");
    println!("  │ 3️⃣  Çoklu coin, tek gün (tüm veri):                     │");
    println!("  │    sentinel --symbols BTCUSDT,ETHUSDT,SOLUSDT --days 1  │");
    println!("  ├─────────────────────────────────────────────────────────┤");
    println!("  │ 4️⃣  Çoklu coin, çoklu gün (7 günlük backtest):          │");
    println!("  │    sentinel --symbols BTCUSDT,ETHUSDT --days 7          │");
    println!("  ├─────────────────────────────────────────────────────────┤");
    println!("  │ 5️⃣  Özel çıktı ve limitsiz:                             │");
    println!("  │    sentinel --symbols BTCUSDT --days 3 \\                │");
    println!("  │              --output my_backtest                       │");
    println!("  └─────────────────────────────────────────────────────────┘");
}

fn date_range(start: &str, end: &str) -> Vec<String> {
    let start = NaiveDate::parse_from_str(start, "%Y-%m-%d").unwrap();
    let end = NaiveDate::parse_from_str(end, "%Y-%m-%d").unwrap();
    let mut dates = vec![];
    let mut current = start;
    while current <= end {
        dates.push(current.format("%Y-%m-%d").to_string());
        current += Duration::days(1);
    }
    dates
}

fn last_n_days(days: i64) -> Vec<String> {
    let now = Local::now();
    let mut dates = vec![];
    for i in (1..=days).rev() {
        let date = now - Duration::days(i);
        dates.push(date.format("%Y-%m-%d").to_string());
    }
    dates
}

fn download_and_extract(
    symbol: &str,
    date: &str,
    output_file: &str,
    row_limit: Option<usize>,
) -> Result<usize, String> {
    let url = format!(
        "https://data.binance.vision/data/spot/daily/aggTrades/{}/{}-aggTrades-{}.zip",
        symbol, symbol, date
    );

    let zip_path = format!("datasets/temp_{}_{}.zip", symbol, date);
    std::fs::create_dir_all("datasets").map_err(|e| format!("Klasör oluşturulamadı: {}", e))?;

    println!("   📥 İndiriliyor...");
    let response = reqwest::blocking::get(&url).map_err(|e| format!("Bağlantı hatası: {}", e))?;

    if response.status() != 200 {
        return Err(format!("❌ Veri yok (HTTP {})", response.status()));
    }

    let bytes = response
        .bytes()
        .map_err(|e| format!("İndirme hatası: {}", e))?;

    if bytes.is_empty() {
        return Err("Boş dosya".to_string());
    }

    let mut file = File::create(&zip_path).map_err(|e| format!("Dosya oluşturulamadı: {}", e))?;
    file.write_all(&bytes)
        .map_err(|e| format!("Yazma hatası: {}", e))?;

    println!("   📦 Arşiv açılıyor...");
    let zip_file = File::open(&zip_path).map_err(|e| format!("Zip açılamadı: {}", e))?;
    let mut archive = ZipArchive::new(zip_file).map_err(|e| format!("Geçersiz zip: {}", e))?;

    let mut total_rows = 0;

    for i in 0..archive.len() {
        let mut file = archive
            .by_index(i)
            .map_err(|e| format!("Arşiv okuma hatası: {}", e))?;

        if file.name().ends_with(".csv") {
            let mut content = String::new();
            file.read_to_string(&mut content)
                .map_err(|e| format!("CSV okuma hatası: {}", e))?;

            let mut output = std::fs::OpenOptions::new()
                .create(true)
                .append(true)
                .open(output_file)
                .map_err(|e| format!("Çıktı dosyası açılamadı: {}", e))?;

            if std::fs::metadata(output_file)
                .map_err(|e| format!("Metadata hatası: {}", e))?
                .len()
                == 0
            {
                writeln!(output, "agg_trade_id,price,qty,first_trade_id,last_trade_id,time,is_buyer_maker,is_best_match")
                    .map_err(|e| format!("Header yazma hatası: {}", e))?;
            }

            let all_lines: Vec<&str> = content.lines().collect();
            let lines_to_take = match row_limit {
                Some(limit) => {
                    if all_lines.len() - 1 > limit {
                        &all_lines[1..=limit]
                    } else {
                        &all_lines[1..]
                    }
                }
                None => &all_lines[1..],
            };

            for line in lines_to_take {
                if !line.is_empty() {
                    writeln!(output, "{}", line)
                        .map_err(|e| format!("Satır yazma hatası: {}", e))?;
                    total_rows += 1;
                }
            }

            break;
        }
    }

    std::fs::remove_file(&zip_path).ok();
    Ok(total_rows)
}

fn format_number(num: usize) -> String {
    if num >= 1_000_000 {
        format!("{:.2}M", num as f64 / 1_000_000.0)
    } else if num >= 1_000 {
        format!("{:.2}K", num as f64 / 1_000.0)
    } else {
        format!("{}", num)
    }
}

// fn get_date_string() -> String {
//     Local::now().format("%Y%m%d_%H%M%S").to_string()
// }
