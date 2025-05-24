import 'package:flutter_count_track/core/database/app_database.dart';

abstract class BarcodeRepository {
  /// Müşteri ürün kodu ve müşteri adına göre ürün bilgisini bulur
  Future<Product?> findProductByCustomerCode(
      String customerProductCode, String customerName);

  /// Sipariş ve ürün ID'sine göre sipariş kalemini bulur
  Future<OrderItem?> findOrderItemByProductId(int orderId, int productId);

  /// Sipariş kaleminin taranan miktarını günceller
  Future<void> updateOrderItemScannedQuantity(
      int orderItemId, int newScannedQuantity);

  /// Barkod okuma işlemini kaydeder
  Future<void> logBarcodeRead(int orderId, int? productId, String barcode);

  /// Benzersiz barkodun daha önce taranıp taranmadığını kontrol eder
  Future<bool> isUniqueBarcodeAlreadyScanned(
      int orderId, int productId, String barcode);

  /// Siparişin tamamlanıp tamamlanmadığını kontrol eder
  Future<bool> checkIfOrderComplete(int orderId);

  /// Sipariş durumunu günceller
  Future<void> updateOrderStatus(int orderId, OrderStatus status);
}
