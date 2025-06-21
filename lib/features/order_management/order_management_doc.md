# Sipariş Yönetimi (Order Management) Modülü Dokümantasyonu

## Genel Bakış

Sipariş Yönetimi modülü, üretim fabrikasında sipariş süreçlerini yönetmek ve takip etmek için geliştirilmiş ana modüllerden biridir. Bu modül MVVM (Model-View-ViewModel) mimarisini kullanarak Riverpod ile state management sağlar.

## Modül Yapısı

```
lib/features/order_management/
├── data/
│   ├── models/
│   │   ├── order.dart
│   │   └── order_item.dart
│   ├── repositories/
│   │   ├── order_repository_impl.dart
│   │   └── order_repository.dart
│   ├── services/
│   │   └── excel_import_service.dart
│   └── datasources/
├── domain/
│   ├── entities/
│   ├── repositories/
│   │   └── order_repository.dart
│   └── usecases/
├── presentation/
│   ├── mixins/
│   │   └── order_list_screen_mixin.dart
│   ├── notifiers/
│   │   ├── order_detail_notifier.dart
│   │   ├── order_notifier.dart
│   │   └── order_providers.dart
│   ├── screens/
│   │   ├── order_detail_screen.dart
│   │   └── order_list_screen.dart
│   └── widgets/
│       ├── order_app_bar.dart
│       ├── order_detail_item_card.dart
│       ├── order_filter_section.dart
│       ├── order_grid.dart
│       ├── order_list_item.dart
│       ├── order_list.dart
│       └── order_search_bar.dart
```

## Ana Veri Modelleri

### Order Model (`order.dart`)
```dart
class Order {
  final int id;
  final String orderCode;
  final String customerName;
  final db.OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Veritabanı dönüşüm metotları
  factory Order.fromDB(db.Order order)
  db.OrdersCompanion toDB()
  Order copyWith({...})
}
```

**Özellikler:**
- Sipariş ana bilgilerini tutar
- Veritabanı ile uyumlu dönüşüm metotları
- İmmutable yapı (copyWith metodu ile güncelleme)

### OrderItem Model (`order_item.dart`)
```dart
class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final int scannedQuantity;
  
  // Hesaplanmış özellikler
  double get progress => quantity > 0 ? scannedQuantity / quantity : 0.0;
  bool get isCompleted => scannedQuantity >= quantity;
}
```

**Özellikler:**
- Sipariş kalemlerini temsil eder
- İlerleme hesaplama metotları içerir
- Tamamlanma durumu kontrolü

## Repository Katmanı

### OrderRepository Interface (`domain/repositories/order_repository.dart`)
Abstract class olarak tanımlanmış, temel CRUD işlemlerini ve stream operasyonlarını içerir.

### OrderRepositoryImpl (`data/repositories/order_repository_impl.dart`)
```dart
class OrderRepositoryImpl implements OrderRepository {
  final AppDatabase _db;
  
  // Temel işlemler
  Future<List<Order>> getOrders({String? searchQuery, OrderStatus? filterStatus})
  Future<Order?> getOrderById(String orderCode)
  Future<int> createOrder(OrdersCompanion order)
  Future<bool> updateOrder(Order order)
  Future<bool> deleteOrder(String orderCode)
  
  // Sipariş kalemi işlemleri
  Future<List<OrderItem>> getOrderItems(String orderCode)
  Future<int> createOrderItem(OrderItemsCompanion orderItem)
  Future<bool> updateOrderItemScannedQuantity(String orderItemId, int newQuantity)
  
  // Arama ve filtreleme
  Future<List<Order>> searchOrders({...})
  Future<Map<String, dynamic>> getOrderSummary(String orderCode)
  
  // Stream işlemleri
  Stream<List<Order>> watchAllOrders()
  Stream<Order> watchOrderById(int id)
  Stream<List<OrderItem>> watchOrderItems(int orderId)
  
  // Diğer Metotlar
  Future<List<BarcodeRead>> getBarcodeHistory(String orderCode, {int? limit});
  Future<Product?> getProductById(int productId);
  Future<ProductCodeMapping?> getProductCodeMapping(
      int productId, String customerName);
  Future<List<Map<String, dynamic>>> getBoxContents(String orderCode);


  // Excel entegrasyonu
  Future<void> createOrderWithItems({
    required model_order.Order orderData,
    required List<model_order_item.OrderItem> itemsData,
    required List<String> customerProductCodes,
  })
}
```

**Özellikler:**
- Drift ORM kullanarak veritabanı işlemleri
- Transaction desteği
- Stream tabanlı reactive programming
- Excel importu için özel metot

## State Management

### OrderState
```dart
class OrderState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? selectedOrderSummary;
  final String? successMessage;
}
```

### OrderNotifier (`presentation/notifiers/order_notifier.dart`)
```dart
class OrderNotifier extends StateNotifier<OrderState> {
  final OrderRepository _repository;
  final ExcelImportService _excelImportService;
  
  // Ana işlemler
  Future<void> loadOrders({String? searchQuery, OrderStatus? filterStatus})
  Future<void> createOrder(OrdersCompanion orderCompanion)
  Future<void> updateOrderStatusUI(String orderCode, OrderStatus newStatus)
  Future<void> deleteOrderUI(String orderCode)
  
  // Detay işlemleri
  Future<void> loadOrderSummaryUI(String orderCode)
  Future<void> updateOrderItemScannedQuantityUI(String orderItemId, int newQuantity, String? activeOrderCode)
  
  // Excel entegrasyonu
  Future<void> importOrdersFromExcelUI(String filePath)
}
```

**Özellikler:**
- Riverpod StateNotifier kullanımı
- UI friendly hata yönetimi
- Loading state'leri
- Success/Error mesajları

## Excel Entegrasyonu

### ExcelImportService (`data/services/excel_import_service.dart`)
```dart
class ExcelImportService {
  Future<List<ExcelOrderImportData>> importOrdersFromExcel(String filePath)
}

class ExcelOrderImportData {
  final Order order;
  final List<OrderItem> items;
  final List<String> customerProductCodes;
}
```

**Excel Formatı Beklentisi:**
- A Kolonu: OrderCode (Sipariş Kodu)
- B Kolonu: CustomerName (Müşteri Adı)
- C Kolonu: CustomerProductCode (Müşteri Ürün Kodu)
- D Kolonu: Quantity (Miktar)

**Özellikler:**
- Excel dosyalarından sipariş verilerini okur
- Hata toleranslı (yanlış satırları atlar)
- Müşteri ürün kod eşleştirmesi
- Batch import desteği

## UI Katmanı

### Ana Ekranlar

#### OrderListScreen (`presentation/screens/order_list_screen.dart`)
- Sipariş listesi görüntüleme
- Arama ve filtreleme
- Excel içe aktarma
- Yeni sipariş ekleme (TODO)

#### OrderDetailScreen (`presentation/screens/order_detail_screen.dart`)
- Sipariş detayları görüntüleme
- Sipariş kalemleri listesi
- Barkod okuma entegrasyonu
- İlerleme takibi

### Widget Bileşenleri

#### OrderAppBar (`presentation/widgets/order_app_bar.dart`)
- Excel içe aktarma butonu
- Yenile butonu
- Başlık

#### OrderFilterSection (`presentation/widgets/order_filter_section.dart`)
- Arama kutusu
- Durum filtresi
- Filtreleme kontrolü

#### OrderListItem (`presentation/widgets/order_list_item.dart`)
- Tek sipariş kartı
- Durum göstergesi
- Detay sayfasına yönlendirme

## Provider Yapısı

```dart
// Ana provider
final orderNotifierProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  final excelService = ref.watch(excelImportServiceProvider);
  return OrderNotifier(repository, excelService);
});

// Bağımlılık provider'ları
final orderRepositoryProvider = Provider((ref) {
  final database = ref.watch(appDatabaseProvider);
  return OrderRepositoryImpl(database);
});

final excelImportServiceProvider = Provider<ExcelImportService>((ref) {
  return ExcelImportService();
});
```

## Sipariş Durumları

```dart
enum OrderStatus {
  pending,   // Bekliyor
  partial,   // Kısmen Gönderildi
  completed  // Tamamlandı
}
```

## Kullanım Örnekleri

### Sipariş Listesini Yükleme
```dart
// Notifier'da
await loadOrders(searchQuery: "SIP001", filterStatus: OrderStatus.pending);

// Widget'ta
final orderState = ref.watch(orderNotifierProvider);
```

### Excel'den Sipariş İçe Aktarma
```dart
await ref.read(orderNotifierProvider.notifier).importOrdersFromExcelUI(filePath);
```

### Sipariş Detaylarını Yükleme
```dart
await ref.read(orderDetailNotifierProvider(orderCode).notifier).refreshOrderDetails();
```

## Hata Yönetimi

- Repository katmanında exception handling
- UI katmanında kullanıcı dostu hata mesajları
- Excel import sırasında hata loglama
- Transaction rollback desteği

## Performans Optimizasyonları

- Drift Stream'ler ile reactive UI
- AutoDispose provider'lar
- Pagination desteği (gelecek)
- Selective widget rebuilding

## Gelecek Geliştirmeler

- [ ] Pagination desteği
- [ ] Yeni sipariş ekleme ekranı
- [ ] Sipariş düzenleme
- [ ] Çeki listesi (PDF) oluşturma
- [ ] Teslimat yönetimi
- [ ] Toplu sipariş işlemleri

## Bağımlılıklar

- `drift`: Veritabanı ORM
- `excel`: Excel dosya işleme
- `flutter_riverpod`: State management
- `flutter/material.dart`: UI komponentleri

## Test Edilmesi Gerekenler

- Repository metotları unit testleri
- Excel import service testleri
- OrderNotifier state transition testleri
- Widget testleri
- Integration testleri 