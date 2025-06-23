import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// Sipariş durumları için enum
enum OrderStatus {
  pending, // Bekliyor
  partial, // Kısmen Gönderildi
  completed // Tamamlandı
}

class OrderStatusConverter extends TypeConverter<OrderStatus, String> {
  const OrderStatusConverter();

  @override
  OrderStatus fromSql(String fromDb) {
    return OrderStatus.values.firstWhere((e) => e.name == fromDb);
  }

  @override
  String toSql(OrderStatus value) {
    return value.name;
  }
}

// Sipariş tablosu
class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get orderCode => text()();
  TextColumn get customerName => text()();
  TextColumn get status => text().map(const OrderStatusConverter())();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// Sipariş kalemleri tablosu
class OrderItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer().references(Orders, #id)();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get quantity => integer()();
  IntColumn get scannedQuantity => integer().withDefault(const Constant(0))();
}

// Ürünler tablosu
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get ourProductCode => text()();
  TextColumn get name => text()();
  TextColumn get barcode => text()();
  BoolColumn get isUniqueBarcodeRequired =>
      boolean().withDefault(const Constant(false))();
}

// Ürün kodu eşleştirme tablosu
class ProductCodeMappings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get customerProductCode => text()();
  IntColumn get productId => integer().references(Products, #id)();
  TextColumn get customerName => text()();
}

// Barkod okuma kayıtları tablosu
class BarcodeReads extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer().references(Orders, #id)();
  IntColumn get productId => integer().nullable().references(Products, #id)();
  TextColumn get barcode => text()();
  IntColumn get boxNumber => integer().nullable()(); // Koli numarası
  DateTimeColumn get readAt => dateTime().withDefault(currentDateAndTime)();
}

// Koli yönetimi tablosu
class Boxes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer().references(Orders, #id)();
  IntColumn get boxNumber => integer()(); // Koli numarası (1, 2, 3, ...)
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// Teslimat tablosu
class Deliveries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer().references(Orders, #id)();
  DateTimeColumn get deliveryDate =>
      dateTime().withDefault(currentDateAndTime)();
}

// Teslimat kalemleri tablosu
class DeliveryItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get deliveryId => integer().references(Deliveries, #id)();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get quantity => integer()();
}

@DriftDatabase(
  tables: [
    Orders,
    OrderItems,
    Products,
    ProductCodeMappings,
    BarcodeReads,
    Boxes,
    Deliveries,
    DeliveryItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        print('🏗️ Database: Creating all tables...');
        await m.createAll();
        print('✅ Database: All tables created successfully');

        // Örnek veri oluştur
        await _initializeSampleData();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1 && to == 2) {
          // Barkod alanını Products tablosuna ekle
          await m.addColumn(products, products.barcode);
        }
        if (from == 2 && to == 3) {
          // Koli sistemi için yeni tablolar ve sütunlar ekle
          await m.createTable(boxes);
          await m.addColumn(barcodeReads, barcodeReads.boxNumber);
        }
        if (from == 3 && to == 4) {
          // Schema değişikliği yok, sadece veri güncelleme
          print('🔄 Database: Version 4 migration - updating sample data');
        }
      },
    );
  }

  /// Örnek veri oluşturma fonksiyonu
  Future<void> _initializeSampleData() async {
    print('🏗️ Database: Initializing sample data...');

    try {
      // Önce mevcut tüm verileri temizle
      await _clearAllData();

      // 10 farklı ürün oluştur (detaylı ve gerçekçi)
      final productCompanions = [
        ProductsCompanion.insert(
          ourProductCode: 'ABC001',
          name: 'Premium Kahve Makinesi',
          barcode: '8697123456789',
          isUniqueBarcodeRequired: const Value(true),
        ),
        ProductsCompanion.insert(
          ourProductCode: 'ABC002',
          name: 'Deluxe Blender Seti',
          barcode: '8697234567890',
          isUniqueBarcodeRequired: const Value(false),
        ),
        ProductsCompanion.insert(
          ourProductCode: 'ABC003',
          name: 'Akıllı Robot Süpürge',
          barcode: '8697345678901',
          isUniqueBarcodeRequired: const Value(true),
        ),
        ProductsCompanion.insert(
          ourProductCode: 'ABC004',
          name: 'Elektrikli Çay Makinesi',
          barcode: '8697456789012',
          isUniqueBarcodeRequired: const Value(false),
        ),
        ProductsCompanion.insert(
          ourProductCode: 'ABC005',
          name: 'Mikser Set 3 Parça',
          barcode: '8697567890123',
          isUniqueBarcodeRequired: const Value(false),
        ),
        ProductsCompanion.insert(
          ourProductCode: 'ABC006',
          name: 'Profesyonel Tost Makinesi',
          barcode: '8697678901234',
          isUniqueBarcodeRequired: const Value(false),
        ),
        ProductsCompanion.insert(
          ourProductCode: 'ABC007',
          name: 'Otomatik Kahve Değirmeni',
          barcode: '8697789012345',
          isUniqueBarcodeRequired: const Value(true),
        ),
        ProductsCompanion.insert(
          ourProductCode: 'ABC008',
          name: 'Dijital Terazi Hassas',
          barcode: '8697890123456',
          isUniqueBarcodeRequired: const Value(false),
        ),
        ProductsCompanion.insert(
          ourProductCode: 'ABC009',
          name: 'Mutfak Robot Çok Fonksiyonlu',
          barcode: '8697901234567',
          isUniqueBarcodeRequired: const Value(true),
        ),
        ProductsCompanion.insert(
          ourProductCode: 'ABC010',
          name: 'Steam Ütü Profesyonel',
          barcode: '8698012345678',
          isUniqueBarcodeRequired: const Value(false),
        ),
      ];

      final List<int> productIds = [];
      for (final product in productCompanions) {
        final id = await into(products).insert(product);
        productIds.add(id);
        print(
            '✅ Database: Created product: ${product.ourProductCode.value} - ${product.name.value} - Barkod: ${product.barcode.value}');
      }

      // 5 farklı sipariş oluştur (detaylı müşteri bilgileri ile)
      final orderCompanions = [
        OrdersCompanion.insert(
          orderCode: 'SIP2024001',
          customerName: 'MediaMarkt Türkiye',
          status: OrderStatus.pending,
        ),
        OrdersCompanion.insert(
          orderCode: 'SIP2024002',
          customerName: 'Teknosa Mağazacılık',
          status: OrderStatus.partial,
        ),
        OrdersCompanion.insert(
          orderCode: 'SIP2024003',
          customerName: 'Vatan Bilgisayar A.Ş.',
          status: OrderStatus.completed,
        ),
        OrdersCompanion.insert(
          orderCode: 'SIP2024004',
          customerName: 'Beko Global Satış',
          status: OrderStatus.pending,
        ),
        OrdersCompanion.insert(
          orderCode: 'SIP2024005',
          customerName: 'Carrefour Sabancı Ticaret',
          status: OrderStatus.partial,
        ),
      ];

      final List<int> orderIds = [];
      for (final order in orderCompanions) {
        final id = await into(orders).insert(order);
        orderIds.add(id);
        print(
            '✅ Database: Created order: ${order.orderCode.value} for ${order.customerName.value}');
      }

      // Detaylı sipariş kalemleri oluştur
      final orderItemCompanions = [
        // SIP2024001 - MediaMarkt (Bekliyor durumunda, kısmen okunmuş)
        OrderItemsCompanion.insert(
          orderId: orderIds[0],
          productId: productIds[0], // Premium Kahve Makinesi
          quantity: 150,
          scannedQuantity: const Value(45),
        ),
        OrderItemsCompanion.insert(
          orderId: orderIds[0],
          productId: productIds[1], // Deluxe Blender Seti
          quantity: 100,
          scannedQuantity: const Value(0),
        ),
        OrderItemsCompanion.insert(
          orderId: orderIds[0],
          productId: productIds[4], // Mikser Set 3 Parça
          quantity: 80,
          scannedQuantity: const Value(25),
        ),

        // SIP2024002 - Teknosa (Kısmen tamamlanmış)
        OrderItemsCompanion.insert(
          orderId: orderIds[1],
          productId: productIds[2], // Akıllı Robot Süpürge
          quantity: 75,
          scannedQuantity: const Value(75),
        ),
        OrderItemsCompanion.insert(
          orderId: orderIds[1],
          productId: productIds[3], // Elektrikli Çay Makinesi
          quantity: 120,
          scannedQuantity: const Value(90),
        ),
        OrderItemsCompanion.insert(
          orderId: orderIds[1],
          productId: productIds[7], // Dijital Terazi Hassas
          quantity: 60,
          scannedQuantity: const Value(0),
        ),

        // SIP2024003 - Vatan (Tamamlanmış)
        OrderItemsCompanion.insert(
          orderId: orderIds[2],
          productId: productIds[6], // Otomatik Kahve Değirmeni
          quantity: 40,
          scannedQuantity: const Value(40),
        ),
        OrderItemsCompanion.insert(
          orderId: orderIds[2],
          productId: productIds[8], // Mutfak Robot Çok Fonksiyonlu
          quantity: 25,
          scannedQuantity: const Value(25),
        ),

        // SIP2024004 - Beko (Bekliyor, hiç okunmamış)
        OrderItemsCompanion.insert(
          orderId: orderIds[3],
          productId: productIds[5], // Profesyonel Tost Makinesi
          quantity: 200,
          scannedQuantity: const Value(0),
        ),
        OrderItemsCompanion.insert(
          orderId: orderIds[3],
          productId: productIds[9], // Steam Ütü Profesyonel
          quantity: 180,
          scannedQuantity: const Value(0),
        ),
        OrderItemsCompanion.insert(
          orderId: orderIds[3],
          productId: productIds[1], // Deluxe Blender Seti
          quantity: 95,
          scannedQuantity: const Value(0),
        ),

        // SIP2024005 - Carrefour (Kısmen okunmuş)
        OrderItemsCompanion.insert(
          orderId: orderIds[4],
          productId: productIds[0], // Premium Kahve Makinesi
          quantity: 85,
          scannedQuantity: const Value(55),
        ),
        OrderItemsCompanion.insert(
          orderId: orderIds[4],
          productId: productIds[4], // Mikser Set 3 Parça
          quantity: 110,
          scannedQuantity: const Value(110),
        ),
        OrderItemsCompanion.insert(
          orderId: orderIds[4],
          productId: productIds[7], // Dijital Terazi Hassas
          quantity: 70,
          scannedQuantity: const Value(35),
        ),
      ];

      for (final item in orderItemCompanions) {
        await into(orderItems).insert(item);
      }
      print('✅ Database: Created ${orderItemCompanions.length} order items');

      // Müşteri ürün kodu eşleştirmeleri oluştur
      final mappingCompanions = [
        // MediaMarkt eşleştirmeleri
        ProductCodeMappingsCompanion.insert(
          customerProductCode: 'MM-COFFEE-001',
          productId: productIds[0],
          customerName: 'MediaMarkt Türkiye',
        ),
        ProductCodeMappingsCompanion.insert(
          customerProductCode: 'MM-BLEND-002',
          productId: productIds[1],
          customerName: 'MediaMarkt Türkiye',
        ),
        ProductCodeMappingsCompanion.insert(
          customerProductCode: 'MM-MIX-005',
          productId: productIds[4],
          customerName: 'MediaMarkt Türkiye',
        ),

        // Teknosa eşleştirmeleri
        ProductCodeMappingsCompanion.insert(
          customerProductCode: 'TK-ROBOT-003',
          productId: productIds[2],
          customerName: 'Teknosa Mağazacılık',
        ),
        ProductCodeMappingsCompanion.insert(
          customerProductCode: 'TK-TEA-004',
          productId: productIds[3],
          customerName: 'Teknosa Mağazacılık',
        ),
        ProductCodeMappingsCompanion.insert(
          customerProductCode: 'TK-SCALE-008',
          productId: productIds[7],
          customerName: 'Teknosa Mağazacılık',
        ),

        // Vatan eşleştirmeleri
        ProductCodeMappingsCompanion.insert(
          customerProductCode: 'VT-GRIND-007',
          productId: productIds[6],
          customerName: 'Vatan Bilgisayar A.Ş.',
        ),
        ProductCodeMappingsCompanion.insert(
          customerProductCode: 'VT-ROBOT-009',
          productId: productIds[8],
          customerName: 'Vatan Bilgisayar A.Ş.',
        ),

        // Beko eşleştirmeleri
        ProductCodeMappingsCompanion.insert(
          customerProductCode: 'BK-TOAST-006',
          productId: productIds[5],
          customerName: 'Beko Global Satış',
        ),
        ProductCodeMappingsCompanion.insert(
          customerProductCode: 'BK-IRON-010',
          productId: productIds[9],
          customerName: 'Beko Global Satış',
        ),
        ProductCodeMappingsCompanion.insert(
          customerProductCode: 'BK-BLEND-002',
          productId: productIds[1],
          customerName: 'Beko Global Satış',
        ),

        // Carrefour eşleştirmeleri
        ProductCodeMappingsCompanion.insert(
          customerProductCode: 'CR-COFFEE-001',
          productId: productIds[0],
          customerName: 'Carrefour Sabancı Ticaret',
        ),
        ProductCodeMappingsCompanion.insert(
          customerProductCode: 'CR-MIX-005',
          productId: productIds[4],
          customerName: 'Carrefour Sabancı Ticaret',
        ),
        ProductCodeMappingsCompanion.insert(
          customerProductCode: 'CR-SCALE-008',
          productId: productIds[7],
          customerName: 'Carrefour Sabancı Ticaret',
        ),
      ];

      for (final mapping in mappingCompanions) {
        await into(productCodeMappings).insert(mapping);
      }
      print(
          '✅ Database: Created ${mappingCompanions.length} product code mappings');

      // Örnek barkod okuma kayıtları oluştur (sadece kısmen/tamamen okunanlar için)
      final barcodeReadCompanions = [
        // MediaMarkt siparişi için okuma kayıtları
        ...List.generate(
            45,
            (index) => BarcodeReadsCompanion.insert(
                  orderId: orderIds[0],
                  productId: Value(productIds[0]),
                  barcode: '8697123456789',
                  boxNumber:
                      Value((index ~/ 15) + 1), // Her 15 ürün için bir koli
                )),
        ...List.generate(
            25,
            (index) => BarcodeReadsCompanion.insert(
                  orderId: orderIds[0],
                  productId: Value(productIds[4]),
                  barcode: '8697567890123',
                  boxNumber: Value((index ~/ 15) + 1),
                )),

        // Teknosa siparişi için okuma kayıtları
        ...List.generate(
            75,
            (index) => BarcodeReadsCompanion.insert(
                  orderId: orderIds[1],
                  productId: Value(productIds[2]),
                  barcode: '8697345678901',
                  boxNumber: Value((index ~/ 15) + 1),
                )),
        ...List.generate(
            90,
            (index) => BarcodeReadsCompanion.insert(
                  orderId: orderIds[1],
                  productId: Value(productIds[3]),
                  barcode: '8697456789012',
                  boxNumber: Value((index ~/ 15) + 1),
                )),

        // Vatan siparişi için okuma kayıtları (tamamlanmış)
        ...List.generate(
            40,
            (index) => BarcodeReadsCompanion.insert(
                  orderId: orderIds[2],
                  productId: Value(productIds[6]),
                  barcode: '8697789012345',
                  boxNumber: Value((index ~/ 15) + 1),
                )),
        ...List.generate(
            25,
            (index) => BarcodeReadsCompanion.insert(
                  orderId: orderIds[2],
                  productId: Value(productIds[8]),
                  barcode: '8697901234567',
                  boxNumber: Value((index ~/ 15) + 1),
                )),

        // Carrefour siparişi için okuma kayıtları
        ...List.generate(
            55,
            (index) => BarcodeReadsCompanion.insert(
                  orderId: orderIds[4],
                  productId: Value(productIds[0]),
                  barcode: '8697123456789',
                  boxNumber: Value((index ~/ 15) + 1),
                )),
        ...List.generate(
            110,
            (index) => BarcodeReadsCompanion.insert(
                  orderId: orderIds[4],
                  productId: Value(productIds[4]),
                  barcode: '8697567890123',
                  boxNumber: Value((index ~/ 15) + 1),
                )),
        ...List.generate(
            35,
            (index) => BarcodeReadsCompanion.insert(
                  orderId: orderIds[4],
                  productId: Value(productIds[7]),
                  barcode: '8697890123456',
                  boxNumber: Value((index ~/ 15) + 1),
                )),
      ];

      for (final barcodeRead in barcodeReadCompanions) {
        await into(barcodeReads).insert(barcodeRead);
      }
      print(
          '✅ Database: Created ${barcodeReadCompanions.length} barcode read records');

      print('🎉 Database: Sample data initialization completed successfully!');
      print('📊 Database: Created 5 comprehensive orders with realistic data');
    } catch (e) {
      print('💥 Database: Error initializing sample data: $e');
    }
  }

  /// Tüm verileri temizle
  Future<void> _clearAllData() async {
    print('🧹 Database: Clearing all existing data...');

    try {
      // Tabloları bağımlılık sırasına göre temizle (foreign key constraints)
      // Her tablo için try-catch kullan, tablo yoksa devam et

      try {
        await delete(barcodeReads).go();
        print('✅ Cleared: barcodeReads');
      } catch (e) {
        print('⚠️ Skip: barcodeReads (table may not exist)');
      }

      try {
        await delete(deliveryItems).go();
        print('✅ Cleared: deliveryItems');
      } catch (e) {
        print('⚠️ Skip: deliveryItems (table may not exist)');
      }

      try {
        await delete(deliveries).go();
        print('✅ Cleared: deliveries');
      } catch (e) {
        print('⚠️ Skip: deliveries (table may not exist)');
      }

      try {
        await delete(boxes).go();
        print('✅ Cleared: boxes');
      } catch (e) {
        print('⚠️ Skip: boxes (table may not exist)');
      }

      try {
        await delete(orderItems).go();
        print('✅ Cleared: orderItems');
      } catch (e) {
        print('⚠️ Skip: orderItems (table may not exist)');
      }

      try {
        await delete(productCodeMappings).go();
        print('✅ Cleared: productCodeMappings');
      } catch (e) {
        print('⚠️ Skip: productCodeMappings (table may not exist)');
      }

      try {
        await delete(orders).go();
        print('✅ Cleared: orders');
      } catch (e) {
        print('⚠️ Skip: orders (table may not exist)');
      }

      try {
        await delete(products).go();
        print('✅ Cleared: products');
      } catch (e) {
        print('⚠️ Skip: products (table may not exist)');
      }

      print('✅ Database: All data cleared successfully');
    } catch (e) {
      print('💥 Database: Error during data clearing: $e');
      rethrow;
    }
  }

  /// Public method - Veritabanını sıfırlayıp yeniden oluştur (debug amaçlı)
  Future<void> resetDatabase() async {
    await _clearAllData();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'paketleme_takip.db'));
    return NativeDatabase(file);
  });
}
