import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class BarcodeSimulatorWidget extends StatefulWidget {
  final Function(String) onBarcodeScanned;
  final String customerName;

  const BarcodeSimulatorWidget({
    super.key,
    required this.onBarcodeScanned,
    required this.customerName,
  });

  @override
  State<BarcodeSimulatorWidget> createState() => _BarcodeSimulatorWidgetState();
}

class _BarcodeSimulatorWidgetState extends State<BarcodeSimulatorWidget> {
  final TextEditingController _barcodeController = TextEditingController();
  final List<String> _predefinedBarcodes = [
    '12345678901',
    '23456789012',
    '34567890123',
    '45678901234',
    '56789012345',
  ];
  final List<String> _scannedBarcodes = [];
  bool _isRandomMode = false;
  final Random _random = Random();

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  String _generateRandomBarcode() {
    // EAN-13 formatında rastgele barkod oluştur (13 basamaklı)
    const length = 13;
    return List.generate(length, (index) => _random.nextInt(10).toString())
        .join();
  }

  void _simulateScan() {
    String barcode;
    if (_isRandomMode) {
      barcode = _generateRandomBarcode();
      _barcodeController.text = barcode;
    } else {
      barcode = _barcodeController.text;
      if (barcode.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen bir barkod girin veya rastgele mod seçin'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    // Barkod tarama işlemini simüle et
    HapticFeedback.mediumImpact(); // Titreşim geri bildirimi
    widget.onBarcodeScanned(barcode);

    setState(() {
      // Taranan barkodu listeye ekle
      _scannedBarcodes.insert(0, barcode);
      if (_scannedBarcodes.length > 10) {
        _scannedBarcodes.removeLast(); // Listeyi sınırla
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Barkod Simülatörü (Test İçin)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),

            // Manuel veya rastgele mod seçimi
            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Rastgele Barkod Üret'),
                    value: _isRandomMode,
                    activeColor: Colors.blue,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() {
                        _isRandomMode = value;
                        if (value) {
                          _barcodeController.text = _generateRandomBarcode();
                        }
                      });
                    },
                  ),
                ),
              ],
            ),

            // Barkod giriş alanı
            TextField(
              controller: _barcodeController,
              decoration: InputDecoration(
                labelText: 'Barkod',
                hintText: _isRandomMode
                    ? 'Rastgele üretilecek'
                    : 'Barkod girin veya önceden tanımlı seçin',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.qr_code),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _barcodeController.clear(),
                ),
              ),
              enabled: !_isRandomMode,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),

            const SizedBox(height: 12),

            // Önceden tanımlı barkodlar
            if (!_isRandomMode) ...[
              const Text(
                'Önceden Tanımlı Barkodlar:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _predefinedBarcodes.map((barcode) {
                  return ActionChip(
                    label: Text(barcode),
                    onPressed: () {
                      setState(() {
                        _barcodeController.text = barcode;
                      });
                    },
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 16),

            // Tarama butonu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _simulateScan,
                icon: const Icon(Icons.barcode_reader),
                label: const Text('Barkod Okutma Simülasyonu'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Son okutulan barkodlar listesi
            if (_scannedBarcodes.isNotEmpty) ...[
              const Divider(),
              const Text(
                'Son Okutulan Barkodlar:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  itemCount: _scannedBarcodes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.check_circle,
                          color: Colors.green, size: 20),
                      title: Text(_scannedBarcodes[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.replay, size: 18),
                        onPressed: () {
                          _barcodeController.text = _scannedBarcodes[index];
                          setState(() {
                            _isRandomMode = false;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
