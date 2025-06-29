import 'package:flutter/material.dart';
import 'package:flutter_count_track/core/database/app_database.dart';
import 'package:flutter_count_track/core/services/supabase_service.dart';
import 'package:flutter_count_track/features/order_management/presentation/mixins/order_list_screen_mixin.dart';
import 'package:flutter_count_track/features/order_management/presentation/notifiers/order_notifier.dart';
import 'package:flutter_count_track/features/order_management/presentation/notifiers/order_providers.dart';
import 'package:flutter_count_track/features/order_management/presentation/screens/add_order_screen.dart';
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
        onImportPressed: () => importFromExcel(context, ref),
        onRefreshPressed: () => refreshOrders(ref),
      ),
      body: Column(
        children: [
          // Real-time bağlantı durumu
          _buildRealTimeStatusBar(orderState, connectivityState),

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

          // Supabase Orders Summary (eğer varsa)
          if (orderState.supabaseOrders.isNotEmpty)
            _buildSupabaseOrdersSummary(context, orderState),

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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sync Floating Action Button
          FloatingActionButton(
            heroTag: "sync",
            onPressed: orderState.isSyncing
                ? null
                : () async {
                    await ref
                        .read(orderNotifierProvider.notifier)
                        .syncWithSupabase();
                  },
            backgroundColor:
                SupabaseService.isOnline ? Colors.teal : Colors.grey,
            child: orderState.isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    SupabaseService.isOnline
                        ? Icons.cloud_sync
                        : Icons.cloud_off,
                    color: Colors.white,
                  ),
          ),
          const SizedBox(height: 8),
          // Add Order Floating Action Button
          FloatingActionButton.extended(
            heroTag: "add",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddOrderScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add, size: 28),
            label: const Text('Yeni Sipariş', style: TextStyle(fontSize: 16)),
            backgroundColor: Colors.orange[600],
            foregroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildSupabaseOrdersSummary(
      BuildContext context, OrderState orderState) {
    final supabaseCount = orderState.supabaseOrders.length;
    final localCount = orderState.orders.length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_done, color: Colors.teal[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Supabase: $supabaseCount sipariş • Local: $localCount sipariş',
              style: TextStyle(
                color: Colors.teal[700],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (supabaseCount != localCount)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Sync Gerekli',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRealTimeStatusBar(
      OrderState orderState, AsyncValue<bool> connectivityState) {
    final isOnline = connectivityState.value ?? false;
    final isRealTimeConnected = orderState.isRealTimeConnected;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isRealTimeConnected && isOnline) {
      statusColor = Colors.green;
      statusText = 'Real-time Aktif • Otomatik Güncelleme Açık';
      statusIcon = Icons.sync;
    } else if (isOnline) {
      statusColor = Colors.orange;
      statusText = 'Çevrimiçi • 30 Saniyede Bir Kontrol';
      statusIcon = Icons.sync_problem;
    } else {
      statusColor = Colors.red;
      statusText = 'Çevrimdışı • Sadece Yerel Veriler';
      statusIcon = Icons.sync_disabled;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: statusColor.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Icon(statusIcon, size: 16, color: statusColor),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (orderState.lastSyncTime != null)
            Text(
              'Son: ${orderState.lastSyncTime!.hour.toString().padLeft(2, '0')}:${orderState.lastSyncTime!.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }
}
