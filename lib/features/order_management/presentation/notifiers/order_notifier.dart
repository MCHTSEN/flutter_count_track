import 'dart:async';

import 'package:flutter_count_track/core/database/app_database.dart';
import 'package:flutter_count_track/core/database/database_provider.dart';
import 'package:flutter_count_track/core/services/supabase_service.dart';
import 'package:flutter_count_track/features/order_management/data/services/excel_import_service.dart';
import 'package:flutter_count_track/features/order_management/domain/repositories/order_repository.dart';
import 'package:flutter_count_track/features/order_management/presentation/notifiers/order_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// State class for order management
class OrderState {
  final List<Order> orders;
  final List<Map<String, dynamic>>
      supabaseOrders; // Supabase'den gelen ham veriler
  final bool isLoading;
  final bool isSyncing;
  final String? error;
  final Map<String, dynamic>? selectedOrderSummary;
  final String? successMessage;
  final DateTime? lastSyncTime;
  final bool isRealTimeConnected;

  const OrderState({
    this.orders = const [],
    this.supabaseOrders = const [],
    this.isLoading = false,
    this.isSyncing = false,
    this.error,
    this.selectedOrderSummary,
    this.successMessage,
    this.lastSyncTime,
    this.isRealTimeConnected = false,
  });

  OrderState copyWith({
    List<Order>? orders,
    List<Map<String, dynamic>>? supabaseOrders,
    bool? isLoading,
    bool? isSyncing,
    String? error,
    Map<String, dynamic>? selectedOrderSummary,
    bool clearSelectedOrderSummary = false,
    String? successMessage,
    bool clearError = false,
    bool clearSuccessMessage = false,
    DateTime? lastSyncTime,
    bool? isRealTimeConnected,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      supabaseOrders: supabaseOrders ?? this.supabaseOrders,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      error: clearError ? null : error,
      selectedOrderSummary: clearSelectedOrderSummary
          ? null
          : selectedOrderSummary ?? this.selectedOrderSummary,
      successMessage: clearSuccessMessage ? null : successMessage,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      isRealTimeConnected: isRealTimeConnected ?? this.isRealTimeConnected,
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  final OrderRepository _repository;
  final ExcelImportService _excelImportService;
  final SupabaseSyncService? _syncService;
  final Logger _logger = Logger('OrderNotifier');
  Timer? _periodicTimer;
  RealtimeChannel? _realtimeChannel;

  OrderNotifier(this._repository, this._excelImportService, this._syncService)
      : super(const OrderState()) {
    loadOrders();
    _startPeriodicRefresh();
    _startRealtimeSubscription();
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    _stopRealtimeSubscription();
    super.dispose();
  }

  /// 30 saniyelik periyodik refresh başlatır
  void _startPeriodicRefresh() {
    _periodicTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _logger.info('⏰ OrderNotifier: 30 saniyelik periyodik refresh');
      loadOrders(forceSync: false);
    });
    _logger.info('⏰ OrderNotifier: Periyodik refresh başlatıldı (30 saniye)');
  }

  /// Real-time subscription başlatır
  void _startRealtimeSubscription() {
    if (_syncService == null) {
      _logger.warning(
          '⚠️ OrderNotifier: Supabase service mevcut değil, real-time sync devre dışı');
      return;
    }

    try {
      _realtimeChannel = _syncService.subscribeToOrderChanges((orderData) {
        _logger.info('🔴 OrderNotifier: Real-time güncelleme alındı');
        // Hemen yeni veriyi yükle (cache'i bypass et)
        loadOrders(isRealtimeUpdate: true);
      });

      state = state.copyWith(isRealTimeConnected: true);
      _logger.info('🔴 OrderNotifier: Real-time subscription başlatıldı');
    } catch (e) {
      _logger.warning(
          '⚠️ OrderNotifier: Real-time subscription başlatılamadı: $e');
      state = state.copyWith(isRealTimeConnected: false);
    }
  }

  /// Real-time subscription'ı durdurur
  void _stopRealtimeSubscription() {
    if (_realtimeChannel != null && _syncService != null) {
      _syncService.unsubscribeFromOrderChanges(_realtimeChannel!);
      _realtimeChannel = null;
      state = state.copyWith(isRealTimeConnected: false);
      _logger.info('🔴 OrderNotifier: Real-time subscription durduruldu');
    }
  }

  /// Ekran focus durumunda çağrılacak method
  void onScreenFocus() {
    _logger.info('👁️ OrderNotifier: Ekran focus alındı, verileri yenileniyor');
    loadOrders(forceSync: true);
  }

  /// Hybrid approach: Local data ile hemen yükle, ardından Supabase'den sync yap
  Future<void> loadOrders({
    String? searchQuery,
    OrderStatus? filterStatus,
    bool forceSync = false,
    bool isRealtimeUpdate = false,
  }) async {
    try {
      // Real-time update ise loading gösterme
      if (!isRealtimeUpdate) {
        state = state.copyWith(
            isLoading: true, clearError: true, clearSuccessMessage: true);
      }

      // 1. Önce local verilerden yükle (hızlı)
      final localOrders = await _repository.getOrders(
          searchQuery: searchQuery, filterStatus: filterStatus);

      state = state.copyWith(orders: localOrders, isLoading: false);

      // 2. Eğer Supabase service varsa, background'da sync yap
      if (_syncService != null &&
          (forceSync || SupabaseService.isOnline || isRealtimeUpdate)) {
        await _syncFromSupabase(
            searchQuery: searchQuery, filterStatus: filterStatus);
      }
    } catch (e) {
      _logger.severe('💥 Orders yüklenirken hata', e);
      state = state.copyWith(
        isLoading: false,
        error: 'Siparişler yüklenirken hata oluştu: $e',
      );
    }
  }

  /// Supabase'den veri çekip sync yapan method
  Future<void> _syncFromSupabase({
    String? searchQuery,
    OrderStatus? filterStatus,
  }) async {
    if (_syncService == null) return;

    try {
      state = state.copyWith(isSyncing: true);
      _logger.info('🔄 Supabase sync başlatıldı');

      // Supabase'den veri çek
      final supabaseOrders = await _syncService.fetchOrdersFromSupabase(
        searchQuery: searchQuery,
        status: filterStatus?.name,
        limit: 100,
      );

      state = state.copyWith(
        supabaseOrders: supabaseOrders,
        lastSyncTime: DateTime.now(),
      );

      // Local verileri tekrar yükle (sync sonrasında güncellenmiş olabilir)
      final localOrders = await _repository.getOrders(
          searchQuery: searchQuery, filterStatus: filterStatus);

      state = state.copyWith(
        orders: localOrders,
        isSyncing: false,
      );

      _logger
          .info('✅ Supabase sync tamamlandı: ${supabaseOrders.length} sipariş');
    } catch (e) {
      _logger.warning(
          '⚠️ Supabase sync hatası (local veriler kullanılıyor)', e);
      state = state.copyWith(
        isSyncing: false,
        error: 'Sync hatası: $e (local veriler kullanılıyor)',
      );
    }
  }

  /// Manuel sync tetikleme
  Future<void> syncWithSupabase() async {
    await loadOrders(forceSync: true);
  }

  Future<void> createOrder(OrdersCompanion orderCompanion) async {
    try {
      state = state.copyWith(
          isLoading: true, clearError: true, clearSuccessMessage: true);

      await _repository.createOrder(orderCompanion);

      // Supabase'e de gönder (background)
      if (_syncService != null && SupabaseService.isOnline) {
        try {
          // Local'dan yeni oluşturulan siparişi al ve Supabase'e push et
          final createdOrder =
              await _repository.getOrderByCode(orderCompanion.orderCode.value);
          if (createdOrder != null) {
            await _syncService.pushOrderToSupabase(createdOrder);
            _logger.info(
                '✅ Sipariş Supabase\'e gönderildi: ${createdOrder.orderCode}');
          }
        } catch (e) {
          _logger.warning(
              '⚠️ Sipariş Supabase\'e gönderilemedi (offline\'da sync olacak)',
              e);
        }
      }

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

      // Supabase'e barkod okuma kaydını gönder (background)
      if (_syncService != null &&
          SupabaseService.isOnline &&
          activeOrderCode != null) {
        try {
          // Order item'dan product ID'yi ve barkod'u al
          final orderItem = await _repository.getOrderItemById(orderItemId);
          if (orderItem != null) {
            final product =
                await _repository.getProductById(orderItem.productId);
            if (product != null) {
              await _syncService.pushBarcodeReadToSupabase(
                orderCode: activeOrderCode,
                barcode: product.barcode,
                productId: product.id,
                scannedQuantity: newQuantity,
              );
              _logger.info('✅ Barkod okuma Supabase\'e gönderildi');
            }
          }
        } catch (e) {
          _logger.warning('⚠️ Barkod okuma Supabase\'e gönderilemedi', e);
        }
      }

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
  final syncService = ref.watch(supabaseSyncServiceProvider);
  return OrderNotifier(repository, excelService, syncService);
});
