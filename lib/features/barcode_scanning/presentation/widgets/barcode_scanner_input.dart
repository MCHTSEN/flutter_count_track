import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_count_track/features/barcode_scanning/presentation/notifiers/barcode_notifier.dart';

class BarcodeScannerInput extends ConsumerStatefulWidget {
  final int orderId;
  final String customerName;
  final Function() onOrderUpdated;

  const BarcodeScannerInput({
    super.key,
    required this.orderId,
    required this.customerName,
    required this.onOrderUpdated,
  });

  @override
  ConsumerState<BarcodeScannerInput> createState() =>
      _BarcodeScannerInputState();
}

class _BarcodeScannerInputState extends ConsumerState<BarcodeScannerInput> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Uygulama başladığında otomatik olarak odaklanması için
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _processBarcode(String barcode) {
    if (barcode.isEmpty) return;

    // Barkodu işle
    ref.read(barcodeNotifierProvider.notifier).processBarcode(
          barcode: barcode,
          orderId: widget.orderId,
          customerName: widget.customerName,
          onOrderUpdated: widget.onOrderUpdated,
        );

    // İşlemden sonra metin kutusunu temizle
    _controller.clear();

    // Odağı tekrar metin kutusuna getir (otomatik modda okumaya devam edebilmek için)
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Barkod Tarama',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: const InputDecoration(
              hintText: 'Barkod okutunuz veya manuel giriş yapınız',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.qr_code_scanner),
            ),
            onSubmitted: _processBarcode,
            autofocus: true,
            // Kullanıcı barkod girdikten sonra "enter" tuşuna basması gerekmesin diye
            // onChanged özelliği kullanılabilir. Ancak bu otomatik barkod okuyucular
            // için karmaşık olabilir, çünkü karakterleri teker teker gönderiyor.
            // İsterseniz bu bölümü açabilirsiniz:
            // onChanged: (value) {
            //   // Barkodlar genellikle sabit uzunluktadır, örneğin 13 karakter
            //   if (value.length == 13) {
            //     _processBarcode(value);
            //   }
            // },
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _processBarcode(_controller.text),
            icon: const Icon(Icons.send),
            label: const Text('Barkodu İşle'),
          ),
        ],
      ),
    );
  }
}
