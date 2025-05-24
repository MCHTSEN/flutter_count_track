import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_count_track/core/database/app_database.dart'; // For Order, OrderItem
import 'package:flutter_count_track/features/order_management/presentation/notifiers/order_detail_notifier.dart';
import 'package:flutter_count_track/features/order_management/presentation/widgets/order_detail_item_card.dart'; // Placeholder for item widget
import 'package:flutter_count_track/shared_widgets/loading_indicator.dart'; // Placeholder for loading widget
import 'package:flutter_count_track/features/barcode_scanning/presentation/widgets/barcode_notification_widget.dart';
import 'package:flutter_count_track/features/barcode_scanning/presentation/notifiers/barcode_notifier.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderCode; // Renamed from orderId for clarity

  const OrderDetailScreen({super.key, required this.orderCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderDetailNotifierProvider(orderCode));
    final barcodeState = ref.watch(barcodeNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Sipariş Detayı: $orderCode',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        toolbarHeight: 80,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: () => ref
                  .read(orderDetailNotifierProvider(orderCode).notifier)
                  .refreshOrderDetails(),
              icon: const Icon(Icons.refresh, size: 28),
              label: const Text('Yenile', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue[800],
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          )
        ],
      ),
      body: _buildBody(context, ref, state, barcodeState),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, OrderDetailState state,
      BarcodeState barcodeState) {
    if (state.isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Card(
          color: Colors.red[50],
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[600]),
                const SizedBox(height: 16),
                Text(
                  'Hata: ${state.errorMessage}',
                  style: TextStyle(
                    color: Colors.red[800],
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state.order == null) {
      return Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[600]),
                const SizedBox(height: 16),
                Text(
                  'Sipariş bilgisi bulunamadı.',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final order = state.order!;
    final itemDetails = state.orderItemDetails ?? [];

    return Column(
      children: [
        // Bildirim alanı - üstte sabit
        BarcodeNotificationWidget(state: barcodeState),

        // Ana grid layout
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sol panel - Sipariş bilgileri ve barkod girişi
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildOrderInfoCard(context, order),
                        const SizedBox(height: 16),
                        _buildBarcodeInputCard(context, ref, order),
                        const SizedBox(height: 16),
                        _buildOrderSummaryCard(context, itemDetails),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Sağ panel - Ürün grid'i
                Expanded(
                  flex: 2,
                  child: _buildProductGrid(context, itemDetails),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderInfoCard(BuildContext context, Order order) {
    String formatDate(DateTime date) {
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    }

    String getStatusText(OrderStatus status) {
      return switch (status) {
        OrderStatus.pending => 'Bekliyor',
        OrderStatus.partial => 'Kısmen Gönderildi',
        OrderStatus.completed => 'Tamamlandı',
      };
    }

    Color getStatusColor(OrderStatus status) {
      return switch (status) {
        OrderStatus.pending => Colors.orange,
        OrderStatus.partial => Colors.blue,
        OrderStatus.completed => Colors.green,
      };
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment, size: 32, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Text(
                  'Sipariş Bilgileri',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 16),
            _buildInfoRow('Sipariş Kodu:', order.orderCode, Icons.qr_code),
            const SizedBox(height: 12),
            _buildInfoRow('Müşteri:', order.customerName, Icons.business),
            const SizedBox(height: 12),
            _buildInfoRow(
                'Tarih:', formatDate(order.createdAt), Icons.calendar_today),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: getStatusColor(order.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: getStatusColor(order.status), width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: getStatusColor(order.status)),
                  const SizedBox(width: 8),
                  Text(
                    getStatusText(order.status),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: getStatusColor(order.status),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarcodeInputCard(
      BuildContext context, WidgetRef ref, Order order) {
    final TextEditingController controller = TextEditingController();
    final FocusNode focusNode = FocusNode();

    return Card(
      elevation: 4,
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.qr_code_scanner, size: 32, color: Colors.green[700]),
                const SizedBox(width: 12),
                Text(
                  'Barkod Okutma',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Barkodu girin veya okutun',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green[600]!, width: 2),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                prefixIcon: Icon(Icons.qr_code, color: Colors.green[600]),
              ),
              onSubmitted: (barcode) {
                if (barcode.isNotEmpty) {
                  _processBarcodeInput(context, ref, order, barcode);
                  controller.clear();
                  focusNode.requestFocus();
                }
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () {
                  String barcode = controller.text;
                  if (barcode.isNotEmpty) {
                    _processBarcodeInput(context, ref, order, barcode);
                    controller.clear();
                    focusNode.requestFocus();
                  }
                },
                icon: const Icon(Icons.qr_code_scanner, size: 28),
                label: const Text('BARKOD OKUT',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickBarcodeButtons(context, ref, order, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(
      BuildContext context, List<OrderItemDetail> itemDetails) {
    int totalItems = itemDetails.length;
    int totalQuantity =
        itemDetails.fold(0, (sum, item) => sum + item.orderItem.quantity);
    int scannedQuantity = itemDetails.fold(
        0, (sum, item) => sum + item.orderItem.scannedQuantity);
    double progress = totalQuantity > 0 ? scannedQuantity / totalQuantity : 0.0;

    return Card(
      elevation: 4,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, size: 32, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Text(
                  'Sipariş Özeti',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 16),
            _buildSummaryRow(
                'Toplam Ürün Çeşidi:', totalItems.toString(), Icons.category),
            const SizedBox(height: 12),
            _buildSummaryRow(
                'Toplam Adet:', totalQuantity.toString(), Icons.inventory),
            const SizedBox(height: 12),
            _buildSummaryRow('Okutulan Adet:', scannedQuantity.toString(),
                Icons.check_circle),
            const SizedBox(height: 16),
            Text(
              'İlerleme',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? Colors.green : Colors.blue,
              ),
              minHeight: 12,
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toInt()}% Tamamlandı',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: progress == 1.0 ? Colors.green[700] : Colors.blue[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid(
      BuildContext context, List<OrderItemDetail> itemDetails) {
    if (itemDetails.isEmpty) {
      return Card(
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined,
                  size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Bu siparişte ürün bulunmamaktadır.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(Icons.inventory, size: 32, color: Colors.purple[700]),
                const SizedBox(width: 12),
                Text(
                  'Siparişteki Ürünler',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700],
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1, height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 sütunlu grid
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2, // Kart boyut oranı
                ),
                itemCount: itemDetails.length,
                itemBuilder: (context, index) {
                  final itemDetail = itemDetails[index];
                  return _buildProductGridItem(context, itemDetail);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGridItem(
      BuildContext context, OrderItemDetail itemDetail) {
    final orderItem = itemDetail.orderItem;
    final product = itemDetail.product;
    final progress = orderItem.quantity > 0
        ? orderItem.scannedQuantity / orderItem.quantity
        : 0.0;

    final isCompleted = orderItem.scannedQuantity >= orderItem.quantity;
    final cardColor = isCompleted ? Colors.green[50] : Colors.white;
    final borderColor = isCompleted ? Colors.green : Colors.grey[300];

    return Card(
      elevation: 2,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor!, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ürün kodu ve durum ikonu
            Row(
              children: [
                Expanded(
                  child: Text(
                    product?.ourProductCode ?? 'Ürün kodu yok',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isCompleted ? Colors.green : Colors.grey,
                  size: 24,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Ürün adı
            Text(
              product?.name ?? 'Ürün adı yok',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const Spacer(),

            // İlerleme çubuğu
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? Colors.green : Colors.blue,
              ),
              minHeight: 8,
            ),

            const SizedBox(height: 8),

            // Miktar bilgisi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${orderItem.scannedQuantity}/${orderItem.quantity}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.green[700] : Colors.blue[700],
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickBarcodeButtons(BuildContext context, WidgetRef ref,
      Order order, TextEditingController controller) {
    final List<String> testBarcodes = [
      '12345678901',
      '23456789012',
      '34567890123',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı Test Barkodları:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...testBarcodes.map((barcode) => ActionChip(
                  label: Text(barcode, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.green[100],
                  onPressed: () {
                    _processBarcodeInput(context, ref, order, barcode);
                  },
                )),
            ActionChip(
              label: const Text('Rastgele', style: TextStyle(fontSize: 12)),
              avatar: const Icon(Icons.shuffle, size: 16),
              backgroundColor: Colors.orange[100],
              onPressed: () {
                final randomBarcode = List.generate(
                    13,
                    (_) => (DateTime.now().millisecondsSinceEpoch % 10)
                        .toString()).join();
                _processBarcodeInput(context, ref, order, randomBarcode);
              },
            ),
          ],
        ),
      ],
    );
  }

  void _processBarcodeInput(
      BuildContext context, WidgetRef ref, Order order, String barcode) {
    ref.read(barcodeNotifierProvider.notifier).processBarcode(
          barcode: barcode,
          orderId: order.id,
          customerName: order.customerName,
          onOrderUpdated: () {
            ref
                .read(orderDetailNotifierProvider(orderCode).notifier)
                .refreshOrderDetails();
          },
        );
  }
}
