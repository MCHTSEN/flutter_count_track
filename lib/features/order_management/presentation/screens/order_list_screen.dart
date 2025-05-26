import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_count_track/core/database/app_database.dart';
import 'package:flutter_count_track/features/order_management/presentation/notifiers/order_notifier.dart';
import 'package:flutter_count_track/features/order_management/presentation/widgets/order_filter_section.dart';
import 'package:flutter_count_track/features/order_management/presentation/widgets/order_list.dart';
import 'package:flutter_count_track/features/order_management/presentation/widgets/order_app_bar.dart';
import 'package:flutter_count_track/features/order_management/presentation/mixins/order_list_screen_mixin.dart';

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

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: OrderAppBar(
        onImportPressed: () => importFromExcel(context, ref),
        onRefreshPressed: () => refreshOrders(ref),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Yeni sipariş ekleme ekranına yönlendir
        },
        icon: const Icon(Icons.add, size: 28),
        label: const Text('Yeni Sipariş', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
      ),
    );
  }
}
