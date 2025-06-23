import 'package:flutter/material.dart';
import 'package:flutter_count_track/core/database/database_provider.dart';
import 'package:flutter_count_track/core/services/supabase_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

class SupabaseTestScreen extends ConsumerStatefulWidget {
  const SupabaseTestScreen({super.key});

  @override
  ConsumerState<SupabaseTestScreen> createState() => _SupabaseTestScreenState();
}

class _SupabaseTestScreenState extends ConsumerState<SupabaseTestScreen> {
  final Logger _logger = Logger('SupabaseTestScreen');
  final List<Map<String, dynamic>> _testResults = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Test Ekranı'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bağlantı Durumu
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bağlantı Durumu',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          SupabaseService.isInitialized
                              ? Icons.check_circle
                              : Icons.error,
                          color: SupabaseService.isInitialized
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Supabase: ${SupabaseService.isInitialized ? "Bağlı" : "Bağlı Değil"}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          SupabaseService.isOnline
                              ? Icons.wifi
                              : Icons.wifi_off,
                          color: SupabaseService.isOnline
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'İnternet: ${SupabaseService.isOnline ? "Online" : "Offline"}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test Butonları
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testConnection,
                    child: const Text('Bağlantı Testi'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testDataFetch,
                    child: const Text('Veri Çekme Testi'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testDataPush,
                    child: const Text('Veri Gönderme Testi'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _clearResults,
                    child: const Text('Sonuçları Temizle'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Loading
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),

            // Test Sonuçları
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Sonuçları',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _testResults.length,
                          itemBuilder: (context, index) {
                            final result = _testResults[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Icon(
                                  result['success'] ? Icons.check : Icons.error,
                                  color: result['success']
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                title: Text(result['title']),
                                subtitle: Text(result['message']),
                                trailing: Text(
                                  result['timestamp'],
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testConnection() async {
    setState(() => _isLoading = true);

    try {
      _logger.info('🔍 Supabase bağlantı testi başlatıldı');

      // Basic connection test
      final response =
          await SupabaseService.client.from('products').select('id').limit(1);

      _addResult(
        title: 'Bağlantı Testi',
        message: 'Başarılı - Supabase bağlantısı çalışıyor',
        success: true,
      );

      _logger.info('✅ Supabase bağlantı testi başarılı');
    } catch (e, stackTrace) {
      _logger.severe('💥 Supabase bağlantı testi hatası', e, stackTrace);
      _addResult(
        title: 'Bağlantı Testi',
        message: 'Hata: $e',
        success: false,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testDataFetch() async {
    setState(() => _isLoading = true);

    try {
      _logger.info('📥 Supabase veri çekme testi başlatıldı');

      final syncService = ref.read(supabaseSyncServiceProvider);
      final orders = await syncService.fetchOrdersFromSupabase(limit: 5);

      _addResult(
        title: 'Veri Çekme Testi',
        message: 'Başarılı - ${orders.length} sipariş çekildi',
        success: true,
      );

      if (orders.isNotEmpty) {
        _addResult(
          title: 'İlk Sipariş',
          message:
              '${orders.first['order_code']} - ${orders.first['customer_name']}',
          success: true,
        );
      }

      _logger.info('✅ Supabase veri çekme testi başarılı');
    } catch (e, stackTrace) {
      _logger.severe('💥 Supabase veri çekme testi hatası', e, stackTrace);
      _addResult(
        title: 'Veri Çekme Testi',
        message: 'Hata: $e',
        success: false,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testDataPush() async {
    setState(() => _isLoading = true);

    try {
      _logger.info('📤 Supabase veri gönderme testi başlatıldı');

      // Test ürünü ekle
      final testProduct = {
        'our_product_code': 'TEST_${DateTime.now().millisecondsSinceEpoch}',
        'name': 'Test Ürün ${DateTime.now().millisecondsSinceEpoch}',
        'barcode': '${DateTime.now().millisecondsSinceEpoch}',
        'is_unique_barcode_required': false,
      };

      final response = await SupabaseService.client
          .from('products')
          .insert(testProduct)
          .select()
          .single();

      _addResult(
        title: 'Veri Gönderme Testi',
        message: 'Başarılı - Ürün eklendi: ${response['our_product_code']}',
        success: true,
      );

      _logger.info('✅ Supabase veri gönderme testi başarılı');
    } catch (e, stackTrace) {
      _logger.severe('💥 Supabase veri gönderme testi hatası', e, stackTrace);
      _addResult(
        title: 'Veri Gönderme Testi',
        message: 'Hata: $e',
        success: false,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addResult({
    required String title,
    required String message,
    required bool success,
  }) {
    setState(() {
      _testResults.insert(0, {
        'title': title,
        'message': message,
        'success': success,
        'timestamp': DateTime.now().toString().substring(11, 19),
      });
    });
  }

  void _clearResults() {
    setState(() {
      _testResults.clear();
    });
  }
}
