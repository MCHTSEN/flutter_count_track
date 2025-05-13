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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Gelecekteki veritabanı şema güncellemeleri için
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'paketleme_takip.db'));
    return NativeDatabase(file);
  });
}
