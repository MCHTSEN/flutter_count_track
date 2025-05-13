import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_count_track/core/constants/app_constants.dart';
import 'package:flutter_count_track/core/database/app_database.dart';
import 'package:flutter_count_track/features/order_management/presentation/notifiers/order_notifier.dart';
import 'package:flutter_count_track/features/order_management/presentation/widgets/order_list_item.dart';
import 'package:flutter_count_track/features/order_management/presentation/widgets/order_search_bar.dart';

class OrderListScreen extends ConsumerWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(orderNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Siparişler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: 'Import from Excel',
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['xls', 'xlsx'],
              );

              if (result != null && result.files.single.path != null) {
                final filePath = result.files.single.path!;
                try {
                  // Call the notifier to handle the import
                  // This method will be created in OrderNotifier
                  await ref
                      .read(orderNotifierProvider.notifier)
                      .importOrdersFromExcelUI(filePath);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Dosya "${result.files.single.name}" başarıyla işlenmek üzere alındı.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Excel içe aktarma hatası: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Dosya seçilmedi veya yol bulunamadı.'),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(orderNotifierProvider.notifier).loadOrders(),
          ),
        ],
      ),
      body: Column(
        children: [
          const OrderSearchBar(),
          Expanded(
            child: _buildOrderList(orderState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Yeni sipariş ekleme ekranına yönlendir
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildOrderList(OrderState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (state.orders.isEmpty) {
      return const Center(
        child: Text('Henüz sipariş bulunmuyor.'),
      );
    }

    return ListView.builder(
      itemCount: state.orders.length,
      itemBuilder: (context, index) {
        final order = state.orders[index];
        return OrderListItem(order: order);
      },
    );
  }
}
