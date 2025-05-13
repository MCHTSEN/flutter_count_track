import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_count_track/core/database/app_database.dart'; // For Order, OrderItem, OrderStatus
import 'package:flutter_count_track/features/order_management/domain/repositories/order_repository.dart';
// Assuming a provider for OrderRepository is defined elsewhere, e.g., order_providers.dart
import 'package:flutter_count_track/features/order_management/presentation/notifiers/order_providers.dart'; // Placeholder for actual provider

// TODO: Define a state class for OrderDetailState (e.g., loading, data, error)

// Example State Definition (adjust as needed):
class OrderDetailState {
  final bool isLoading;
  final Order? order;
  final List<OrderItem>? orderItems;
  final String? errorMessage;

  const OrderDetailState({
    this.isLoading = false,
    this.order,
    this.orderItems,
    this.errorMessage,
  });

  OrderDetailState copyWith({
    bool? isLoading,
    Order? order,
    List<OrderItem>? orderItems,
    String? errorMessage,
    bool clearError = false, // Utility to easily clear error message
  }) {
    return OrderDetailState(
      isLoading: isLoading ?? this.isLoading,
      order: order ?? this.order,
      orderItems: orderItems ?? this.orderItems,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
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
      final order = await _orderRepository.getOrderById(_orderCode);
      if (order != null) {
        final items = await _orderRepository.getOrderItems(_orderCode);
        state =
            state.copyWith(isLoading: false, order: order, orderItems: items);
      } else {
        state = state.copyWith(
            isLoading: false,
            errorMessage: "Sipariş bulunamadı."); // Order not found.
      }
    } catch (e) {
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
