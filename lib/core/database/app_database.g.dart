// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $OrdersTable extends Orders with TableInfo<$OrdersTable, Order> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _orderCodeMeta =
      const VerificationMeta('orderCode');
  @override
  late final GeneratedColumn<String> orderCode = GeneratedColumn<String>(
      'order_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customerNameMeta =
      const VerificationMeta('customerName');
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
      'customer_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<OrderStatus, String> status =
      GeneratedColumn<String>('status', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<OrderStatus>($OrdersTable.$converterstatus);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, orderCode, customerName, status, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'orders';
  @override
  VerificationContext validateIntegrity(Insertable<Order> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('order_code')) {
      context.handle(_orderCodeMeta,
          orderCode.isAcceptableOrUnknown(data['order_code']!, _orderCodeMeta));
    } else if (isInserting) {
      context.missing(_orderCodeMeta);
    }
    if (data.containsKey('customer_name')) {
      context.handle(
          _customerNameMeta,
          customerName.isAcceptableOrUnknown(
              data['customer_name']!, _customerNameMeta));
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Order map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Order(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      orderCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}order_code'])!,
      customerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_name'])!,
      status: $OrdersTable.$converterstatus.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $OrdersTable createAlias(String alias) {
    return $OrdersTable(attachedDatabase, alias);
  }

  static TypeConverter<OrderStatus, String> $converterstatus =
      const OrderStatusConverter();
}

class Order extends DataClass implements Insertable<Order> {
  final int id;
  final String orderCode;
  final String customerName;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Order(
      {required this.id,
      required this.orderCode,
      required this.customerName,
      required this.status,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['order_code'] = Variable<String>(orderCode);
    map['customer_name'] = Variable<String>(customerName);
    {
      map['status'] =
          Variable<String>($OrdersTable.$converterstatus.toSql(status));
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  OrdersCompanion toCompanion(bool nullToAbsent) {
    return OrdersCompanion(
      id: Value(id),
      orderCode: Value(orderCode),
      customerName: Value(customerName),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Order.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Order(
      id: serializer.fromJson<int>(json['id']),
      orderCode: serializer.fromJson<String>(json['orderCode']),
      customerName: serializer.fromJson<String>(json['customerName']),
      status: serializer.fromJson<OrderStatus>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'orderCode': serializer.toJson<String>(orderCode),
      'customerName': serializer.toJson<String>(customerName),
      'status': serializer.toJson<OrderStatus>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Order copyWith(
          {int? id,
          String? orderCode,
          String? customerName,
          OrderStatus? status,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Order(
        id: id ?? this.id,
        orderCode: orderCode ?? this.orderCode,
        customerName: customerName ?? this.customerName,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Order copyWithCompanion(OrdersCompanion data) {
    return Order(
      id: data.id.present ? data.id.value : this.id,
      orderCode: data.orderCode.present ? data.orderCode.value : this.orderCode,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Order(')
          ..write('id: $id, ')
          ..write('orderCode: $orderCode, ')
          ..write('customerName: $customerName, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, orderCode, customerName, status, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Order &&
          other.id == this.id &&
          other.orderCode == this.orderCode &&
          other.customerName == this.customerName &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class OrdersCompanion extends UpdateCompanion<Order> {
  final Value<int> id;
  final Value<String> orderCode;
  final Value<String> customerName;
  final Value<OrderStatus> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const OrdersCompanion({
    this.id = const Value.absent(),
    this.orderCode = const Value.absent(),
    this.customerName = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  OrdersCompanion.insert({
    this.id = const Value.absent(),
    required String orderCode,
    required String customerName,
    required OrderStatus status,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : orderCode = Value(orderCode),
        customerName = Value(customerName),
        status = Value(status);
  static Insertable<Order> custom({
    Expression<int>? id,
    Expression<String>? orderCode,
    Expression<String>? customerName,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderCode != null) 'order_code': orderCode,
      if (customerName != null) 'customer_name': customerName,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  OrdersCompanion copyWith(
      {Value<int>? id,
      Value<String>? orderCode,
      Value<String>? customerName,
      Value<OrderStatus>? status,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return OrdersCompanion(
      id: id ?? this.id,
      orderCode: orderCode ?? this.orderCode,
      customerName: customerName ?? this.customerName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (orderCode.present) {
      map['order_code'] = Variable<String>(orderCode.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (status.present) {
      map['status'] =
          Variable<String>($OrdersTable.$converterstatus.toSql(status.value));
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrdersCompanion(')
          ..write('id: $id, ')
          ..write('orderCode: $orderCode, ')
          ..write('customerName: $customerName, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _ourProductCodeMeta =
      const VerificationMeta('ourProductCode');
  @override
  late final GeneratedColumn<String> ourProductCode = GeneratedColumn<String>(
      'our_product_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isUniqueBarcodeRequiredMeta =
      const VerificationMeta('isUniqueBarcodeRequired');
  @override
  late final GeneratedColumn<bool> isUniqueBarcodeRequired =
      GeneratedColumn<bool>('is_unique_barcode_required', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("is_unique_barcode_required" IN (0, 1))'),
          defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, ourProductCode, name, isUniqueBarcodeRequired];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(Insertable<Product> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('our_product_code')) {
      context.handle(
          _ourProductCodeMeta,
          ourProductCode.isAcceptableOrUnknown(
              data['our_product_code']!, _ourProductCodeMeta));
    } else if (isInserting) {
      context.missing(_ourProductCodeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_unique_barcode_required')) {
      context.handle(
          _isUniqueBarcodeRequiredMeta,
          isUniqueBarcodeRequired.isAcceptableOrUnknown(
              data['is_unique_barcode_required']!,
              _isUniqueBarcodeRequiredMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      ourProductCode: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}our_product_code'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      isUniqueBarcodeRequired: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}is_unique_barcode_required'])!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class Product extends DataClass implements Insertable<Product> {
  final int id;
  final String ourProductCode;
  final String name;
  final bool isUniqueBarcodeRequired;
  const Product(
      {required this.id,
      required this.ourProductCode,
      required this.name,
      required this.isUniqueBarcodeRequired});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['our_product_code'] = Variable<String>(ourProductCode);
    map['name'] = Variable<String>(name);
    map['is_unique_barcode_required'] = Variable<bool>(isUniqueBarcodeRequired);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      ourProductCode: Value(ourProductCode),
      name: Value(name),
      isUniqueBarcodeRequired: Value(isUniqueBarcodeRequired),
    );
  }

  factory Product.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<int>(json['id']),
      ourProductCode: serializer.fromJson<String>(json['ourProductCode']),
      name: serializer.fromJson<String>(json['name']),
      isUniqueBarcodeRequired:
          serializer.fromJson<bool>(json['isUniqueBarcodeRequired']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ourProductCode': serializer.toJson<String>(ourProductCode),
      'name': serializer.toJson<String>(name),
      'isUniqueBarcodeRequired':
          serializer.toJson<bool>(isUniqueBarcodeRequired),
    };
  }

  Product copyWith(
          {int? id,
          String? ourProductCode,
          String? name,
          bool? isUniqueBarcodeRequired}) =>
      Product(
        id: id ?? this.id,
        ourProductCode: ourProductCode ?? this.ourProductCode,
        name: name ?? this.name,
        isUniqueBarcodeRequired:
            isUniqueBarcodeRequired ?? this.isUniqueBarcodeRequired,
      );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      ourProductCode: data.ourProductCode.present
          ? data.ourProductCode.value
          : this.ourProductCode,
      name: data.name.present ? data.name.value : this.name,
      isUniqueBarcodeRequired: data.isUniqueBarcodeRequired.present
          ? data.isUniqueBarcodeRequired.value
          : this.isUniqueBarcodeRequired,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('ourProductCode: $ourProductCode, ')
          ..write('name: $name, ')
          ..write('isUniqueBarcodeRequired: $isUniqueBarcodeRequired')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, ourProductCode, name, isUniqueBarcodeRequired);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.ourProductCode == this.ourProductCode &&
          other.name == this.name &&
          other.isUniqueBarcodeRequired == this.isUniqueBarcodeRequired);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<int> id;
  final Value<String> ourProductCode;
  final Value<String> name;
  final Value<bool> isUniqueBarcodeRequired;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.ourProductCode = const Value.absent(),
    this.name = const Value.absent(),
    this.isUniqueBarcodeRequired = const Value.absent(),
  });
  ProductsCompanion.insert({
    this.id = const Value.absent(),
    required String ourProductCode,
    required String name,
    this.isUniqueBarcodeRequired = const Value.absent(),
  })  : ourProductCode = Value(ourProductCode),
        name = Value(name);
  static Insertable<Product> custom({
    Expression<int>? id,
    Expression<String>? ourProductCode,
    Expression<String>? name,
    Expression<bool>? isUniqueBarcodeRequired,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ourProductCode != null) 'our_product_code': ourProductCode,
      if (name != null) 'name': name,
      if (isUniqueBarcodeRequired != null)
        'is_unique_barcode_required': isUniqueBarcodeRequired,
    });
  }

  ProductsCompanion copyWith(
      {Value<int>? id,
      Value<String>? ourProductCode,
      Value<String>? name,
      Value<bool>? isUniqueBarcodeRequired}) {
    return ProductsCompanion(
      id: id ?? this.id,
      ourProductCode: ourProductCode ?? this.ourProductCode,
      name: name ?? this.name,
      isUniqueBarcodeRequired:
          isUniqueBarcodeRequired ?? this.isUniqueBarcodeRequired,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ourProductCode.present) {
      map['our_product_code'] = Variable<String>(ourProductCode.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isUniqueBarcodeRequired.present) {
      map['is_unique_barcode_required'] =
          Variable<bool>(isUniqueBarcodeRequired.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('ourProductCode: $ourProductCode, ')
          ..write('name: $name, ')
          ..write('isUniqueBarcodeRequired: $isUniqueBarcodeRequired')
          ..write(')'))
        .toString();
  }
}

class $OrderItemsTable extends OrderItems
    with TableInfo<$OrderItemsTable, OrderItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _orderIdMeta =
      const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<int> orderId = GeneratedColumn<int>(
      'order_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES orders (id)'));
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
      'product_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES products (id)'));
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _scannedQuantityMeta =
      const VerificationMeta('scannedQuantity');
  @override
  late final GeneratedColumn<int> scannedQuantity = GeneratedColumn<int>(
      'scanned_quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, orderId, productId, quantity, scannedQuantity];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_items';
  @override
  VerificationContext validateIntegrity(Insertable<OrderItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta,
          orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('scanned_quantity')) {
      context.handle(
          _scannedQuantityMeta,
          scannedQuantity.isAcceptableOrUnknown(
              data['scanned_quantity']!, _scannedQuantityMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      orderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}product_id'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      scannedQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}scanned_quantity'])!,
    );
  }

  @override
  $OrderItemsTable createAlias(String alias) {
    return $OrderItemsTable(attachedDatabase, alias);
  }
}

class OrderItem extends DataClass implements Insertable<OrderItem> {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final int scannedQuantity;
  const OrderItem(
      {required this.id,
      required this.orderId,
      required this.productId,
      required this.quantity,
      required this.scannedQuantity});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['order_id'] = Variable<int>(orderId);
    map['product_id'] = Variable<int>(productId);
    map['quantity'] = Variable<int>(quantity);
    map['scanned_quantity'] = Variable<int>(scannedQuantity);
    return map;
  }

  OrderItemsCompanion toCompanion(bool nullToAbsent) {
    return OrderItemsCompanion(
      id: Value(id),
      orderId: Value(orderId),
      productId: Value(productId),
      quantity: Value(quantity),
      scannedQuantity: Value(scannedQuantity),
    );
  }

  factory OrderItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderItem(
      id: serializer.fromJson<int>(json['id']),
      orderId: serializer.fromJson<int>(json['orderId']),
      productId: serializer.fromJson<int>(json['productId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      scannedQuantity: serializer.fromJson<int>(json['scannedQuantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'orderId': serializer.toJson<int>(orderId),
      'productId': serializer.toJson<int>(productId),
      'quantity': serializer.toJson<int>(quantity),
      'scannedQuantity': serializer.toJson<int>(scannedQuantity),
    };
  }

  OrderItem copyWith(
          {int? id,
          int? orderId,
          int? productId,
          int? quantity,
          int? scannedQuantity}) =>
      OrderItem(
        id: id ?? this.id,
        orderId: orderId ?? this.orderId,
        productId: productId ?? this.productId,
        quantity: quantity ?? this.quantity,
        scannedQuantity: scannedQuantity ?? this.scannedQuantity,
      );
  OrderItem copyWithCompanion(OrderItemsCompanion data) {
    return OrderItem(
      id: data.id.present ? data.id.value : this.id,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      scannedQuantity: data.scannedQuantity.present
          ? data.scannedQuantity.value
          : this.scannedQuantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderItem(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('scannedQuantity: $scannedQuantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, orderId, productId, quantity, scannedQuantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderItem &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.productId == this.productId &&
          other.quantity == this.quantity &&
          other.scannedQuantity == this.scannedQuantity);
}

class OrderItemsCompanion extends UpdateCompanion<OrderItem> {
  final Value<int> id;
  final Value<int> orderId;
  final Value<int> productId;
  final Value<int> quantity;
  final Value<int> scannedQuantity;
  const OrderItemsCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.scannedQuantity = const Value.absent(),
  });
  OrderItemsCompanion.insert({
    this.id = const Value.absent(),
    required int orderId,
    required int productId,
    required int quantity,
    this.scannedQuantity = const Value.absent(),
  })  : orderId = Value(orderId),
        productId = Value(productId),
        quantity = Value(quantity);
  static Insertable<OrderItem> custom({
    Expression<int>? id,
    Expression<int>? orderId,
    Expression<int>? productId,
    Expression<int>? quantity,
    Expression<int>? scannedQuantity,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (scannedQuantity != null) 'scanned_quantity': scannedQuantity,
    });
  }

  OrderItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? orderId,
      Value<int>? productId,
      Value<int>? quantity,
      Value<int>? scannedQuantity}) {
    return OrderItemsCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      scannedQuantity: scannedQuantity ?? this.scannedQuantity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<int>(orderId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (scannedQuantity.present) {
      map['scanned_quantity'] = Variable<int>(scannedQuantity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderItemsCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('scannedQuantity: $scannedQuantity')
          ..write(')'))
        .toString();
  }
}

class $ProductCodeMappingsTable extends ProductCodeMappings
    with TableInfo<$ProductCodeMappingsTable, ProductCodeMapping> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductCodeMappingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _customerProductCodeMeta =
      const VerificationMeta('customerProductCode');
  @override
  late final GeneratedColumn<String> customerProductCode =
      GeneratedColumn<String>('customer_product_code', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
      'product_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES products (id)'));
  static const VerificationMeta _customerNameMeta =
      const VerificationMeta('customerName');
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
      'customer_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, customerProductCode, productId, customerName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_code_mappings';
  @override
  VerificationContext validateIntegrity(Insertable<ProductCodeMapping> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('customer_product_code')) {
      context.handle(
          _customerProductCodeMeta,
          customerProductCode.isAcceptableOrUnknown(
              data['customer_product_code']!, _customerProductCodeMeta));
    } else if (isInserting) {
      context.missing(_customerProductCodeMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('customer_name')) {
      context.handle(
          _customerNameMeta,
          customerName.isAcceptableOrUnknown(
              data['customer_name']!, _customerNameMeta));
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductCodeMapping map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductCodeMapping(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      customerProductCode: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}customer_product_code'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}product_id'])!,
      customerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_name'])!,
    );
  }

  @override
  $ProductCodeMappingsTable createAlias(String alias) {
    return $ProductCodeMappingsTable(attachedDatabase, alias);
  }
}

class ProductCodeMapping extends DataClass
    implements Insertable<ProductCodeMapping> {
  final int id;
  final String customerProductCode;
  final int productId;
  final String customerName;
  const ProductCodeMapping(
      {required this.id,
      required this.customerProductCode,
      required this.productId,
      required this.customerName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['customer_product_code'] = Variable<String>(customerProductCode);
    map['product_id'] = Variable<int>(productId);
    map['customer_name'] = Variable<String>(customerName);
    return map;
  }

  ProductCodeMappingsCompanion toCompanion(bool nullToAbsent) {
    return ProductCodeMappingsCompanion(
      id: Value(id),
      customerProductCode: Value(customerProductCode),
      productId: Value(productId),
      customerName: Value(customerName),
    );
  }

  factory ProductCodeMapping.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductCodeMapping(
      id: serializer.fromJson<int>(json['id']),
      customerProductCode:
          serializer.fromJson<String>(json['customerProductCode']),
      productId: serializer.fromJson<int>(json['productId']),
      customerName: serializer.fromJson<String>(json['customerName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'customerProductCode': serializer.toJson<String>(customerProductCode),
      'productId': serializer.toJson<int>(productId),
      'customerName': serializer.toJson<String>(customerName),
    };
  }

  ProductCodeMapping copyWith(
          {int? id,
          String? customerProductCode,
          int? productId,
          String? customerName}) =>
      ProductCodeMapping(
        id: id ?? this.id,
        customerProductCode: customerProductCode ?? this.customerProductCode,
        productId: productId ?? this.productId,
        customerName: customerName ?? this.customerName,
      );
  ProductCodeMapping copyWithCompanion(ProductCodeMappingsCompanion data) {
    return ProductCodeMapping(
      id: data.id.present ? data.id.value : this.id,
      customerProductCode: data.customerProductCode.present
          ? data.customerProductCode.value
          : this.customerProductCode,
      productId: data.productId.present ? data.productId.value : this.productId,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductCodeMapping(')
          ..write('id: $id, ')
          ..write('customerProductCode: $customerProductCode, ')
          ..write('productId: $productId, ')
          ..write('customerName: $customerName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, customerProductCode, productId, customerName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductCodeMapping &&
          other.id == this.id &&
          other.customerProductCode == this.customerProductCode &&
          other.productId == this.productId &&
          other.customerName == this.customerName);
}

class ProductCodeMappingsCompanion extends UpdateCompanion<ProductCodeMapping> {
  final Value<int> id;
  final Value<String> customerProductCode;
  final Value<int> productId;
  final Value<String> customerName;
  const ProductCodeMappingsCompanion({
    this.id = const Value.absent(),
    this.customerProductCode = const Value.absent(),
    this.productId = const Value.absent(),
    this.customerName = const Value.absent(),
  });
  ProductCodeMappingsCompanion.insert({
    this.id = const Value.absent(),
    required String customerProductCode,
    required int productId,
    required String customerName,
  })  : customerProductCode = Value(customerProductCode),
        productId = Value(productId),
        customerName = Value(customerName);
  static Insertable<ProductCodeMapping> custom({
    Expression<int>? id,
    Expression<String>? customerProductCode,
    Expression<int>? productId,
    Expression<String>? customerName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerProductCode != null)
        'customer_product_code': customerProductCode,
      if (productId != null) 'product_id': productId,
      if (customerName != null) 'customer_name': customerName,
    });
  }

  ProductCodeMappingsCompanion copyWith(
      {Value<int>? id,
      Value<String>? customerProductCode,
      Value<int>? productId,
      Value<String>? customerName}) {
    return ProductCodeMappingsCompanion(
      id: id ?? this.id,
      customerProductCode: customerProductCode ?? this.customerProductCode,
      productId: productId ?? this.productId,
      customerName: customerName ?? this.customerName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (customerProductCode.present) {
      map['customer_product_code'] =
          Variable<String>(customerProductCode.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductCodeMappingsCompanion(')
          ..write('id: $id, ')
          ..write('customerProductCode: $customerProductCode, ')
          ..write('productId: $productId, ')
          ..write('customerName: $customerName')
          ..write(')'))
        .toString();
  }
}

class $BarcodeReadsTable extends BarcodeReads
    with TableInfo<$BarcodeReadsTable, BarcodeRead> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BarcodeReadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _orderIdMeta =
      const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<int> orderId = GeneratedColumn<int>(
      'order_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES orders (id)'));
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
      'product_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES products (id)'));
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
      'read_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, orderId, productId, barcode, readAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'barcode_reads';
  @override
  VerificationContext validateIntegrity(Insertable<BarcodeRead> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta,
          orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    } else if (isInserting) {
      context.missing(_barcodeMeta);
    }
    if (data.containsKey('read_at')) {
      context.handle(_readAtMeta,
          readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BarcodeRead map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BarcodeRead(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      orderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}product_id']),
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode'])!,
      readAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}read_at'])!,
    );
  }

  @override
  $BarcodeReadsTable createAlias(String alias) {
    return $BarcodeReadsTable(attachedDatabase, alias);
  }
}

class BarcodeRead extends DataClass implements Insertable<BarcodeRead> {
  final int id;
  final int orderId;
  final int? productId;
  final String barcode;
  final DateTime readAt;
  const BarcodeRead(
      {required this.id,
      required this.orderId,
      this.productId,
      required this.barcode,
      required this.readAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['order_id'] = Variable<int>(orderId);
    if (!nullToAbsent || productId != null) {
      map['product_id'] = Variable<int>(productId);
    }
    map['barcode'] = Variable<String>(barcode);
    map['read_at'] = Variable<DateTime>(readAt);
    return map;
  }

  BarcodeReadsCompanion toCompanion(bool nullToAbsent) {
    return BarcodeReadsCompanion(
      id: Value(id),
      orderId: Value(orderId),
      productId: productId == null && nullToAbsent
          ? const Value.absent()
          : Value(productId),
      barcode: Value(barcode),
      readAt: Value(readAt),
    );
  }

  factory BarcodeRead.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BarcodeRead(
      id: serializer.fromJson<int>(json['id']),
      orderId: serializer.fromJson<int>(json['orderId']),
      productId: serializer.fromJson<int?>(json['productId']),
      barcode: serializer.fromJson<String>(json['barcode']),
      readAt: serializer.fromJson<DateTime>(json['readAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'orderId': serializer.toJson<int>(orderId),
      'productId': serializer.toJson<int?>(productId),
      'barcode': serializer.toJson<String>(barcode),
      'readAt': serializer.toJson<DateTime>(readAt),
    };
  }

  BarcodeRead copyWith(
          {int? id,
          int? orderId,
          Value<int?> productId = const Value.absent(),
          String? barcode,
          DateTime? readAt}) =>
      BarcodeRead(
        id: id ?? this.id,
        orderId: orderId ?? this.orderId,
        productId: productId.present ? productId.value : this.productId,
        barcode: barcode ?? this.barcode,
        readAt: readAt ?? this.readAt,
      );
  BarcodeRead copyWithCompanion(BarcodeReadsCompanion data) {
    return BarcodeRead(
      id: data.id.present ? data.id.value : this.id,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      productId: data.productId.present ? data.productId.value : this.productId,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BarcodeRead(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('productId: $productId, ')
          ..write('barcode: $barcode, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, orderId, productId, barcode, readAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BarcodeRead &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.productId == this.productId &&
          other.barcode == this.barcode &&
          other.readAt == this.readAt);
}

class BarcodeReadsCompanion extends UpdateCompanion<BarcodeRead> {
  final Value<int> id;
  final Value<int> orderId;
  final Value<int?> productId;
  final Value<String> barcode;
  final Value<DateTime> readAt;
  const BarcodeReadsCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.productId = const Value.absent(),
    this.barcode = const Value.absent(),
    this.readAt = const Value.absent(),
  });
  BarcodeReadsCompanion.insert({
    this.id = const Value.absent(),
    required int orderId,
    this.productId = const Value.absent(),
    required String barcode,
    this.readAt = const Value.absent(),
  })  : orderId = Value(orderId),
        barcode = Value(barcode);
  static Insertable<BarcodeRead> custom({
    Expression<int>? id,
    Expression<int>? orderId,
    Expression<int>? productId,
    Expression<String>? barcode,
    Expression<DateTime>? readAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (productId != null) 'product_id': productId,
      if (barcode != null) 'barcode': barcode,
      if (readAt != null) 'read_at': readAt,
    });
  }

  BarcodeReadsCompanion copyWith(
      {Value<int>? id,
      Value<int>? orderId,
      Value<int?>? productId,
      Value<String>? barcode,
      Value<DateTime>? readAt}) {
    return BarcodeReadsCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      barcode: barcode ?? this.barcode,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<int>(orderId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BarcodeReadsCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('productId: $productId, ')
          ..write('barcode: $barcode, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }
}

class $DeliveriesTable extends Deliveries
    with TableInfo<$DeliveriesTable, Delivery> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeliveriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _orderIdMeta =
      const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<int> orderId = GeneratedColumn<int>(
      'order_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES orders (id)'));
  static const VerificationMeta _deliveryDateMeta =
      const VerificationMeta('deliveryDate');
  @override
  late final GeneratedColumn<DateTime> deliveryDate = GeneratedColumn<DateTime>(
      'delivery_date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, orderId, deliveryDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deliveries';
  @override
  VerificationContext validateIntegrity(Insertable<Delivery> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta,
          orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('delivery_date')) {
      context.handle(
          _deliveryDateMeta,
          deliveryDate.isAcceptableOrUnknown(
              data['delivery_date']!, _deliveryDateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Delivery map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Delivery(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      orderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_id'])!,
      deliveryDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}delivery_date'])!,
    );
  }

  @override
  $DeliveriesTable createAlias(String alias) {
    return $DeliveriesTable(attachedDatabase, alias);
  }
}

class Delivery extends DataClass implements Insertable<Delivery> {
  final int id;
  final int orderId;
  final DateTime deliveryDate;
  const Delivery(
      {required this.id, required this.orderId, required this.deliveryDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['order_id'] = Variable<int>(orderId);
    map['delivery_date'] = Variable<DateTime>(deliveryDate);
    return map;
  }

  DeliveriesCompanion toCompanion(bool nullToAbsent) {
    return DeliveriesCompanion(
      id: Value(id),
      orderId: Value(orderId),
      deliveryDate: Value(deliveryDate),
    );
  }

  factory Delivery.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Delivery(
      id: serializer.fromJson<int>(json['id']),
      orderId: serializer.fromJson<int>(json['orderId']),
      deliveryDate: serializer.fromJson<DateTime>(json['deliveryDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'orderId': serializer.toJson<int>(orderId),
      'deliveryDate': serializer.toJson<DateTime>(deliveryDate),
    };
  }

  Delivery copyWith({int? id, int? orderId, DateTime? deliveryDate}) =>
      Delivery(
        id: id ?? this.id,
        orderId: orderId ?? this.orderId,
        deliveryDate: deliveryDate ?? this.deliveryDate,
      );
  Delivery copyWithCompanion(DeliveriesCompanion data) {
    return Delivery(
      id: data.id.present ? data.id.value : this.id,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      deliveryDate: data.deliveryDate.present
          ? data.deliveryDate.value
          : this.deliveryDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Delivery(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('deliveryDate: $deliveryDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, orderId, deliveryDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Delivery &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.deliveryDate == this.deliveryDate);
}

class DeliveriesCompanion extends UpdateCompanion<Delivery> {
  final Value<int> id;
  final Value<int> orderId;
  final Value<DateTime> deliveryDate;
  const DeliveriesCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.deliveryDate = const Value.absent(),
  });
  DeliveriesCompanion.insert({
    this.id = const Value.absent(),
    required int orderId,
    this.deliveryDate = const Value.absent(),
  }) : orderId = Value(orderId);
  static Insertable<Delivery> custom({
    Expression<int>? id,
    Expression<int>? orderId,
    Expression<DateTime>? deliveryDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (deliveryDate != null) 'delivery_date': deliveryDate,
    });
  }

  DeliveriesCompanion copyWith(
      {Value<int>? id, Value<int>? orderId, Value<DateTime>? deliveryDate}) {
    return DeliveriesCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      deliveryDate: deliveryDate ?? this.deliveryDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<int>(orderId.value);
    }
    if (deliveryDate.present) {
      map['delivery_date'] = Variable<DateTime>(deliveryDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeliveriesCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('deliveryDate: $deliveryDate')
          ..write(')'))
        .toString();
  }
}

class $DeliveryItemsTable extends DeliveryItems
    with TableInfo<$DeliveryItemsTable, DeliveryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeliveryItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _deliveryIdMeta =
      const VerificationMeta('deliveryId');
  @override
  late final GeneratedColumn<int> deliveryId = GeneratedColumn<int>(
      'delivery_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES deliveries (id)'));
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
      'product_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES products (id)'));
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, deliveryId, productId, quantity];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'delivery_items';
  @override
  VerificationContext validateIntegrity(Insertable<DeliveryItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('delivery_id')) {
      context.handle(
          _deliveryIdMeta,
          deliveryId.isAcceptableOrUnknown(
              data['delivery_id']!, _deliveryIdMeta));
    } else if (isInserting) {
      context.missing(_deliveryIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeliveryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeliveryItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      deliveryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}delivery_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}product_id'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
    );
  }

  @override
  $DeliveryItemsTable createAlias(String alias) {
    return $DeliveryItemsTable(attachedDatabase, alias);
  }
}

class DeliveryItem extends DataClass implements Insertable<DeliveryItem> {
  final int id;
  final int deliveryId;
  final int productId;
  final int quantity;
  const DeliveryItem(
      {required this.id,
      required this.deliveryId,
      required this.productId,
      required this.quantity});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['delivery_id'] = Variable<int>(deliveryId);
    map['product_id'] = Variable<int>(productId);
    map['quantity'] = Variable<int>(quantity);
    return map;
  }

  DeliveryItemsCompanion toCompanion(bool nullToAbsent) {
    return DeliveryItemsCompanion(
      id: Value(id),
      deliveryId: Value(deliveryId),
      productId: Value(productId),
      quantity: Value(quantity),
    );
  }

  factory DeliveryItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeliveryItem(
      id: serializer.fromJson<int>(json['id']),
      deliveryId: serializer.fromJson<int>(json['deliveryId']),
      productId: serializer.fromJson<int>(json['productId']),
      quantity: serializer.fromJson<int>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deliveryId': serializer.toJson<int>(deliveryId),
      'productId': serializer.toJson<int>(productId),
      'quantity': serializer.toJson<int>(quantity),
    };
  }

  DeliveryItem copyWith(
          {int? id, int? deliveryId, int? productId, int? quantity}) =>
      DeliveryItem(
        id: id ?? this.id,
        deliveryId: deliveryId ?? this.deliveryId,
        productId: productId ?? this.productId,
        quantity: quantity ?? this.quantity,
      );
  DeliveryItem copyWithCompanion(DeliveryItemsCompanion data) {
    return DeliveryItem(
      id: data.id.present ? data.id.value : this.id,
      deliveryId:
          data.deliveryId.present ? data.deliveryId.value : this.deliveryId,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeliveryItem(')
          ..write('id: $id, ')
          ..write('deliveryId: $deliveryId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, deliveryId, productId, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeliveryItem &&
          other.id == this.id &&
          other.deliveryId == this.deliveryId &&
          other.productId == this.productId &&
          other.quantity == this.quantity);
}

class DeliveryItemsCompanion extends UpdateCompanion<DeliveryItem> {
  final Value<int> id;
  final Value<int> deliveryId;
  final Value<int> productId;
  final Value<int> quantity;
  const DeliveryItemsCompanion({
    this.id = const Value.absent(),
    this.deliveryId = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantity = const Value.absent(),
  });
  DeliveryItemsCompanion.insert({
    this.id = const Value.absent(),
    required int deliveryId,
    required int productId,
    required int quantity,
  })  : deliveryId = Value(deliveryId),
        productId = Value(productId),
        quantity = Value(quantity);
  static Insertable<DeliveryItem> custom({
    Expression<int>? id,
    Expression<int>? deliveryId,
    Expression<int>? productId,
    Expression<int>? quantity,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deliveryId != null) 'delivery_id': deliveryId,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
    });
  }

  DeliveryItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? deliveryId,
      Value<int>? productId,
      Value<int>? quantity}) {
    return DeliveryItemsCompanion(
      id: id ?? this.id,
      deliveryId: deliveryId ?? this.deliveryId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deliveryId.present) {
      map['delivery_id'] = Variable<int>(deliveryId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeliveryItemsCompanion(')
          ..write('id: $id, ')
          ..write('deliveryId: $deliveryId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $OrdersTable orders = $OrdersTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $OrderItemsTable orderItems = $OrderItemsTable(this);
  late final $ProductCodeMappingsTable productCodeMappings =
      $ProductCodeMappingsTable(this);
  late final $BarcodeReadsTable barcodeReads = $BarcodeReadsTable(this);
  late final $DeliveriesTable deliveries = $DeliveriesTable(this);
  late final $DeliveryItemsTable deliveryItems = $DeliveryItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        orders,
        products,
        orderItems,
        productCodeMappings,
        barcodeReads,
        deliveries,
        deliveryItems
      ];
}

typedef $$OrdersTableCreateCompanionBuilder = OrdersCompanion Function({
  Value<int> id,
  required String orderCode,
  required String customerName,
  required OrderStatus status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$OrdersTableUpdateCompanionBuilder = OrdersCompanion Function({
  Value<int> id,
  Value<String> orderCode,
  Value<String> customerName,
  Value<OrderStatus> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$OrdersTableReferences
    extends BaseReferences<_$AppDatabase, $OrdersTable, Order> {
  $$OrdersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$OrderItemsTable, List<OrderItem>>
      _orderItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.orderItems,
          aliasName: $_aliasNameGenerator(db.orders.id, db.orderItems.orderId));

  $$OrderItemsTableProcessedTableManager get orderItemsRefs {
    final manager = $$OrderItemsTableTableManager($_db, $_db.orderItems)
        .filter((f) => f.orderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_orderItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$BarcodeReadsTable, List<BarcodeRead>>
      _barcodeReadsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.barcodeReads,
              aliasName:
                  $_aliasNameGenerator(db.orders.id, db.barcodeReads.orderId));

  $$BarcodeReadsTableProcessedTableManager get barcodeReadsRefs {
    final manager = $$BarcodeReadsTableTableManager($_db, $_db.barcodeReads)
        .filter((f) => f.orderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_barcodeReadsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DeliveriesTable, List<Delivery>>
      _deliveriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.deliveries,
          aliasName: $_aliasNameGenerator(db.orders.id, db.deliveries.orderId));

  $$DeliveriesTableProcessedTableManager get deliveriesRefs {
    final manager = $$DeliveriesTableTableManager($_db, $_db.deliveries)
        .filter((f) => f.orderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_deliveriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$OrdersTableFilterComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get orderCode => $composableBuilder(
      column: $table.orderCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<OrderStatus, OrderStatus, String> get status =>
      $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> orderItemsRefs(
      Expression<bool> Function($$OrderItemsTableFilterComposer f) f) {
    final $$OrderItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.orderItems,
        getReferencedColumn: (t) => t.orderId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderItemsTableFilterComposer(
              $db: $db,
              $table: $db.orderItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> barcodeReadsRefs(
      Expression<bool> Function($$BarcodeReadsTableFilterComposer f) f) {
    final $$BarcodeReadsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.barcodeReads,
        getReferencedColumn: (t) => t.orderId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BarcodeReadsTableFilterComposer(
              $db: $db,
              $table: $db.barcodeReads,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> deliveriesRefs(
      Expression<bool> Function($$DeliveriesTableFilterComposer f) f) {
    final $$DeliveriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.deliveries,
        getReferencedColumn: (t) => t.orderId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeliveriesTableFilterComposer(
              $db: $db,
              $table: $db.deliveries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$OrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get orderCode => $composableBuilder(
      column: $table.orderCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerName => $composableBuilder(
      column: $table.customerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$OrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get orderCode =>
      $composableBuilder(column: $table.orderCode, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => column);

  GeneratedColumnWithTypeConverter<OrderStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> orderItemsRefs<T extends Object>(
      Expression<T> Function($$OrderItemsTableAnnotationComposer a) f) {
    final $$OrderItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.orderItems,
        getReferencedColumn: (t) => t.orderId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.orderItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> barcodeReadsRefs<T extends Object>(
      Expression<T> Function($$BarcodeReadsTableAnnotationComposer a) f) {
    final $$BarcodeReadsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.barcodeReads,
        getReferencedColumn: (t) => t.orderId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BarcodeReadsTableAnnotationComposer(
              $db: $db,
              $table: $db.barcodeReads,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> deliveriesRefs<T extends Object>(
      Expression<T> Function($$DeliveriesTableAnnotationComposer a) f) {
    final $$DeliveriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.deliveries,
        getReferencedColumn: (t) => t.orderId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeliveriesTableAnnotationComposer(
              $db: $db,
              $table: $db.deliveries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$OrdersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrdersTable,
    Order,
    $$OrdersTableFilterComposer,
    $$OrdersTableOrderingComposer,
    $$OrdersTableAnnotationComposer,
    $$OrdersTableCreateCompanionBuilder,
    $$OrdersTableUpdateCompanionBuilder,
    (Order, $$OrdersTableReferences),
    Order,
    PrefetchHooks Function(
        {bool orderItemsRefs, bool barcodeReadsRefs, bool deliveriesRefs})> {
  $$OrdersTableTableManager(_$AppDatabase db, $OrdersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> orderCode = const Value.absent(),
            Value<String> customerName = const Value.absent(),
            Value<OrderStatus> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              OrdersCompanion(
            id: id,
            orderCode: orderCode,
            customerName: customerName,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String orderCode,
            required String customerName,
            required OrderStatus status,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              OrdersCompanion.insert(
            id: id,
            orderCode: orderCode,
            customerName: customerName,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$OrdersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {orderItemsRefs = false,
              barcodeReadsRefs = false,
              deliveriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (orderItemsRefs) db.orderItems,
                if (barcodeReadsRefs) db.barcodeReads,
                if (deliveriesRefs) db.deliveries
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (orderItemsRefs)
                    await $_getPrefetchedData<Order, $OrdersTable, OrderItem>(
                        currentTable: table,
                        referencedTable:
                            $$OrdersTableReferences._orderItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$OrdersTableReferences(db, table, p0)
                                .orderItemsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.orderId == item.id),
                        typedResults: items),
                  if (barcodeReadsRefs)
                    await $_getPrefetchedData<Order, $OrdersTable, BarcodeRead>(
                        currentTable: table,
                        referencedTable:
                            $$OrdersTableReferences._barcodeReadsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$OrdersTableReferences(db, table, p0)
                                .barcodeReadsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.orderId == item.id),
                        typedResults: items),
                  if (deliveriesRefs)
                    await $_getPrefetchedData<Order, $OrdersTable, Delivery>(
                        currentTable: table,
                        referencedTable:
                            $$OrdersTableReferences._deliveriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$OrdersTableReferences(db, table, p0)
                                .deliveriesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.orderId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$OrdersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OrdersTable,
    Order,
    $$OrdersTableFilterComposer,
    $$OrdersTableOrderingComposer,
    $$OrdersTableAnnotationComposer,
    $$OrdersTableCreateCompanionBuilder,
    $$OrdersTableUpdateCompanionBuilder,
    (Order, $$OrdersTableReferences),
    Order,
    PrefetchHooks Function(
        {bool orderItemsRefs, bool barcodeReadsRefs, bool deliveriesRefs})>;
typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  Value<int> id,
  required String ourProductCode,
  required String name,
  Value<bool> isUniqueBarcodeRequired,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<int> id,
  Value<String> ourProductCode,
  Value<String> name,
  Value<bool> isUniqueBarcodeRequired,
});

final class $$ProductsTableReferences
    extends BaseReferences<_$AppDatabase, $ProductsTable, Product> {
  $$ProductsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$OrderItemsTable, List<OrderItem>>
      _orderItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.orderItems,
          aliasName:
              $_aliasNameGenerator(db.products.id, db.orderItems.productId));

  $$OrderItemsTableProcessedTableManager get orderItemsRefs {
    final manager = $$OrderItemsTableTableManager($_db, $_db.orderItems)
        .filter((f) => f.productId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_orderItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ProductCodeMappingsTable,
      List<ProductCodeMapping>> _productCodeMappingsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.productCodeMappings,
          aliasName: $_aliasNameGenerator(
              db.products.id, db.productCodeMappings.productId));

  $$ProductCodeMappingsTableProcessedTableManager get productCodeMappingsRefs {
    final manager =
        $$ProductCodeMappingsTableTableManager($_db, $_db.productCodeMappings)
            .filter((f) => f.productId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_productCodeMappingsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$BarcodeReadsTable, List<BarcodeRead>>
      _barcodeReadsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.barcodeReads,
          aliasName:
              $_aliasNameGenerator(db.products.id, db.barcodeReads.productId));

  $$BarcodeReadsTableProcessedTableManager get barcodeReadsRefs {
    final manager = $$BarcodeReadsTableTableManager($_db, $_db.barcodeReads)
        .filter((f) => f.productId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_barcodeReadsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DeliveryItemsTable, List<DeliveryItem>>
      _deliveryItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.deliveryItems,
              aliasName: $_aliasNameGenerator(
                  db.products.id, db.deliveryItems.productId));

  $$DeliveryItemsTableProcessedTableManager get deliveryItemsRefs {
    final manager = $$DeliveryItemsTableTableManager($_db, $_db.deliveryItems)
        .filter((f) => f.productId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_deliveryItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ourProductCode => $composableBuilder(
      column: $table.ourProductCode,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isUniqueBarcodeRequired => $composableBuilder(
      column: $table.isUniqueBarcodeRequired,
      builder: (column) => ColumnFilters(column));

  Expression<bool> orderItemsRefs(
      Expression<bool> Function($$OrderItemsTableFilterComposer f) f) {
    final $$OrderItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.orderItems,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderItemsTableFilterComposer(
              $db: $db,
              $table: $db.orderItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> productCodeMappingsRefs(
      Expression<bool> Function($$ProductCodeMappingsTableFilterComposer f) f) {
    final $$ProductCodeMappingsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.productCodeMappings,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductCodeMappingsTableFilterComposer(
              $db: $db,
              $table: $db.productCodeMappings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> barcodeReadsRefs(
      Expression<bool> Function($$BarcodeReadsTableFilterComposer f) f) {
    final $$BarcodeReadsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.barcodeReads,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BarcodeReadsTableFilterComposer(
              $db: $db,
              $table: $db.barcodeReads,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> deliveryItemsRefs(
      Expression<bool> Function($$DeliveryItemsTableFilterComposer f) f) {
    final $$DeliveryItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.deliveryItems,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeliveryItemsTableFilterComposer(
              $db: $db,
              $table: $db.deliveryItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ourProductCode => $composableBuilder(
      column: $table.ourProductCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isUniqueBarcodeRequired => $composableBuilder(
      column: $table.isUniqueBarcodeRequired,
      builder: (column) => ColumnOrderings(column));
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ourProductCode => $composableBuilder(
      column: $table.ourProductCode, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isUniqueBarcodeRequired => $composableBuilder(
      column: $table.isUniqueBarcodeRequired, builder: (column) => column);

  Expression<T> orderItemsRefs<T extends Object>(
      Expression<T> Function($$OrderItemsTableAnnotationComposer a) f) {
    final $$OrderItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.orderItems,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.orderItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> productCodeMappingsRefs<T extends Object>(
      Expression<T> Function($$ProductCodeMappingsTableAnnotationComposer a)
          f) {
    final $$ProductCodeMappingsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.productCodeMappings,
            getReferencedColumn: (t) => t.productId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ProductCodeMappingsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.productCodeMappings,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> barcodeReadsRefs<T extends Object>(
      Expression<T> Function($$BarcodeReadsTableAnnotationComposer a) f) {
    final $$BarcodeReadsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.barcodeReads,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BarcodeReadsTableAnnotationComposer(
              $db: $db,
              $table: $db.barcodeReads,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> deliveryItemsRefs<T extends Object>(
      Expression<T> Function($$DeliveryItemsTableAnnotationComposer a) f) {
    final $$DeliveryItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.deliveryItems,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeliveryItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.deliveryItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProductsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (Product, $$ProductsTableReferences),
    Product,
    PrefetchHooks Function(
        {bool orderItemsRefs,
        bool productCodeMappingsRefs,
        bool barcodeReadsRefs,
        bool deliveryItemsRefs})> {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> ourProductCode = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<bool> isUniqueBarcodeRequired = const Value.absent(),
          }) =>
              ProductsCompanion(
            id: id,
            ourProductCode: ourProductCode,
            name: name,
            isUniqueBarcodeRequired: isUniqueBarcodeRequired,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String ourProductCode,
            required String name,
            Value<bool> isUniqueBarcodeRequired = const Value.absent(),
          }) =>
              ProductsCompanion.insert(
            id: id,
            ourProductCode: ourProductCode,
            name: name,
            isUniqueBarcodeRequired: isUniqueBarcodeRequired,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ProductsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {orderItemsRefs = false,
              productCodeMappingsRefs = false,
              barcodeReadsRefs = false,
              deliveryItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (orderItemsRefs) db.orderItems,
                if (productCodeMappingsRefs) db.productCodeMappings,
                if (barcodeReadsRefs) db.barcodeReads,
                if (deliveryItemsRefs) db.deliveryItems
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (orderItemsRefs)
                    await $_getPrefetchedData<Product, $ProductsTable,
                            OrderItem>(
                        currentTable: table,
                        referencedTable:
                            $$ProductsTableReferences._orderItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductsTableReferences(db, table, p0)
                                .orderItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productId == item.id),
                        typedResults: items),
                  if (productCodeMappingsRefs)
                    await $_getPrefetchedData<Product, $ProductsTable,
                            ProductCodeMapping>(
                        currentTable: table,
                        referencedTable: $$ProductsTableReferences
                            ._productCodeMappingsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductsTableReferences(db, table, p0)
                                .productCodeMappingsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productId == item.id),
                        typedResults: items),
                  if (barcodeReadsRefs)
                    await $_getPrefetchedData<Product, $ProductsTable,
                            BarcodeRead>(
                        currentTable: table,
                        referencedTable: $$ProductsTableReferences
                            ._barcodeReadsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductsTableReferences(db, table, p0)
                                .barcodeReadsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productId == item.id),
                        typedResults: items),
                  if (deliveryItemsRefs)
                    await $_getPrefetchedData<Product, $ProductsTable,
                            DeliveryItem>(
                        currentTable: table,
                        referencedTable: $$ProductsTableReferences
                            ._deliveryItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductsTableReferences(db, table, p0)
                                .deliveryItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProductsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (Product, $$ProductsTableReferences),
    Product,
    PrefetchHooks Function(
        {bool orderItemsRefs,
        bool productCodeMappingsRefs,
        bool barcodeReadsRefs,
        bool deliveryItemsRefs})>;
typedef $$OrderItemsTableCreateCompanionBuilder = OrderItemsCompanion Function({
  Value<int> id,
  required int orderId,
  required int productId,
  required int quantity,
  Value<int> scannedQuantity,
});
typedef $$OrderItemsTableUpdateCompanionBuilder = OrderItemsCompanion Function({
  Value<int> id,
  Value<int> orderId,
  Value<int> productId,
  Value<int> quantity,
  Value<int> scannedQuantity,
});

final class $$OrderItemsTableReferences
    extends BaseReferences<_$AppDatabase, $OrderItemsTable, OrderItem> {
  $$OrderItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OrdersTable _orderIdTable(_$AppDatabase db) => db.orders
      .createAlias($_aliasNameGenerator(db.orderItems.orderId, db.orders.id));

  $$OrdersTableProcessedTableManager get orderId {
    final $_column = $_itemColumn<int>('order_id')!;

    final manager = $$OrdersTableTableManager($_db, $_db.orders)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias(
          $_aliasNameGenerator(db.orderItems.productId, db.products.id));

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<int>('product_id')!;

    final manager = $$ProductsTableTableManager($_db, $_db.products)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$OrderItemsTableFilterComposer
    extends Composer<_$AppDatabase, $OrderItemsTable> {
  $$OrderItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get scannedQuantity => $composableBuilder(
      column: $table.scannedQuantity,
      builder: (column) => ColumnFilters(column));

  $$OrdersTableFilterComposer get orderId {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderId,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableFilterComposer(
              $db: $db,
              $table: $db.orders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableFilterComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$OrderItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderItemsTable> {
  $$OrderItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get scannedQuantity => $composableBuilder(
      column: $table.scannedQuantity,
      builder: (column) => ColumnOrderings(column));

  $$OrdersTableOrderingComposer get orderId {
    final $$OrdersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderId,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableOrderingComposer(
              $db: $db,
              $table: $db.orders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableOrderingComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$OrderItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderItemsTable> {
  $$OrderItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get scannedQuantity => $composableBuilder(
      column: $table.scannedQuantity, builder: (column) => column);

  $$OrdersTableAnnotationComposer get orderId {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderId,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableAnnotationComposer(
              $db: $db,
              $table: $db.orders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableAnnotationComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$OrderItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrderItemsTable,
    OrderItem,
    $$OrderItemsTableFilterComposer,
    $$OrderItemsTableOrderingComposer,
    $$OrderItemsTableAnnotationComposer,
    $$OrderItemsTableCreateCompanionBuilder,
    $$OrderItemsTableUpdateCompanionBuilder,
    (OrderItem, $$OrderItemsTableReferences),
    OrderItem,
    PrefetchHooks Function({bool orderId, bool productId})> {
  $$OrderItemsTableTableManager(_$AppDatabase db, $OrderItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> orderId = const Value.absent(),
            Value<int> productId = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<int> scannedQuantity = const Value.absent(),
          }) =>
              OrderItemsCompanion(
            id: id,
            orderId: orderId,
            productId: productId,
            quantity: quantity,
            scannedQuantity: scannedQuantity,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int orderId,
            required int productId,
            required int quantity,
            Value<int> scannedQuantity = const Value.absent(),
          }) =>
              OrderItemsCompanion.insert(
            id: id,
            orderId: orderId,
            productId: productId,
            quantity: quantity,
            scannedQuantity: scannedQuantity,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$OrderItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({orderId = false, productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (orderId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.orderId,
                    referencedTable:
                        $$OrderItemsTableReferences._orderIdTable(db),
                    referencedColumn:
                        $$OrderItemsTableReferences._orderIdTable(db).id,
                  ) as T;
                }
                if (productId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productId,
                    referencedTable:
                        $$OrderItemsTableReferences._productIdTable(db),
                    referencedColumn:
                        $$OrderItemsTableReferences._productIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$OrderItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OrderItemsTable,
    OrderItem,
    $$OrderItemsTableFilterComposer,
    $$OrderItemsTableOrderingComposer,
    $$OrderItemsTableAnnotationComposer,
    $$OrderItemsTableCreateCompanionBuilder,
    $$OrderItemsTableUpdateCompanionBuilder,
    (OrderItem, $$OrderItemsTableReferences),
    OrderItem,
    PrefetchHooks Function({bool orderId, bool productId})>;
typedef $$ProductCodeMappingsTableCreateCompanionBuilder
    = ProductCodeMappingsCompanion Function({
  Value<int> id,
  required String customerProductCode,
  required int productId,
  required String customerName,
});
typedef $$ProductCodeMappingsTableUpdateCompanionBuilder
    = ProductCodeMappingsCompanion Function({
  Value<int> id,
  Value<String> customerProductCode,
  Value<int> productId,
  Value<String> customerName,
});

final class $$ProductCodeMappingsTableReferences extends BaseReferences<
    _$AppDatabase, $ProductCodeMappingsTable, ProductCodeMapping> {
  $$ProductCodeMappingsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias($_aliasNameGenerator(
          db.productCodeMappings.productId, db.products.id));

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<int>('product_id')!;

    final manager = $$ProductsTableTableManager($_db, $_db.products)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ProductCodeMappingsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductCodeMappingsTable> {
  $$ProductCodeMappingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerProductCode => $composableBuilder(
      column: $table.customerProductCode,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => ColumnFilters(column));

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableFilterComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProductCodeMappingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductCodeMappingsTable> {
  $$ProductCodeMappingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerProductCode => $composableBuilder(
      column: $table.customerProductCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerName => $composableBuilder(
      column: $table.customerName,
      builder: (column) => ColumnOrderings(column));

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableOrderingComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProductCodeMappingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductCodeMappingsTable> {
  $$ProductCodeMappingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerProductCode => $composableBuilder(
      column: $table.customerProductCode, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableAnnotationComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProductCodeMappingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductCodeMappingsTable,
    ProductCodeMapping,
    $$ProductCodeMappingsTableFilterComposer,
    $$ProductCodeMappingsTableOrderingComposer,
    $$ProductCodeMappingsTableAnnotationComposer,
    $$ProductCodeMappingsTableCreateCompanionBuilder,
    $$ProductCodeMappingsTableUpdateCompanionBuilder,
    (ProductCodeMapping, $$ProductCodeMappingsTableReferences),
    ProductCodeMapping,
    PrefetchHooks Function({bool productId})> {
  $$ProductCodeMappingsTableTableManager(
      _$AppDatabase db, $ProductCodeMappingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductCodeMappingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductCodeMappingsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductCodeMappingsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> customerProductCode = const Value.absent(),
            Value<int> productId = const Value.absent(),
            Value<String> customerName = const Value.absent(),
          }) =>
              ProductCodeMappingsCompanion(
            id: id,
            customerProductCode: customerProductCode,
            productId: productId,
            customerName: customerName,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String customerProductCode,
            required int productId,
            required String customerName,
          }) =>
              ProductCodeMappingsCompanion.insert(
            id: id,
            customerProductCode: customerProductCode,
            productId: productId,
            customerName: customerName,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ProductCodeMappingsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (productId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productId,
                    referencedTable: $$ProductCodeMappingsTableReferences
                        ._productIdTable(db),
                    referencedColumn: $$ProductCodeMappingsTableReferences
                        ._productIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ProductCodeMappingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductCodeMappingsTable,
    ProductCodeMapping,
    $$ProductCodeMappingsTableFilterComposer,
    $$ProductCodeMappingsTableOrderingComposer,
    $$ProductCodeMappingsTableAnnotationComposer,
    $$ProductCodeMappingsTableCreateCompanionBuilder,
    $$ProductCodeMappingsTableUpdateCompanionBuilder,
    (ProductCodeMapping, $$ProductCodeMappingsTableReferences),
    ProductCodeMapping,
    PrefetchHooks Function({bool productId})>;
typedef $$BarcodeReadsTableCreateCompanionBuilder = BarcodeReadsCompanion
    Function({
  Value<int> id,
  required int orderId,
  Value<int?> productId,
  required String barcode,
  Value<DateTime> readAt,
});
typedef $$BarcodeReadsTableUpdateCompanionBuilder = BarcodeReadsCompanion
    Function({
  Value<int> id,
  Value<int> orderId,
  Value<int?> productId,
  Value<String> barcode,
  Value<DateTime> readAt,
});

final class $$BarcodeReadsTableReferences
    extends BaseReferences<_$AppDatabase, $BarcodeReadsTable, BarcodeRead> {
  $$BarcodeReadsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OrdersTable _orderIdTable(_$AppDatabase db) => db.orders
      .createAlias($_aliasNameGenerator(db.barcodeReads.orderId, db.orders.id));

  $$OrdersTableProcessedTableManager get orderId {
    final $_column = $_itemColumn<int>('order_id')!;

    final manager = $$OrdersTableTableManager($_db, $_db.orders)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias(
          $_aliasNameGenerator(db.barcodeReads.productId, db.products.id));

  $$ProductsTableProcessedTableManager? get productId {
    final $_column = $_itemColumn<int>('product_id');
    if ($_column == null) return null;
    final manager = $$ProductsTableTableManager($_db, $_db.products)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$BarcodeReadsTableFilterComposer
    extends Composer<_$AppDatabase, $BarcodeReadsTable> {
  $$BarcodeReadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get readAt => $composableBuilder(
      column: $table.readAt, builder: (column) => ColumnFilters(column));

  $$OrdersTableFilterComposer get orderId {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderId,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableFilterComposer(
              $db: $db,
              $table: $db.orders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableFilterComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BarcodeReadsTableOrderingComposer
    extends Composer<_$AppDatabase, $BarcodeReadsTable> {
  $$BarcodeReadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
      column: $table.readAt, builder: (column) => ColumnOrderings(column));

  $$OrdersTableOrderingComposer get orderId {
    final $$OrdersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderId,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableOrderingComposer(
              $db: $db,
              $table: $db.orders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableOrderingComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BarcodeReadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BarcodeReadsTable> {
  $$BarcodeReadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  $$OrdersTableAnnotationComposer get orderId {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderId,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableAnnotationComposer(
              $db: $db,
              $table: $db.orders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableAnnotationComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BarcodeReadsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BarcodeReadsTable,
    BarcodeRead,
    $$BarcodeReadsTableFilterComposer,
    $$BarcodeReadsTableOrderingComposer,
    $$BarcodeReadsTableAnnotationComposer,
    $$BarcodeReadsTableCreateCompanionBuilder,
    $$BarcodeReadsTableUpdateCompanionBuilder,
    (BarcodeRead, $$BarcodeReadsTableReferences),
    BarcodeRead,
    PrefetchHooks Function({bool orderId, bool productId})> {
  $$BarcodeReadsTableTableManager(_$AppDatabase db, $BarcodeReadsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BarcodeReadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BarcodeReadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BarcodeReadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> orderId = const Value.absent(),
            Value<int?> productId = const Value.absent(),
            Value<String> barcode = const Value.absent(),
            Value<DateTime> readAt = const Value.absent(),
          }) =>
              BarcodeReadsCompanion(
            id: id,
            orderId: orderId,
            productId: productId,
            barcode: barcode,
            readAt: readAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int orderId,
            Value<int?> productId = const Value.absent(),
            required String barcode,
            Value<DateTime> readAt = const Value.absent(),
          }) =>
              BarcodeReadsCompanion.insert(
            id: id,
            orderId: orderId,
            productId: productId,
            barcode: barcode,
            readAt: readAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BarcodeReadsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({orderId = false, productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (orderId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.orderId,
                    referencedTable:
                        $$BarcodeReadsTableReferences._orderIdTable(db),
                    referencedColumn:
                        $$BarcodeReadsTableReferences._orderIdTable(db).id,
                  ) as T;
                }
                if (productId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productId,
                    referencedTable:
                        $$BarcodeReadsTableReferences._productIdTable(db),
                    referencedColumn:
                        $$BarcodeReadsTableReferences._productIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$BarcodeReadsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BarcodeReadsTable,
    BarcodeRead,
    $$BarcodeReadsTableFilterComposer,
    $$BarcodeReadsTableOrderingComposer,
    $$BarcodeReadsTableAnnotationComposer,
    $$BarcodeReadsTableCreateCompanionBuilder,
    $$BarcodeReadsTableUpdateCompanionBuilder,
    (BarcodeRead, $$BarcodeReadsTableReferences),
    BarcodeRead,
    PrefetchHooks Function({bool orderId, bool productId})>;
typedef $$DeliveriesTableCreateCompanionBuilder = DeliveriesCompanion Function({
  Value<int> id,
  required int orderId,
  Value<DateTime> deliveryDate,
});
typedef $$DeliveriesTableUpdateCompanionBuilder = DeliveriesCompanion Function({
  Value<int> id,
  Value<int> orderId,
  Value<DateTime> deliveryDate,
});

final class $$DeliveriesTableReferences
    extends BaseReferences<_$AppDatabase, $DeliveriesTable, Delivery> {
  $$DeliveriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OrdersTable _orderIdTable(_$AppDatabase db) => db.orders
      .createAlias($_aliasNameGenerator(db.deliveries.orderId, db.orders.id));

  $$OrdersTableProcessedTableManager get orderId {
    final $_column = $_itemColumn<int>('order_id')!;

    final manager = $$OrdersTableTableManager($_db, $_db.orders)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$DeliveryItemsTable, List<DeliveryItem>>
      _deliveryItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.deliveryItems,
              aliasName: $_aliasNameGenerator(
                  db.deliveries.id, db.deliveryItems.deliveryId));

  $$DeliveryItemsTableProcessedTableManager get deliveryItemsRefs {
    final manager = $$DeliveryItemsTableTableManager($_db, $_db.deliveryItems)
        .filter((f) => f.deliveryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_deliveryItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DeliveriesTableFilterComposer
    extends Composer<_$AppDatabase, $DeliveriesTable> {
  $$DeliveriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deliveryDate => $composableBuilder(
      column: $table.deliveryDate, builder: (column) => ColumnFilters(column));

  $$OrdersTableFilterComposer get orderId {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderId,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableFilterComposer(
              $db: $db,
              $table: $db.orders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> deliveryItemsRefs(
      Expression<bool> Function($$DeliveryItemsTableFilterComposer f) f) {
    final $$DeliveryItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.deliveryItems,
        getReferencedColumn: (t) => t.deliveryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeliveryItemsTableFilterComposer(
              $db: $db,
              $table: $db.deliveryItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DeliveriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DeliveriesTable> {
  $$DeliveriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deliveryDate => $composableBuilder(
      column: $table.deliveryDate,
      builder: (column) => ColumnOrderings(column));

  $$OrdersTableOrderingComposer get orderId {
    final $$OrdersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderId,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableOrderingComposer(
              $db: $db,
              $table: $db.orders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DeliveriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeliveriesTable> {
  $$DeliveriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get deliveryDate => $composableBuilder(
      column: $table.deliveryDate, builder: (column) => column);

  $$OrdersTableAnnotationComposer get orderId {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderId,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableAnnotationComposer(
              $db: $db,
              $table: $db.orders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> deliveryItemsRefs<T extends Object>(
      Expression<T> Function($$DeliveryItemsTableAnnotationComposer a) f) {
    final $$DeliveryItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.deliveryItems,
        getReferencedColumn: (t) => t.deliveryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeliveryItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.deliveryItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DeliveriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DeliveriesTable,
    Delivery,
    $$DeliveriesTableFilterComposer,
    $$DeliveriesTableOrderingComposer,
    $$DeliveriesTableAnnotationComposer,
    $$DeliveriesTableCreateCompanionBuilder,
    $$DeliveriesTableUpdateCompanionBuilder,
    (Delivery, $$DeliveriesTableReferences),
    Delivery,
    PrefetchHooks Function({bool orderId, bool deliveryItemsRefs})> {
  $$DeliveriesTableTableManager(_$AppDatabase db, $DeliveriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeliveriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeliveriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeliveriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> orderId = const Value.absent(),
            Value<DateTime> deliveryDate = const Value.absent(),
          }) =>
              DeliveriesCompanion(
            id: id,
            orderId: orderId,
            deliveryDate: deliveryDate,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int orderId,
            Value<DateTime> deliveryDate = const Value.absent(),
          }) =>
              DeliveriesCompanion.insert(
            id: id,
            orderId: orderId,
            deliveryDate: deliveryDate,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DeliveriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {orderId = false, deliveryItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (deliveryItemsRefs) db.deliveryItems
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (orderId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.orderId,
                    referencedTable:
                        $$DeliveriesTableReferences._orderIdTable(db),
                    referencedColumn:
                        $$DeliveriesTableReferences._orderIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (deliveryItemsRefs)
                    await $_getPrefetchedData<Delivery, $DeliveriesTable,
                            DeliveryItem>(
                        currentTable: table,
                        referencedTable: $$DeliveriesTableReferences
                            ._deliveryItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DeliveriesTableReferences(db, table, p0)
                                .deliveryItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.deliveryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DeliveriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DeliveriesTable,
    Delivery,
    $$DeliveriesTableFilterComposer,
    $$DeliveriesTableOrderingComposer,
    $$DeliveriesTableAnnotationComposer,
    $$DeliveriesTableCreateCompanionBuilder,
    $$DeliveriesTableUpdateCompanionBuilder,
    (Delivery, $$DeliveriesTableReferences),
    Delivery,
    PrefetchHooks Function({bool orderId, bool deliveryItemsRefs})>;
typedef $$DeliveryItemsTableCreateCompanionBuilder = DeliveryItemsCompanion
    Function({
  Value<int> id,
  required int deliveryId,
  required int productId,
  required int quantity,
});
typedef $$DeliveryItemsTableUpdateCompanionBuilder = DeliveryItemsCompanion
    Function({
  Value<int> id,
  Value<int> deliveryId,
  Value<int> productId,
  Value<int> quantity,
});

final class $$DeliveryItemsTableReferences
    extends BaseReferences<_$AppDatabase, $DeliveryItemsTable, DeliveryItem> {
  $$DeliveryItemsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $DeliveriesTable _deliveryIdTable(_$AppDatabase db) =>
      db.deliveries.createAlias(
          $_aliasNameGenerator(db.deliveryItems.deliveryId, db.deliveries.id));

  $$DeliveriesTableProcessedTableManager get deliveryId {
    final $_column = $_itemColumn<int>('delivery_id')!;

    final manager = $$DeliveriesTableTableManager($_db, $_db.deliveries)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deliveryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias(
          $_aliasNameGenerator(db.deliveryItems.productId, db.products.id));

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<int>('product_id')!;

    final manager = $$ProductsTableTableManager($_db, $_db.products)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DeliveryItemsTableFilterComposer
    extends Composer<_$AppDatabase, $DeliveryItemsTable> {
  $$DeliveryItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  $$DeliveriesTableFilterComposer get deliveryId {
    final $$DeliveriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deliveryId,
        referencedTable: $db.deliveries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeliveriesTableFilterComposer(
              $db: $db,
              $table: $db.deliveries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableFilterComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DeliveryItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $DeliveryItemsTable> {
  $$DeliveryItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  $$DeliveriesTableOrderingComposer get deliveryId {
    final $$DeliveriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deliveryId,
        referencedTable: $db.deliveries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeliveriesTableOrderingComposer(
              $db: $db,
              $table: $db.deliveries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableOrderingComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DeliveryItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeliveryItemsTable> {
  $$DeliveryItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  $$DeliveriesTableAnnotationComposer get deliveryId {
    final $$DeliveriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deliveryId,
        referencedTable: $db.deliveries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeliveriesTableAnnotationComposer(
              $db: $db,
              $table: $db.deliveries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableAnnotationComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DeliveryItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DeliveryItemsTable,
    DeliveryItem,
    $$DeliveryItemsTableFilterComposer,
    $$DeliveryItemsTableOrderingComposer,
    $$DeliveryItemsTableAnnotationComposer,
    $$DeliveryItemsTableCreateCompanionBuilder,
    $$DeliveryItemsTableUpdateCompanionBuilder,
    (DeliveryItem, $$DeliveryItemsTableReferences),
    DeliveryItem,
    PrefetchHooks Function({bool deliveryId, bool productId})> {
  $$DeliveryItemsTableTableManager(_$AppDatabase db, $DeliveryItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeliveryItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeliveryItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeliveryItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> deliveryId = const Value.absent(),
            Value<int> productId = const Value.absent(),
            Value<int> quantity = const Value.absent(),
          }) =>
              DeliveryItemsCompanion(
            id: id,
            deliveryId: deliveryId,
            productId: productId,
            quantity: quantity,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int deliveryId,
            required int productId,
            required int quantity,
          }) =>
              DeliveryItemsCompanion.insert(
            id: id,
            deliveryId: deliveryId,
            productId: productId,
            quantity: quantity,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DeliveryItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({deliveryId = false, productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (deliveryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.deliveryId,
                    referencedTable:
                        $$DeliveryItemsTableReferences._deliveryIdTable(db),
                    referencedColumn:
                        $$DeliveryItemsTableReferences._deliveryIdTable(db).id,
                  ) as T;
                }
                if (productId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productId,
                    referencedTable:
                        $$DeliveryItemsTableReferences._productIdTable(db),
                    referencedColumn:
                        $$DeliveryItemsTableReferences._productIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$DeliveryItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DeliveryItemsTable,
    DeliveryItem,
    $$DeliveryItemsTableFilterComposer,
    $$DeliveryItemsTableOrderingComposer,
    $$DeliveryItemsTableAnnotationComposer,
    $$DeliveryItemsTableCreateCompanionBuilder,
    $$DeliveryItemsTableUpdateCompanionBuilder,
    (DeliveryItem, $$DeliveryItemsTableReferences),
    DeliveryItem,
    PrefetchHooks Function({bool deliveryId, bool productId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db, _db.orders);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$OrderItemsTableTableManager get orderItems =>
      $$OrderItemsTableTableManager(_db, _db.orderItems);
  $$ProductCodeMappingsTableTableManager get productCodeMappings =>
      $$ProductCodeMappingsTableTableManager(_db, _db.productCodeMappings);
  $$BarcodeReadsTableTableManager get barcodeReads =>
      $$BarcodeReadsTableTableManager(_db, _db.barcodeReads);
  $$DeliveriesTableTableManager get deliveries =>
      $$DeliveriesTableTableManager(_db, _db.deliveries);
  $$DeliveryItemsTableTableManager get deliveryItems =>
      $$DeliveryItemsTableTableManager(_db, _db.deliveryItems);
}
