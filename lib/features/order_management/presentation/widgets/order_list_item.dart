import 'package:flutter/material.dart';
import 'package:flutter_count_track/core/database/app_database.dart';

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
        trailing: _buildStatusChip(order.status),
        onTap: () {
          // TODO: Sipariş detay sayfasına yönlendir
        },
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    final (color, label) = switch (status) {
      OrderStatus.pending => (Colors.orange, 'Bekliyor'),
      OrderStatus.partial => (Colors.blue, 'Kısmi Gönderim'),
      OrderStatus.completed => (Colors.green, 'Tamamlandı'),
    };

    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
