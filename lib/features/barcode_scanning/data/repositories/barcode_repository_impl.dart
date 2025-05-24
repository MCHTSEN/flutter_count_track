import 'package:drift/drift.dart';
import 'package:flutter_count_track/core/database/app_database.dart';
import 'package:flutter_count_track/features/barcode_scanning/domain/repositories/barcode_repository.dart';

class BarcodeRepositoryImpl implements BarcodeRepository {
  final AppDatabase database;

  BarcodeRepositoryImpl(this.database);

  @override
  Future<Product?> findProductByCustomerCode(
      String customerProductCode, String customerName) async {
    // Müşteri ürün kodu ve müşteri adına göre eşleştirme kaydını bul
    final mapping = await (database.select(database.productCodeMappings)
          ..where((tbl) => tbl.customerProductCode.equals(customerProductCode))
          ..where((tbl) => tbl.customerName.equals(customerName)))
        .getSingleOrNull();

    if (mapping == null) {
      return null;
    }

    // Eşleşen ürün kaydını bul
    final product = await (database.select(database.products)
          ..where((tbl) => tbl.id.equals(mapping.productId)))
        .getSingleOrNull();

    return product;
  }

  @override
  Future<OrderItem?> findOrderItemByProductId(
      int orderId, int productId) async {
    // Sipariş ve ürün ID'sine göre sipariş kalemini bul
    return await (database.select(database.orderItems)
          ..where((tbl) => tbl.orderId.equals(orderId))
          ..where((tbl) => tbl.productId.equals(productId)))
        .getSingleOrNull();
  }

  @override
  Future<void> updateOrderItemScannedQuantity(
      int orderItemId, int newScannedQuantity) async {
    await (database.update(database.orderItems)
          ..where((tbl) => tbl.id.equals(orderItemId)))
        .write(OrderItemsCompanion(scannedQuantity: Value(newScannedQuantity)));
  }

  @override
  Future<void> logBarcodeRead(
      int orderId, int? productId, String barcode) async {
    await database.into(database.barcodeReads).insert(
          BarcodeReadsCompanion.insert(
            orderId: orderId,
            productId:
                productId == null ? const Value.absent() : Value(productId),
            barcode: barcode,
          ),
        );
  }

  @override
  Future<bool> isUniqueBarcodeAlreadyScanned(
      int orderId, int productId, String barcode) async {
    // Bu barkodun daha önce bu sipariş için tarandığını kontrol et
    final result = await (database.select(database.barcodeReads)
          ..where((tbl) => tbl.orderId.equals(orderId))
          ..where((tbl) => tbl.productId.equals(productId))
          ..where((tbl) => tbl.barcode.equals(barcode)))
        .get();

    return result.isNotEmpty;
  }

  @override
  Future<bool> checkIfOrderComplete(int orderId) async {
    // Tüm sipariş kalemlerinin tamamlanıp tamamlanmadığını kontrol et
    final items = await (database.select(database.orderItems)
          ..where((tbl) => tbl.orderId.equals(orderId)))
        .get();

    // Hiç sipariş kalemi yoksa tamamlanmış olarak kabul etme
    if (items.isEmpty) {
      return false;
    }

    // Tüm sipariş kalemlerinin istenen miktarda taranıp taranmadığını kontrol et
    return items.every((item) => item.scannedQuantity >= item.quantity);
  }

  @override
  Future<void> updateOrderStatus(int orderId, OrderStatus status) async {
    await (database.update(database.orders)
          ..where((tbl) => tbl.id.equals(orderId)))
        .write(OrdersCompanion(
      status: Value(status),
      updatedAt: Value(DateTime.now()),
    ));
  }
}
