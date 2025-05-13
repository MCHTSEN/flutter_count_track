import 'package:flutter/material.dart';
import 'package:flutter_count_track/core/database/app_database.dart';
import 'package:flutter_count_track/features/order_management/presentation/screens/order_detail_screen.dart';

class OrderListItem extends StatelessWidget {
  final Order order;

  const OrderListItem({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          'Sipariş #${order.orderCode}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(order.customerName),
            const SizedBox(height: 4),
            Text(
              'Oluşturulma: ${_formatDate(order.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: _buildStatusChip(context, order.status),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OrderDetailScreen(orderCode: order.orderCode),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, OrderStatus status) {
    final (Color chipColor, String label) = switch (status) {
      OrderStatus.pending => (
          Theme.of(context).colorScheme.secondaryContainer,
          'Bekliyor'
        ),
      OrderStatus.partial => (
          Theme.of(context).colorScheme.tertiaryContainer,
          'Kısmi Gönderim'
        ),
      OrderStatus.completed => (
          Theme.of(context).colorScheme.primaryContainer,
          'Tamamlandı'
        ),
    };

    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          fontSize: 12,
        ),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
