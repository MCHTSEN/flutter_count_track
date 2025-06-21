import 'package:flutter/material.dart';
import 'package:flutter_count_track/features/order_management/presentation/notifiers/order_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BoxManagementScreen extends ConsumerStatefulWidget {
  final String orderCode;

  const BoxManagementScreen({super.key, required this.orderCode});

  @override
  ConsumerState<BoxManagementScreen> createState() =>
      _BoxManagementScreenState();
}

class _BoxManagementScreenState extends ConsumerState<BoxManagementScreen> {
  List<Map<String, dynamic>> _boxContents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBoxContents();
  }

  Future<void> _loadBoxContents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(orderRepositoryProvider);
      final boxData = await repository.getBoxContents(widget.orderCode);

      setState(() {
        _boxContents = boxData;
        _isLoading = false;
      });

      print('📦 BoxManagement: Loaded ${boxData.length} boxes');
    } catch (e) {
      print('❌ BoxManagement: Error loading box contents: $e');
      setState(() {
        _boxContents = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Koli Yönetimi - ${widget.orderCode}'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadBoxContents();
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Koli bilgileri yükleniyor...'),
          ],
        ),
      );
    }

    if (_boxContents.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Henüz koli oluşturulmamış',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Barkod okutmaya başladığınızda koliler otomatik oluşturulacak',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Özet kartı
          _buildSummaryCard(),
          const SizedBox(height: 16),

          // Koli listesi
          Expanded(
            child: ListView.builder(
              itemCount: _boxContents.length,
              itemBuilder: (context, index) {
                final boxData = _boxContents[index];
                final boxNumber = boxData['boxNumber'] as int;
                final contents = boxData['contents'] as List<dynamic>;
                return _buildBoxCard(
                    boxNumber, contents.cast<Map<String, dynamic>>());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final totalBoxes = _boxContents.length;
    final totalItems = _boxContents.fold<int>(0, (sum, box) {
      final contents = box['contents'] as List<dynamic>;
      return sum +
          contents.fold<int>(
              0, (itemSum, item) => itemSum + (item['quantity'] as int? ?? 0));
    });

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Icon(Icons.inventory_2, size: 32, color: Colors.orange[700]),
                  const SizedBox(height: 8),
                  Text(
                    '$totalBoxes',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('Toplam Koli'),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 60,
              color: Colors.grey[300],
            ),
            Expanded(
              child: Column(
                children: [
                  Icon(Icons.inventory, size: 32, color: Colors.blue[700]),
                  const SizedBox(height: 8),
                  Text(
                    '$totalItems',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('Toplam Ürün'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoxCard(int boxNumber, List<Map<String, dynamic>> contents) {
    final totalItems = contents.fold<int>(
        0, (sum, item) => sum + (item['quantity'] as int? ?? 0));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: CircleAvatar(
          backgroundColor: Colors.orange[100],
          child: Text(
            '$boxNumber',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
            ),
          ),
        ),
        title: Text(
          'Koli $boxNumber',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${contents.length} farklı ürün - $totalItems adet',
        ),
        children:
            contents.map((item) => _buildItemTile(boxNumber, item)).toList(),
      ),
    );
  }

  Widget _buildItemTile(int boxNumber, Map<String, dynamic> item) {
    final timestamp = item['timestamp'] as DateTime?;
    final formattedTime = timestamp != null
        ? '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}'
        : '';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${item['quantity'] ?? 0}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
      ),
      title: Text(
        item['productName'] ?? 'Bilinmeyen Ürün',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ürün Kodu: ${item['productCode'] ?? 'Bilinmeyen'}'),
          Text('Barkod: ${item['barcode'] ?? 'Bilinmeyen'}'),
          if (formattedTime.isNotEmpty) Text('Son Okuma: $formattedTime'),
        ],
      ),
    );
  }
}
