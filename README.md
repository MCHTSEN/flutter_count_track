# Flutter Count Track

Paketleme süreçlerini takip etmek için geliştirilmiş Flutter masaüstü uygulaması.

## Özellikler

- 📦 Sipariş yönetimi
- 🔍 Barkod okuma ve sayım
- 📊 Dashboard ve raporlama
- 🔄 Offline-first hibrit sync sistemi
- 🎵 Sesli bildirimler
- 📱 Modern, responsive UI

## Teknolojiler

- **Framework:** Flutter Desktop
- **State Management:** Riverpod
- **Database:** SQLite (Drift)
- **Backend Sync:** Supabase
- **Architecture:** MVVM

## Supabase Tabloları

Uygulamada kullanılan 4 ana tablo:

1. **products** - Ürün bilgileri
2. **orders** - Sipariş bilgileri  
3. **order_items** - Sipariş kalemleri
4. **product_code_mappings** - Müşteri ürün kodu eşleştirme

## Kurulum

1. Bağımlılıkları yükleyin:
```bash
flutter pub get
```

2. Supabase yapılandırmasını tamamlayın:
   - `lib/core/config/supabase_config.dart` dosyasını düzenleyin
   - `supabase_schema.sql` dosyasını Supabase SQL Editor'da çalıştırın

3. Uygulamayı çalıştırın:
```bash
flutter run -d windows
```

## Proje Yapısı

```
lib/
├── core/                 # Temel servisler ve yapılandırma
├── features/            # Ana özellikler (sipariş, barkod, dashboard)
└── shared_widgets/      # Ortak bileşenler
```

## Geliştirme

- Kodlama kuralları: `.cursorrules` dosyasına bakın
- Mimari: MVVM pattern
- UI: Component-based yapı
- Database: Offline-first yaklaşım
