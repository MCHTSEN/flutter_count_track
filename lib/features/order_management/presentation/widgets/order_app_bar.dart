import 'package:flutter/material.dart';
import 'package:flutter_count_track/core/database/app_database.dart';
import 'package:flutter_count_track/core/utils/ui_helper.dart';
import 'package:flutter_count_track/features/order_management/presentation/notifiers/order_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onRefreshPressed;
  final OrderState orderState;
  final AsyncValue<bool> connectivityState;

  const OrderAppBar({
    super.key,
    required this.onRefreshPressed,
    required this.orderState,
    required this.connectivityState,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _buildStatsRow(),
      backgroundColor: Colors.blue[800],
      foregroundColor: Colors.white,
      toolbarHeight: 100,
      actions: [
        Row(
          children: [
            _buildSupabaseStatus(),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: onRefreshPressed,
              icon: const Icon(Icons.refresh, size: 28),
              label: const Text('Yenile', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue[800],
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ).withPadding(right: 8),
      ],
    );
  }

  Widget _buildSupabaseStatus() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildRealTimeStatusBar(),
        const SizedBox(height: 4),
        if (orderState.supabaseOrders.isNotEmpty) _buildSupabaseOrdersSummary(),
      ],
    );
  }

  Widget _buildSupabaseOrdersSummary() {
    final supabaseCount = orderState.supabaseOrders.length;
    final localCount = orderState.orders.length;

    return Row(
      children: [
        Icon(Icons.cloud_done, color: Colors.white.withOpacity(0.8), size: 14),
        const SizedBox(width: 4),
        Text(
          'Supabase: $supabaseCount • Local: $localCount',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (supabaseCount != localCount) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Sync Gerekli',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildRealTimeStatusBar() {
    final isOnline = connectivityState.value ?? false;
    final isRealTimeConnected = orderState.isRealTimeConnected;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isRealTimeConnected && isOnline) {
      statusColor = Colors.green[300]!;
      statusText = 'Real-time Aktif';
      statusIcon = Icons.sync;
    } else if (isOnline) {
      statusColor = Colors.orange[300]!;
      statusText = 'Çevrimiçi';
      statusIcon = Icons.wifi;
    } else {
      statusColor = Colors.red[300]!;
      statusText = 'Çevrimdışı';
      statusIcon = Icons.wifi_off;
    }

    return Row(
      children: [
        Icon(statusIcon, size: 14, color: statusColor),
        const SizedBox(width: 4),
        Text(
          statusText,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    final pendingCount =
        orderState.orders.where((o) => o.status == OrderStatus.pending).length;
    final partialCount =
        orderState.orders.where((o) => o.status == OrderStatus.partial).length;
    final completedCount = orderState.orders
        .where((o) => o.status == OrderStatus.completed)
        .length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatChip(
          'Bekliyor',
          pendingCount.toString(),
          Colors.orange,
          Icons.pending_actions,
        ),
        const SizedBox(width: 20),
        _buildStatChip(
          'Kısmi',
          partialCount.toString(),
          Colors.blue,
          Icons.local_shipping,
        ),
        const SizedBox(width: 20),
        _buildStatChip(
          'Tamamlandı',
          completedCount.toString(),
          Colors.green,
          Icons.check_circle,
        ),
        const SizedBox(width: 20),
        _buildStatChip(
          'Toplam',
          orderState.orders.length.toString(),
          Colors.purple,
          Icons.inventory,
        ),
      ],
    );
  }

  Widget _buildStatChip(
      String title, String count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                count,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
