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
  Future<List<Order>> getAllOrders() async {
    return await _db.select(_db.orders).get();
  }

  @override
  Future<Order> getOrderById(int id) async {
    return await (_db.select(_db.orders)..where((o) => o.id.equals(id)))
        .getSingle();
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
  Future<bool> deleteOrder(int id) async {
    final deletedRows =
        await (_db.delete(_db.orders)..where((o) => o.id.equals(id))).go();
    return deletedRows > 0;
  }

  @override
  Future<List<OrderItem>> getOrderItems(int orderId) async {
    return await (_db.select(_db.orderItems)
          ..where((oi) => oi.orderId.equals(orderId)))
        .get();
  }

  @override
  Future<int> createOrderItem(OrderItemsCompanion orderItem) async {
    return await _db.into(_db.orderItems).insert(orderItem);
  }

  @override
  Future<bool> updateOrderItemScannedQuantity(
      int orderItemId, int newQuantity) async {
    final affectedRows = await (_db.update(_db.orderItems)
          ..where((oi) => oi.id.equals(orderItemId)))
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
  Future<bool> updateOrderStatus(int orderId, OrderStatus newStatus) async {
    final affectedRows = await (_db.update(_db.orders)
          ..where((o) => o.id.equals(orderId)))
        .write(OrdersCompanion(
      status: Value(newStatus),
      updatedAt: Value(DateTime.now()),
    ));
    return affectedRows > 0;
  }

  @override
  Future<Map<String, dynamic>> getOrderSummary(int orderId) async {
    final order = await getOrderById(orderId);
    final items = await getOrderItems(orderId);

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
      'progress': items.isEmpty ? 0.0 : totalScannedQuantity / totalQuantity,
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
    required List<String> customerProductCodes, // Received for mapping
  }) async {
    await _db.transaction(() async {
      // 1. Check if order with orderCode already exists
      final existingOrderQuery = _db.select(_db.orders)
        ..where((o) => o.orderCode.equals(orderData.orderCode));
      final existingOrder = await existingOrderQuery.getSingleOrNull();

      if (existingOrder != null) {
        // TODO: Decide on more sophisticated handling for duplicate order codes as per project rules.
        // For now, throw an exception to prevent duplicates as per "mükerrer kayıt önlenecek".
        throw Exception(
            'Sipariş kodu "${orderData.orderCode}" ile zaten bir sipariş mevcut.');
      }

      // 2. Create the new Order
      final newOrderId = await _db.into(_db.orders).insert(
            OrdersCompanion(
              orderCode: Value(orderData.orderCode),
              customerName: Value(orderData.customerName),
              status: Value(orderData.status),
              createdAt: Value(orderData.createdAt),
              updatedAt: Value(orderData.updatedAt),
            ),
          );

      // 3. Create OrderItems
      for (var i = 0; i < itemsData.length; i++) {
        final item = itemsData[i];
        final customerProductCode = customerProductCodes[i];

        // --- CRITICAL TODO: Implement Product ID Mapping (F4.x) ---
        // The following productId is a PLACEHOLDER.
        // You MUST look up 'customerProductCode' in 'ProductCodeMapping' table
        // to get the correct internal 'productId'.
        // Handle cases where mapping is not found (e.g., skip item, default product, throw error).
        int mappedProductId = 0; // <<<<------ PLACEHOLDER PRODUCT ID
        // Example: mappedProductId = await _getProductIdFromMapping(customerProductCode, orderData.customerName);
        // --- END CRITICAL TODO ---

        await _db.into(_db.orderItems).insert(
              OrderItemsCompanion(
                orderId: Value(newOrderId),
                // productId: Value(item.productId), // This was from the temporary model, use mappedProductId
                productId: Value(
                    mappedProductId), // Use the (currently placeholder) mapped ID
                quantity: Value(item.quantity),
                scannedQuantity: Value(item.scannedQuantity),
              ),
            );
      }
    });
  }

  // TODO: Helper method for product mapping, potentially in a dedicated ProductMappingService
  // Future<int> _getProductIdFromMapping(String customerProductCode, String customerName) async {
  //   // Access ProductCodeMappingDAO here
  //   // ... logic to find product id ...
  //   return 0; // Placeholder
  // }
}
