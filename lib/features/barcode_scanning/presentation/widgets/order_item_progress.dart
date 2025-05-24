import 'package:flutter/material.dart';
import 'package:flutter_count_track/core/database/app_database.dart';

class OrderItemProgress extends StatelessWidget {
  final OrderItem item;
  final Product? product;
  final ProductCodeMapping? mapping;

  const OrderItemProgress({
    super.key,
    required this.item,
    this.product,
    this.mapping,
  });

  @override
  Widget build(BuildContext context) {
    final double progress =
        item.quantity > 0 ? item.scannedQuantity / item.quantity : 0.0;

    final bool isComplete = item.scannedQuantity >= item.quantity;

    // Renkler
    final Color progressColor =
        isComplete ? Colors.green : (progress > 0 ? Colors.blue : Colors.grey);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ürün bilgileri
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mapping?.customerProductCode ?? 'Ürün Kodu Yok',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (product != null)
                        Text(
                          'Firma Kodu: ${product!.ourProductCode}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                    ],
                  ),
                ),
                // Sayım durumu
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: progressColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: progressColor),
                  ),
                  child: Text(
                    '${item.scannedQuantity} / ${item.quantity}',
                    style: TextStyle(
                      color: progressColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // İlerleme çubuğu
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              color: progressColor,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),

            const SizedBox(height: 8),

            // İlerleme durumu
            Text(
              isComplete
                  ? 'Tamamlandı'
                  : 'Kalan: ${item.quantity - item.scannedQuantity}',
              style: TextStyle(
                color: isComplete ? Colors.green : Colors.black54,
                fontWeight: isComplete ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
