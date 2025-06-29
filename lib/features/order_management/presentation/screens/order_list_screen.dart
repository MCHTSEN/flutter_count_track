import 'package:flutter/material.dart';
import 'package:flutter_count_track/core/database/app_database.dart';
import 'package:flutter_count_track/features/order_management/presentation/mixins/order_list_screen_mixin.dart';
import 'package:flutter_count_track/features/order_management/presentation/notifiers/order_notifier.dart';
import 'package:flutter_count_track/features/order_management/presentation/notifiers/order_providers.dart';
import 'package:flutter_count_track/features/order_management/presentation/widgets/order_app_bar.dart';
import 'package:flutter_count_track/features/order_management/presentation/widgets/order_filter_section.dart';
import 'package:flutter_count_track/features/order_management/presentation/widgets/order_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderListScreen extends ConsumerStatefulWidget {
  const OrderListScreen({super.key});

  @override
  ConsumerState<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen>
    with OrderListScreenMixin, WidgetsBindingObserver {
  String _searchQuery = '';
  OrderStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    // App lifecycle observer'ı kaydet
    WidgetsBinding.instance.addObserver(this);

    // Ekran ilk açıldığında refresh et
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onScreenFocus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Uygulama foreground'a geçtiğinde refresh et
    if (state == AppLifecycleState.resumed) {
      _onScreenFocus();
    }
  }

  /// Ekran focus alındığında çağrılır
  void _onScreenFocus() {
    print('👁️ OrderListScreen: Focus alındı, verileri yenileniyor');
    ref.read(orderNotifierProvider.notifier).onScreenFocus();
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderNotifierProvider);
    final connectivityState = ref.watch(connectivityStatusProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: OrderAppBar(
        onRefreshPressed: () => refreshOrders(ref),
        orderState: orderState,
        connectivityState: connectivityState,
      ),
      body: Column(
        children: [
          // Üst filtreleme ve arama alanı
          OrderFilterSection(
            searchQuery: _searchQuery,
            selectedStatus: _selectedStatus,
            onSearchChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            onStatusChanged: (value) {
              setState(() {
                _selectedStatus = value;
              });
            },
            orders: orderState.orders,
          ),

          // Ana sipariş listesi
          Expanded(
            child: OrderList(
              orders: orderState.orders,
              isLoading: orderState.isLoading,
              error: orderState.error,
              searchQuery: _searchQuery,
              selectedStatus: _selectedStatus,
              onRetry: () => refreshOrders(ref),
              onClearFilters: () => clearFilters(() {
                setState(() {
                  _searchQuery = '';
                  _selectedStatus = null;
                });
              }),
            ),
          ),
        ],
      ),
    );
  }
}
