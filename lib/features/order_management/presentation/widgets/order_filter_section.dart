import 'package:flutter/material.dart';
import 'package:flutter_count_track/core/database/app_database.dart';

class OrderFilterSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Arama ve filtreleme satırı
          Row(
            children: [
              // Arama kutusu
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Sipariş kodu veya müşteri adı ara...',
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
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
                  onChanged: onSearchChanged,
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
                      value: selectedStatus,
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
                      onChanged: onStatusChanged,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
