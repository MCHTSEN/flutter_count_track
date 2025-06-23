# 🚀 Firebase → Supabase Migration Guide

## Genel Bakış

Bu dokümantasyon, Paketleme Takip Sistemi'nin **Firebase** backend'inden **Supabase** backend'ine geçiş sürecini açıklar. Yeni sistem **offline-first hybrid sync** yaklaşımı ile geliştirilmiştir.

## 🔄 Değişiklik Özeti

### Eski Sistem (v1.x)
- ❌ Firebase Firestore
- ❌ Online-only yaklaşım
- ❌ Sınırlı offline desteği
- ❌ Temel conflict handling

### Yeni Sistem (v2.0)
- ✅ **Supabase** backend
- ✅ **Offline-first** yaklaşım
- ✅ **Hybrid sync** sistemi
- ✅ **Advanced conflict resolution**
- ✅ **Real-time updates**
- ✅ **Comprehensive logging**

## 📁 Değiştirilen Dosyalar

### 1. Bağımlılıklar
```yaml
# pubspec.yaml
dependencies:
  # ❌ Kaldırılan
  # firebase_core: ^3.8.0
  # cloud_firestore: ^5.5.0
  
  # ✅ Eklenen
  supabase_flutter: ^2.10.0
  logging: ^1.2.0
```

### 2. Yeni Dosyalar
```
✅ lib/core/services/supabase_service.dart
✅ lib/core/config/supabase_config.dart
✅ lib/core/services/supabase_service_doc.md
✅ SUPABASE_MIGRATION_README.md
```

### 3. Güncellenen Dosyalar
```
🔄 lib/main.dart
🔄 lib/core/database/database_provider.dart
🔄 lib/features/order_management/data/repositories/order_repository_impl.dart
🔄 lib/features/order_management/presentation/notifiers/order_providers.dart
🔄 lib/features/order_management/order_management_doc.md
🔄 lib/core/database/database_doc.md
```

### 4. Kaldırılan Dosyalar
```
❌ lib/core/services/firebase_service.dart
```

## 🎯 Ana Özellikler

### 1. Offline-First Yaklaşım
```dart
// Tüm işlemler önce local'de yapılır
final localOrders = await _getLocalOrders();

// Online ise arka planda sync
if (SupabaseService.isOnline) {
  _syncInBackground();
}

return localOrders; // Hemen döndür
```

### 2. Hybrid Sync Sistemi
```dart
// Barkod okuma örneği
Future<bool> updateOrderItemScannedQuantity(String orderItemId, int newQuantity) async {
  // 1. Local güncelle (offline-first)
  final success = await _updateLocal(orderItemId, newQuantity);
  
  // 2. Online ise Supabase'e gönder
  if (success && SupabaseService.isOnline) {
    await _syncToSupabase(orderItemId, newQuantity);
  }
  
  return success;
}
```

### 3. Conflict Resolution
```dart
// Timestamp tabanlı çözüm
if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
  // Remote kazandı - local'i güncelle
  await _updateLocalFromRemote(remoteData);
} else if (localUpdatedAt.isAfter(remoteUpdatedAt)) {
  // Local kazandı - remote'u güncelle
  await _pushLocalToRemote(localData);
}
```

### 4. Real-time Updates
```dart
// Supabase Realtime subscription
final channel = _supabaseClient
    .channel('order_changes')
    .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'orders',
      callback: (payload) => _handleOrderChange(payload),
    )
    .subscribe();
```

### 5. Comprehensive Logging
```dart
// Kategorize edilmiş loglar
_logger.info('📖 Data fetch operation');      // Data operations
_logger.info('📤 Data push operation');       // Sync operations  
_logger.info('🔄 Conflict resolution');       // Conflict handling
_logger.info('🔴 Realtime update');          // Real-time events
_logger.info('📶 Connectivity change');       // Network status
```

## 🛠️ Kurulum ve Yapılandırma

### 1. Bağımlılıkları Güncelle
```bash
flutter pub get
```

### 2. Supabase Konfigürasyonu
```dart
// lib/core/config/supabase_config.dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

### 3. Main.dart Konfigürasyonu
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Logging başlat
  _setupLogging();
  
  // Supabase başlat
  await SupabaseService.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  
  runApp(MyApp());
}
```

## 📊 Veri Akışı

### Eski Sistem (Firebase)
```
[UI ACTION] → [FIREBASE] → [NETWORK] → [SUCCESS/ERROR]
                ↓
[LOCAL CACHE] ← [OFFLINE LIMITED]
```

### Yeni Sistem (Supabase)
```
[UI ACTION] → [LOCAL DB] → [IMMEDIATE SUCCESS]
                  ↓
[ONLINE CHECK] → [SUPABASE SYNC] → [BACKGROUND]
                      ↓
[CONFLICT RESOLUTION] → [UPDATE LOCAL] → [UI REFRESH]
```

## 🔍 Testing ve Debug

### Debug Komutları
```dart
// Supabase durumu
print('Initialized: ${SupabaseService.isInitialized}');
print('Online: ${SupabaseService.isOnline}');
print('Device ID: ${SupabaseService.deviceId}');

// Sync durumu
final syncService = ref.read(supabaseSyncServiceProvider);
await syncService.resolveConflicts();
```

### Log Monitoring
```bash
# Console'da logları filtrele
flutter logs | grep "SupabaseService"
flutter logs | grep "OrderRepositoryImpl"
flutter logs | grep "🔄"  # Sync operations
flutter logs | grep "💥"  # Errors
```

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