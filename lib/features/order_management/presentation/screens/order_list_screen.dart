import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_count_track/core/constants/app_constants.dart';
import 'package:flutter_count_track/core/database/app_database.dart';
import 'package:flutter_count_track/features/order_management/presentation/notifiers/order_notifier.dart';
import 'package:flutter_count_track/features/order_management/presentation/widgets/order_list_item.dart';
import 'package:flutter_count_track/features/order_management/presentation/widgets/order_search_bar.dart';
import 'package:flutter_count_track/features/order_management/presentation/screens/order_detail_screen.dart';

class OrderListScreen extends ConsumerStatefulWidget {
  const OrderListScreen({super.key});

  @override
  ConsumerState<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen> {
  String _searchQuery = '';
  OrderStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Sipariş Yönetimi',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        toolbarHeight: 80,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _importFromExcel(context, ref),
                  icon: const Icon(Icons.file_upload, size: 28),
                  label: const Text('Excel İçe Aktar',
                      style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () =>
                      ref.read(orderNotifierProvider.notifier).loadOrders(),
                  icon: const Icon(Icons.refresh, size: 28),
                  label: const Text('Yenile', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue[800],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Üst filtreleme ve arama alanı
          _buildFilterSection(),

          // Ana sipariş grid'i
          Expanded(
            child: _buildOrderGrid(orderState),
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

  Widget _buildFilterSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Arama ve filtre satırı
          Row(
            children: [
              // Arama kutusu
              Expanded(
                flex: 2,
                child: TextField(
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'Sipariş kodu veya müşteri adı ara...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon:
                        Icon(Icons.search, color: Colors.blue[600], size: 28),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.blue[600]!, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              const SizedBox(width: 16),

              // Durum filtresi
              Expanded(
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<OrderStatus?>(
                      value: _selectedStatus,
                      hint: Text(
                        'Tüm Durumlar',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      icon: Icon(Icons.arrow_drop_down,
                          color: Colors.blue[600], size: 28),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<OrderStatus?>(
                          value: null,
                          child: Text('Tüm Durumlar'),
                        ),
                        DropdownMenuItem<OrderStatus>(
                          value: OrderStatus.pending,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Bekliyor'),
                            ],
                          ),
                        ),
                        DropdownMenuItem<OrderStatus>(
                          value: OrderStatus.partial,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Kısmen Gönderildi'),
                            ],
                          ),
                        ),
                        DropdownMenuItem<OrderStatus>(
                          value: OrderStatus.completed,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Tamamlandı'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // İstatistik kartları
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final orderState = ref.watch(orderNotifierProvider);
    final orders = orderState.orders;

    final pendingCount =
        orders.where((o) => o.status == OrderStatus.pending).length;
    final partialCount =
        orders.where((o) => o.status == OrderStatus.partial).length;
    final completedCount =
        orders.where((o) => o.status == OrderStatus.completed).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Bekliyor',
            pendingCount.toString(),
            Colors.orange,
            Icons.pending_actions,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Kısmen Gönderildi',
            partialCount.toString(),
            Colors.blue,
            Icons.local_shipping,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Tamamlandı',
            completedCount.toString(),
            Colors.green,
            Icons.check_circle,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Toplam',
            orders.length.toString(),
            Colors.purple,
            Icons.inventory,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderGrid(OrderState state) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(strokeWidth: 6),
            SizedBox(height: 16),
            Text(
              'Siparişler yükleniyor...',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (state.error != null) {
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
                  'Hata: ${state.error}',
                  style: TextStyle(
                    color: Colors.red[800],
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () =>
                      ref.read(orderNotifierProvider.notifier).loadOrders(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar Dene'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Filtrelenmiş siparişleri al
    final filteredOrders = _getFilteredOrders(state.orders);

    if (filteredOrders.isEmpty) {
      return Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty || _selectedStatus != null
                      ? 'Arama kriterlerine uygun sipariş bulunamadı.'
                      : 'Henüz sipariş bulunmuyor.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_searchQuery.isNotEmpty || _selectedStatus != null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _selectedStatus = null;
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Filtreleri Temizle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 3 sütunlu grid
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1, // Kart boyut oranı
        ),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
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

    IconData getStatusIcon(OrderStatus status) {
      return switch (status) {
        OrderStatus.pending => Icons.pending_actions,
        OrderStatus.partial => Icons.local_shipping,
        OrderStatus.completed => Icons.check_circle,
      };
    }

    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: getStatusColor(order.status).withOpacity(0.3), width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Sipariş detay ekranına git
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OrderDetailScreen(orderCode: order.orderCode),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst kısım - Sipariş kodu ve durum
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.orderCode,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: getStatusColor(order.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      getStatusIcon(order.status),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Müşteri adı
              Row(
                children: [
                  Icon(Icons.business, color: Colors.grey[600], size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.customerName,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Tarih
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey[600], size: 18),
                  const SizedBox(width: 6),
                  Text(
                    formatDate(order.createdAt),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Alt kısım - Durum etiketi
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: getStatusColor(order.status), width: 1),
                ),
                child: Text(
                  getStatusText(order.status),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: getStatusColor(order.status),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Order> _getFilteredOrders(List<Order> orders) {
    return orders.where((order) {
      // Arama filtresi
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!order.orderCode.toLowerCase().contains(query) &&
            !order.customerName.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Durum filtresi
      if (_selectedStatus != null && order.status != _selectedStatus) {
        return false;
      }

      return true;
    }).toList();
  }

  Future<void> _importFromExcel(BuildContext context, WidgetRef ref) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      try {
        await ref
            .read(orderNotifierProvider.notifier)
            .importOrdersFromExcelUI(filePath);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Dosya "${result.files.single.name}" başarıyla içe aktarıldı.',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green[600],
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Excel içe aktarma hatası: $e',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red[600],
              duration: const Duration(seconds: 6),
            ),
          );
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dosya seçilmedi veya yol bulunamadı.'),
          ),
        );
      }
    }
  }
}
