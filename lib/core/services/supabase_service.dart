import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_count_track/core/database/app_database.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Arkaplanda işlenecek barkod güncellemesi
class BarcodeUpdate {
  final String orderCode;
  final String barcode;
  final int? productId;
  final int scannedQuantity;
  final DateTime timestamp;
  final int retryCount;

  BarcodeUpdate({
    required this.orderCode,
    required this.barcode,
    required this.productId,
    required this.scannedQuantity,
    required this.timestamp,
    required this.retryCount,
  });

  BarcodeUpdate copyWith({int? retryCount}) {
    return BarcodeUpdate(
      orderCode: orderCode,
      barcode: barcode,
      productId: productId,
      scannedQuantity: scannedQuantity,
      timestamp: timestamp,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

/// Supabase servislerini yöneten ana sınıf
/// Offline-first yaklaşım ile hybrid sync sistemi sağlar
class SupabaseService {
  static final Logger _logger = Logger('SupabaseService');
  static SupabaseClient? _client;
  static bool _initialized = false;
  static StreamSubscription<List<ConnectivityResult>>?
      _connectivitySubscription;
  static bool _isOnline = false;
  static late String _deviceId;

  /// Supabase'i başlatır
  static Future<void> initialize({
    required String url,
    required String anonKey,
    String? deviceId,
  }) async {
    if (_initialized) {
      _logger.info('Supabase zaten başlatılmış');
      return;
    }

    try {
      _logger.info('Supabase başlatılıyor...');

      // Device ID'yi ayarla
      _deviceId = deviceId ?? _generateDeviceId();
      _logger.info('Device ID: $_deviceId');

      // Supabase'i başlat
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );

      _client = Supabase.instance.client;
      _initialized = true;

      // İnternet bağlantısını izle
      _startConnectivityMonitoring();

      // İlk bağlantı durumunu kontrol et
      final connectivityResult = await (Connectivity().checkConnectivity());
      _updateConnectionStatus(connectivityResult);

      _logger.info('✅ Supabase: Başarıyla başlatıldı');
    } catch (e, stackTrace) {
      _logger.severe('💥 Supabase: Başlatma hatası', e, stackTrace);
      rethrow;
    }
  }

  /// Supabase client instance'ını döndürür
  static SupabaseClient get client {
    if (!_initialized || _client == null) {
      throw StateError(
          'Supabase henüz başlatılmadı. SupabaseService.initialize() çağırın.');
    }
    return _client!;
  }

  /// Supabase'in başlatılıp başlatılmadığını kontrol eder
  static bool get isInitialized => _initialized;

  /// Online durumunu döndürür
  static bool get isOnline => _isOnline;

  /// Device ID'yi döndürür
  static String get deviceId => _deviceId;

  /// İnternet bağlantısını izlemeye başlar
  static void _startConnectivityMonitoring() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
    _logger.info('İnternet bağlantısı izleme başlatıldı');
  }

  /// Bağlantı durumunu günceller
  static void _updateConnectionStatus(List<ConnectivityResult> result) {
    final wasOnline = _isOnline;
    _isOnline = result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.ethernet);

    if (wasOnline != _isOnline) {
      _logger.info(
          '📶 Bağlantı durumu değişti: ${_isOnline ? "Online" : "Offline"}');

      if (_isOnline) {
        // Online olduğunda sync işlemini başlat
        _triggerSync();
      }
    }
  }

  /// Sync işlemini tetikler
  static void _triggerSync() {
    _logger.info('🔄 Sync işlemi tetiklendi');
    // Sync işlemi burada çağırılacak
    // Bu method order_sync_service tarafından dinlenecek
  }

  /// Device ID oluşturur
  static String _generateDeviceId() {
    return 'device_${DateTime.now().millisecondsSinceEpoch}_${kIsWeb ? "web" : "mobile"}';
  }

  /// Servisi temizler
  static Future<void> dispose() async {
    _logger.info('Supabase servisi kapatılıyor...');
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _initialized = false;
    _client = null;
    _logger.info('✅ Supabase servisi kapatıldı');
  }
}

/// Supabase tabloları ile local database arasında sync işlemlerini yöneten sınıf
class SupabaseSyncService {
  static final Logger _logger = Logger('SupabaseSyncService');
  late final AppDatabase _localDb;
  late final SupabaseClient _supabaseClient;

  // Background queue sistemi
  final List<BarcodeUpdate> _backgroundQueue = [];
  Timer? _backgroundTimer;

  SupabaseSyncService({
    required AppDatabase localDatabase,
    required SupabaseClient supabaseClient,
  }) {
    _localDb = localDatabase;
    _supabaseClient = supabaseClient;
    _logger.info('SupabaseSyncService oluşturuldu');
  }

  /// Ürünleri Supabase'den çeker
  Future<List<Map<String, dynamic>>> fetchProductsFromSupabase({
    String? searchQuery,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      _logger.info('📥 Supabase\'den ürünler çekiliyor...');

      dynamic query = _supabaseClient.from('products').select('''
            id,
            our_product_code,
            name,
            barcode,
            is_unique_barcode_required,
            created_at,
            updated_at
          ''');

      // Arama filtresi
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
            'name.ilike.%$searchQuery%,our_product_code.ilike.%$searchQuery%,barcode.ilike.%$searchQuery%');
      }

      // Sayfalama
      query = query.range(offset, offset + limit - 1);

      // Sıralama
      query = query.order('name', ascending: true);

      final response = await query;
      _logger.info('✅ ${response.length} ürün Supabase\'den çekildi');

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      _logger.severe('💥 Supabase\'den ürün çekme hatası', e, stackTrace);
      rethrow;
    }
  }

  /// Siparişleri Supabase'den çeker ve local database ile senkronize eder
  Future<List<Map<String, dynamic>>> fetchOrdersFromSupabase({
    String? searchQuery,
    String? status,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      _logger.info('📥 Supabase\'den siparişler çekiliyor...');

      dynamic query = _supabaseClient.from('orders').select('''
            id,
            order_code,
            customer_name,
            status,
            created_at,
            updated_at,
            last_sync_at,
            order_items(
              id,
              product_id,
              quantity,
              scanned_quantity,
              products(
                id,
                our_product_code,
                name,
                barcode,
                is_unique_barcode_required
              )
            )
          ''');

      // Arama filtresi
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
            'order_code.ilike.%$searchQuery%,customer_name.ilike.%$searchQuery%');
      }

      // Durum filtresi
      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      // Sayfalama
      query = query.range(offset, offset + limit - 1);

      // Sıralama
      query = query.order('created_at', ascending: false);

      final response = await query;
      _logger.info('✅ ${response.length} sipariş Supabase\'den çekildi');

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      _logger.severe('💥 Supabase\'den sipariş çekme hatası', e, stackTrace);
      rethrow;
    }
  }

  /// Ürünleri local database ile sync eder
  Future<void> syncProductsWithLocal() async {
    try {
      _logger.info('🔄 Ürünler sync ediliyor...');

      // Supabase'den ürünleri çek
      final remoteProducts = await fetchProductsFromSupabase();

      for (final remoteProductData in remoteProducts) {
        final productCode = remoteProductData['our_product_code'] as String;

        // Local'de bu ürün var mı kontrol et
        final existingProduct = await (_localDb.select(_localDb.products)
              ..where((p) => p.ourProductCode.equals(productCode)))
            .getSingleOrNull();

        if (existingProduct == null) {
          // Local'de yok, ekle
          await _insertProductFromRemote(remoteProductData);
        } else {
          // Local'de var, güncelle
          await _updateProductFromRemote(existingProduct, remoteProductData);
        }
      }

      _logger.info('✅ Ürün sync tamamlandı');
    } catch (e, stackTrace) {
      _logger.severe('💥 Ürün sync hatası', e, stackTrace);
      rethrow;
    }
  }

  /// Remote'dan gelen veri ile yeni ürün ekler
  Future<void> _insertProductFromRemote(
      Map<String, dynamic> remoteProductData) async {
    final productCompanion = ProductsCompanion(
      ourProductCode: Value(remoteProductData['our_product_code']),
      name: Value(remoteProductData['name']),
      barcode: Value(remoteProductData['barcode']),
      isUniqueBarcodeRequired:
          Value(remoteProductData['is_unique_barcode_required'] ?? false),
    );

    await _localDb.into(_localDb.products).insert(productCompanion);
  }

  /// Remote'dan gelen veri ile local ürünü günceller
  Future<void> _updateProductFromRemote(
      Product localProduct, Map<String, dynamic> remoteProductData) async {
    await (_localDb.update(_localDb.products)
          ..where((p) => p.id.equals(localProduct.id)))
        .write(ProductsCompanion(
      name: Value(remoteProductData['name']),
      barcode: Value(remoteProductData['barcode']),
      isUniqueBarcodeRequired:
          Value(remoteProductData['is_unique_barcode_required'] ?? false),
    ));
  }

  /// Local siparişi Supabase'e gönderir
  Future<void> pushOrderToSupabase(Order order) async {
    if (!SupabaseService.isOnline) {
      _logger.warning('⚠️ Offline durumda - sipariş sync kuyruğuna eklendi');
      // TODO: Sync kuyruğuna ekle
      return;
    }

    try {
      _logger.info('📤 Sipariş Supabase\'e gönderiliyor: ${order.orderCode}');

      final orderData = {
        'order_code': order.orderCode,
        'customer_name': order.customerName,
        'status': order.status.name,
        'created_at': order.createdAt.toIso8601String(),
        'updated_at': order.updatedAt.toIso8601String(),
        'last_sync_at': DateTime.now().toIso8601String(),
        'device_id': SupabaseService.deviceId,
      };

      await _supabaseClient
          .from('orders')
          .upsert(orderData, onConflict: 'order_code');

      _logger.info(
          '✅ Sipariş başarıyla Supabase\'e gönderildi: ${order.orderCode}');
    } catch (e, stackTrace) {
      _logger.severe('💥 Sipariş Supabase\'e gönderme hatası', e, stackTrace);
      rethrow;
    }
  }

  /// Conflict resolution - hangisi daha güncel ise o kullanılır
  Future<void> resolveConflicts() async {
    try {
      _logger.info('🔄 Conflict resolution başlatıldı');

      // Local ve remote verileri karşılaştır
      final localOrders = await _localDb.select(_localDb.orders).get();
      final remoteOrders = await fetchOrdersFromSupabase();

      for (final localOrder in localOrders) {
        final remoteOrder = remoteOrders.firstWhere(
          (remote) => remote['order_code'] == localOrder.orderCode,
          orElse: () => <String, dynamic>{},
        );

        if (remoteOrder.isNotEmpty) {
          final localUpdatedAt = localOrder.updatedAt;
          final remoteUpdatedAt = DateTime.parse(remoteOrder['updated_at']);

          if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
            // Remote daha güncel - local'i güncelle
            _logger.info(
                '🔄 Remote daha güncel: ${localOrder.orderCode} - Local güncelleniyor');
            await _updateLocalOrderFromRemote(
                localOrder.orderCode, remoteOrder);
          } else if (localUpdatedAt.isAfter(remoteUpdatedAt)) {
            // Local daha güncel - remote'u güncelle
            _logger.info(
                '🔄 Local daha güncel: ${localOrder.orderCode} - Remote güncelleniyor');
            await pushOrderToSupabase(localOrder);
          }
        }
      }

      _logger.info('✅ Conflict resolution tamamlandı');
    } catch (e, stackTrace) {
      _logger.severe('💥 Conflict resolution hatası', e, stackTrace);
      rethrow;
    }
  }

  /// Remote'dan gelen veri ile local order'ı günceller
  Future<void> _updateLocalOrderFromRemote(
      String orderCode, Map<String, dynamic> remoteOrder) async {
    try {
      // Local order'ı güncelle
      await (_localDb.update(_localDb.orders)
            ..where((o) => o.orderCode.equals(orderCode)))
          .write(OrdersCompanion(
        customerName: Value(remoteOrder['customer_name']),
        status: Value(OrderStatus.values.firstWhere(
          (s) => s.name == remoteOrder['status'],
          orElse: () => OrderStatus.pending,
        )),
        updatedAt: Value(DateTime.parse(remoteOrder['updated_at'])),
      ));

      _logger.info('✅ Local order güncellendi: $orderCode');
    } catch (e, stackTrace) {
      _logger.severe('💥 Local order güncelleme hatası', e, stackTrace);
      rethrow;
    }
  }

  /// Realtime subscription kurar
  RealtimeChannel subscribeToOrderChanges(
      Function(Map<String, dynamic>) onOrderChange) {
    _logger.info('🔴 Realtime subscription kuruldu: orders');

    return _supabaseClient
        .channel('order_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          callback: (payload) {
            _logger.info(
                '🔴 Realtime order değişikliği alındı: ${payload.eventType}');
            onOrderChange(payload.newRecord);
          },
        )
        .subscribe();
  }

  /// Realtime subscription'ı kaldırır
  Future<void> unsubscribeFromOrderChanges(RealtimeChannel channel) async {
    await _supabaseClient.removeChannel(channel);
    _logger.info('🔴 Realtime subscription kaldırıldı');
  }

  /// Barkod okuma verilerini Supabase'e gönderir (arkaplanda)
  Future<void> pushBarcodeReadToSupabase({
    required String orderCode,
    required String barcode,
    required int? productId,
    required int scannedQuantity,
  }) async {
    // Background işlem olarak çalıştır
    unawaited(_pushBarcodeReadToSupabaseBackground(
      orderCode: orderCode,
      barcode: barcode,
      productId: productId,
      scannedQuantity: scannedQuantity,
    ));
  }

  /// Arkaplanda barkod okuma verilerini Supabase'e gönderir
  Future<void> _pushBarcodeReadToSupabaseBackground({
    required String orderCode,
    required String barcode,
    required int? productId,
    required int scannedQuantity,
  }) async {
    if (!SupabaseService.isOnline) {
      _logger
          .warning('⚠️ Offline durumda - barkod okuma sync kuyruğuna eklendi');
      // Offline durumunda queue'ya ekle
      _addToBackgroundQueue(BarcodeUpdate(
        orderCode: orderCode,
        barcode: barcode,
        productId: productId,
        scannedQuantity: scannedQuantity,
        timestamp: DateTime.now(),
        retryCount: 0,
      ));
      return;
    }

    try {
      _logger.info(
          '📤 Barkod okuma Supabase\'e gönderiliyor (arkaplanda): $barcode');

      // Önce siparişin ID'sini bul
      final orderResponse = await _supabaseClient
          .from('orders')
          .select('id')
          .eq('order_code', orderCode)
          .single();

      final orderId = orderResponse['id'];

      // Eğer productId varsa, sipariş kalemi güncelle
      if (productId != null) {
        await _supabaseClient
            .from('order_items')
            .update({
              'scanned_quantity': scannedQuantity,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('order_id', orderId)
            .eq('product_id', productId);
      }

      _logger.info(
          '✅ Barkod okuma başarıyla Supabase\'e gönderildi (arkaplanda): $barcode');
    } catch (e, stackTrace) {
      _logger.warning(
          '⚠️ Barkod okuma Supabase\'e gönderme hatası (arkaplanda) - queue\'ya eklendi',
          e);

      // Hata durumunda queue'ya ekle
      _addToBackgroundQueue(BarcodeUpdate(
        orderCode: orderCode,
        barcode: barcode,
        productId: productId,
        scannedQuantity: scannedQuantity,
        timestamp: DateTime.now(),
        retryCount: 0,
      ));
    }
  }

  /// Background queue'ya barkod güncellemesi ekler
  void _addToBackgroundQueue(BarcodeUpdate update) {
    _backgroundQueue.add(update);
    _logger.info(
        '📝 Barkod okuma queue\'ya eklendi: ${update.barcode} (Queue size: ${_backgroundQueue.length})');

    // Timer'ı başlat (eğer çalışmıyorsa)
    _startBackgroundTimer();
  }

  /// Background timer'ı başlatır
  void _startBackgroundTimer() {
    if (_backgroundTimer != null && _backgroundTimer!.isActive) {
      return; // Zaten çalışıyor
    }

    _backgroundTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _processBackgroundQueue();
    });

    _logger.info('⏰ Background timer başlatıldı (30 saniye aralık)');
  }

  /// Background queue'daki güncellemeleri işler
  Future<void> _processBackgroundQueue() async {
    if (_backgroundQueue.isEmpty) {
      return;
    }

    if (!SupabaseService.isOnline) {
      _logger.info(
          '⚠️ Offline durumda - background queue işlenmiyor (${_backgroundQueue.length} item)');
      return;
    }

    _logger.info(
        '🔄 Background queue işleniyor (${_backgroundQueue.length} item)');

    final itemsToProcess = List<BarcodeUpdate>.from(_backgroundQueue);
    _backgroundQueue.clear();

    for (final update in itemsToProcess) {
      try {
        await _processSingleBarcodeUpdate(update);
        _logger.info('✅ Background queue item işlendi: ${update.barcode}');
      } catch (e) {
        _logger.warning(
            '⚠️ Background queue item hatası: ${update.barcode}', e);

        // Retry limiti kontrolü (maksimum 3 deneme)
        if (update.retryCount < 3) {
          _backgroundQueue
              .add(update.copyWith(retryCount: update.retryCount + 1));
          _logger.info(
              '🔄 Retry queue\'ya eklendi: ${update.barcode} (${update.retryCount + 1}/3)');
        } else {
          _logger.severe(
              '💥 Background queue item başarısız (max retry): ${update.barcode}');
        }
      }
    }
  }

  /// Tek bir barkod güncellemesini işler
  Future<void> _processSingleBarcodeUpdate(BarcodeUpdate update) async {
    // Önce siparişin ID'sini bul
    final orderResponse = await _supabaseClient
        .from('orders')
        .select('id')
        .eq('order_code', update.orderCode)
        .single();

    final orderId = orderResponse['id'];

    // Eğer productId varsa, sipariş kalemi güncelle
    if (update.productId != null) {
      await _supabaseClient
          .from('order_items')
          .update({
            'scanned_quantity': update.scannedQuantity,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('order_id', orderId)
          .eq('product_id', update.productId!);

      _logger.info(
          '📤 Order item güncellendi: OrderCode=${update.orderCode}, ProductId=${update.productId}, Quantity=${update.scannedQuantity}');
    }
  }

  /// Background timer'ı durdurur
  void _stopBackgroundTimer() {
    _backgroundTimer?.cancel();
    _backgroundTimer = null;
    _logger.info('⏹️ Background timer durduruldu');
  }

  /// Bekleyen queue'yu işlemeye zorlar (manuel tetikleme)
  Future<void> forceProcessQueue() async {
    _logger.info('🚀 Background queue manuel tetiklendi');
    await _processBackgroundQueue();
  }

  /// Service'i temizler
  void dispose() {
    _stopBackgroundTimer();
    _backgroundQueue.clear();
    _logger.info('✅ SupabaseSyncService temizlendi');
  }
}
