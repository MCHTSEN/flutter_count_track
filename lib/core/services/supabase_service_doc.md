# Supabase Servisi Dokümantasyonu

## Genel Bakış

Supabase Servisi, Paketleme Takip Sistemi'nin yeni cloud backend entegrasyonunu sağlayan ana modüldür. **Firebase** yerine **Supabase** kullanılarak **offline-first hybrid sync** sistemi ile geliştirilmiştir.

## Ana Özellikler

### 🔄 Offline-First Yaklaşım
- Tüm veriler önce local SQLite veritabanına kaydedilir
- İnternet bağlantısı olmasa bile sistem tam işlevsellik sağlar
- Online olduğunda otomatik senkronizasyon başlar

### 📡 Hybrid Sync Sistemi
- **Background Sync**: Arka planda sürekli senkronizasyon
- **Conflict Resolution**: Veri çakışmalarının akıllı çözümü
- **Timestamp-based Versioning**: Hangi verinin daha güncel olduğunu belirleme

### 🔴 Real-time Updates
- **Supabase Realtime**: Gerçek zamanlı veri güncellemeleri
- **WebSocket Bağlantısı**: Anlık bildirimler
- **Channel-based Subscriptions**: Modüler real-time yapısı

### 📝 Comprehensive Logging
- **Structured Logging**: Tüm işlemler kategorize edilmiş loglar
- **Error Tracking**: Detaylı hata analizi
- **Performance Monitoring**: İşlem performans ölçümü

## Mimari Yapı

```
lib/core/services/
├── supabase_service.dart          # Ana Supabase servisi
├── supabase_service_doc.md       # Bu dokümantasyon
└── supabase_config.dart          # Konfigürasyon ayarları

Related Files:
├── core/config/supabase_config.dart    # Config sabitler
├── core/database/database_provider.dart # Provider entegrasyonu
└── main.dart                           # Başlangıç konfigürasyonu
```

## Ana Sınıflar

### 1. SupabaseService (Static Class)

Ana Supabase client'ını yöneten static sınıf.

```dart
class SupabaseService {
  static final Logger _logger = Logger('SupabaseService');
  static SupabaseClient? _client;
  static bool _initialized = false;
  static bool _isOnline = false;
  static String _deviceId;

  // Ana metotlar
  static Future<void> initialize({required String url, required String anonKey})
  static SupabaseClient get client
  static bool get isInitialized
  static bool get isOnline
  static String get deviceId
  static Future<void> dispose()

  // Özel metotlar
  static void _startConnectivityMonitoring()
  static void _updateConnectionStatus(List<ConnectivityResult> result)
  static void _triggerSync()
  static String _generateDeviceId()
}
```

**Temel Özellikler:**
- 🚀 **Lazy Initialization**: İlk kullanımda başlatılır
- 📶 **Connectivity Monitoring**: İnternet bağlantısını sürekli izler
- 🔐 **PKCE Auth Flow**: Güvenli kimlik doğrulama
- 📱 **Device Tracking**: Her cihaz için benzersiz ID

### 2. SupabaseSyncService (Instance Class)

Local database ile Supabase arasında sync işlemlerini yöneten sınıf.

```dart
class SupabaseSyncService {
  static final Logger _logger = Logger('SupabaseSyncService');
  late final AppDatabase _localDb;
  late final SupabaseClient _supabaseClient;

  // Constructor
  SupabaseSyncService({required AppDatabase localDatabase, required SupabaseClient supabaseClient})

  // Fetch/Pull metotları
  Future<List<Map<String, dynamic>>> fetchOrdersFromSupabase({...})
  
  // Push metotları  
  Future<void> pushOrderToSupabase(Order order)
  Future<void> pushBarcodeReadToSupabase({...})
  
  // Conflict Resolution
  Future<void> resolveConflicts()
  Future<void> _updateLocalOrderFromRemote(String orderCode, Map<String, dynamic> remoteOrder)
  
  // Realtime
  RealtimeChannel subscribeToOrderChanges(Function(Map<String, dynamic>) onOrderChange)
  Future<void> unsubscribeFromOrderChanges(RealtimeChannel channel)
}
```

**Sync Stratejileri:**
- 📥 **Pull-First**: Önce remote'dan local'e çek
- 📤 **Push-On-Change**: Değişiklik olduğunda hemen gönder
- ⚖️ **Last-Write-Wins**: En son güncellenen kazanır
- 🔄 **Eventual Consistency**: Nihai tutarlılık

## Kullanım Örnekleri

### 1. Başlangıç Konfigürasyonu

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Logging'i başlat
  _setupLogging();
  
  // Supabase'i başlat
  await SupabaseService.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  
  runApp(MyApp());
}
```

### 2. Order Repository'de Kullanım

```dart
class OrderRepositoryImpl implements OrderRepository {
  final AppDatabase _db;
  final SupabaseSyncService? _syncService;
  
  @override
  Future<List<Order>> getOrders({String? searchQuery, OrderStatus? filterStatus}) async {
    // 1. Önce local'den al (offline-first)
    final localOrders = await _getLocalOrders(searchQuery, filterStatus);
    
    // 2. Online ise arka planda sync et
    if (SupabaseService.isOnline && _syncService != null) {
      _syncOrdersInBackground(searchQuery, filterStatus);
    }
    
    return localOrders;
  }
}
```

### 3. Barkod Okuma Sync'i

```dart
Future<bool> updateOrderItemScannedQuantity(String orderItemId, int newQuantity) async {
  // 1. Local'i güncelle
  final success = await _updateLocalQuantity(orderItemId, newQuantity);
  
  // 2. Online ise Supabase'e gönder
  if (success && SupabaseService.isOnline && _syncService != null) {
    await _syncService!.pushBarcodeReadToSupabase(
      orderCode: orderCode,
      barcode: barcode,
      productId: productId,
      scannedQuantity: newQuantity,
    );
  }
  
  return success;
}
```

### 4. Real-time Subscriptions

```dart
void setupRealtimeSubscription() {
  final channel = _syncService.subscribeToOrderChanges((orderData) {
    // Real-time order değişikliği geldi
    _logger.info('📡 Real-time order güncellendi: ${orderData['order_code']}');
    // UI'ı güncelle
    _refreshOrderList();
  });
  
  // Dispose'da subscription'ı kapat
  ref.onDispose(() {
    _syncService.unsubscribeFromOrderChanges(channel);
  });
}
```

## Veri Akışı Diyagramı

```
[LOCAL OPERATION] → [LOCAL DATABASE] → [SUCCESS]
                              ↓
[ONLINE CHECK] → [SUPABASE SYNC] → [BACKGROUND]
                         ↓
[CONFLICT RESOLUTION] → [UPDATE LOCAL] → [UI REFRESH]
```

## Hata Yönetimi

### 1. Network Hataları
```dart
try {
  await _supabaseClient.from('orders').select();
} catch (e) {
  if (e is PostgrestException) {
    _logger.severe('💥 Supabase sorgu hatası: ${e.message}');
  } else if (e is SocketException) {
    _logger.warning('📶 İnternet bağlantısı yok, offline mode');
  }
  // Graceful degradation - local data kullan
  return await _getLocalData();
}
```

### 2. Conflict Resolution
```dart
Future<void> resolveConflicts() async {
  for (final localOrder in localOrders) {
    final remoteOrder = await _getRemoteOrder(localOrder.orderCode);
    
    if (remoteOrder != null) {
      if (remoteOrder.updatedAt.isAfter(localOrder.updatedAt)) {
        // Remote daha güncel
        await _updateLocalFromRemote(localOrder, remoteOrder);
        _logger.info('🔄 Remote kazandı: ${localOrder.orderCode}');
      } else if (localOrder.updatedAt.isAfter(remoteOrder.updatedAt)) {
        // Local daha güncel
        await _pushLocalToRemote(localOrder);
        _logger.info('🔄 Local kazandı: ${localOrder.orderCode}');
      }
    }
  }
}
```

## Performance Optimizasyonları

### 1. Batch Operations
```dart
// Tekil işlemler yerine batch kullan
await _supabaseClient.from('orders').upsert([
  order1Data,
  order2Data,
  order3Data,
], onConflict: 'order_code');
```

### 2. Selective Sync
```dart
// Sadece değişen alanları sync et
await _supabaseClient.from('orders')
  .update({'scanned_quantity': newQuantity, 'updated_at': now})
  .eq('id', orderId);
```

### 3. Connection Pooling
```dart
// Tek client instance kullan
static SupabaseClient get client {
  if (_client == null) {
    throw StateError('Supabase not initialized');
  }
  return _client!;
}
```

## Monitoring ve Analytics

### 1. Logging Categories
```dart
// İşlem tipleri
_logger.info('📖 Data fetch operation');      // Data operations
_logger.info('📤 Data push operation');       // Sync operations  
_logger.info('🔄 Conflict resolution');       // Conflict handling
_logger.info('🔴 Realtime update');          // Real-time events
_logger.info('📶 Connectivity change');       // Network status
```

### 2. Performance Metrics
```dart
final stopwatch = Stopwatch()..start();
await _performSyncOperation();
stopwatch.stop();
_logger.info('⏱️ Sync completed in ${stopwatch.elapsedMilliseconds}ms');
```

### 3. Error Categorization
```dart
try {
  await _operation();
} catch (e, stackTrace) {
  if (e is TimeoutException) {
    _logger.warning('⏰ Operation timeout');
  } else if (e is FormatException) {
    _logger.severe('💥 Data format error', e, stackTrace);
  } else {
    _logger.severe('💥 Unknown error', e, stackTrace);
  }
}
```

## Güvenlik Konuları

### 1. Row Level Security (RLS)
```sql
-- Supabase'de RLS politikaları
CREATE POLICY "Users can only see their company orders" ON orders
  FOR SELECT USING (company_id = auth.jwt() ->> 'company_id');

CREATE POLICY "Users can only update their company orders" ON orders  
  FOR UPDATE USING (company_id = auth.jwt() ->> 'company_id');
```

### 2. Data Validation
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

### 3. Secure Local Storage
```dart
// Hassas verileri encrypt et
const secureStorage = FlutterSecureStorage();
await secureStorage.write(key: 'device_id', value: deviceId);
```

## Troubleshooting

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

### Debug Komutları

```dart
// Supabase durumunu kontrol et
print('Initialized: ${SupabaseService.isInitialized}');
print('Online: ${SupabaseService.isOnline}');
print('Device ID: ${SupabaseService.deviceId}');

// Sync durumunu kontrol et
final syncService = ref.read(supabaseSyncServiceProvider);
await syncService.resolveConflicts();
```

## Gelecek Geliştirmeler

- [ ] **Incremental Sync**: Sadece değişen kayıtları sync etme
- [ ] **Offline Queue Management**: Offline işlemlerin kuyruk yönetimi
- [ ] **Advanced Conflict Resolution**: Kullanıcı müdahaleli çakışma çözümü
- [ ] **Data Compression**: Sync verilerinin sıkıştırılması
- [ ] **Health Monitoring**: Sistem sağlığı izleme
- [ ] **Auto-retry Logic**: Başarısız işlemlerin otomatik tekrarı
- [ ] **Migration Tools**: Eski Firebase verilerinin geçişi

## Bağımlılıklar

```yaml
dependencies:
  supabase_flutter: ^2.10.0
  connectivity_plus: ^6.1.4
  logging: ^1.2.0
  drift: ^2.14.0
```

## Test Stratejisi

### Unit Tests
- [ ] SupabaseService initialization
- [ ] Connectivity monitoring
- [ ] Sync operations
- [ ] Conflict resolution logic

### Integration Tests  
- [ ] End-to-end sync flow
- [ ] Offline/online transitions
- [ ] Real-time subscriptions
- [ ] Error scenarios

### Performance Tests
- [ ] Large dataset sync
- [ ] Concurrent operations
- [ ] Memory usage
- [ ] Battery impact (mobile)

## Lisans ve Attribution

Bu modül MIT lisansı altında yayınlanmıştır. Supabase client'ı Supabase ekibi tarafından geliştirilmiştir.

---

**Son Güncelleme**: 2024-12-19  
**Versiyon**: 2.0.0  
**Durum**: ✅ Aktif Geliştirme 