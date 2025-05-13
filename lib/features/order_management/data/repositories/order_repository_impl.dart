import 'package:drift/drift.dart';
import 'package:flutter_count_track/core/database/app_database.dart';
import 'package:flutter_count_track/features/order_management/domain/repositories/order_repository.dart';
import 'package:flutter_count_track/features/order_management/data/models/order.dart'
    as model_order;
import 'package:flutter_count_track/features/order_management/data/models/order_item.dart'
    as model_order_item;

class OrderRepositoryImpl implements OrderRepository {
  final AppDatabase _db;

  OrderRepositoryImpl(this._db);

  @override
  Future<List<Order>> getOrders({
    String? searchQuery,
    OrderStatus? filterStatus,
  }) async {
    var query = _db.select(_db.orders);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query
        ..where((o) =>
            o.orderCode.contains(searchQuery) |
            o.customerName.contains(searchQuery));
    }
    if (filterStatus != null) {
      query = query..where((o) => o.status.equals(filterStatus.name));
    }
    query = query
      ..orderBy([
        (o) => OrderingTerm(expression: o.createdAt, mode: OrderingMode.desc)
      ]);
    return await query.get();
  }

  @override
  Future<Order?> getOrderById(String orderCode) async {
    return await (_db.select(_db.orders)
          ..where((o) => o.orderCode.equals(orderCode)))
        .getSingleOrNull();
  }

  @override
  Future<int> createOrder(OrdersCompanion order) async {
    return await _db.into(_db.orders).insert(order);
  }

  @override
  Future<bool> updateOrder(Order order) async {
    return await _db.update(_db.orders).replace(order);
  }

  @override
  Future<bool> deleteOrder(String orderCode) async {
    final orderToDelete = await getOrderById(orderCode);
    if (orderToDelete == null) {
      return false;
    }
    await (_db.delete(_db.orderItems)
          ..where((oi) => oi.orderId.equals(orderToDelete.id)))
        .go();

    final deletedRows = await (_db.delete(_db.orders)
          ..where((o) => o.id.equals(orderToDelete.id)))
        .go();
    return deletedRows > 0;
  }

  @override
  Future<List<OrderItem>> getOrderItems(String orderCode) async {
    final order = await getOrderById(orderCode);
    if (order == null) {
      return [];
    }
    return await (_db.select(_db.orderItems)
          ..where((oi) => oi.orderId.equals(order.id)))
        .get();
  }

  @override
  Future<int> createOrderItem(OrderItemsCompanion orderItem) async {
    return await _db.into(_db.orderItems).insert(orderItem);
  }

  @override
  Future<bool> updateOrderItemScannedQuantity(
      String orderItemId, int newQuantity) async {
    final itemId = int.tryParse(orderItemId);
    if (itemId == null) {
      print("Error: orderItemId '$orderItemId' is not a valid integer for PK.");
      return false;
    }

    final affectedRows = await (_db.update(_db.orderItems)
          ..where((oi) => oi.id.equals(itemId)))
        .write(OrderItemsCompanion(scannedQuantity: Value(newQuantity)));
    return affectedRows > 0;
  }

  @override
  Future<List<Order>> searchOrders({
    String? orderCode,
    String? customerName,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = _db.select(_db.orders);

    if (orderCode != null) {
      query = query..where((o) => o.orderCode.contains(orderCode));
    }
    if (customerName != null) {
      query = query..where((o) => o.customerName.contains(customerName));
    }
    if (status != null) {
      query = query..where((o) => o.status.equals(status.name));
    }
    if (startDate != null) {
      query = query..where((o) => o.createdAt.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query = query..where((o) => o.createdAt.isSmallerOrEqualValue(endDate));
    }

    return await query.get();
  }

  @override
  Future<bool> updateOrderStatus(
      String orderCode, OrderStatus newStatus) async {
    final orderToUpdate = await getOrderById(orderCode);
    if (orderToUpdate == null) {
      return false;
    }
    final affectedRows = await (_db.update(_db.orders)
          ..where((o) => o.id.equals(orderToUpdate.id)))
        .write(OrdersCompanion(
      status: Value(newStatus),
      updatedAt: Value(DateTime.now()),
    ));
    return affectedRows > 0;
  }

  @override
  Future<Map<String, dynamic>> getOrderSummary(String orderCode) async {
    final order = await getOrderById(orderCode);
    if (order == null) {
      return {'error': 'Order not found'};
    }
    final items = await getOrderItems(orderCode);

    int totalQuantity = 0;
    int totalScannedQuantity = 0;

    for (var item in items) {
      totalQuantity += item.quantity;
      totalScannedQuantity += item.scannedQuantity;
    }

    return {
      'order': order,
      'items': items,
      'totalQuantity': totalQuantity,
      'totalScannedQuantity': totalScannedQuantity,
      'progress': totalQuantity == 0
          ? 0.0
          : totalScannedQuantity / totalQuantity.toDouble(),
    };
  }

  @override
  Stream<List<Order>> watchAllOrders() {
    return (_db.select(_db.orders)
          ..orderBy([
            (o) =>
                OrderingTerm(expression: o.createdAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  @override
  Stream<Order> watchOrderById(int id) {
    return (_db.select(_db.orders)..where((o) => o.id.equals(id)))
        .watchSingle();
  }

  @override
  Stream<List<OrderItem>> watchOrderItems(int orderId) {
    return (_db.select(_db.orderItems)
          ..where((oi) => oi.orderId.equals(orderId)))
        .watch();
  }

  @override
  Future<void> createOrderWithItems({
    required model_order.Order orderData,
    required List<model_order_item.OrderItem> itemsData,
    required List<String> customerProductCodes,
  }) async {
    await _db.transaction(() async {
      final existingOrderQuery = _db.select(_db.orders)
        ..where((o) => o.orderCode.equals(orderData.orderCode));
      final existingOrder = await existingOrderQuery.getSingleOrNull();

      if (existingOrder != null) {
        throw Exception(
            'Sipariş kodu "${orderData.orderCode}" ile zaten bir sipariş mevcut.');
      }

      final newOrderId = await _db.into(_db.orders).insert(
            OrdersCompanion(
              orderCode: Value(orderData.orderCode),
              customerName: Value(orderData.customerName),
              status: Value(orderData.status ?? OrderStatus.pending),
              createdAt: Value(orderData.createdAt ?? DateTime.now()),
              updatedAt: Value(DateTime.now()),
            ),
          );

      for (var i = 0; i < itemsData.length; i++) {
        final item = itemsData[i];
        int mappedProductId = item.productId ?? 0;

        await _db.into(_db.orderItems).insert(
              OrderItemsCompanion(
                orderId: Value(newOrderId),
                productId: Value(mappedProductId),
                quantity: Value(item.quantity),
                scannedQuantity: Value(item.scannedQuantity ?? 0),
              ),
            );
      }
    });
  }

  @override
  Future<void> importOrdersFromExcel(String filePath) async {
    print(
        "OrderRepositoryImpl: importOrdersFromExcel called with $filePath. Actual Excel parsing and data transformation to be handled by a service.");
    throw UnimplementedError(
        "Excel import logic needs to be implemented in a service layer calling repository methods.");
  }
}
