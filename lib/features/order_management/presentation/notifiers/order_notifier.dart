import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_count_track/core/database/app_database.dart';
import 'package:flutter_count_track/features/order_management/domain/repositories/order_repository.dart';
import 'package:flutter_count_track/features/order_management/data/repositories/order_repository_impl.dart';
import 'package:flutter_count_track/features/order_management/data/services/excel_import_service.dart';

// State class for order management
class OrderState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? selectedOrderSummary;

  const OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.selectedOrderSummary,
  });

  OrderState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? selectedOrderSummary,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedOrderSummary: selectedOrderSummary ?? this.selectedOrderSummary,
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  final OrderRepository _repository;
  final ExcelImportService _excelImportService;

  OrderNotifier(this._repository, this._excelImportService)
      : super(const OrderState()) {
    // İlk yüklemede siparişleri getir
    loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final orders = await _repository.getAllOrders();
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Siparişler yüklenirken hata oluştu: $e',
      );
    }
  }

  Future<void> createOrder(OrdersCompanion order) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _repository.createOrder(order);
      await loadOrders(); // Listeyi yenile
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Sipariş oluşturulurken hata oluştu: $e',
      );
    }
  }

  Future<void> updateOrderStatus(int orderId, OrderStatus newStatus) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _repository.updateOrderStatus(orderId, newStatus);
      await loadOrders(); // Listeyi yenile
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Sipariş durumu güncellenirken hata oluştu: $e',
      );
    }
  }

  Future<void> deleteOrder(int orderId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _repository.deleteOrder(orderId);
      await loadOrders(); // Listeyi yenile
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Sipariş silinirken hata oluştu: $e',
      );
    }
  }

  Future<void> searchOrders({
    String? orderCode,
    String? customerName,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final orders = await _repository.searchOrders(
        orderCode: orderCode,
        customerName: customerName,
        status: status,
        startDate: startDate,
        endDate: endDate,
      );
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Sipariş araması yapılırken hata oluştu: $e',
      );
    }
  }

  Future<void> loadOrderSummary(int orderId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final summary = await _repository.getOrderSummary(orderId);
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

  Future<void> updateOrderItemScannedQuantity(
    int orderItemId,
    int newQuantity,
  ) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _repository.updateOrderItemScannedQuantity(
          orderItemId, newQuantity);

      // Refresh both the main order list and the selected order summary if applicable
      await loadOrders();
      if (state.selectedOrderSummary != null) {
        final orderId = (state.selectedOrderSummary!['order'] as Order).id;
        await loadOrderSummary(orderId);
      }
      state = state.copyWith(
          isLoading: false); // Ensure loading is set to false after operations
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Taranan miktar güncellenirken hata oluştu: $e',
      );
    }
  }

  Future<void> importOrdersFromExcelFile(String filePath) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final List<ExcelOrderImportData> importDataList =
          await _excelImportService.importOrdersFromExcel(filePath);

      if (importDataList.isEmpty) {
        state = state.copyWith(
            isLoading: false,
            error: "Excel dosyasında içe aktarılacak geçerli veri bulunamadı.");
        return;
      }

      for (var importData in importDataList) {
        await _repository.createOrderWithItems(
          orderData: importData.order,
          itemsData: importData.items,
          customerProductCodes: importData.customerProductCodes,
        );
      }

      await loadOrders(); // Refresh the order list
      // state is already set to isLoading: false by loadOrders if successful
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Excel içe aktarma işlemi sırasında hata: $e',
      );
      // Re-throw to allow UI to catch it if needed, or handle it all here.
      // For now, the error is set in the state and caught by the UI's SnackBar.
    }
  }
}

// Providers
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return OrderRepositoryImpl(database);
});

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final excelImportServiceProvider = Provider<ExcelImportService>((ref) {
  return ExcelImportService();
});

final orderNotifierProvider =
    StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  final excelImportService = ref.watch(excelImportServiceProvider);
  return OrderNotifier(repository, excelImportService);
});
