import 'dart:async';

import 'package:flutter_count_track/core/database/app_database.dart'; // For Order, OrderItem, OrderStatus
import 'package:flutter_count_track/core/database/database_provider.dart';
import 'package:flutter_count_track/core/services/supabase_service.dart';
import 'package:flutter_count_track/features/order_management/domain/repositories/order_repository.dart';
// Assuming a provider for OrderRepository is defined elsewhere, e.g., order_providers.dart
import 'package:flutter_count_track/features/order_management/presentation/notifiers/order_providers.dart'; // Placeholder for actual provider
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  Timer? _syncTimer;
  RealtimeChannel? _realtimeChannel;
  final SupabaseSyncService? _supabaseService;

  OrderDetailNotifier(
      this._orderCode, this._orderRepository, this._supabaseService)
      : super(const OrderDetailState(isLoading: true)) {
    _fetchOrderDetails();
    _startPeriodicSync();
    _startRealtimeSubscription();
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _stopRealtimeSubscription();
    super.dispose();
  }

  Future<void> _fetchOrderDetails() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      print(
          '🔍 OrderDetail: Fetching order details for orderCode: $_orderCode');

      final order = await _orderRepository.getOrderById(_orderCode);
      print('📋 OrderDetail: Order found: ${order?.orderCode ?? 'null'}');

      if (order != null) {
        print('🔄 OrderDetail: Fetching order items...');
        final items = await _orderRepository.getOrderItems(_orderCode);
        print('📦 OrderDetail: Found ${items.length} order items');

        // Order items'ları debug için detaylı yazdır
        for (var i = 0; i < items.length; i++) {
          final item = items[i];
          print(
              '📋 OrderDetail: Item $i - OrderId: ${item.orderId}, ProductId: ${item.productId}, Quantity: ${item.quantity}, Scanned: ${item.scannedQuantity}');
        }

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

        print(
            '🎯 OrderDetail: Setting state with ${itemDetails.length} itemDetails');
        state = state.copyWith(
            isLoading: false,
            order: order,
            orderItemDetails: itemDetails,
            barcodeHistory: barcodeHistory);
        print('✅ OrderDetail: State updated successfully');
      } else {
        print('❌ OrderDetail: Order not found');
        state = state.copyWith(
            isLoading: false,
            errorMessage: "Sipariş bulunamadı."); // Order not found.
      }
    } catch (e, stackTrace) {
      print('💥 OrderDetail: Error fetching details: $e');
      print('💥 OrderDetail: Stack trace: $stackTrace');
      state = state.copyWith(
          isLoading: false,
          errorMessage:
              "Detaylar getirilirken hata: ${e.toString()}"); // Error fetching details
    }
  }

  Future<void> refreshOrderDetails() async {
    print(
        '🔄 OrderDetail: refreshOrderDetails çağırıldı - OrderCode: $_orderCode');
    await _fetchOrderDetails();
    print(
        '✅ OrderDetail: refreshOrderDetails tamamlandı - ItemDetails: ${state.orderItemDetails?.length ?? 0}');
  }

  /// Manuel sync ile refresh (Yenile butonu için)
  Future<void> refreshOrderDetailsWithSync() async {
    print(
        '🔄 OrderDetail: Manuel sync ile refresh başlatıldı - OrderCode: $_orderCode');
    await _fetchOrderDetailsWithSync();
    print(
        '✅ OrderDetail: Manuel sync ile refresh tamamlandı - ItemDetails: ${state.orderItemDetails?.length ?? 0}');
  }

  /// 30 saniyelik periyodik sync başlatır (5 dakika yerine)
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      print(
          '⏰ OrderDetail: 30 saniyelik periyodik sync başlatıldı - OrderCode: $_orderCode');
      _fetchOrderDetailsWithSync();
    });
    print(
        '⏰ OrderDetail: Periyodik sync başlatıldı (30 saniye) - OrderCode: $_orderCode');
  }

  /// Real-time subscription başlatır
  void _startRealtimeSubscription() {
    if (_supabaseService == null) {
      print(
          '⚠️ OrderDetail: Supabase service mevcut değil, real-time sync devre dışı');
      return;
    }

    try {
      _realtimeChannel = _supabaseService.subscribeToOrderChanges((orderData) {
        // Sadece bu siparişe ait değişiklikleri işle
        if (orderData['order_code'] == _orderCode) {
          print(
              '🔴 OrderDetail: Real-time güncelleme alındı - OrderCode: $_orderCode');
          _fetchOrderDetailsWithSync();
        }
      });
      print(
          '🔴 OrderDetail: Real-time subscription başlatıldı - OrderCode: $_orderCode');
    } catch (e) {
      print('⚠️ OrderDetail: Real-time subscription başlatılamadı: $e');
    }
  }

  /// Real-time subscription'ı durdurur
  void _stopRealtimeSubscription() {
    if (_realtimeChannel != null && _supabaseService != null) {
      _supabaseService.unsubscribeFromOrderChanges(_realtimeChannel!);
      _realtimeChannel = null;
      print(
          '🔴 OrderDetail: Real-time subscription durduruldu - OrderCode: $_orderCode');
    }
  }

  /// Ekran focus durumunda çağrılacak method
  void onScreenFocus() {
    print(
        '👁️ OrderDetail: Ekran focus alındı, verileri yenileniyor - OrderCode: $_orderCode');
    _fetchOrderDetailsWithSync();
  }

  /// Sync ile order details fetch eder
  Future<void> _fetchOrderDetailsWithSync() async {
    try {
      print(
          '🔄 OrderDetail: Sync ile fetching başlatıldı - OrderCode: $_orderCode');

      final order = await _orderRepository.getOrderById(_orderCode);
      if (order == null) {
        print('❌ OrderDetail: Order not found');
        state = state.copyWith(
            isLoading: false, errorMessage: "Sipariş bulunamadı.");
        return;
      }

      // Sync ile order items çek
      final items = await _orderRepository.getOrderItemsWithSync(_orderCode);
      print('📦 OrderDetail: Sync ile ${items.length} order items bulundu');

      // Ürün detaylarını ve barkod bilgilerini getir
      final List<OrderItemDetail> itemDetails = [];

      for (final item in items) {
        final product = await _orderRepository.getProductById(item.productId);
        final mapping = await _orderRepository.getProductCodeMapping(
            item.productId, order.customerName);

        itemDetails.add(OrderItemDetail(
          orderItem: item,
          product: product,
          productCodeMapping: mapping,
        ));
      }

      // Barkod geçmişini getir
      final barcodeHistory =
          await _orderRepository.getBarcodeHistory(_orderCode);

      state = state.copyWith(
          isLoading: false,
          order: order,
          orderItemDetails: itemDetails,
          barcodeHistory: barcodeHistory);

      print(
          '✅ OrderDetail: Sync ile fetch tamamlandı - ${itemDetails.length} items');
    } catch (e, stackTrace) {
      print('💥 OrderDetail: Sync ile fetch hatası: $e');
      print('💥 OrderDetail: Stack trace: $stackTrace');
    }
  }

  // TODO: Add other methods if needed, e.g., to update item scanned quantity which would then refresh
}

final orderDetailNotifierProvider = StateNotifierProvider.autoDispose
    .family<OrderDetailNotifier, OrderDetailState, String>((ref, orderCode) {
  final orderRepository = ref.watch(orderRepositoryProvider);
  SupabaseSyncService? supabaseService;
  try {
    supabaseService = ref.watch(supabaseSyncServiceProvider);
  } catch (e) {
    supabaseService = null;
  }
  return OrderDetailNotifier(orderCode, orderRepository, supabaseService);
});
