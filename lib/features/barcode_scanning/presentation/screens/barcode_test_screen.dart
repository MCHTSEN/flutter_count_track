import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_count_track/features/barcode_scanning/presentation/notifiers/barcode_notifier.dart';
import 'package:flutter_count_track/features/barcode_scanning/presentation/widgets/barcode_notification_widget.dart';
import 'package:flutter_count_track/features/barcode_scanning/presentation/widgets/barcode_simulator_widget.dart';

class BarcodeTestScreen extends ConsumerWidget {
  const BarcodeTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final barcodeState = ref.watch(barcodeNotifierProvider);

    // Test için sabit değerler
    const int testOrderId = 1; // Var olan bir sipariş ID'si
    const String testCustomerName = 'Test Müşteri'; // Var olan bir müşteri adı

    void onBarcodeScanned(String barcode) {
      // Barkod notifier'a ilet
      ref.read(barcodeNotifierProvider.notifier).processBarcode(
            barcode: barcode,
            orderId: testOrderId,
            customerName: testCustomerName,
            onOrderUpdated: () {
              // Sipariş güncellendiğinde yapılacak işlemler
              // Gerçek uygulamada burada sipariş detay sayfasını yenileme vs. olabilir
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sipariş başarıyla güncellendi!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Barkod Okuma Testi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Bilgi kartı
            const Card(
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Barkod Test Ekranı',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Bu ekran, gerçek bir barkod okuyucu olmadan barkod okuma özelliğini test etmek için kullanılır.',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 16),
                    Text('Test Parametreleri:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Sipariş ID: $testOrderId'),
                    Text('Müşteri Adı: $testCustomerName'),
                  ],
                ),
              ),
            ),

            // Barkod bildirim widget'ı
            BarcodeNotificationWidget(state: barcodeState),

            // Barkod simülatör widget'ı
            BarcodeSimulatorWidget(
              onBarcodeScanned: onBarcodeScanned,
              customerName: testCustomerName,
            ),

            // Test bilgileri açıklama bölümü
            const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Test Senaryoları:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                      '• Rastgele veya önceden tanımlı barkodlar ile test edin'),
                  Text(
                      '• Aynı barkodu tekrar okutmayı deneyin (unique barkod kontrolü için)'),
                  Text(
                      '• Var olmayan ürün kodları için rastgele uzun sayılar deneyin'),
                  Text(
                      '• Barkod okuma sonuçlarını, ekranın üst kısmındaki bildirim alanından takip edin'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
