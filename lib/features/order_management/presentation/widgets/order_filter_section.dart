import 'package:flutter/material.dart';
import 'package:flutter_count_track/core/database/app_database.dart';

class OrderFilterSection extends StatefulWidget {
  final String searchQuery;
  final OrderStatus? selectedStatus;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<OrderStatus?> onStatusChanged;
  final List<Order> orders;

  const OrderFilterSection({
    super.key,
    required this.searchQuery,
    required this.selectedStatus,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.orders,
  });

  @override
  State<OrderFilterSection> createState() => _OrderFilterSectionState();
}

class _OrderFilterSectionState extends State<OrderFilterSection> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(OrderFilterSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  controller: _searchController,
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
                  onChanged: widget.onSearchChanged,
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
                      value: widget.selectedStatus,
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
                      onChanged: widget.onStatusChanged,
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
    final pendingCount =
        widget.orders.where((o) => o.status == OrderStatus.pending).length;
    final partialCount =
        widget.orders.where((o) => o.status == OrderStatus.partial).length;
    final completedCount =
        widget.orders.where((o) => o.status == OrderStatus.completed).length;

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
            widget.orders.length.toString(),
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
}
