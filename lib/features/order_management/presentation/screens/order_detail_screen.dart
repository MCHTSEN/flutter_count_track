import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_count_track/core/database/app_database.dart'; // For Order, OrderItem
import 'package:flutter_count_track/features/order_management/presentation/notifiers/order_detail_notifier.dart';
import 'package:flutter_count_track/features/order_management/presentation/widgets/order_detail_item_card.dart'; // Placeholder for item widget
import 'package:flutter_count_track/shared_widgets/loading_indicator.dart'; // Placeholder for loading widget

class OrderDetailScreen extends ConsumerWidget {
  final String orderCode; // Renamed from orderId for clarity

  const OrderDetailScreen({super.key, required this.orderCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderDetailNotifierProvider(orderCode));

    return Scaffold(
      appBar: AppBar(
        title: Text('Sipariş Detayı: $orderCode'), // Sipariş Detayı
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(orderDetailNotifierProvider(orderCode).notifier)
                .refreshOrderDetails(),
            tooltip: 'Yenile', // Refresh
          )
        ],
      ),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(
      BuildContext context, WidgetRef ref, OrderDetailState state) {
    if (state.isLoading) {
      return const Center(
          child: LoadingIndicator()); // Use shared loading indicator
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Hata: ${state.errorMessage}', // Error
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (state.order == null) {
      // This case might be covered by errorMessage, but as a fallback:
      return const Center(
          child: Text(
              'Sipariş bilgisi bulunamadı.')); // Order information not found.
    }

    final order = state.order!;
    final items = state.orderItems ?? [];

    // Helper to format date
    String formatDate(DateTime date) {
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    }

    // Helper to get status string
    String getStatusText(OrderStatus status) {
      return switch (status) {
        OrderStatus.pending => 'Bekliyor', // Pending
        OrderStatus.partial => 'Kısmen Gönderildi', // Partially Shipped
        OrderStatus.completed => 'Tamamlandı', // Completed
      };
    }

    return RefreshIndicator(
      onRefresh: () => ref
          .read(orderDetailNotifierProvider(orderCode).notifier)
          .refreshOrderDetails(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Müşteri: ${order.customerName}',
                style: Theme.of(context).textTheme.titleLarge), // Customer
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tarih: ${formatDate(order.createdAt)}'), // Date
                Chip(
                  label: Text(getStatusText(order.status)),
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Siparişteki Ürünler',
                style:
                    Theme.of(context).textTheme.titleLarge), // Items in Order
            const Divider(),
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text(
                          'Bu siparişte ürün bulunmamaktadır.')) // No items in this order.
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        // TODO: Create and use OrderDetailItemCard widget
                        return OrderDetailItemCard(
                            orderItem: item); // Placeholder
                        // return ListTile(
                        //   title: Text('Ürün ID: ${item.productId}'), // Product ID
                        //   subtitle: Text('İstenen: ${item.quantity}, Okunan: ${item.scannedQuantity}'), // Required: X, Scanned: Y
                        //   trailing: Text('Kalan: ${item.quantity - item.scannedQuantity}'), // Remaining
                        //   // TODO: Add progress bar based on quantity vs scannedQuantity
                        // );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
