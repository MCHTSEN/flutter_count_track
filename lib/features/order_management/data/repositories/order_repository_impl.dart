import 'package:drift/drift.dart';
import 'package:flutter_count_track/core/database/app_database.dart';
import 'package:flutter_count_track/core/services/supabase_service.dart';
import 'package:flutter_count_track/features/order_management/data/models/order.dart'
    as model_order;
import 'package:flutter_count_track/features/order_management/data/models/order_item.dart'
    as model_order_item;
import 'package:flutter_count_track/features/order_management/domain/repositories/order_repository.dart';
import 'package:logging/logging.dart';

class OrderRepositoryImpl implements OrderRepository {
  final AppDatabase _db;
  late final SupabaseSyncService? _syncService;
  static final Logger _logger = Logger('OrderRepositoryImpl');

  OrderRepositoryImpl(this._db, [SupabaseSyncService? syncService]) {
    _syncService = syncService;
    _logger.info('OrderRepositoryImpl oluşturuldu');
  }

  @override
  Future<List<Order>> getOrders({
    String? searchQuery,
    OrderStatus? filterStatus,
  }) async {
    _logger.info(
        '📖 Siparişler getiriliyor - Arama: $searchQuery, Durum: $filterStatus');

    // Önce lokal verileri al (offline-first)
    var query = _db.select(_db.orders);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query
        ..where((o) =>
            o.orderCode.contains(searchQuery) |
            o.customerName.contains(searchQuery));
    }
    if (filterStatus != null) {
      query = query..where((o) => o.status.equals(filterStatus.name));
    }
    query = query
      ..orderBy([
        (o) => OrderingTerm(expression: o.createdAt, mode: OrderingMode.desc)
      ]);

    final localOrders = await query.get();
    _logger.info('📖 ${localOrders.length} sipariş local database\'den alındı');

    // Eğer online ise ve sync service varsa, arka planda Supabase'den güncellemeleri al
    if (SupabaseService.isOnline && _syncService != null) {
      _logger.info('🔄 Online - Arka planda Supabase sync\'i başlatılıyor');
      _syncOrdersInBackground(searchQuery, filterStatus);
    }

    return localOrders;
  }

  /// Arka planda Supabase'den siparişleri sync eder
  Future<void> _syncOrdersInBackground(
      String? searchQuery, OrderStatus? filterStatus) async {
    try {
      _logger.info('🔄 Arka plan sync başlatıldı');

      if (_syncService == null) {
        _logger.warning('⚠️ Sync service mevcut değil');
        return;
      }

      // Supabase'den siparişleri çek
      final remoteOrders = await _syncService.fetchOrdersFromSupabase(
        searchQuery: searchQuery,
        status: filterStatus?.name,
      );

      // Her remote order için local ile karşılaştır ve gerekirse güncelle
      for (final remoteOrderData in remoteOrders) {
        await _syncSingleOrder(remoteOrderData);
      }

      _logger.info('✅ Arka plan sync tamamlandı');
    } catch (e, stackTrace) {
      _logger.severe('💥 Arka plan sync hatası', e, stackTrace);
    }
  }

  /// Tek bir siparişi sync eder
  Future<void> _syncSingleOrder(Map<String, dynamic> remoteOrderData) async {
    try {
      final orderCode = remoteOrderData['order_code'] as String;
      final localOrder = await getOrderById(orderCode);

      if (localOrder == null) {
        // Local'de yok, ekle
        _logger.info('📥 Yeni sipariş local\'e ekleniyor: $orderCode');
        await _insertOrderFromRemote(remoteOrderData);
      } else {
        // Local'de var, timestamp'leri karşılaştır
        final remoteUpdatedAt = DateTime.parse(remoteOrderData['updated_at']);
        if (remoteUpdatedAt.isAfter(localOrder.updatedAt)) {
          _logger.info(
              '🔄 Remote sipariş daha güncel, local güncelleniyor: $orderCode');
          await _updateOrderFromRemote(localOrder, remoteOrderData);
        }
      }
    } catch (e, stackTrace) {
      _logger.severe('💥 Tek sipariş sync hatası', e, stackTrace);
    }
  }

  /// Remote'dan gelen veriyi local'e ekler
  Future<void> _insertOrderFromRemote(
      Map<String, dynamic> remoteOrderData) async {
    final orderCompanion = OrdersCompanion(
      orderCode: Value(remoteOrderData['order_code']),
      customerName: Value(remoteOrderData['customer_name']),
      status: Value(_parseOrderStatus(remoteOrderData['status'])),
      createdAt: Value(DateTime.parse(remoteOrderData['created_at'])),
      updatedAt: Value(DateTime.parse(remoteOrderData['updated_at'])),
    );

    await _db.into(_db.orders).insert(orderCompanion);
  }

  /// Remote'dan gelen veri ile local order'ı günceller
  Future<void> _updateOrderFromRemote(
      Order localOrder, Map<String, dynamic> remoteOrderData) async {
    await (_db.update(_db.orders)..where((o) => o.id.equals(localOrder.id)))
        .write(OrdersCompanion(
      customerName: Value(remoteOrderData['customer_name']),
      status: Value(_parseOrderStatus(remoteOrderData['status'])),
      updatedAt: Value(DateTime.parse(remoteOrderData['updated_at'])),
    ));
  }

  /// String'den OrderStatus'e çevirir
  OrderStatus _parseOrderStatus(String statusString) {
    return OrderStatus.values.firstWhere(
      (status) => status.name == statusString,
      orElse: () => OrderStatus.pending,
    );
  }

  @override
  Future<Order?> getOrderById(String orderCode) async {
    return await (_db.select(_db.orders)
          ..where((o) => o.orderCode.equals(orderCode)))
        .getSingleOrNull();
  }

  @override
  Future<Order?> getOrderByCode(String orderCode) async {
    return await (_db.select(_db.orders)
          ..where((o) => o.orderCode.equals(orderCode)))
        .getSingleOrNull();
  }

  @override
  Future<int> createOrder(OrdersCompanion order) async {
    return await _db.into(_db.orders).insert(order);
  }

  @override
  Future<bool> updateOrder(Order order) async {
    return await _db.update(_db.orders).replace(order);
  }

  @override
  Future<bool> deleteOrder(String orderCode) async {
    final orderToDelete = await getOrderById(orderCode);
    if (orderToDelete == null) {
      return false;
    }
    await (_db.delete(_db.orderItems)
          ..where((oi) => oi.orderId.equals(orderToDelete.id)))
        .go();

    final deletedRows = await (_db.delete(_db.orders)
          ..where((o) => o.id.equals(orderToDelete.id)))
        .go();
    return deletedRows > 0;
  }

  @override
  Future<List<OrderItem>> getOrderItems(String orderCode) async {
    final order = await getOrderById(orderCode);
    if (order == null) {
      return [];
    }
    return await (_db.select(_db.orderItems)
          ..where((oi) => oi.orderId.equals(order.id)))
        .get();
  }

  @override
  Future<OrderItem?> getOrderItemById(String orderItemId) async {
    final itemId = int.tryParse(orderItemId);
    if (itemId == null) return null;

    return await (_db.select(_db.orderItems)
          ..where((oi) => oi.id.equals(itemId)))
        .getSingleOrNull();
  }

  @override
  Future<int> createOrderItem(OrderItemsCompanion orderItem) async {
    return await _db.into(_db.orderItems).insert(orderItem);
  }

  @override
  Future<bool> updateOrderItemScannedQuantity(
      String orderItemId, int newQuantity) async {
    _logger.info(
        '📝 Sipariş kalemi taranan miktar güncelleniyor - ID: $orderItemId, Miktar: $newQuantity');

    final itemId = int.tryParse(orderItemId);
    if (itemId == null) {
      _logger.severe(
          "💥 Hata: orderItemId '$orderItemId' geçerli bir integer değil");
      return false;
    }

    try {
      // Önce local'i güncelle (offline-first)
      final affectedRows = await (_db.update(_db.orderItems)
            ..where((oi) => oi.id.equals(itemId)))
          .write(OrderItemsCompanion(
        scannedQuantity: Value(newQuantity),
      ));

      if (affectedRows > 0) {
        _logger.info('✅ Local sipariş kalemi güncellendi - ID: $orderItemId');

        // Eğer online ise ve sync service varsa, Supabase'e de gönder
        if (SupabaseService.isOnline && _syncService != null) {
          _logger.info('📤 Supabase\'e barkod okuma gönderiliyor');
          _pushBarcodeReadToSupabase(orderItemId, newQuantity);
        } else {
          _logger.warning(
              '⚠️ Offline durumda - barkod okuma daha sonra sync edilecek');
          // TODO: Sync kuyruğuna ekle
        }

        return true;
      } else {
        _logger.warning(
            '⚠️ Hiçbir sipariş kalemi güncellenmedi - ID: $orderItemId');
        return false;
      }
    } catch (e, stackTrace) {
      _logger.severe('💥 Sipariş kalemi güncelleme hatası', e, stackTrace);
      return false;
    }
  }

  /// Barkod okuma verilerini Supabase'e gönderir (arka planda)
  Future<void> _pushBarcodeReadToSupabase(
      String orderItemId, int newQuantity) async {
    try {
      if (_syncService == null) {
        _logger.warning('⚠️ Sync service mevcut değil');
        return;
      }

      // Order item'ı bul
      final itemId = int.parse(orderItemId);
      final orderItem = await (_db.select(_db.orderItems)
            ..where((oi) => oi.id.equals(itemId)))
          .getSingleOrNull();

      if (orderItem == null) {
        _logger.warning('⚠️ Sipariş kalemi bulunamadı - ID: $orderItemId');
        return;
      }

      // Order'ı bul
      final order = await (_db.select(_db.orders)
            ..where((o) => o.id.equals(orderItem.orderId)))
          .getSingleOrNull();

      if (order == null) {
        _logger
            .warning('⚠️ Sipariş bulunamadı - Order ID: ${orderItem.orderId}');
        return;
      }

      // Product'ı bul (barcode için)
      final product = await (_db.select(_db.products)
            ..where((p) => p.id.equals(orderItem.productId)))
          .getSingleOrNull();

      // Supabase'e barkod okuma gönder
      await _syncService.pushBarcodeReadToSupabase(
        orderCode: order.orderCode,
        barcode: product?.barcode ?? 'UNKNOWN_BARCODE',
        productId: orderItem.productId,
        scannedQuantity: newQuantity,
      );

      _logger.info('✅ Barkod okuma Supabase\'e gönderildi');
    } catch (e, stackTrace) {
      _logger.severe('💥 Supabase barkod okuma gönderme hatası', e, stackTrace);
    }
  }

  @override
  Future<List<Order>> searchOrders({
    String? orderCode,
    String? customerName,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = _db.select(_db.orders);

    if (orderCode != null) {
      query = query..where((o) => o.orderCode.contains(orderCode));
    }
    if (customerName != null) {
      query = query..where((o) => o.customerName.contains(customerName));
    }
    if (status != null) {
      query = query..where((o) => o.status.equals(status.name));
    }
    if (startDate != null) {
      query = query..where((o) => o.createdAt.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query = query..where((o) => o.createdAt.isSmallerOrEqualValue(endDate));
    }

    return await query.get();
  }

  @override
  Future<bool> updateOrderStatus(
      String orderCode, OrderStatus newStatus) async {
    final orderToUpdate = await getOrderById(orderCode);
    if (orderToUpdate == null) {
      return false;
    }
    final affectedRows = await (_db.update(_db.orders)
          ..where((o) => o.id.equals(orderToUpdate.id)))
        .write(OrdersCompanion(
      status: Value(newStatus),
      updatedAt: Value(DateTime.now()),
    ));
    return affectedRows > 0;
  }

  @override
  Future<Map<String, dynamic>> getOrderSummary(String orderCode) async {
    final order = await getOrderById(orderCode);
    if (order == null) {
      return {'error': 'Order not found'};
    }
    final items = await getOrderItems(orderCode);

    int totalQuantity = 0;
    int totalScannedQuantity = 0;

    for (var item in items) {
      totalQuantity += item.quantity;
      totalScannedQuantity += item.scannedQuantity;
    }

    return {
      'order': order,
      'items': items,
      'totalQuantity': totalQuantity,
      'totalScannedQuantity': totalScannedQuantity,
      'progress': totalQuantity == 0
          ? 0.0
          : totalScannedQuantity / totalQuantity.toDouble(),
    };
  }

  @override
  Stream<List<Order>> watchAllOrders() {
    return (_db.select(_db.orders)
          ..orderBy([
            (o) =>
                OrderingTerm(expression: o.createdAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  @override
  Stream<Order> watchOrderById(int id) {
    return (_db.select(_db.orders)..where((o) => o.id.equals(id)))
        .watchSingle();
  }

  @override
  Stream<List<OrderItem>> watchOrderItems(int orderId) {
    return (_db.select(_db.orderItems)
          ..where((oi) => oi.orderId.equals(orderId)))
        .watch();
  }

  @override
  Future<void> createOrderWithItems({
    required model_order.Order orderData,
    required List<model_order_item.OrderItem> itemsData,
    required List<String> customerProductCodes,
  }) async {
    await _db.transaction(() async {
      final existingOrderQuery = _db.select(_db.orders)
        ..where((o) => o.orderCode.equals(orderData.orderCode));
      final existingOrder = await existingOrderQuery.getSingleOrNull();

      if (existingOrder != null) {
        throw Exception(
            'Sipariş kodu "${orderData.orderCode}" ile zaten bir sipariş mevcut.');
      }

      final newOrderId = await _db.into(_db.orders).insert(
            OrdersCompanion(
              orderCode: Value(orderData.orderCode),
              customerName: Value(orderData.customerName),
              status: Value(orderData.status ?? OrderStatus.pending),
              createdAt: Value(orderData.createdAt ?? DateTime.now()),
              updatedAt: Value(DateTime.now()),
            ),
          );

      for (var i = 0; i < itemsData.length; i++) {
        final item = itemsData[i];
        int mappedProductId = item.productId ?? 0;

        await _db.into(_db.orderItems).insert(
              OrderItemsCompanion(
                orderId: Value(newOrderId),
                productId: Value(mappedProductId),
                quantity: Value(item.quantity),
                scannedQuantity: Value(item.scannedQuantity ?? 0),
              ),
            );
      }
    });
  }

  @override
  Future<void> importOrdersFromExcel(String filePath) async {
    print(
        "OrderRepositoryImpl: importOrdersFromExcel called with $filePath. Actual Excel parsing and data transformation to be handled by a service.");
    throw UnimplementedError(
        "Excel import logic needs to be implemented in a service layer calling repository methods.");
  }

  @override
  Future<Product?> getProductById(int productId) async {
    return await (_db.select(_db.products)
          ..where((p) => p.id.equals(productId)))
        .getSingleOrNull();
  }

  @override
  Future<ProductCodeMapping?> getProductCodeMapping(
      int productId, String customerName) async {
    return await (_db.select(_db.productCodeMappings)
          ..where((pcm) => pcm.productId.equals(productId))
          ..where((pcm) => pcm.customerName.equals(customerName)))
        .getSingleOrNull();
  }

  @override
  Future<List<ProductCodeMapping>> getProductCodeMappings(int productId) async {
    return await (_db.select(_db.productCodeMappings)
          ..where((pcm) => pcm.productId.equals(productId)))
        .get();
  }

  @override
  Future<List<BarcodeRead>> getBarcodeHistory(String orderCode,
      {int? limit}) async {
    final order = await getOrderById(orderCode);
    if (order == null) return [];

    final query = _db.select(_db.barcodeReads)
      ..where((b) => b.orderId.equals(order.id))
      ..orderBy(
          [(b) => OrderingTerm(expression: b.readAt, mode: OrderingMode.desc)]);

    if (limit != null) {
      query.limit(limit);
    }

    return await query.get();
  }

  @override
  Future<List<Map<String, dynamic>>> getBoxContents(String orderCode) async {
    final order = await getOrderById(orderCode);
    if (order == null) return [];

    final barcodeReads = await (_db.select(_db.barcodeReads)
          ..where((b) => b.orderId.equals(order.id))
          ..where((b) => b.productId.isNotNull()))
        .get();

    if (barcodeReads.isEmpty) return [];

    final allProducts = await (_db.select(_db.products)).get();
    final productMap = {for (var p in allProducts) p.id: p};

    final Map<int, Map<int, Map<String, dynamic>>> groupedByBox = {};

    for (var read in barcodeReads) {
      final boxNum = read.boxNumber;
      final prodId = read.productId;
      if (boxNum == null || prodId == null) continue;

      final product = productMap[prodId];
      if (product == null) continue;

      groupedByBox.putIfAbsent(boxNum, () => {});
      final boxContent = groupedByBox[boxNum]!;

      boxContent.putIfAbsent(
          prodId,
          () => {
                'productId': prodId,
                'productCode': product.ourProductCode,
                'productName': product.name,
                'barcode': product.barcode,
                'quantity': 0,
                'timestamps': <DateTime>[],
              });

      final productEntry = boxContent[prodId]!;
      productEntry['quantity'] = (productEntry['quantity'] as int) + 1;
      (productEntry['timestamps'] as List<DateTime>).add(read.readAt);
    }

    final List<Map<String, dynamic>> result = [];
    groupedByBox.forEach((boxNumber, contents) {
      final contentList = contents.values.toList();
      for (var item in contentList) {
        (item['timestamps'] as List<DateTime>).sort((a, b) => b.compareTo(a));
        item['timestamp'] = (item['timestamps'] as List<DateTime>).first;
      }

      contentList.sort((a, b) =>
          (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));

      result.add({
        'boxNumber': boxNumber,
        'contents': contentList,
      });
    });

    result.sort((a, b) => (a['boxNumber'] as int).compareTo(b['boxNumber']));

    return result;
  }
}
