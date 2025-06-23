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
  Future<Order?> getOrderByCode(
      String orderCode); // Sipariş kodu ile sipariş getir
  Future<int> createOrder(
      OrdersCompanion order); // Added back for OrderNotifier
  Future<bool> updateOrder(Order order); // Keep for general updates if needed
  Future<bool> deleteOrder(String orderId); // Use String ID

  // Order Item Operations
  Future<List<OrderItem>> getOrderItems(
      String orderId); // Use String for ID consistency
  Future<OrderItem?> getOrderItemById(
      String orderItemId); // Sipariş kalemi getir
  Future<int> createOrderItem(
      OrderItemsCompanion orderItem); // Sipariş kalemi oluştur
  Future<bool> updateOrderItemScannedQuantity(
      String orderItemId, int newQuantity); // Use String ID

  // Combined Order Creation from Import
  Future<void> createOrderWithItems({
    required model_order.Order orderData,
    required List<model_order_item.OrderItem> itemsData,
    required List<String> customerProductCodes,
  });

  // Sipariş özet bilgileri
  Future<Map<String, dynamic>> getOrderSummary(String orderCode);

  // Method to update order status
  Future<bool> updateOrderStatus(String orderCode, OrderStatus newStatus);

  // Sipariş arama
  Future<List<Order>> searchOrders({
    String? orderCode,
    String? customerName,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  });

  // Excel'den içe aktarma
  Future<void> importOrdersFromExcel(String filePath);

  // Streamler
  Stream<List<Order>> watchAllOrders();
  Stream<Order> watchOrderById(int id);
  // Stream<List<OrderItem>> watchOrderItems(String orderId);

  // Ürün ve barkod bilgileri
  Future<Product?> getProductById(int productId);
  Future<ProductCodeMapping?> getProductCodeMapping(
      int productId, String customerName);
  Future<List<BarcodeRead>> getBarcodeHistory(String orderCode, {int? limit});

  // Koli yönetimi
  Future<List<Map<String, dynamic>>> getBoxContents(String orderCode);
}
