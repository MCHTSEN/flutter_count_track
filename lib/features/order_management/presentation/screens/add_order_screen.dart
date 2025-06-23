import 'package:flutter/material.dart';
import 'package:flutter_count_track/core/database/app_database.dart';
import 'package:flutter_count_track/core/database/database_provider.dart';
import 'package:flutter_count_track/features/order_management/presentation/notifiers/order_notifier.dart';
import 'package:flutter_count_track/features/order_management/presentation/widgets/product_selection_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Order Item Data Class
class OrderItemData {
  final Product product;
  final int quantity;
  final String? customerProductCode;

  OrderItemData({
    required this.product,
    required this.quantity,
    this.customerProductCode,
  });

  OrderItemData copyWith({
    Product? product,
    int? quantity,
    String? customerProductCode,
  }) {
    return OrderItemData(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      customerProductCode: customerProductCode ?? this.customerProductCode,
    );
  }
}

class AddOrderScreen extends ConsumerStatefulWidget {
  const AddOrderScreen({super.key});

  @override
  ConsumerState<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends ConsumerState<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orderCodeController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  final List<OrderItemData> _selectedProducts = [];

  @override
  void initState() {
    super.initState();
    _orderCodeController.text = _generateOrderCode();
  }

  @override
  void dispose() {
    _orderCodeController.dispose();
    _customerNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Yeni Sipariş Ekle'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: () => _resetForm(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Formu Sıfırla',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            if (_isLoading) const LinearProgressIndicator(minHeight: 3),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfoCard(),
                    const SizedBox(height: 16),
                    _buildProductSelectionCard(),
                    const SizedBox(height: 16),
                    _buildAdditionalInfoCard(),
                    const SizedBox(height: 20),
                    if (_selectedProducts.isNotEmpty) _buildOrderSummaryCard(),
                  ],
                ),
              ),
            ),
            _buildBottomActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Temel Bilgiler',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[600],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _orderCodeController,
              decoration: InputDecoration(
                labelText: 'Sipariş Kodu *',
                hintText: 'ORD-2024-001',
                prefixIcon: const Icon(Icons.tag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    _orderCodeController.text = _generateOrderCode();
                  },
                  tooltip: 'Yeni Kod Oluştur',
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Sipariş kodu zorunludur';
                }
                if (value.length < 3) {
                  return 'Sipariş kodu en az 3 karakter olmalıdır';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _customerNameController,
              decoration: InputDecoration(
                labelText: 'Müşteri Adı *',
                hintText: 'Müşteri adını girin',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Müşteri adı zorunludur';
                }
                if (value.length < 2) {
                  return 'Müşteri adı en az 2 karakter olmalıdır';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSelectionCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory_2, color: Colors.green[600]),
                const SizedBox(width: 8),
                Text(
                  'Ürün Seçimi',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[600],
                      ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showProductSelectionDialog(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ürün Ekle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Seçilen Ürünler Listesi
            if (_selectedProducts.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Henüz ürün seçilmedi',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Siparişe ürün eklemek için "Ürün Ekle" butonuna tıklayın',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ..._selectedProducts.map((item) => _buildProductItem(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(OrderItemData item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.inventory, color: Colors.blue[600], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Kod: ${item.product.ourProductCode}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: TextFormField(
              initialValue: item.quantity.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Miktar',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              onChanged: (value) {
                final quantity = int.tryParse(value) ?? 0;
                _updateProductQuantity(item.product.id, quantity);
              },
              validator: (value) {
                final quantity = int.tryParse(value ?? '');
                if (quantity == null || quantity <= 0) {
                  return 'Geçerli miktar';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _removeProduct(item.product.id),
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Ürünü Kaldır',
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note_add, color: Colors.orange[600]),
                const SizedBox(width: 8),
                Text(
                  'Ek Bilgiler',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[600],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notlar',
                hintText: 'Sipariş ile ilgili ek notlar...',
                prefixIcon: const Icon(Icons.note),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    final totalQuantity =
        _selectedProducts.fold(0, (sum, item) => sum + item.quantity);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.summarize, color: Colors.purple[600]),
                const SizedBox(width: 8),
                Text(
                  'Sipariş Özeti',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[600],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
                'Toplam Ürün Çeşidi', '${_selectedProducts.length}'),
            _buildSummaryRow('Toplam Miktar', '$totalQuantity'),
            _buildSummaryRow('Durum', 'Bekliyor'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildBottomActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.pop(context);
                    },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('İptal'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed:
                  _isLoading || _selectedProducts.isEmpty ? null : _saveOrder,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Siparişi Kaydet'),
            ),
          ),
        ],
      ),
    );
  }

  void _showProductSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => ProductSelectionDialog(
        onProductSelected: (product, quantity) {
          _addProduct(product, quantity);
        },
      ),
    );
  }

  void _addProduct(Product product, int quantity) {
    setState(() {
      final existingIndex = _selectedProducts.indexWhere(
        (item) => item.product.id == product.id,
      );

      if (existingIndex >= 0) {
        // Mevcut ürünün miktarını güncelle
        _selectedProducts[existingIndex] =
            _selectedProducts[existingIndex].copyWith(
          quantity: quantity,
        );
      } else {
        // Yeni ürün ekle
        _selectedProducts.add(OrderItemData(
          product: product,
          quantity: quantity,
        ));
      }
    });
  }

  void _updateProductQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      _removeProduct(productId);
      return;
    }

    setState(() {
      final index = _selectedProducts.indexWhere(
        (item) => item.product.id == productId,
      );
      if (index >= 0) {
        _selectedProducts[index] = _selectedProducts[index].copyWith(
          quantity: quantity,
        );
      }
    });
  }

  void _removeProduct(int productId) {
    setState(() {
      _selectedProducts.removeWhere((item) => item.product.id == productId);
    });
  }

  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('En az bir ürün seçmelisiniz'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Önce siparişi oluştur
      final orderCompanion = OrdersCompanion.insert(
        orderCode: _orderCodeController.text.trim(),
        customerName: _customerNameController.text.trim(),
        status: OrderStatus.pending,
      );

      await ref
          .read(orderNotifierProvider.notifier)
          .createOrder(orderCompanion);

      // 2. Sipariş kalemlerini ekle
      await _addOrderItems();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Sipariş başarıyla oluşturuldu!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addOrderItems() async {
    final database = ref.read(appDatabaseProvider);
    final orderCode = _orderCodeController.text.trim();

    // Siparişi bul
    final order = await (database.select(database.orders)
          ..where((o) => o.orderCode.equals(orderCode)))
        .getSingle();

    // Her ürün için order item ekle
    for (final item in _selectedProducts) {
      final orderItemCompanion = OrderItemsCompanion.insert(
        orderId: order.id,
        productId: item.product.id,
        quantity: item.quantity,
      );

      await database.into(database.orderItems).insert(orderItemCompanion);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _orderCodeController.text = _generateOrderCode();
    _customerNameController.clear();
    _notesController.clear();
    setState(() {
      _selectedProducts.clear();
    });
  }

  String _generateOrderCode() {
    final now = DateTime.now();
    return 'ORD-${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';
  }
}
