import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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
  DateTimeColumn get readAt => dateTime().withDefault(currentDateAndTime)();
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
    Deliveries,
    DeliveryItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();

        // Örnek veri oluştur
        await _initializeSampleData();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1 && to == 2) {
          // Barkod alanını Products tablosuna ekle
          await m.addColumn(products, products.barcode);
        }
      },
    );
  }

  /// Örnek veri oluşturma fonksiyonu
  Future<void> _initializeSampleData() async {
    print('🏗️ Database: Initializing sample data...');

    try {
      // Önce ürünler oluştur
      final productCompanions = [
        ProductsCompanion.insert(
          ourProductCode: 'PRD001',
          name: 'Ürün 1 - Standart Paket',
          barcode: '1234567890123',
          isUniqueBarcodeRequired: const Value(false),
        ),
        ProductsCompanion.insert(
          ourProductCode: 'PRD002',
          name: 'Ürün 2 - Premium Paket',
          barcode: '2345678901234',
          isUniqueBarcodeRequired: const Value(true),
        ),
        ProductsCompanion.insert(
          ourProductCode: 'PRD003',
          name: 'Ürün 3 - Deluxe Paket',
          barcode: '3456789012345',
          isUniqueBarcodeRequired: const Value(false),
        ),
        ProductsCompanion.insert(
          ourProductCode: 'PRD004',
          name: 'Ürün 4 - Ekonomik Paket',
          barcode: '4567890123456',
          isUniqueBarcodeRequired: const Value(false),
        ),
        ProductsCompanion.insert(
          ourProductCode: 'PRD005',
          name: 'Ürün 5 - Özel Seri',
          barcode: '5678901234567',
          isUniqueBarcodeRequired: const Value(true),
        ),
      ];

      final List<int> productIds = [];
      for (final product in productCompanions) {
        final id = await into(products).insert(product);
        productIds.add(id);
        print(
            '✅ Database: Created product: ${product.ourProductCode.value} - ${product.name.value} - Barkod: ${product.barcode.value}');
      }

      // Örnek siparişler oluştur
      final orderCompanions = [
        OrdersCompanion.insert(
          orderCode: 'SIP001',
          customerName: 'ABC Şirketi',
          status: OrderStatus.pending,
        ),
        OrdersCompanion.insert(
          orderCode: 'SIP002',
          customerName: 'XYZ Ltd.',
          status: OrderStatus.partial,
        ),
        OrdersCompanion.insert(
          orderCode: 'SIP003',
          customerName: 'DEF A.Ş.',
          status: OrderStatus.completed,
        ),
      ];

      final List<int> orderIds = [];
      for (final order in orderCompanions) {
        final id = await into(orders).insert(order);
        orderIds.add(id);
        print(
            '✅ Database: Created order: ${order.orderCode.value} for ${order.customerName.value}');
      }

      // Sipariş kalemleri oluştur
      final orderItemCompanions = [
        // SIP001 için
        OrderItemsCompanion.insert(
          orderId: orderIds[0],
          productId: productIds[0],
          quantity: 100,
          scannedQuantity: const Value(25),
        ),
        OrderItemsCompanion.insert(
          orderId: orderIds[0],
          productId: productIds[1],
          quantity: 50,
          scannedQuantity: const Value(0),
        ),
        OrderItemsCompanion.insert(
          orderId: orderIds[0],
          productId: productIds[2],
          quantity: 75,
          scannedQuantity: const Value(10),
        ),

        // SIP002 için
        OrderItemsCompanion.insert(
          orderId: orderIds[1],
          productId: productIds[2],
          quantity: 200,
          scannedQuantity: const Value(150),
        ),
        OrderItemsCompanion.insert(
          orderId: orderIds[1],
          productId: productIds[3],
          quantity: 80,
          scannedQuantity: const Value(80),
        ),

        // SIP003 için
        OrderItemsCompanion.insert(
          orderId: orderIds[2],
          productId: productIds[4],
          quantity: 30,
          scannedQuantity: const Value(30),
        ),
        OrderItemsCompanion.insert(
          orderId: orderIds[2],
          productId: productIds[0],
          quantity: 120,
          scannedQuantity: const Value(120),
        ),
      ];

      for (final item in orderItemCompanions) {
        await into(orderItems).insert(item);
      }
      print('✅ Database: Created ${orderItemCompanions.length} order items');

      // Müşteri ürün kodu eşleştirmeleri oluştur
      final mappingCompanions = [
        ProductCodeMappingsCompanion.insert(
          customerProductCode: 'ABC-001',
          productId: productIds[0],
          customerName: 'ABC Şirketi',
        ),
        ProductCodeMappingsCompanion.insert(
          customerProductCode: 'ABC-002',
          productId: productIds[1],
          customerName: 'ABC Şirketi',
        ),
        ProductCodeMappingsCompanion.insert(
          customerProductCode: 'XYZ-A1',
          productId: productIds[2],
          customerName: 'XYZ Ltd.',
        ),
        ProductCodeMappingsCompanion.insert(
          customerProductCode: 'XYZ-B2',
          productId: productIds[3],
          customerName: 'XYZ Ltd.',
        ),
        ProductCodeMappingsCompanion.insert(
          customerProductCode: 'DEF-SPECIAL',
          productId: productIds[4],
          customerName: 'DEF A.Ş.',
        ),
      ];

      for (final mapping in mappingCompanions) {
        await into(productCodeMappings).insert(mapping);
      }
      print(
          '✅ Database: Created ${mappingCompanions.length} product code mappings');

      print('🎉 Database: Sample data initialization completed successfully!');
    } catch (e) {
      print('💥 Database: Error initializing sample data: $e');
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'paketleme_takip.db'));
    return NativeDatabase(file);
  });
}
