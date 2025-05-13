import 'package:flutter/material.dart';
import 'package:flutter_count_track/core/database/app_database.dart'; // For OrderItem

class OrderDetailItemCard extends StatelessWidget {
  final OrderItem orderItem;

  const OrderDetailItemCard({super.key, required this.orderItem});

  @override
  Widget build(BuildContext context) {
    // TODO: Fetch Product details (ourProductCode, customerProductCode via mapping) using orderItem.productId
    // This might require passing the repository/notifier or making another Riverpod call if complex.
    // For now, just display productId.

    double progress = 0;
    if (orderItem.quantity > 0) {
      progress = orderItem.scannedQuantity / orderItem.quantity;
    }

    int remainingQuantity = orderItem.quantity - orderItem.scannedQuantity;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TODO: Display Müşteri Ürün Kodu and Bizim Ürün Kodumuz (after mapping)
            Text(
              'Ürün ID: ${orderItem.productId}', // Product ID - Placeholder, replace with actual codes
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'İstenen Miktar: ${orderItem.quantity}'), // Required Quantity
                Text(
                    'Okunan Miktar: ${orderItem.scannedQuantity}'), // Scanned Quantity
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Kalan Miktar: $remainingQuantity', // Remaining Quantity
              style: TextStyle(
                  color: remainingQuantity > 0 ? Colors.orange : Colors.green,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? Colors.green : Colors.blue,
              ),
              minHeight: 10,
            ),
          ],
        ),
      ),
    );
  }
}
