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
    with OrderListScreenMixin {
  String _searchQuery = '';
  OrderStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderNotifierProvider);
    final connectivityStatus = ref.watch(connectivityStatusProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: OrderAppBar(
        onImportPressed: () => importFromExcel(context, ref),
        onRefreshPressed: () => refreshOrders(ref),
      ),
      body: Column(
        children: [
          // Sync Status Bar
          _buildSyncStatusBar(context, orderState, connectivityStatus),

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

  Widget _buildSyncStatusBar(
    BuildContext context,
    OrderState orderState,
    AsyncValue<bool> connectivityStatus,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _getSyncStatusColor(orderState, connectivityStatus),
      child: Row(
        children: [
          Icon(
            _getSyncStatusIcon(orderState, connectivityStatus),
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getSyncStatusText(orderState, connectivityStatus),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (orderState.lastSyncTime != null)
            Text(
              'Son Sync: ${_formatTime(orderState.lastSyncTime!)}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
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

  Color _getSyncStatusColor(
      OrderState orderState, AsyncValue<bool> connectivityStatus) {
    if (orderState.isSyncing) return Colors.blue;
    if (orderState.error != null) return Colors.red;

    return connectivityStatus.when(
      data: (isOnline) => isOnline ? Colors.green : Colors.orange,
      loading: () => Colors.grey,
      error: (_, __) => Colors.red,
    );
  }

  IconData _getSyncStatusIcon(
      OrderState orderState, AsyncValue<bool> connectivityStatus) {
    if (orderState.isSyncing) return Icons.sync;
    if (orderState.error != null) return Icons.error;

    return connectivityStatus.when(
      data: (isOnline) => isOnline ? Icons.cloud_done : Icons.cloud_off,
      loading: () => Icons.cloud_queue,
      error: (_, __) => Icons.error,
    );
  }

  String _getSyncStatusText(
      OrderState orderState, AsyncValue<bool> connectivityStatus) {
    if (orderState.isSyncing) {
      return 'Supabase ile senkronizasyon yapılıyor...';
    }

    if (orderState.error != null) {
      return 'Hata: ${orderState.error}';
    }

    return connectivityStatus.when(
      data: (isOnline) => isOnline
          ? 'Online - Supabase bağlantısı aktif'
          : 'Offline - Sadece yerel veriler',
      loading: () => 'Bağlantı durumu kontrol ediliyor...',
      error: (_, __) => 'Bağlantı hatası',
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
