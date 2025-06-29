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
    int? boxNumber,
  }) async {
    print(
        '🔄 ProcessBarcode: Başlıyor - OrderId: $orderId, Barkod: $barcode, Müşteri: $customerName');

    // 1. Barkoda karşılık gelen ürünü bul
    final product = await _barcodeRepository.findProductByCustomerCode(
      barcode,
      customerName,
    );

    if (product == null) {
      print('❌ ProcessBarcode: Ürün bulunamadı');
      // Başarısız okumalar kayıt edilmemeli - koli dropdown bug'ını önlemek için
      // await _barcodeRepository.logBarcodeRead(orderId, null, barcode, boxNumber: boxNumber);
      return BarcodeProcessResult.productNotFound;
    }

    print('✅ ProcessBarcode: Ürün bulundu: ${product.ourProductCode}');

    // 2. Ürünün mevcut siparişte olup olmadığını kontrol et
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

    // 3. Ürün için benzersiz barkod kontrolü (gerekliyse)
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

    // 4. Siparişteki okunan miktarı artır (eğer hala tamamlanmadıysa)
    if (orderItem.scannedQuantity < orderItem.quantity) {
      // 5. Tüm kontrollerden geçtiyse barkodu kaydet
      await _barcodeRepository.logBarcodeRead(orderId, product.id, barcode,
          boxNumber: boxNumber);

      final newScannedQuantity = orderItem.scannedQuantity + 1;
      await _barcodeRepository.updateOrderItemScannedQuantity(
        orderItem.id,
        newScannedQuantity,
      );

      print(
          '✅ ProcessBarcode: Miktar güncellendi: $newScannedQuantity/${orderItem.quantity}');

      // Siparişin durumunu güncelle (kısmi veya tamamlandı)
      final isComplete = await _barcodeRepository.checkIfOrderComplete(orderId);
      if (isComplete) {
        await _barcodeRepository.updateOrderStatus(
            orderId, OrderStatus.completed);
        print('🎉 ProcessBarcode: Sipariş tamamlandı!');
      } else {
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
