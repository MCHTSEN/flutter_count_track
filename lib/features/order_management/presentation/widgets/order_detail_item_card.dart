import 'package:flutter/material.dart';
import 'package:flutter_count_track/core/database/app_database.dart'; // For OrderItem
import 'package:flutter_count_track/features/order_management/presentation/notifiers/order_detail_notifier.dart';

class OrderDetailItemCard extends StatelessWidget {
  final OrderItemDetail itemDetail;

  const OrderDetailItemCard({super.key, required this.itemDetail});

  @override
  Widget build(BuildContext context) {
    final OrderItem orderItem = itemDetail.orderItem;
    final Product? product = itemDetail.product;
    final ProductCodeMapping? mapping = itemDetail.productCodeMapping;

    double progress = 0;
    if (orderItem.quantity > 0) {
      progress = orderItem.scannedQuantity / orderItem.quantity;
    }

    int remainingQuantity = orderItem.quantity - orderItem.scannedQuantity;

    // Barkod bilgisi
    final String customerBarcode =
        mapping?.customerProductCode ?? 'Barkod bilgisi yok';
    final String ourProductCode = product?.ourProductCode ?? 'Ürün kodu yok';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ürün başlık ve barkod bilgileri
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sol taraf - Ürün bilgileri
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Müşteri Ürün Kodu: $customerBarcode',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bizim Ürün Kodumuz: $ourProductCode',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),

                // Sağ taraf - QR ikon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.qr_code, size: 30),
                      Text(
                        customerBarcode,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Miktar bilgileri
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

            // İlerleme çubuğu
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? Colors.green : Colors.blue,
              ),
              minHeight: 10,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}
