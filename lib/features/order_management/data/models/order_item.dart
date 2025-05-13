import 'package:drift/drift.dart';
import 'package:flutter_count_track/core/database/app_database.dart' as db;

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final int scannedQuantity;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.scannedQuantity,
  });

  // Veritabanından gelen veriyi OrderItem nesnesine dönüştürme
  factory OrderItem.fromDB(db.OrderItem orderItem) {
    return OrderItem(
      id: orderItem.id,
      orderId: orderItem.orderId,
      productId: orderItem.productId,
      quantity: orderItem.quantity,
      scannedQuantity: orderItem.scannedQuantity,
    );
  }

  // OrderItem nesnesini veritabanı formatına dönüştürme
  db.OrderItemsCompanion toDB() {
    return db.OrderItemsCompanion(
      orderId: Value(orderId),
      productId: Value(productId),
      quantity: Value(quantity),
      scannedQuantity: Value(scannedQuantity),
    );
  }

  // İlerleme yüzdesini hesaplama
  double get progress => quantity > 0 ? scannedQuantity / quantity : 0.0;

  // Tamamlanma durumunu kontrol etme
  bool get isCompleted => scannedQuantity >= quantity;

  // Kopya oluşturma ve belirli alanları güncelleme
  OrderItem copyWith({
    int? id,
    int? orderId,
    int? productId,
    int? quantity,
    int? scannedQuantity,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      scannedQuantity: scannedQuantity ?? this.scannedQuantity,
    );
  }
}
