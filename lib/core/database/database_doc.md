# Veritabanı (Database) Modülü Dokümantasyonu

## Genel Bakış

Database modülü, Paketleme Takip Sistemi'nin merkezi veri yönetim katmanıdır. Drift ORM kullanarak SQLite veritabanı ile etkileşim sağlar ve tüm uygulama verilerini yönetir. **v2.0** ile birlikte **Supabase** entegrasyonu ve **offline-first hybrid sync** sistemi eklenmiştir.

### Yeni Özellikler (v2.0)
- ✅ **Supabase Entegrasyonu**: Cloud database sync desteği
- ✅ **Offline-First Architecture**: İnternet olmadan tam işlevsellik
- ✅ **Hybrid Sync System**: Local ↔ Remote senkronizasyon
- ✅ **Conflict Resolution**: Veri çakışmalarının otomatik çözümü
- ✅ **Real-time Updates**: Anlık veri güncellemeleri
- ✅ **Comprehensive Logging**: Detaylı database işlem logları

## Modül Yapısı

```
lib/core/database/
├── app_database.dart       # Ana veritabanı tanımları ve yapılandırması
├── app_database.g.dart     # Drift tarafından generate edilen kod
└── database_provider.dart  # Riverpod provider tanımı
```

## Veritabanı Yapısı

### Schema Version: 2

Mevcut veritabanı versiyonu 2'dir ve aşağıdaki tabloları içerir:

## Tablo Tanımları

### 1. Orders Tablosu
```dart
class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get orderCode => text()();
  TextColumn get customerName => text()();
  TextColumn get status => text().map(const OrderStatusConverter())();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
```

**Alanlar:**
- `id`: Otomatik artan primary key
- `orderCode`: Sipariş kodu (benzersiz)
- `customerName`: Müşteri adı
- `status`: Sipariş durumu (enum olarak saklanır)
- `createdAt`: Oluşturulma tarihi (otomatik)
- `updatedAt`: Güncellenme tarihi (otomatik)

### 2. OrderItems Tablosu
```dart
class OrderItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer().references(Orders, #id)();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get quantity => integer()();
  IntColumn get scannedQuantity => integer().withDefault(const Constant(0))();
}
```

**Alanlar:**
- `id`: Otomatik artan primary key
- `orderId`: Orders tablosu ile foreign key
- `productId`: Products tablosu ile foreign key
- `quantity`: İstenen miktar
- `scannedQuantity`: Taranan miktar (başlangıçta 0)

### 3. Products Tablosu
```dart
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get ourProductCode => text()();
  TextColumn get name => text()();
  TextColumn get barcode => text()();
  BoolColumn get isUniqueBarcodeRequired => boolean().withDefault(const Constant(false))();
}
```

**Alanlar:**
- `id`: Otomatik artan primary key
- `ourProductCode`: Firma içi ürün kodu
- `name`: Ürün adı
- `barcode`: Ürün barkodu
- `isUniqueBarcodeRequired`: Benzersiz barkod gereksinimi (boolean)

### 4. ProductCodeMappings Tablosu
```dart
class ProductCodeMappings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get customerProductCode => text()();
  IntColumn get productId => integer().references(Products, #id)();
  TextColumn get customerName => text()();
}
```

**Alanlar:**
- `id`: Otomatik artan primary key
- `customerProductCode`: Müşteriye ait ürün kodu
- `productId`: Products tablosu ile foreign key
- `customerName`: Müşteri adı

### 5. BarcodeReads Tablosu
```dart
class BarcodeReads extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer().references(Orders, #id)();
  IntColumn get productId => integer().nullable().references(Products, #id)();
  TextColumn get barcode => text()();
  DateTimeColumn get readAt => dateTime().withDefault(currentDateAndTime)();
}
```

**Alanlar:**
- `id`: Otomatik artan primary key
- `orderId`: Orders tablosu ile foreign key
- `productId`: Products tablosu ile foreign key (nullable)
- `barcode`: Okunan barkod
- `readAt`: Okuma zamanı (otomatik)

### 6. Deliveries Tablosu
```dart
class Deliveries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer().references(Orders, #id)();
  DateTimeColumn get deliveryDate => dateTime().withDefault(currentDateAndTime)();
}
```

**Alanlar:**
- `id`: Otomatik artan primary key
- `orderId`: Orders tablosu ile foreign key
- `deliveryDate`: Teslimat tarihi (otomatik)

### 7. DeliveryItems Tablosu
```dart
class DeliveryItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get deliveryId => integer().references(Deliveries, #id)();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get quantity => integer()();
}
```

**Alanlar:**
- `id`: Otomatik artan primary key
- `deliveryId`: Deliveries tablosu ile foreign key
- `productId`: Products tablosu ile foreign key
- `quantity`: Teslimat miktarı

## Enum Tanımları

### OrderStatus
```dart
enum OrderStatus {
  pending,   // Bekliyor
  partial,   // Kısmen Gönderildi
  completed  // Tamamlandı
}
```

**OrderStatusConverter** ile veritabanında string olarak saklanır.

## Ana Veritabanı Sınıfı

### AppDatabase
```dart
@DriftDatabase(
  tables: [
    Orders,
    OrderItems,
    Products,
    ProductCodeMappings,
    BarcodeReads,
    Deliveries,
    DeliveryItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => // Migration tanımları...
}
```

**Özellikler:**
- Drift ORM tabanlı
- SQLite backend
- Otomatik code generation
- Migration desteği
- Transaction desteği

## Migration Stratejisi

### Başlangıç (onCreate)
```dart
onCreate: (Migrator m) async {
  await m.createAll();
  await _initializeSampleData(); // Örnek veri oluşturma
}
```

### Version Upgrade (onUpgrade)
```dart
onUpgrade: (Migrator m, int from, int to) async {
  if (from == 1 && to == 2) {
    // Barkod alanını Products tablosuna ekle
    await m.addColumn(products, products.barcode);
  }
}
```

## Örnek Veri Oluşturma

### _initializeSampleData() Metodu

Uygulama ilk kurulumunda aşağıdaki örnek veriler oluşturulur:

#### Örnek Ürünler
- **PRD001**: Ürün 1 - Standart Paket (Barkod: 1234567890123)
- **PRD002**: Ürün 2 - Premium Paket (Barkod: 2345678901234, Unique: true)
- **PRD003**: Ürün 3 - Deluxe Paket (Barkod: 3456789012345)
- **PRD004**: Ürün 4 - Ekonomik Paket (Barkod: 4567890123456)
- **PRD005**: Ürün 5 - Özel Seri (Barkod: 5678901234567, Unique: true)

#### Örnek Siparişler
- **SIP001**: ABC Şirketi (pending)
- **SIP002**: XYZ Ltd. (partial)
- **SIP003**: DEF A.Ş. (completed)

#### Örnek Sipariş Kalemleri
Her sipariş için çeşitli ürünler ve miktarlar tanımlanmıştır.

#### Örnek Müşteri Kod Eşleştirmeleri
- ABC-001 → PRD001 (ABC Şirketi)
- ABC-002 → PRD002 (ABC Şirketi)
- XYZ-A1 → PRD003 (XYZ Ltd.)
- XYZ-B2 → PRD004 (XYZ Ltd.)
- DEF-SPECIAL → PRD005 (DEF A.Ş.)

## Veritabanı Bağlantısı

### Connection Setup
```dart
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'paketleme_takip.db'));
    return NativeDatabase(file);
  });
}
```

**Özellikler:**
- LazyDatabase: İlk erişimde bağlantı kurar
- NativeDatabase: Platform-specific SQLite
- Documents Directory: Uygulama verilerini depolar
- Dosya adı: `paketleme_takip.db`

## Provider Yapısı

### DatabaseProvider (`database_provider.dart`)
```dart
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  
  // Provider dispose edildiğinde veritabanını kapat
  ref.onDispose(() => db.close());
  
  return db;
});
```

**Özellikler:**
- Riverpod Provider
- Singleton pattern
- Otomatik cleanup (onDispose)
- Dependency injection desteği

## Veri İlişkileri

### Foreign Key İlişkileri

```
Orders 1 ← ∞ OrderItems
Orders 1 ← ∞ BarcodeReads
Orders 1 ← ∞ Deliveries

Products 1 ← ∞ OrderItems
Products 1 ← ∞ ProductCodeMappings
Products 1 ← ∞ BarcodeReads
Products 1 ← ∞ DeliveryItems

Deliveries 1 ← ∞ DeliveryItems
```

### İş Mantığı İlişkileri

1. **Sipariş → Sipariş Kalemleri**: Bir sipariş birden fazla ürün içerebilir
2. **Ürün → Müşteri Kod Eşleştirmesi**: Bir ürün farklı müşteriler için farklı kodlara sahip olabilir
3. **Barkod Okuma**: Her barkod okuma işlemi kaydedilir
4. **Teslimat**: Siparişler kısmi veya tam teslimat yapılabilir

## Veritabanı İşlemleri

### Transaction Desteği
```dart
await db.transaction(() async {
  // Birden fazla işlem atomik olarak yapılır
  await createOrder();
  await createOrderItems();
});
```

### Stream Desteği
```dart
// Reactive programming için stream'ler
Stream<List<Order>> watchAllOrders() {
  return select(orders).watch();
}
```

### Query Optimization
- İndex tanımları
- Efficient JOIN'ler
- Lazy loading
- Pagination desteği

## Hata Yönetimi

### Database Exception Handling
```dart
try {
  await database.operation();
} catch (e) {
  if (e is SqliteException) {
    // SQLite specific error handling
  }
  // General error handling
}
```

### Migration Hata Yönetimi
- Schema version uyumsuzlukları
- Data corruption kontrolü
- Rollback stratejileri

## Performans Optimizasyonları

### İndeksler
- Primary key'ler otomatik indeksli
- Foreign key'ler için indeksler
- Arama alanları için composite indeksler

### Query Optimizasyonu
- Selective column fetching
- Efficient WHERE clauses
- JOIN optimization
- LIMIT/OFFSET for pagination

### Connection Pooling
- LazyDatabase ile lazy initialization
- Connection reuse
- Proper connection closing

## Backup ve Recovery

### Veri Yedekleme
- SQLite dosya kopyalama
- Export to SQL
- JSON export desteği

### Veri Geri Yükleme
- SQLite dosya restore
- Import from SQL
- Migration replay

## Security Considerations

### Veri Güvenliği
- Local storage encryption (gelecek)
- SQL injection koruması (Drift otomatik)
- Access control

### Privacy
- Local-only data storage
- No cloud synchronization (şu an için)
- GDPR compliance ready

## Monitoring ve Logging

### Database Logging
```dart
print('🏗️ Database: Initializing sample data...');
print('✅ Database: Created product: ${product.name}');
print('💥 Database: Error initializing sample data: $e');
```

### Performance Monitoring
- Query execution time
- Memory usage tracking
- Storage size monitoring

## Test Stratejisi

### Unit Tests
- [ ] Table creation tests
- [ ] Migration tests
- [ ] CRUD operation tests
- [ ] Constraint validation tests

### Integration Tests
- [ ] Cross-table relationship tests
- [ ] Transaction tests
- [ ] Stream functionality tests

### Performance Tests
- [ ] Large dataset handling
- [ ] Concurrent access tests
- [ ] Memory leak tests

## Gelecek Geliştirmeler

### Database Enhancements
- [ ] Cloud synchronization
- [ ] Encryption at rest
- [ ] Advanced indexing
- [ ] Partitioning for large datasets

### Schema Improvements
- [ ] Audit log tablosu
- [ ] User management tabloları
- [ ] Configuration tablosu
- [ ] Analytics tabloları

### Performance Improvements
- [ ] Query result caching
- [ ] Background data processing
- [ ] Incremental backup
- [ ] Compression

## Bağımlılıklar

### Core Dependencies
- `drift`: ^2.x.x - ORM framework
- `drift/native.dart`: SQLite integration
- `path_provider`: Documents directory
- `path`: File path utilities

### Development Dependencies
- `drift_dev`: Code generation
- `build_runner`: Build process

## Troubleshooting

### Yaygın Sorunlar

#### Migration Hataları
```
Solution: Schema version kontrolü ve manual migration
```

#### Connection Hataları
```
Solution: LazyDatabase reset ve path kontrolü
```

#### Data Corruption
```
Solution: Backup restore ve integrity check
```

### Debug Araçları
- SQLite Database Browser
- Drift Inspector
- Flutter Inspector
- Database file examination

## Kullanım Örnekleri

### Temel CRUD İşlemleri
```dart
// Create
await db.into(db.orders).insert(orderCompanion);

// Read
final orders = await db.select(db.orders).get();

// Update
await (db.update(db.orders)..where((t) => t.id.equals(1)))
  .write(OrdersCompanion(status: Value(OrderStatus.completed)));

// Delete
await (db.delete(db.orders)..where((t) => t.id.equals(1))).go();
```

### Stream Kullanımı
```dart
// Riverpod ile stream watching
final ordersStream = ref.watch(
  StreamProvider((ref) => 
    ref.read(appDatabaseProvider).select(db.orders).watch()
  )
);
```

### Transaction Kullanımı
```dart
await db.transaction(() async {
  final orderId = await db.into(db.orders).insert(orderCompanion);
  
  for (final item in orderItems) {
    await db.into(db.orderItems).insert(
      item.copyWith(orderId: Value(orderId))
    );
  }
});
``` 