import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_count_track/core/database/app_database.dart';
import 'package:flutter_count_track/core/database/database_provider.dart';
import 'package:flutter_count_track/core/services/supabase_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductSelectionDialog extends ConsumerStatefulWidget {
  final Function(Product product, int quantity) onProductSelected;

  const ProductSelectionDialog({
    super.key,
    required this.onProductSelected,
  });

  @override
  ConsumerState<ProductSelectionDialog> createState() =>
      _ProductSelectionDialogState();
}

class _ProductSelectionDialogState
    extends ConsumerState<ProductSelectionDialog> {
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  Product? _selectedProduct;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      // Önce Supabase'den ürünleri sync et
      final syncService = ref.read(supabaseSyncServiceProvider);
      if (SupabaseService.isOnline) {
        await syncService.syncProductsWithLocal();
      }

      // Local database'den ürünleri al
      final database = ref.read(appDatabaseProvider);
      final products = await (database.select(database.products)
            ..orderBy([(p) => OrderingTerm(expression: p.name)]))
          .get();

      setState(() {
        _products = products;
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ürünler yüklenirken hata: $e')),
        );
      }
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products.where((product) {
        return product.name.toLowerCase().contains(query) ||
            product.ourProductCode.toLowerCase().contains(query) ||
            (product.barcode.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.inventory_2, color: Colors.green[600]),
                const SizedBox(width: 8),
                const Text(
                  'Ürün Seç',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Ürün Ara',
                hintText: 'Ürün adı, kodu veya barkod ile arayın',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Products List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredProducts.isEmpty
                      ? const Center(
                          child: Text('Ürün bulunamadı'),
                        )
                      : ListView.builder(
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            final isSelected =
                                _selectedProduct?.id == product.id;

                            return Card(
                              elevation: isSelected ? 4 : 1,
                              color: isSelected ? Colors.green[50] : null,
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.green[100]
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.inventory,
                                    color: isSelected
                                        ? Colors.green[700]
                                        : Colors.grey[600],
                                  ),
                                ),
                                title: Text(
                                  product.name,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Kod: ${product.ourProductCode}'),
                                    Text('Barkod: ${product.barcode}'),
                                  ],
                                ),
                                trailing: isSelected
                                    ? Icon(Icons.check_circle,
                                        color: Colors.green[600])
                                    : null,
                                onTap: () {
                                  setState(() {
                                    _selectedProduct = product;
                                  });
                                },
                              ),
                            );
                          },
                        ),
            ),

            const SizedBox(height: 16),

            // Quantity Input
            if (_selectedProduct != null)
              Row(
                children: [
                  const Text('Miktar: ',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),

            const SizedBox(height: 16),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('İptal'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedProduct == null
                        ? null
                        : () {
                            final quantity =
                                int.tryParse(_quantityController.text) ?? 1;
                            if (quantity > 0) {
                              widget.onProductSelected(
                                  _selectedProduct!, quantity);
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Geçerli bir miktar girin')),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Ekle'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Basit ürün data class'ı
class ProductData {
  final int id;
  final String ourProductCode;
  final String name;
  final String? barcode;
  final String? customerProductCode;

  ProductData({
    required this.id,
    required this.ourProductCode,
    required this.name,
    this.barcode,
    this.customerProductCode,
  });

  factory ProductData.fromProduct(Product product) {
    return ProductData(
      id: product.id,
      ourProductCode: product.ourProductCode,
      name: product.name,
      barcode: product.barcode,
    );
  }
}
