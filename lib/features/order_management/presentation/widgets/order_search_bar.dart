import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_count_track/core/database/app_database.dart';
import 'package:flutter_count_track/features/order_management/presentation/notifiers/order_notifier.dart';

class OrderSearchBar extends ConsumerStatefulWidget {
  const OrderSearchBar({super.key});

  @override
  ConsumerState<OrderSearchBar> createState() => _OrderSearchBarState();
}

class _OrderSearchBarState extends ConsumerState<OrderSearchBar> {
  final _searchController = TextEditingController();
  OrderStatus? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    ref.read(orderNotifierProvider.notifier).loadOrders(
          searchQuery:
              _searchController.text.isEmpty ? null : _searchController.text,
          filterStatus: _selectedStatus,
        );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _performSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Sipariş Kodu Ara...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch();
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              _performSearch();
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<OrderStatus>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Durum',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: OrderStatus.values.map((status) {
                    final label = switch (status) {
                      OrderStatus.pending => 'Bekliyor',
                      OrderStatus.partial => 'Kısmi Gönderim',
                      OrderStatus.completed => 'Tamamlandı',
                    };
                    return DropdownMenuItem(
                      value: status,
                      child: Text(label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                    _performSearch();
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context, true),
                tooltip: 'Başlangıç Tarihi',
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context, false),
                tooltip: 'Bitiş Tarihi',
              ),
            ],
          ),
          if (_startDate != null || _endDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  if (_startDate != null)
                    Chip(
                      label: Text('Başlangıç: ${_formatDate(_startDate!)}'),
                      onDeleted: () {
                        setState(() {
                          _startDate = null;
                        });
                        _performSearch();
                      },
                    ),
                  const SizedBox(width: 8),
                  if (_endDate != null)
                    Chip(
                      label: Text('Bitiş: ${_formatDate(_endDate!)}'),
                      onDeleted: () {
                        setState(() {
                          _endDate = null;
                        });
                        _performSearch();
                      },
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
