import 'package:drift/drift.dart';
import 'package:flutter_count_track/core/database/app_database.dart' as db;

class Order {
  final int id;
  final String orderCode;
  final String customerName;
  final db.OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.orderCode,
    required this.customerName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert database entity to Order model
  factory Order.fromDB(db.Order order) {
    return Order(
      id: order.id,
      orderCode: order.orderCode,
      customerName: order.customerName,
      status: order.status,
      createdAt: order.createdAt,
      updatedAt: order.updatedAt,
    );
  }

  // Convert Order model to database companion
  db.OrdersCompanion toDB() {
    return db.OrdersCompanion(
      orderCode: Value(orderCode),
      customerName: Value(customerName),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  // Create a copy with optional field updates
  Order copyWith({
    int? id,
    String? orderCode,
    String? customerName,
    db.OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      orderCode: orderCode ?? this.orderCode,
      customerName: customerName ?? this.customerName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
