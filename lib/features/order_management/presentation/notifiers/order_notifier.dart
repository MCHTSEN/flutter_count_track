import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_count_track/core/database/app_database.dart';
import 'package:flutter_count_track/features/order_management/domain/repositories/order_repository.dart';
import 'package:flutter_count_track/features/order_management/presentation/notifiers/order_providers.dart';
import 'package:flutter_count_track/features/order_management/data/services/excel_import_service.dart';

// State class for order management
class OrderState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? selectedOrderSummary;
  final String? successMessage;

  const OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.selectedOrderSummary,
    this.successMessage,
  });

  OrderState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? selectedOrderSummary,
    bool clearSelectedOrderSummary = false,
    String? successMessage,
    bool clearError = false,
    bool clearSuccessMessage = false,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error,
      selectedOrderSummary: clearSelectedOrderSummary
          ? null
          : selectedOrderSummary ?? this.selectedOrderSummary,
      successMessage: clearSuccessMessage ? null : successMessage,
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  final OrderRepository _repository;
  final ExcelImportService _excelImportService;

  OrderNotifier(this._repository, this._excelImportService)
      : super(const OrderState()) {
    loadOrders();
  }

  Future<void> loadOrders(
      {String? searchQuery, OrderStatus? filterStatus}) async {
    try {
      state = state.copyWith(
          isLoading: true, clearError: true, clearSuccessMessage: true);
      final orders = await _repository.getOrders(
          searchQuery: searchQuery, filterStatus: filterStatus);
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Siparişler yüklenirken hata oluştu: $e',
      );
    }
  }

  Future<void> createOrder(OrdersCompanion orderCompanion) async {
    try {
      state = state.copyWith(
          isLoading: true, clearError: true, clearSuccessMessage: true);
      await _repository.createOrder(orderCompanion);
      await loadOrders();
      state = state.copyWith(
          isLoading: false, successMessage: "Sipariş başarıyla oluşturuldu.");
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Sipariş oluşturulurken hata oluştu: $e',
      );
    }
  }

  Future<void> updateOrderStatusUI(
      String orderCode, OrderStatus newStatus) async {
    try {
      state = state.copyWith(
          isLoading: true, clearError: true, clearSuccessMessage: true);
      bool success = await _repository.updateOrderStatus(orderCode, newStatus);
      await loadOrders();
      if (success) {
        state = state.copyWith(
            isLoading: false, successMessage: "Sipariş durumu güncellendi.");
      } else {
        state = state.copyWith(
            isLoading: false, error: "Sipariş durumu güncellenemedi.");
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Sipariş durumu güncellenirken hata oluştu: $e',
      );
    }
  }

  Future<void> deleteOrderUI(String orderCode) async {
    try {
      state = state.copyWith(
          isLoading: true, clearError: true, clearSuccessMessage: true);
      bool success = await _repository.deleteOrder(orderCode);
      await loadOrders();
      if (success) {
        state = state.copyWith(
            isLoading: false, successMessage: "Sipariş silindi.");
      } else {
        state = state.copyWith(isLoading: false, error: "Sipariş silinemedi.");
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Sipariş silinirken hata oluştu: $e',
      );
    }
  }

  Future<void> loadOrderSummaryUI(String orderCode) async {
    try {
      state = state.copyWith(
          isLoading: true,
          clearError: true,
          clearSuccessMessage: true,
          clearSelectedOrderSummary: true);
      final summary = await _repository.getOrderSummary(orderCode);
      state = state.copyWith(
        selectedOrderSummary: summary,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Sipariş özeti yüklenirken hata oluştu: $e',
      );
    }
  }

  Future<void> updateOrderItemScannedQuantityUI(
    String orderItemId,
    int newQuantity,
    String? activeOrderCode,
  ) async {
    try {
      state = state.copyWith(
          isLoading: true, clearError: true, clearSuccessMessage: true);
      await _repository.updateOrderItemScannedQuantity(
          orderItemId, newQuantity);

      await loadOrders();
      if (activeOrderCode != null &&
          state.selectedOrderSummary != null &&
          state.selectedOrderSummary!['order']?.orderCode == activeOrderCode) {
        await loadOrderSummaryUI(activeOrderCode);
      }
      state = state.copyWith(
          isLoading: false, successMessage: "Ürün miktarı güncellendi.");
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Taranan miktar güncellenirken hata oluştu: $e',
      );
    }
  }

  Future<void> importOrdersFromExcelUI(String filePath) async {
    try {
      state = state.copyWith(
          isLoading: true, clearError: true, clearSuccessMessage: true);
      final List<ExcelOrderImportData> importedData =
          await _excelImportService.importOrdersFromExcel(filePath);

      int successCount = 0;
      int failureCount = 0;
      List<String> errorMessages = [];

      for (var data in importedData) {
        try {
          await _repository.createOrderWithItems(
            orderData: data.order,
            itemsData: data.items,
            customerProductCodes: data.customerProductCodes,
          );
          successCount++;
        } catch (e) {
          failureCount++;
          errorMessages.add("Sipariş ${data.order.orderCode}: ${e.toString()}");
        }
      }

      await loadOrders();

      String message = "Excel içe aktarma tamamlandı. Başarılı: $successCount";
      if (failureCount > 0) {
        message += ", Hatalı: $failureCount.";
        state = state.copyWith(
            isLoading: false,
            error: "$message\nDetaylar: ${errorMessages.join('\n')}",
            successMessage: successCount > 0
                ? "Bazı siparişler başarıyla aktarıldı."
                : null);
      } else {
        state = state.copyWith(isLoading: false, successMessage: message);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Excel içe aktarma sırasında genel hata: $e',
      );
    }
  }
}

final orderNotifierProvider =
    StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  final excelService = ref.watch(excelImportServiceProvider);
  return OrderNotifier(repository, excelService);
});
