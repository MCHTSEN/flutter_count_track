import 'package:drift/drift.dart';
import 'package:flutter_count_track/core/database/app_database.dart';
import 'package:flutter_count_track/features/order_management/data/models/order.dart'
    as model_order;
import 'package:flutter_count_track/features/order_management/data/models/order_item.dart'
    as model_order_item;

abstract class OrderRepository {
  // Order CRUD and Listing
  Future<List<Order>> getOrders({
    String? searchQuery,
    OrderStatus? filterStatus,
  });
  Future<Order?> getOrderById(
      String orderId); // Use String for ID consistency with UI/Notifier
  Future<int> createOrder(
      OrdersCompanion order); // Added back for OrderNotifier
  Future<bool> updateOrder(Order order); // Keep for general updates if needed
  Future<bool> deleteOrder(String orderId); // Use String ID

  // Order Item Operations
  Future<List<OrderItem>> getOrderItems(
      String orderId); // Use String for ID consistency
  Future<bool> updateOrderItemScannedQuantity(
      String orderItemId, int newQuantity); // Use String ID

  // Combined Order Creation from Import
  Future<void> createOrderWithItems({
    required model_order.Order orderData,
    required List<model_order_item.OrderItem> itemsData,
    required List<String> customerProductCodes,
  });

  // Sipariş özet bilgileri
  Future<Map<String, dynamic>> getOrderSummary(String orderId); // Use String ID

  // Method to update order status
  Future<bool> updateOrderStatus(
      String orderId, OrderStatus newStatus); // Use String ID

  // Excel Import - kept as is, might internally use createOrderWithItems
  Future<void> importOrdersFromExcel(String filePath);

  // Streams
  // Consider a single watchOrders stream with filter parameters if needed
  Stream<List<Order>> watchAllOrders();
  // Stream<Order?> watchOrderById(String orderId);
  // Stream<List<OrderItem>> watchOrderItems(String orderId);
}
