import 'package:drift/drift.dart';
import 'package:flutter_count_track/core/database/app_database.dart';
import 'package:flutter_count_track/features/order_management/data/models/order.dart'
    as model_order;
import 'package:flutter_count_track/features/order_management/data/models/order_item.dart'
    as model_order_item;

abstract class OrderRepository {
  // Sipariş işlemleri
  Future<List<Order>> getAllOrders();
  Future<Order> getOrderById(int id);
  Future<int> createOrder(OrdersCompanion order);
  Future<bool> updateOrder(Order order);
  Future<bool> deleteOrder(int id);

  // Sipariş kalem işlemleri
  Future<List<OrderItem>> getOrderItems(int orderId);
  Future<int> createOrderItem(OrderItemsCompanion orderItem);
  Future<bool> updateOrderItemScannedQuantity(int orderItemId, int newQuantity);

  // Sipariş arama ve filtreleme
  Future<List<Order>> searchOrders({
    String? orderCode,
    String? customerName,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  });

  // Sipariş özet bilgileri
  Future<Map<String, dynamic>> getOrderSummary(int orderId);

  // Stream'ler
  Stream<List<Order>> watchAllOrders();
  Stream<Order> watchOrderById(int id);
  Stream<List<OrderItem>> watchOrderItems(int orderId);

  // Method to update order status
  Future<bool> updateOrderStatus(int orderId, OrderStatus newStatus);

  // New method for importing orders with items from Excel data
  Future<void> createOrderWithItems({
    required model_order.Order orderData,
    required List<model_order_item.OrderItem> itemsData,
    required List<String> customerProductCodes,
  });
}
