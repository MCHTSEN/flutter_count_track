# Supabase Integration Guide

Bu döküman, projenin Supabase entegrasyonu ve kullanımını açıklar.

## Mevcut Durum

Uygulama **offline-first hybrid sync** yaklaşımı ile **4 ana tablo** kullanıyor:

### ✅ Aktif Tablolar
1. **products** - Ürün bilgileri
2. **orders** - Sipariş bilgileri
3. **order_items** - Sipariş kalemleri
4. **product_code_mappings** - Müşteri ürün kodu eşleştirme

## Offline-First Yaklaşım
```dart
// Tüm işlemler önce local'de yapılır
final localOrders = await _getLocalOrders();

// Online ise arka planda sync
if (SupabaseService.isOnline) {
  _syncInBackground();
}

return localOrders; // Hemen döndür
```

## Kurulum

### 1. Supabase Konfigürasyonu
```dart
// lib/core/config/supabase_config.dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

### 2. Veritabanı Şeması
`supabase_schema.sql` dosyasını Supabase Dashboard > SQL Editor'da çalıştırın.

## 📈 Performance Optimizasyonları

### 1. Batch Operations
```dart
// Tekil yerine batch işlemler
await _supabaseClient.from('orders').upsert([
  order1Data, order2Data, order3Data
], onConflict: 'order_code');
```

### 2. Selective Sync
```dart
// Sadece değişen alanları sync et
await _supabaseClient.from('orders')
  .update({'scanned_quantity': newQuantity})
  .eq('id', orderId);
```

### 3. Connection Pooling
```dart
// Tek client instance
static SupabaseClient get client {
  if (_client == null) {
    throw StateError('Supabase not initialized');
  }
  return _client!;
}
```

## 🚨 Troubleshooting

### Yaygın Sorunlar

#### 1. Initialization Failed
```
💥 Supabase: Başlatma hatası: Invalid URL or API key
```
**Çözüm**: `SupabaseConfig`'deki URL ve API key'i kontrol edin.

#### 2. Sync Conflicts
```
🔄 Conflict resolution başlatıldı - 5 çakışma bulundu
```
**Çözüm**: Normal durum, sistem otomatik çözecek.

#### 3. Network Timeout
```
📶 İnternet bağlantısı yok, offline mode
```
**Çözüm**: Sistem offline çalışmaya devam eder.

### Error Categories
- 📶 **Network**: İnternet bağlantısı sorunları
- 💥 **Critical**: Sistem çökmesi riski olan hatalar  
- ⚠️ **Warning**: Dikkat gerektiren durumlar
- ℹ️ **Info**: Bilgilendirici mesajlar

## 🔐 Güvenlik Görevleri

### Supabase RLS Politikaları
```sql
-- Orders tablosu için RLS
CREATE POLICY "Users can only see their company orders" ON orders
  FOR SELECT USING (company_id = auth.jwt() ->> 'company_id');

CREATE POLICY "Users can only update their company orders" ON orders  
  FOR UPDATE USING (company_id = auth.jwt() ->> 'company_id');
```

### Data Validation
```dart
Future<void> pushOrderToSupabase(Order order) async {
  // Veri doğrulama
  if (order.orderCode.isEmpty) {
    throw ArgumentError('Order code cannot be empty');
  }
  
  if (order.customerName.length > 255) {
    throw ArgumentError('Customer name too long');
  }
  
  // Supabase'e gönder
  await _supabaseClient.from('orders').upsert(order.toJson());
}
```

## 📚 Dokümantasyon

### Ana Dokümanlar
- 📖 [Supabase Servisi](lib/core/services/supabase_service_doc.md)
- 📖 [Order Management](lib/features/order_management/order_management_doc.md)
- 📖 [Database](lib/core/database/database_doc.md)

### Code Examples
- 🔧 [Order Repository Implementation](lib/features/order_management/data/repositories/order_repository_impl.dart)
- 🔧 [Supabase Service](lib/core/services/supabase_service.dart)
- 🔧 [Order Providers](lib/features/order_management/presentation/notifiers/order_providers.dart)

## 🚀 Gelecek Geliştirmeler

### Kısa Vadeli (1-2 ay)
- [ ] **Sync Queue Management**: Offline işlemlerin kuyruk yönetimi
- [ ] **Auto-retry Logic**: Başarısız işlemlerin otomatik tekrarı
- [ ] **Health Monitoring**: Sistem sağlığı dashboard'u

### Orta Vadeli (3-6 ay)
- [ ] **Incremental Sync**: Sadece değişen kayıtları sync etme
- [ ] **Advanced Conflict Resolution**: Kullanıcı müdahaleli çözüm
- [ ] **Data Compression**: Sync verilerinin sıkıştırılması

### Uzun Vadeli (6+ ay)
- [ ] **Multi-tenant Support**: Çoklu şirket desteği
- [ ] **Migration Tools**: Firebase'den veri geçiş araçları
- [ ] **Analytics Integration**: Kullanım analytics'i

## 📞 Destek ve İletişim

### Log Analizi
Sistem logları aşağıdaki kategorilerde takip edilebilir:

```bash
# Tüm Supabase logları
flutter logs | grep "Supabase"

# Sync işlemleri
flutter logs | grep "🔄"

# Hata durumları  
flutter logs | grep "💥"

# Network durumu
flutter logs | grep "📶"
```

### Performance Monitoring
```dart
// İşlem süreleri
final stopwatch = Stopwatch()..start();
await _performSyncOperation();
stopwatch.stop();
_logger.info('⏱️ Sync completed in ${stopwatch.elapsedMilliseconds}ms');
```

---

## 📋 Migration Checklist

### Ön Hazırlık
- [x] Supabase projesi oluşturuldu
- [x] Database schema hazırlandı
- [x] RLS politikaları tanımlandı
- [x] API keys alındı

### Code Migration
- [x] Firebase bağımlılıkları kaldırıldı
- [x] Supabase bağımlılıkları eklendi
- [x] Supabase servisi oluşturuldu
- [x] Order repository güncellendi
- [x] Providers güncellendi
- [x] Main.dart konfigüre edildi

### Testing
- [ ] Unit testler yazılacak
- [ ] Integration testler yazılacak
- [ ] Performance testler yapılacak
- [ ] Offline scenario testleri yapılacak

### Documentation
- [x] Migration guide oluşturuldu
- [x] Supabase servisi dokümante edildi
- [x] Order management güncellendi
- [x] Database docs güncellendi

### Deployment
- [ ] Staging environment test edilecek
- [ ] Production deployment planlanacak
- [ ] Rollback planı hazırlanacak
- [ ] Monitoring kurulacak

---

**Son Güncelleme**: 2024-12-19  
**Migration Versiyonu**: v2.0.0  
**Durum**: ✅ Development Complete, Testing Phase 

# Supabase Migration Guide

Bu döküman, projenin Supabase entegrasyonu ve migration sürecini açıklar.

## Mevcut Durum

Uygulama şu anda **4 ana tablo** ile çalışmaktadır:

### ✅ Aktif Tablolar
1. **products** - Ürün bilgileri
2. **orders** - Sipariş bilgileri
3. **order_items** - Sipariş kalemleri
4. **product_code_mappings** - Müşteri ürün kodu eşleştirme

## Migration Adımları

### 1. Supabase Proje Kurulumu
```bash
# Supabase CLI kurulumu
npm install -g supabase

# Proje başlatma
supabase init
```

### 2. Veritabanı Şeması Oluşturma
`supabase_schema.sql` dosyasını Supabase Dashboard > SQL Editor'da çalıştırın.

### 3. Konfigürasyon
`lib/core/config/supabase_config.dart` dosyasında:
```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

### 4. RLS Politikaları
Şu anda basit authenticated user politikası kullanılıyor. Gelecekte daha granüler politikalar eklenebilir.

## Offline-First Yaklaşım

- Tüm veriler önce SQLite'a yazılır
- Supabase senkronizasyonu arka planda yapılır
- İnternet bağlantısı olmadığında uygulama çalışmaya devam eder

## Sync Stratejisi

1. **Okuma**: Önce local, sonra remote'dan güncelleme
2. **Yazma**: Önce local, sonra remote'a gönderim
3. **Conflict Resolution**: Timestamp bazlı (son güncelleme kazanır)

## Önemli Notlar

- API maliyetlerini azaltmak için real-time özellikler sınırlı kullanılıyor
- Gereksiz tablolar kaldırıldı (barcode_reads, deliveries, boxes vb.)
- Test verileri schema'da mevcut 