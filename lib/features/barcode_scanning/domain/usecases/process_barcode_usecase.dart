import 'package:flutter_count_track/core/database/app_database.dart';
import 'package:flutter_count_track/features/barcode_scanning/domain/repositories/barcode_repository.dart';

enum BarcodeProcessResult {
  success, // Başarılı okuma
  duplicateUniqueBarcode, // Tekrarlanan tekil barkod
  productNotFound, // Ürün bulunamadı
  productNotInOrder, // Ürün siparişte değil
  orderItemAlreadyComplete, // Sipariş kalemi zaten tamamlandı
}

class ProcessBarcodeUseCase {
  final BarcodeRepository _barcodeRepository;

  ProcessBarcodeUseCase(this._barcodeRepository);

  Future<BarcodeProcessResult> call({
    required int orderId,
    required String barcode,
    required String customerName,
  }) async {
    print(
        '🔄 ProcessBarcode: Başlıyor - OrderId: $orderId, Barkod: $barcode, Müşteri: $customerName');

    // Barkodu kaydet (hangi ürüne ait olduğunu henüz bilmiyoruz)
    await _barcodeRepository.logBarcodeRead(orderId, null, barcode);

    // Barkoda karşılık gelen ürünü bul
    final product = await _barcodeRepository.findProductByCustomerCode(
      barcode,
      customerName,
    );

    if (product == null) {
      print('❌ ProcessBarcode: Ürün bulunamadı');
      return BarcodeProcessResult.productNotFound;
    }

    print('✅ ProcessBarcode: Ürün bulundu: ${product.ourProductCode}');

    // Ürünün mevcut siparişte olup olmadığını kontrol et
    final orderItem = await _barcodeRepository.findOrderItemByProductId(
      orderId,
      product.id,
    );

    if (orderItem == null) {
      print('❌ ProcessBarcode: Ürün siparişte bulunamadı');
      return BarcodeProcessResult.productNotInOrder;
    }

    print(
        '✅ ProcessBarcode: Sipariş kalemi bulundu: ${orderItem.scannedQuantity}/${orderItem.quantity}');

    // Barkod kaydını ürün ID'si ile güncelle
    await _barcodeRepository.logBarcodeRead(orderId, product.id, barcode);

    // Ürün için benzersiz barkod kontrolü gerekiyorsa kontrol et
    if (product.isUniqueBarcodeRequired) {
      final isDuplicate =
          await _barcodeRepository.isUniqueBarcodeAlreadyScanned(
        orderId,
        product.id,
        barcode,
      );

      if (isDuplicate) {
        print('⚠️ ProcessBarcode: Tekrarlanan benzersiz barkod');
        return BarcodeProcessResult.duplicateUniqueBarcode;
      }
    }

    // Siparişteki okunan miktarı artır (eğer hala tamamlanmadıysa)
    if (orderItem.scannedQuantity < orderItem.quantity) {
      final newScannedQuantity = orderItem.scannedQuantity + 1;
      await _barcodeRepository.updateOrderItemScannedQuantity(
        orderItem.id,
        newScannedQuantity,
      );

      print(
          '✅ ProcessBarcode: Miktar güncellendi: $newScannedQuantity/${orderItem.quantity}');

      // Siparişin tamamlanıp tamamlanmadığını kontrol et
      final isComplete = await _barcodeRepository.checkIfOrderComplete(orderId);
      if (isComplete) {
        await _barcodeRepository.updateOrderStatus(
            orderId, OrderStatus.completed);
        print('🎉 ProcessBarcode: Sipariş tamamlandı!');
      } else {
        // En az bir ürün okunduysa kısmen tamamlandı olarak güncelle
        await _barcodeRepository.updateOrderStatus(
            orderId, OrderStatus.partial);
        print('📦 ProcessBarcode: Sipariş kısmen tamamlandı');
      }

      return BarcodeProcessResult.success;
    } else {
      print('⚠️ ProcessBarcode: Sipariş kalemi zaten tamamlanmış');
      return BarcodeProcessResult.orderItemAlreadyComplete;
    }
  }
}
