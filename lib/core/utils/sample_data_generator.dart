import 'package:flutter_count_track/core/database/app_database.dart';
import 'package:drift/drift.dart';

class SampleDataGenerator {
  final AppDatabase _db;

  SampleDataGenerator(this._db);

  // Örnek veriler oluştur
  Future<void> generateSampleData() async {
    // Önce mevcut verileri temizle
    await _clearAllData();

    // Örnek ürünler oluştur
    await _createSampleProducts();

    // Örnek siparişler oluştur
    await _createSampleOrders();

    // Örnek teslimatlar oluştur
    await _createSampleDeliveries();
  }

  Future<void> _clearAllData() async {
    await _db.delete(_db.deliveryItems).go();
    await _db.delete(_db.deliveries).go();
    await _db.delete(_db.barcodeReads).go();
    await _db.delete(_db.orderItems).go();
    await _db.delete(_db.orders).go();
    await _db.delete(_db.productCodeMappings).go();
    await _db.delete(_db.products).go();
  }

  Future<void> _createSampleProducts() async {
    final products = [
      const ProductsCompanion(
        ourProductCode: Value('PRD001'),
        name: Value('Laptop Bilgisayar'),
        barcode: Value('1234567890123'),
        isUniqueBarcodeRequired: Value(false),
      ),
      const ProductsCompanion(
        ourProductCode: Value('PRD002'),
        name: Value('Kablosuz Mouse'),
        barcode: Value('1234567890124'),
        isUniqueBarcodeRequired: Value(false),
      ),
      const ProductsCompanion(
        ourProductCode: Value('PRD003'),
        name: Value('Mekanik Klavye'),
        barcode: Value('1234567890125'),
        isUniqueBarcodeRequired: Value(false),
      ),
      const ProductsCompanion(
        ourProductCode: Value('PRD004'),
        name: Value('USB Kablo'),
        barcode: Value('1234567890126'),
        isUniqueBarcodeRequired: Value(false),
      ),
      const ProductsCompanion(
        ourProductCode: Value('PRD005'),
        name: Value('Monitör'),
        barcode: Value('1234567890127'),
        isUniqueBarcodeRequired: Value(false),
      ),
    ];

    for (final product in products) {
      await _db.into(_db.products).insert(product);
    }
  }

  Future<void> _createSampleOrders() async {
    final customers = [
      'ABC Teknoloji Ltd.',
      'XYZ Bilişim A.Ş.',
      'DEF Elektronik',
      'GHI Yazılım',
      'JKL Donanım',
    ];

    final now = DateTime.now();

    // Son 3 ay için siparişler oluştur
    for (int monthOffset = 0; monthOffset < 3; monthOffset++) {
      final monthDate = DateTime(now.year, now.month - monthOffset, 1);

      // Her ay için 10-20 sipariş oluştur
      final orderCount = 10 + (monthOffset * 5);

      for (int i = 0; i < orderCount; i++) {
        final customer = customers[i % customers.length];
        final orderDate = monthDate.add(Duration(days: i % 28));

        // Sipariş durumunu rastgele belirle
        OrderStatus status;
        if (i % 3 == 0) {
          status = OrderStatus.completed;
        } else if (i % 3 == 1) {
          status = OrderStatus.pending;
        } else {
          status = OrderStatus.partial;
        }

        final orderId = await _db.into(_db.orders).insert(
              OrdersCompanion(
                orderCode:
                    Value('ORD$monthOffset${i.toString().padLeft(3, '0')}'),
                customerName: Value(customer),
                status: Value(status),
                createdAt: Value(orderDate),
                updatedAt: Value(orderDate),
              ),
            );

        // Her sipariş için 1-5 ürün ekle
        final productCount = 1 + (i % 5);
        for (int j = 0; j < productCount; j++) {
          final productId = 1 + (j % 5); // 1-5 arası ürün ID'leri
          final quantity = 5 + (i % 10); // 5-14 arası miktar
          final scannedQuantity = status == OrderStatus.completed
              ? quantity
              : status == OrderStatus.partial
                  ? (quantity * 0.7).round()
                  : 0;

          await _db.into(_db.orderItems).insert(
                OrderItemsCompanion(
                  orderId: Value(orderId),
                  productId: Value(productId),
                  quantity: Value(quantity),
                  scannedQuantity: Value(scannedQuantity),
                ),
              );
        }
      }
    }
  }

  Future<void> _createSampleDeliveries() async {
    // Tamamlanan ve kısmi siparişler için teslimatlar oluştur
    final completedOrders = await (_db.select(_db.orders)
          ..where((o) =>
              o.status.equals(OrderStatus.completed.name) |
              o.status.equals(OrderStatus.partial.name)))
        .get();

    for (final order in completedOrders) {
      final deliveryId = await _db.into(_db.deliveries).insert(
            DeliveriesCompanion(
              orderId: Value(order.id),
              deliveryDate: Value(order.createdAt.add(const Duration(days: 1))),
            ),
          );

      // Sipariş kalemlerini al
      final orderItems = await (_db.select(_db.orderItems)
            ..where((oi) => oi.orderId.equals(order.id)))
          .get();

      for (final item in orderItems) {
        if (item.scannedQuantity > 0) {
          await _db.into(_db.deliveryItems).insert(
                DeliveryItemsCompanion(
                  deliveryId: Value(deliveryId),
                  productId: Value(item.productId),
                  quantity: Value(item.scannedQuantity),
                ),
              );
        }
      }
    }
  }

  // Veritabanında veri olup olmadığını kontrol et
  Future<bool> hasData() async {
    final orderCount =
        await _db.select(_db.orders).get().then((orders) => orders.length);
    return orderCount > 0;
  }
}
