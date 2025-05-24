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
    // Barkodu kaydet (hangi ürüne ait olduğunu henüz bilmiyoruz)
    await _barcodeRepository.logBarcodeRead(orderId, null, barcode);

    // Barkoda karşılık gelen ürünü bul
    final product = await _barcodeRepository.findProductByCustomerCode(
      barcode,
      customerName,
    );

    if (product == null) {
      return BarcodeProcessResult.productNotFound;
    }

    // Ürünün mevcut siparişte olup olmadığını kontrol et
    final orderItem = await _barcodeRepository.findOrderItemByProductId(
      orderId,
      product.id,
    );

    if (orderItem == null) {
      return BarcodeProcessResult.productNotInOrder;
    }

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

      // Siparişin tamamlanıp tamamlanmadığını kontrol et
      final isComplete = await _barcodeRepository.checkIfOrderComplete(orderId);
      if (isComplete) {
        await _barcodeRepository.updateOrderStatus(
            orderId, OrderStatus.completed);
      } else {
        // En az bir ürün okunduysa kısmen tamamlandı olarak güncelle
        await _barcodeRepository.updateOrderStatus(
            orderId, OrderStatus.partial);
      }

      return BarcodeProcessResult.success;
    } else {
      return BarcodeProcessResult.orderItemAlreadyComplete;
    }
  }
}
