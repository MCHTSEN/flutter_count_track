import 'package:flutter_count_track/core/database/app_database.dart'; // For Order, OrderItem, OrderStatus
import 'package:flutter_count_track/features/order_management/domain/repositories/order_repository.dart';
// Assuming a provider for OrderRepository is defined elsewhere, e.g., order_providers.dart
import 'package:flutter_count_track/features/order_management/presentation/notifiers/order_providers.dart'; // Placeholder for actual provider
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Ürün ve barkod bilgilerini içeren yardımcı sınıf
class OrderItemDetail {
  final OrderItem orderItem;
  final Product? product;
  final ProductCodeMapping? productCodeMapping;

  OrderItemDetail({
    required this.orderItem,
    this.product,
    this.productCodeMapping,
  });
}

// Example State Definition (adjust as needed):
class OrderDetailState {
  final bool isLoading;
  final Order? order;
  final List<OrderItemDetail>? orderItemDetails;
  final List<BarcodeRead>? barcodeHistory;
  final String? errorMessage;

  const OrderDetailState({
    this.isLoading = false,
    this.order,
    this.orderItemDetails,
    this.barcodeHistory,
    this.errorMessage,
  });

  OrderDetailState copyWith({
    bool? isLoading,
    Order? order,
    List<OrderItemDetail>? orderItemDetails,
    List<BarcodeRead>? barcodeHistory,
    String? errorMessage,
    bool clearError = false, // Utility to easily clear error message
  }) {
    return OrderDetailState(
      isLoading: isLoading ?? this.isLoading,
      order: order ?? this.order,
      orderItemDetails: orderItemDetails ?? this.orderItemDetails,
      barcodeHistory: barcodeHistory ?? this.barcodeHistory,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  // Sadece OrderItem listesi alabilmek için yardımcı getter
  List<OrderItem>? get orderItems =>
      orderItemDetails?.map((detail) => detail.orderItem).toList();
}

class OrderDetailNotifier extends StateNotifier<OrderDetailState> {
  final OrderRepository _orderRepository;
  final String _orderCode; // Changed from orderId to orderCode for clarity

  OrderDetailNotifier(this._orderCode, this._orderRepository)
      : super(const OrderDetailState(isLoading: true)) {
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      print(
          '🔍 OrderDetail: Fetching order details for orderCode: $_orderCode');

      final order = await _orderRepository.getOrderById(_orderCode);
      print('📋 OrderDetail: Order found: ${order?.orderCode ?? 'null'}');

      if (order != null) {
        final items = await _orderRepository.getOrderItems(_orderCode);
        print('📦 OrderDetail: Found ${items.length} order items');

        // Ürün detaylarını ve barkod bilgilerini getir
        final List<OrderItemDetail> itemDetails = [];

        for (final item in items) {
          print(
              '🔎 OrderDetail: Processing order item with productId: ${item.productId}');

          // Ürün bilgisini getir
          final product = await _orderRepository.getProductById(item.productId);
          print(
              '🏷️ OrderDetail: Product found: ${product?.ourProductCode ?? 'null'} - ${product?.name ?? 'null'}');

          // Ürün kodu eşleştirme bilgisini getir
          final mapping = await _orderRepository.getProductCodeMapping(
              item.productId, order.customerName);
          print(
              '🔗 OrderDetail: Mapping found: ${mapping?.customerProductCode ?? 'null'}');

          itemDetails.add(OrderItemDetail(
            orderItem: item,
            product: product,
            productCodeMapping: mapping,
          ));
        }

        print(
            '✅ OrderDetail: Successfully processed ${itemDetails.length} items');
        print(
            '📊 OrderDetail: Products found: ${itemDetails.where((d) => d.product != null).length}/${itemDetails.length}');

        // Barkod geçmişini getir
        final barcodeHistory =
            await _orderRepository.getBarcodeHistory(_orderCode);
        print('📖 OrderDetail: Found ${barcodeHistory.length} barcode reads');

        state = state.copyWith(
            isLoading: false,
            order: order,
            orderItemDetails: itemDetails,
            barcodeHistory: barcodeHistory);
      } else {
        print('❌ OrderDetail: Order not found');
        state = state.copyWith(
            isLoading: false,
            errorMessage: "Sipariş bulunamadı."); // Order not found.
      }
    } catch (e) {
      print('💥 OrderDetail: Error fetching details: $e');
      state = state.copyWith(
          isLoading: false,
          errorMessage:
              "Detaylar getirilirken hata: ${e.toString()}"); // Error fetching details
    }
  }

  Future<void> refreshOrderDetails() async {
    await _fetchOrderDetails();
  }

  // TODO: Add other methods if needed, e.g., to update item scanned quantity which would then refresh
}

final orderDetailNotifierProvider = StateNotifierProvider.autoDispose
    .family<OrderDetailNotifier, OrderDetailState, String>((ref, orderCode) {
  final orderRepository = ref.watch(orderRepositoryProvider);
  return OrderDetailNotifier(orderCode, orderRepository);
});
