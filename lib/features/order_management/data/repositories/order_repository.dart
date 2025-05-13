import 'package:drift/drift.dart';
import 'package:flutter_count_track/core/database/app_database.dart' as db;
import 'package:flutter_count_track/features/order_management/data/models/order.dart';
import 'package:flutter_count_track/features/order_management/data/models/order_item.dart';

class OrderRepository {
  final db.AppDatabase _db;

  OrderRepository(this._db);

  // Tüm siparişleri getir
  Future<List<Order>> getAllOrders() async {
    final orders = await _db.select(_db.orders).get();
    return orders.map((order) => Order.fromDB(order)).toList();
  }

  // Sipariş arama
  Future<List<Order>> searchOrders(String searchText) async {
    final query = _db.select(_db.orders)
      ..where((tbl) =>
          tbl.orderCode.like('%$searchText%') |
          tbl.customerName.like('%$searchText%'));
    final orders = await query.get();
    return orders.map((order) => Order.fromDB(order)).toList();
  }

  // Sipariş detayını getir
  Future<Order?> getOrderById(int id) async {
    final query = _db.select(_db.orders)..where((tbl) => tbl.id.equals(id));
    final order = await query.getSingleOrNull();
    return order != null ? Order.fromDB(order) : null;
  }

  // Sipariş oluştur
  Future<int> createOrder(Order order) async {
    return await _db.into(_db.orders).insert(order.toDB());
  }

  // Sipariş durumunu güncelle
  Future<bool> updateOrderStatus(int orderId, db.OrderStatus status) async {
    return await (_db.update(_db.orders)
              ..where((tbl) => tbl.id.equals(orderId)))
            .write(db.OrdersCompanion(
          status: Value(status),
          updatedAt: Value(DateTime.now()),
        )) >
        0;
  }

  // Sipariş kalemlerini getir
  Future<List<OrderItem>> getOrderItems(int orderId) async {
    final query = _db.select(_db.orderItems)
      ..where((tbl) => tbl.orderId.equals(orderId));
    final items = await query.get();
    return items.map((item) => OrderItem.fromDB(item)).toList();
  }

  // Sipariş kalemi oluştur
  Future<int> createOrderItem(OrderItem item) async {
    return await _db.into(_db.orderItems).insert(item.toDB());
  }

  // Okutulan miktar güncelleme
  Future<bool> updateScannedQuantity(int orderItemId, int newQuantity) async {
    return await (_db.update(_db.orderItems)
              ..where((tbl) => tbl.id.equals(orderItemId)))
            .write(db.OrderItemsCompanion(
          scannedQuantity: Value(newQuantity),
        )) >
        0;
  }

  // Sipariş ve kalemlerini sil (gerekirse)
  Future<void> deleteOrder(int orderId) async {
    await (_db.delete(_db.orderItems)
          ..where((tbl) => tbl.orderId.equals(orderId)))
        .go();
    await (_db.delete(_db.orders)..where((tbl) => tbl.id.equals(orderId))).go();
  }
}
