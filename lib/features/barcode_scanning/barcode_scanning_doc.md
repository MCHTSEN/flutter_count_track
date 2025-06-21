# Barkod Okuma (Barcode Scanning) Modülü Dokümantasyonu

## Genel Bakış

Barkod Okuma modülü, üretim sürecinde ürünlerin barkodlarını okuyarak sipariş takibi yapmak için geliştirilmiştir. Bu modül MVVM mimarisi ile clean architecture prensiplerini takip eder ve ses/görsel geri bildirim sağlar.

## Modül Yapısı

```
lib/features/barcode_scanning/
├── data/
│   ├── datasources/
│   ├── models/
│   ├── repositories/
│   │   └── barcode_repository_impl.dart
│   └── services/
│       └── sound_service.dart
├── domain/
│   ├── entities/
│   ├── repositories/
│   │   └── barcode_repository.dart
│   └── usecases/
│       └── process_barcode_usecase.dart
└── presentation/
    ├── notifiers/
    │   └── barcode_notifier.dart
    ├── screens/
    │   └── barcode_test_screen.dart
    └── widgets/
        ├── barcode_notification_widget.dart
        ├── barcode_scanner_input.dart
        ├── barcode_simulator_widget.dart
        └── order_item_progress.dart
```

## Barkod İşleme Süreci

### 1. Barkod Durumları (BarcodeStatus)
```dart
enum BarcodeStatus {
  none,        // Hiç işlem yok
  processing,  // İşlem devam ediyor
  success,     // Başarılı okuma
  warning,     // Uyarı (tekrarlanan barkod vb.)
  error,       // Hata (ürün bulunamadı vb.)
}
```

### 2. Barkod İşlem Sonuçları (BarcodeProcessResult)
```dart
enum BarcodeProcessResult {
  success,                    // Başarılı okuma
  duplicateUniqueBarcode,     // Tekrarlanan tekil barkod
  productNotFound,            // Ürün bulunamadı
  productNotInOrder,          // Ürün siparişte değil
  orderItemAlreadyComplete,   // Sipariş kalemi zaten tamamlandı
}
```

## Domain Katmanı

### BarcodeRepository Interface (`domain/repositories/barcode_repository.dart`)
```dart
abstract class BarcodeRepository {
  /// Müşteri ürün kodu ve müşteri adına göre ürün bilgisini bulur
  Future<Product?> findProductByCustomerCode(String customerProductCode, String customerName);
  
  /// Sipariş ve ürün ID'sine göre sipariş kalemini bulur
  Future<OrderItem?> findOrderItemByProductId(int orderId, int productId);
  
  /// Sipariş kaleminin taranan miktarını günceller
  Future<void> updateOrderItemScannedQuantity(int orderItemId, int newScannedQuantity);
  
  /// Barkod okuma işlemini kaydeder ve log ID'sini döndürür
  Future<int> logBarcodeRead(int orderId, int? productId, String barcode, {int? boxNumber});

  /// Var olan bir barkod kaydını ürün ID'si ile günceller
  Future<void> updateBarcodeReadWithProductId(int logId, int productId);
  
  /// Benzersiz barkodun daha önce taranıp taranmadığını kontrol eder
  Future<bool> isUniqueBarcodeAlreadyScanned(int orderId, int productId, String barcode);
  
  /// Siparişin tamamlanıp tamamlanmadığını kontrol eder
  Future<bool> checkIfOrderComplete(int orderId);
  
  /// Sipariş durumunu günceller
  Future<void> updateOrderStatus(int orderId, OrderStatus status);
}
```

### ProcessBarcodeUseCase (`domain/usecases/process_barcode_usecase.dart`)
```dart
class ProcessBarcodeUseCase {
  final BarcodeRepository _barcodeRepository;
  
  Future<BarcodeProcessResult> call({
    required int orderId,
    required String barcode,
    required String customerName,
    int? boxNumber,
  })
}
```

**İşlem Sırası (Güncellenmiş Mantık):**
1. Barkoda karşılık gelen ürünü bul (doğrudan barkod veya müşteri kod eşleştirmesi). Ürün bulunamazsa, denemeyi kaydet ve süreci sonlandır.
2. Ürünün siparişte olup olmadığını kontrol et.
3. Ürün için benzersiz barkod kontrolü yap (eğer ürün bunu gerektiriyorsa). Tekrar eden barkod ise süreci sonlandır.
4. Sipariş kaleminin miktarının dolup dolmadığını kontrol et. Doluysa süreci sonlandır.
5. **Tüm kontrollerden geçerse**, barkod okuma kaydını veritabanına **tek seferde** oluştur.
6. Sipariş kaleminin taranan miktarını artır.
7. Sipariş durumunu güncelle (kısmen/tamamen tamamlandı).

## Data Katmanı

### BarcodeRepositoryImpl (`data/repositories/barcode_repository_impl.dart`)
```dart
class BarcodeRepositoryImpl implements BarcodeRepository {
  final AppDatabase database;
  
  @override
  Future<Product?> findProductByCustomerCode(String customerProductCode, String customerName) async {
    // Önce doğrudan barkod ile ürün tablosunda ara
    final productByBarcode = await (database.select(database.products)
      ..where((tbl) => tbl.barcode.equals(customerProductCode)))
      .getSingleOrNull();
    
    if (productByBarcode != null) return productByBarcode;
    
    // Eğer doğrudan barkod ile bulunamadıysa, müşteri ürün kodu eşleştirmesi ile ara
    final mapping = await (database.select(database.productCodeMappings)
      ..where((tbl) => tbl.customerProductCode.equals(customerProductCode))
      ..where((tbl) => tbl.customerName.equals(customerName)))
      .getSingleOrNull();
    
    if (mapping == null) return null;
    
    // Eşleşen ürün kaydını bul
    return await (database.select(database.products)
      ..where((tbl) => tbl.id.equals(mapping.productId)))
      .getSingleOrNull();
  }
}
```

**Özellikler:**
- İki aşamalı ürün arama (doğrudan barkod + müşteri kod eşleştirmesi)
- Barkod okuma kayıtları tutma
- Benzersiz barkod kontrolü
- Sipariş durumu otomatik güncelleme

### SoundService (`data/services/sound_service.dart`)
```dart
enum SoundType {
  success,  // Başarılı okuma sesi
  warning,  // Uyarı sesi  
  error,    // Hata sesi
}

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  
  Future<void> playSound(SoundType type) async {
    String path;
    switch (type) {
      case SoundType.success: path = 'sounds/success.mp3'; break;
      case SoundType.warning: path = 'sounds/warning.mp3'; break;
      case SoundType.error: path = 'sounds/error.mp3'; break;
    }
    await _audioPlayer.play(AssetSource(path));
  }
}
```

**Özellikler:**
- Singleton pattern
- Asset'lerden ses çalma
- Hata toleranslı (ses çalınamazsa sessizce devam)
- AudioPlayer integration

## Presentation Katmanı

### BarcodeState
```dart
class BarcodeState {
  final BarcodeStatus status;
  final String message;
  final bool isProcessing;
  
  BarcodeState copyWith({BarcodeStatus? status, String? message, bool? isProcessing})
}
```

### BarcodeNotifier (`presentation/notifiers/barcode_notifier.dart`)
```dart
class BarcodeNotifier extends StateNotifier<BarcodeState> {
  final ProcessBarcodeUseCase _processBarcodeUseCase;
  final SoundService _soundService;
  
  Future<void> processBarcode({
    required String barcode,
    required int orderId,
    required String customerName,
    required VoidCallback onOrderUpdated,
  }) async {
    // İşlem devam ediyorsa çık
    if (state.isProcessing) return;
    
    // Loading state'e geç
    state = state.copyWith(isProcessing: true);
    
    // Barkod işleme
    final result = await _processBarcodeUseCase(
      orderId: orderId,
      barcode: barcode,
      customerName: customerName,
    );
    
    // Sonuca göre ses çal ve durum güncelle
    String message;
    BarcodeStatus status;
    
    switch (result) {
      case BarcodeProcessResult.success:
        message = 'Barkod başarıyla okundu.';
        status = BarcodeStatus.success;
        await _soundService.playSound(SoundType.success);
        onOrderUpdated(); // Sipariş verilerini güncelle
        break;
      case BarcodeProcessResult.duplicateUniqueBarcode:
        message = 'Bu barkod zaten okutuldu!';
        status = BarcodeStatus.warning;
        await _soundService.playSound(SoundType.warning);
        break;
      // ... diğer durumlar
    }
    
    // Final state
    state = state.copyWith(status: status, message: message, isProcessing: false);
    
    // 3 saniye sonra durum mesajını temizle
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      state = state.copyWith(status: BarcodeStatus.none, message: '');
    }
  }
}
```

**Özellikler:**
- Async barkod işleme
- Ses geri bildirimi
- Otomatik mesaj temizleme
- Callback ile UI güncelleme
- Loading state management

## UI Widget'ları

### BarcodeNotificationWidget (`presentation/widgets/barcode_notification_widget.dart`)
```dart
class BarcodeNotificationWidget extends StatelessWidget {
  final BarcodeState state;
  
  @override
  Widget build(BuildContext context) {
    if (state.status == BarcodeStatus.none) return const SizedBox.shrink();
    
    Color backgroundColor;
    IconData iconData;
    
    switch (state.status) {
      case BarcodeStatus.success:
        backgroundColor = Colors.green;
        iconData = Icons.check_circle;
        break;
      case BarcodeStatus.warning:
        backgroundColor = Colors.orange;
        iconData = Icons.warning;
        break;
      case BarcodeStatus.error:
        backgroundColor = Colors.red;
        iconData = Icons.error;
        break;
      default:
        backgroundColor = Colors.grey;
        iconData = Icons.info;
    }
    
    return Container(/* Styled notification container */);
  }
}
```

**Özellikler:**
- Durum bazlı renklendirme
- İkonlu mesaj gösterimi
- Gölge efekti
- Responsive tasarım

### OrderItemProgress (`presentation/widgets/order_item_progress.dart`)
```dart
class OrderItemProgress extends StatelessWidget {
  final OrderItem item;
  final Product? product;
  final ProductCodeMapping? mapping;
  
  @override
  Widget build(BuildContext context) {
    final double progress = item.quantity > 0 ? item.scannedQuantity / item.quantity : 0.0;
    final bool isComplete = item.scannedQuantity >= item.quantity;
    
    final Color progressColor = isComplete ? Colors.green : (progress > 0 ? Colors.blue : Colors.grey);
    
    return Container(/* Progress bar with product info */);
  }
}
```

**Özellikler:**
- İlerleme çubuğu gösterimi
- Tamamlanma durumu renklendirmesi
- Ürün bilgisi gösterimi
- Ürün kod eşleştirme bilgisi

### BarcodeSimulatorWidget (`presentation/widgets/barcode_simulator_widget.dart`)
Test ve geliştirme amaçlı barkod simülasyon widget'ı.

### BarcodeScannerInput (`presentation/widgets/barcode_scanner_input.dart`)
Fiziksel barkod okuyucu girişi için text field widget'ı.

## Provider Yapısı

```dart
// Ana barkod notifier provider
final barcodeNotifierProvider = StateNotifierProvider.autoDispose<BarcodeNotifier, BarcodeState>((ref) {
  final processBarcodeUseCase = ref.watch(processBarcodeUseCaseProvider);
  final soundService = ref.watch(soundServiceProvider);
  return BarcodeNotifier(processBarcodeUseCase, soundService);
});

// Use case provider
final processBarcodeUseCaseProvider = Provider((ref) {
  final barcodeRepository = ref.watch(barcodeRepositoryProvider);
  return ProcessBarcodeUseCase(barcodeRepository);
});

// Repository provider
final barcodeRepositoryProvider = Provider((ref) {
  final database = ref.watch(appDatabaseProvider);
  return BarcodeRepositoryImpl(database);
});

// Sound service provider
final soundServiceProvider = Provider((ref) {
  return SoundService();
});
```

## Barkod İşleme Akışı

1. **Barkod Girişi**: Fiziksel okuyucu veya manuel giriş
2. **Ürün Bulma**: 
   - Önce doğrudan barkod ile ürün ara
   - Bulunamazsa müşteri kod eşleştirmesi ile ara
3. **Sipariş Kontrolü**: Ürünün mevcut siparişte olup olmadığını kontrol et
4. **Benzersiz Barkod Kontrolü**: Gerekiyorsa tekrarlanan barkod kontrolü
5. **Miktar Güncelleme**: Taranan miktarı artır
6. **Sipariş Durumu**: Otomatik olarak partial/completed durumuna geçir
7. **Geri Bildirim**: Ses + görsel bildirim
8. **UI Güncelleme**: Sipariş verilerini yenile

## Ses Dosyaları

Asset klasöründe bulunması gereken ses dosyaları:
- `assets/sounds/success.mp3`: Başarılı okuma sesi
- `assets/sounds/warning.mp3`: Uyarı sesi
- `assets/sounds/error.mp3`: Hata sesi

## Hata Yönetimi

### Repository Seviyesi
- Database connection hataları
- SQL query hataları
- Null safety

### Use Case Seviyesi
- İş mantığı kuralları
- Durum validasyonları
- Logging

### Presentation Seviyesi
- Kullanıcı dostu hata mesajları
- Loading state'leri
- Network/Database hatalarında retry

## Performans Optimizasyonları

- AutoDispose provider kullanımı
- Minimal state değişiklikleri
- Veritabanı query optimizasyonları
- Ses dosyaları için efficient caching

## Test Senaryoları

### Unit Tests
- [ ] ProcessBarcodeUseCase tüm senaryoları
- [ ] BarcodeRepositoryImpl metotları
- [ ] SoundService functionality
- [ ] BarcodeNotifier state transitions

### Integration Tests
- [ ] Barkod okuma end-to-end flow
- [ ] Database persistence
- [ ] UI state updates
- [ ] Sound service integration

### Widget Tests
- [ ] BarcodeNotificationWidget rendering
- [ ] OrderItemProgress calculation
- [ ] Input widget functionality

## Kullanım Örnekleri

### Temel Barkod İşleme
```dart
// Widget'ta
final barcodeState = ref.watch(barcodeNotifierProvider);

// Barkod işleme
await ref.read(barcodeNotifierProvider.notifier).processBarcode(
  barcode: scannedBarcode,
  orderId: currentOrderId,
  customerName: customerName,
  onOrderUpdated: () {
    // Sipariş verilerini yenile
    ref.refresh(orderDetailNotifierProvider(orderCode));
  },
);
```

### UI'da Bildirim Gösterme
```dart
Column(
  children: [
    BarcodeNotificationWidget(state: barcodeState),
    // Diğer UI elementleri
  ],
)
```

## Gelecek Geliştirmeler

- [ ] Kamera tabanlı barkod okuma
- [ ] Batch barkod okuma
- [ ] Offline sync desteği
- [ ] Barkod format validasyonu
- [ ] Analytics ve raporlama
- [ ] Bluetooth barkod okuyucu desteği

## Bağımlılıklar

- `drift`: Veritabanı ORM
- `audioplayers`: Ses çalma
- `flutter_riverpod`: State management
- `flutter/material.dart`: UI komponentleri 