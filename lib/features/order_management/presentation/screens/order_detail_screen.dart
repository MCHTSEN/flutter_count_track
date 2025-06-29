import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_count_track/core/database/app_database.dart'; // For Order, OrderItem
import 'package:flutter_count_track/features/barcode_scanning/presentation/notifiers/barcode_notifier.dart';
import 'package:flutter_count_track/features/barcode_scanning/presentation/widgets/barcode_overlay_notification.dart';
import 'package:flutter_count_track/features/order_management/presentation/notifiers/order_detail_notifier.dart';
import 'package:flutter_count_track/features/order_management/presentation/notifiers/order_providers.dart';
import 'package:flutter_count_track/features/order_management/presentation/screens/box_management_screen.dart';
import 'package:flutter_count_track/shared_widgets/loading_indicator.dart'; // Placeholder for loading widget
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../data/services/packing_list_service.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderCode; // Renamed from orderId for clarity

  const OrderDetailScreen({super.key, required this.orderCode});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _selectedBoxNumber = 1; // Varsayılan olarak Koli 1

  // Barkod okuyucu için keyboard listener state
  String _barcodeBuffer = '';
  DateTime? _lastKeyPress;
  final FocusNode _keyboardFocusNode = FocusNode();

  // Animasyon controller'ları
  late AnimationController _quantityAnimationController;
  late Animation<double> _quantityScaleAnimation;

  // Son güncellenmiş ürün ID'sini takip et
  int? _lastUpdatedProductId;

  // Barkod okuyucu ayarları
  static const Duration _barcodeTimeout =
      Duration(milliseconds: 100); // Karakterler arası max süre
  static const int _minBarcodeLength = 3; // Minimum barkod uzunluğu
  static const int _maxBarcodeLength = 50; // Maximum barkod uzunluğu

  @override
  void initState() {
    super.initState();

    // Animasyon controller'ını başlat
    _quantityAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _quantityScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _quantityAnimationController,
      curve: Curves.elasticOut,
    ));

    // App lifecycle observer'ı kaydet
    WidgetsBinding.instance.addObserver(this);

    // Sistem haptic feedback'ini devre dışı bırak
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    // Klavye odağını hemen al
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocusNode.requestFocus();
      // Ekran ilk açıldığında da refresh et
      _onScreenFocus();
    });
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    _quantityAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    // Overlay service'i temizle
    BarcodeOverlayService.instance.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Uygulama foreground'a geçtiğinde refresh et
    if (state == AppLifecycleState.resumed) {
      _onScreenFocus();
    }
  }

  /// Ekran focus alındığında çağrılır
  void _onScreenFocus() {
    if (!mounted) return;

    print('👁️ OrderDetailScreen: Focus alındı, verileri yenileniyor');
    ref
        .read(orderDetailNotifierProvider(widget.orderCode).notifier)
        .onScreenFocus();
  }

  /// Keyboard event'lerini işler - gerçek barkod okuyucu için
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final now = DateTime.now();

      // Enter tuşu - barkodu işle
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        _processBarcodeFromBuffer();
        return;
      }

      // Escape tuşu - buffer'ı temizle
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        _clearBarcodeBuffer();
        return;
      }

      // Karakter tuşları
      final character = event.character;
      if (character != null && character.isNotEmpty) {
        setState(() {
          // Timeout kontrolü - eğer son tuştan sonra çok geçtiyse, yeni barkod başlatılıyor
          if (_lastKeyPress != null &&
              now.difference(_lastKeyPress!) > _barcodeTimeout) {
            _clearBarcodeBufferInternal();
          }

          // Karakteri buffer'a ekle
          _barcodeBuffer += character;
          _lastKeyPress = now;

          // Buffer çok uzunsa temizle (hata durumu)
          if (_barcodeBuffer.length > _maxBarcodeLength) {
            _clearBarcodeBufferInternal();
          }
        });

        // Debug: Buffer durumunu göster (ses olmadan)
        debugPrint(
            '🔍 Barkod Buffer: $_barcodeBuffer (${_barcodeBuffer.length} karakter)');
      }
    }
  }

  /// Buffer'dan barkodu işler
  void _processBarcodeFromBuffer() {
    if (!mounted) return;

    if (_barcodeBuffer.length >= _minBarcodeLength) {
      final barcode = _barcodeBuffer.trim();
      debugPrint('✅ Barkod işleniyor: $barcode');

      final state = ref.read(orderDetailNotifierProvider(widget.orderCode));
      final order = state.order;

      if (order != null) {
        _processBarcodeInput(context, ref, order, barcode);
      }
    } else {
      debugPrint(
          '⚠️ Barkod çok kısa: $_barcodeBuffer (min: $_minBarcodeLength)');
    }

    _clearBarcodeBuffer();
  }

  /// Barkod buffer'ını temizler (UI güncellemeli)
  void _clearBarcodeBuffer() {
    if (!mounted) return;

    setState(() {
      _clearBarcodeBufferInternal();
    });
  }

  /// Barkod buffer'ını temizler (internal - UI güncellemesiz)
  void _clearBarcodeBufferInternal() {
    _barcodeBuffer = '';
    _lastKeyPress = null;
    debugPrint('🧹 Barkod buffer temizlendi');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderDetailNotifierProvider(widget.orderCode));

    return RawKeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      includeSemantics: false,
      onKey: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text('Sipariş Detayı: ${widget.orderCode}',
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
          toolbarHeight: 80,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  _generatePackingList(context, ref);
                },
                icon: const Icon(Icons.picture_as_pdf, size: 24),
                label:
                    const Text('Çeki Listesi', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[600],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BoxManagementScreen(
                        orderCode: widget.orderCode,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.inventory_2, size: 24),
                label:
                    const Text('Koli Yönetimi', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ElevatedButton.icon(
                onPressed: () => ref
                    .read(
                        orderDetailNotifierProvider(widget.orderCode).notifier)
                    .refreshOrderDetailsWithSync(),
                icon: const Icon(Icons.refresh, size: 28),
                label: const Text('Yenile', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue[800],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ),
          ],
        ),
        body: _buildBody(context, ref, state),
      ),
    );
  }

  Future<void> _generatePackingList(BuildContext context, WidgetRef ref) async {
    final orderState = ref.read(orderDetailNotifierProvider(widget.orderCode));
    final order = orderState.order;

    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('PDF oluşturmak için sipariş bilgisi gerekli.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Çeki listesi oluşturuluyor...')),
    );

    try {
      final repository = ref.read(orderRepositoryProvider);
      final boxContents = await repository.getBoxContents(widget.orderCode);

      if (boxContents.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listelenecek ürün bulunamadı.')),
        );
        return;
      }

      final packingListService = PackingListService();
      final pdfData = await packingListService.generatePackingListPdf(
        order.orderCode,
        order.customerName,
        boxContents,
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdfData,
        name: 'CekiListesi_${order.orderCode}',
      );
    } catch (e) {
      print('❌ PDF Generation Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata oluştu: $e')),
      );
    }
  }

  Widget _buildBody(
      BuildContext context, WidgetRef ref, OrderDetailState state) {
    if (state.isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Card(
          color: Colors.red[50],
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[600]),
                const SizedBox(height: 16),
                Text(
                  'Hata: ${state.errorMessage}',
                  style: TextStyle(
                    color: Colors.red[800],
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state.order == null) {
      return Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[600]),
                const SizedBox(height: 16),
                Text(
                  'Sipariş bilgisi bulunamadı.',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final order = state.order!;
    final itemDetails = state.orderItemDetails ?? [];

    // Debug logları
    print('🎯 OrderDetailScreen: State loaded - Order: ${order.orderCode}');
    print('🎯 OrderDetailScreen: ItemDetails count: ${itemDetails.length}');
    for (var i = 0; i < itemDetails.length; i++) {
      final detail = itemDetails[i];
      print(
          '🎯 OrderDetailScreen: Detail $i - ProductId: ${detail.orderItem.productId}, Product: ${detail.product?.name ?? 'null'}');
    }

    return Column(
      children: [
        // Ana grid layout (overlay notification artık inline değil)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sol panel - Sipariş bilgileri ve barkod girişi
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildOrderInfoCard(context, order),
                        const SizedBox(height: 16),
                        _buildBarcodeInputCard(context, ref, order),
                        const SizedBox(height: 16),
                        _buildBarcodeHistoryCard(context, ref, order),
                        const SizedBox(height: 16),
                        _buildOrderSummaryCard(context, itemDetails),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Sağ panel - Ürün grid'i
                Expanded(
                  flex: 2,
                  child: _buildProductGrid(context, itemDetails),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderInfoCard(BuildContext context, Order order) {
    String formatDate(DateTime date) {
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    }

    String getStatusText(OrderStatus status) {
      return switch (status) {
        OrderStatus.pending => 'Bekliyor',
        OrderStatus.partial => 'Kısmen Gönderildi',
        OrderStatus.completed => 'Tamamlandı',
      };
    }

    Color getStatusColor(OrderStatus status) {
      return switch (status) {
        OrderStatus.pending => Colors.orange,
        OrderStatus.partial => Colors.blue,
        OrderStatus.completed => Colors.green,
      };
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment, size: 32, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Text(
                  'Sipariş Bilgileri',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 16),
            _buildInfoRow('Sipariş Kodu:', order.orderCode, Icons.qr_code),
            const SizedBox(height: 12),
            _buildInfoRow('Müşteri:', order.customerName, Icons.business),
            const SizedBox(height: 12),
            _buildInfoRow(
                'Tarih:', formatDate(order.createdAt), Icons.calendar_today),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: getStatusColor(order.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: getStatusColor(order.status), width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: getStatusColor(order.status)),
                  const SizedBox(width: 8),
                  Text(
                    getStatusText(order.status),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: getStatusColor(order.status),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarcodeInputCard(
      BuildContext context, WidgetRef ref, Order order) {
    return Card(
      elevation: 4,
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.qr_code_scanner, size: 32, color: Colors.green[700]),
                const SizedBox(width: 12),
                Text(
                  'Barkod Okutma',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'KEYBOARD LISTENER',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 16),

            // Barkod durumu göstergesi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _barcodeBuffer.isNotEmpty
                    ? Colors.orange[50]
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _barcodeBuffer.isNotEmpty
                      ? Colors.orange[300]!
                      : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _barcodeBuffer.isNotEmpty
                            ? Icons.keyboard
                            : Icons.qr_code_scanner,
                        color: _barcodeBuffer.isNotEmpty
                            ? Colors.orange[600]
                            : Colors.grey[600],
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _barcodeBuffer.isNotEmpty
                            ? 'Barkod Okunuyor...'
                            : 'Barkod okutmaya hazır',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _barcodeBuffer.isNotEmpty
                              ? Colors.orange[700]
                              : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  if (_barcodeBuffer.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Text(
                        _barcodeBuffer,
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_barcodeBuffer.length} karakter - Enter tuşuna basın veya bekleyin',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 8),
                    Text(
                      'Barkod okuyucuyu kullanın veya klavyeyle yazın',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _barcodeBuffer.isNotEmpty
                        ? () {
                            _processBarcodeFromBuffer();
                            // İşleme sonrası focus'u keyboard listener'a geri dön
                            Future.delayed(const Duration(milliseconds: 100),
                                () {
                              FocusScope.of(context).unfocus();
                              _keyboardFocusNode.requestFocus();
                            });
                          }
                        : null,
                    icon: const Icon(Icons.check, size: 24),
                    label: const Text('İŞLE',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: ElevatedButton.icon(
                    onPressed: _barcodeBuffer.isNotEmpty
                        ? () {
                            _clearBarcodeBuffer();
                            // Temizleme sonrası focus'u keyboard listener'a geri dön
                            Future.delayed(const Duration(milliseconds: 100),
                                () {
                              FocusScope.of(context).unfocus();
                              _keyboardFocusNode.requestFocus();
                            });
                          }
                        : null,
                    icon: const Icon(Icons.clear, size: 20),
                    label:
                        const Text('Temizle', style: TextStyle(fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[100],
                      foregroundColor: Colors.red[700],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildQuickBarcodeButtons(context, ref, order),
          ],
        ),
      ),
    );
  }

  Widget _buildBarcodeHistoryCard(
      BuildContext context, WidgetRef ref, Order order) {
    // Gerçek barkod geçmişini state'den al
    final state = ref.watch(orderDetailNotifierProvider(widget.orderCode));
    final barcodeHistory = state.barcodeHistory ?? [];

    // BarcodeRead'leri UI için uygun formata çevir ve ürün bilgilerini getir
    final List<Map<String, dynamic>> recentScans = [];

    for (final read in barcodeHistory) {
      // Ürün bilgisini state'deki order item details'den bul
      final itemDetails = state.orderItemDetails ?? [];
      final matchingItem = itemDetails
          .where((item) => item.orderItem.productId == read.productId)
          .firstOrNull;

      final productCode = matchingItem?.product?.ourProductCode ??
          (read.productId != null ? 'ÜRN${read.productId}' : 'Bilinmeyen');

      recentScans.add({
        'barcode': read.barcode,
        'productCode': productCode,
        'boxNumber': read.boxNumber ?? 0,
        'timestamp': read.readAt,
      });
    }

    return Card(
      elevation: 4,
      color: Colors.purple[50],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, size: 32, color: Colors.purple[700]),
                const SizedBox(width: 12),
                Text(
                  'Barkod Geçmişi',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700],
                  ),
                ),
              ],
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 16),

            // Son 2 barkod - yan yana
            if (recentScans.isNotEmpty) ...[
              Text(
                'Son Okutulan Barkodlar:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // En son okutulan barkod
                  Expanded(
                    child: _buildRecentBarcodeCard(
                      recentScans[0],
                      'Son Okuma',
                      Colors.green,
                      true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Bir önceki okutulan barkod
                  Expanded(
                    child: recentScans.length > 1
                        ? _buildRecentBarcodeCard(
                            recentScans[1],
                            'Önceki Okuma',
                            Colors.blue,
                            false,
                          )
                        : Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Center(
                              child: Text(
                                'Henüz ikinci\nbarkod yok',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Diğer barkodlar - liste halinde
            if (recentScans.length > 2) ...[
              Text(
                'Önceki Okumalar:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: recentScans.length - 2,
                  itemBuilder: (context, index) {
                    final scan = recentScans[index + 2];
                    return _buildBarcodeHistoryTile(scan);
                  },
                ),
              ),
            ] else ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.qr_code_scanner,
                          size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'Henüz barkod okutulmadı',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBarcodeCard(
      Map<String, dynamic> scan, String title, Color color, bool isLatest) {
    final String formattedTime =
        '${scan['timestamp'].hour.toString().padLeft(2, '0')}:${scan['timestamp'].minute.toString().padLeft(2, '0')}';

    return Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color,
          width: isLatest ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isLatest ? Icons.new_releases : Icons.history,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Spacer(),
              Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            scan['productCode'],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            scan['barcode'],
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: Colors.grey[700],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Koli ${scan['boxNumber']}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarcodeHistoryTile(Map<String, dynamic> scan) {
    final String formattedTime =
        '${scan['timestamp'].hour.toString().padLeft(2, '0')}:${scan['timestamp'].minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          backgroundColor: Colors.purple[100],
          child: Icon(Icons.qr_code, color: Colors.purple[700], size: 18),
        ),
        title: Text(
          scan['productCode'],
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          scan['barcode'],
          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formattedTime,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.purple[100],
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                'Koli ${scan['boxNumber']}',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(
      BuildContext context, List<OrderItemDetail> itemDetails) {
    int totalItems = itemDetails.length;
    int totalQuantity =
        itemDetails.fold(0, (sum, item) => sum + item.orderItem.quantity);
    int scannedQuantity = itemDetails.fold(
        0, (sum, item) => sum + item.orderItem.scannedQuantity);
    double progress = totalQuantity > 0 ? scannedQuantity / totalQuantity : 0.0;

    return Card(
      elevation: 4,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, size: 32, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Text(
                  'Sipariş Özeti',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 16),
            _buildSummaryRow(
                'Toplam Ürün Çeşidi:', totalItems.toString(), Icons.category),
            const SizedBox(height: 12),
            _buildSummaryRow(
                'Toplam Adet:', totalQuantity.toString(), Icons.inventory),
            const SizedBox(height: 12),
            _buildSummaryRow('Okutulan Adet:', scannedQuantity.toString(),
                Icons.check_circle),
            const SizedBox(height: 16),
            Text(
              'İlerleme',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? Colors.green : Colors.blue,
              ),
              minHeight: 12,
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toInt()}% Tamamlandı',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: progress == 1.0 ? Colors.green[700] : Colors.blue[700],
              ),
            ),
            const SizedBox(height: 20),
            // Koli yönetimi butonu
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid(
      BuildContext context, List<OrderItemDetail> itemDetails) {
    if (itemDetails.isEmpty) {
      return Card(
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined,
                  size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Bu siparişte ürün bulunmamaktadır.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductHeader(),
          const Divider(thickness: 1, height: 1),
          _buildBoxSelectionSection(),
          const Divider(thickness: 1, height: 1),
          Expanded(
            child: _buildCombinedProductList(itemDetails),
          ),
        ],
      ),
    );
  }

  Widget _buildProductHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Icon(Icons.inventory, size: 32, color: Colors.purple[700]),
          const SizedBox(width: 12),
          Text(
            'Siparişteki Ürünler',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.purple[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoxSelectionSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory_2, size: 20, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Text(
                'Koli Yönetimi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Consumer(
            builder: (context, ref, child) {
              final state =
                  ref.watch(orderDetailNotifierProvider(widget.orderCode));
              final barcodeHistory = state.barcodeHistory ?? [];

              // Kullanılan koli numaralarını ve potansiyel yeni koli numarasını al
              final Set<int> allBoxesSet = barcodeHistory
                  .map((read) => read.boxNumber)
                  .whereType<int>()
                  .toSet();
              allBoxesSet.add(1); // Her zaman en az 1. koli olsun
              allBoxesSet.add(
                  _selectedBoxNumber); // Seçili olanı da ekle (yeni olabilir)

              final availableBoxes = allBoxesSet.toList()..sort();

              final validSelectedBox =
                  availableBoxes.contains(_selectedBoxNumber)
                      ? _selectedBoxNumber
                      : (availableBoxes.isNotEmpty ? availableBoxes.last : 1);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<int>(
                      value: validSelectedBox,
                      decoration: InputDecoration(
                        labelText: 'Aktif Koli',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.orange[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.orange[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.orange[600]!, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.orange[50],
                      ),
                      items: availableBoxes.map((boxNumber) {
                        // Bu kolide kaç ürün var
                        final itemsInBox = barcodeHistory
                            .where((read) => read.boxNumber == boxNumber)
                            .length;

                        return DropdownMenuItem<int>(
                          value: boxNumber,
                          child: Text('Koli $boxNumber ($itemsInBox ürün)'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedBoxNumber = value;
                          });

                          // Dropdown seçimi sonrası focus'u kaldır ve keyboard listener'a geri dön
                          Future.delayed(const Duration(milliseconds: 100), () {
                            FocusScope.of(context).unfocus();
                            _keyboardFocusNode.requestFocus();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedBoxNumber = (availableBoxes.isNotEmpty
                                  ? availableBoxes.last
                                  : 0) +
                              1;
                        });

                        // Buton tıklaması sonrası focus'u keyboard listener'a geri dön
                        Future.delayed(const Duration(milliseconds: 100), () {
                          FocusScope.of(context).unfocus();
                          _keyboardFocusNode.requestFocus();
                        });
                      },
                      icon: const Icon(Icons.add_box_outlined),
                      label: const Text('Yeni Koli'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[100],
                        foregroundColor: Colors.orange[800],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.orange[300]!),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedProductList(List<OrderItemDetail> itemDetails) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(orderDetailNotifierProvider(widget.orderCode));
        final barcodeHistory = state.barcodeHistory ?? [];

        // Son okutulan ürünleri bul
        final List<OrderItemDetail> recentItems = [];
        final List<OrderItemDetail> otherItems = [];

        // Barkod geçmişinden son 2 ürünü bul
        if (barcodeHistory.isNotEmpty) {
          final recentProductIds =
              barcodeHistory.take(2).map((read) => read.productId).toSet();

          for (final item in itemDetails) {
            if (recentProductIds.contains(item.product?.id)) {
              recentItems.add(item);
            } else {
              otherItems.add(item);
            }
          }
        } else {
          otherItems.addAll(itemDetails);
        }

        // Diğer ürünleri sırala (bitmeyenler önce)
        otherItems.sort((a, b) {
          final aCompleted =
              a.orderItem.scannedQuantity >= a.orderItem.quantity;
          final bCompleted =
              b.orderItem.scannedQuantity >= b.orderItem.quantity;

          if (aCompleted && !bCompleted) return 1;
          if (!aCompleted && bCompleted) return -1;
          return 0;
        });

        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              // Son okutulan ürünler - büyük kartlar
              ...recentItems
                  .map((item) => _buildRecentProductCard(item, barcodeHistory)),

              // Diğer ürünler - normal liste
              ...otherItems.map((item) => _buildProductListTile(item)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentProductCard(
      OrderItemDetail itemDetail, List<dynamic> barcodeHistory) {
    final orderItem = itemDetail.orderItem;
    final product = itemDetail.product;
    final progress = orderItem.quantity > 0
        ? orderItem.scannedQuantity / orderItem.quantity
        : 0.0;
    final isCompleted = orderItem.scannedQuantity >= orderItem.quantity;

    // Son okuma zamanını bul
    dynamic lastRead;
    try {
      lastRead = barcodeHistory.firstWhere(
        (read) => read.productId == product?.id,
      );
    } catch (e) {
      lastRead = null;
    }

    final String timeText = lastRead != null
        ? '${lastRead.readAt.hour.toString().padLeft(2, '0')}:${lastRead.readAt.minute.toString().padLeft(2, '0')}'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.new_releases,
                  color: Colors.green[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SON OKUTULAN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[600],
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      product?.ourProductCode ?? 'Ürün kodu yok',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ],
                ),
              ),
              if (timeText.isNotEmpty)
                Text(
                  timeText,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            product?.name ?? 'Ürün adı yok',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          if (product?.barcode != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.qr_code, size: 16, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  Text(
                    product!.barcode,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'monospace',
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              isCompleted ? Colors.green : Colors.blue,
            ),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAnimatedQuantityTextLarge(
                '${orderItem.scannedQuantity}/${orderItem.quantity}',
                product?.id,
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductListTile(OrderItemDetail itemDetail) {
    final orderItem = itemDetail.orderItem;
    final product = itemDetail.product;
    final progress = orderItem.quantity > 0
        ? orderItem.scannedQuantity / orderItem.quantity
        : 0.0;
    final isCompleted = orderItem.scannedQuantity >= orderItem.quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        tileColor: isCompleted ? Colors.green[50] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isCompleted ? Colors.green[200]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isCompleted ? Colors.green[100] : Colors.blue[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isCompleted ? Icons.check_circle : Icons.inventory,
            color: isCompleted ? Colors.green[600] : Colors.blue[600],
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Text(
              product?.ourProductCode ?? 'Ürün kodu yok',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            if (product?.barcode != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  product!.barcode,
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color: Colors.blue[700],
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              product?.name ?? 'Ürün adı yok',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? Colors.green : Colors.blue,
              ),
              minHeight: 6,
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildAnimatedQuantityText(
              '${orderItem.scannedQuantity}/${orderItem.quantity}',
              product?.id,
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickBarcodeButtons(
      BuildContext context, WidgetRef ref, Order order) {
    final state = ref.watch(orderDetailNotifierProvider(widget.orderCode));
    final itemDetails = state.orderItemDetails ?? [];

    // Siparişte bulunan ürünlerin barkodlarını al
    final List<String> productBarcodes = itemDetails
        .where((detail) => detail.product?.barcode != null)
        .map((detail) => detail.product!.barcode)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı Test Barkodları (Bu Siparişte):',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        if (productBarcodes.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...productBarcodes.map((barcode) {
                // İlgili ürünü bul
                final product = itemDetails
                    .firstWhere((detail) => detail.product?.barcode == barcode)
                    .product;
                return ActionChip(
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        product?.ourProductCode ?? '',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        barcode,
                        style: const TextStyle(
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green[100],
                  avatar:
                      Icon(Icons.qr_code, size: 16, color: Colors.green[700]),
                  onPressed: () {
                    _processBarcodeInput(context, ref, order, barcode);
                  },
                );
              }),
              ActionChip(
                label: const Text('Rastgele', style: TextStyle(fontSize: 12)),
                avatar: const Icon(Icons.shuffle, size: 16),
                backgroundColor: Colors.orange[100],
                onPressed: () {
                  final randomBarcode = List.generate(
                      13,
                      (_) => (DateTime.now().millisecondsSinceEpoch % 10)
                          .toString()).join();
                  _processBarcodeInput(context, ref, order, randomBarcode);
                },
              ),
            ],
          ),
        ] else ...[
          Text(
            'Bu sipariş için ürün barkodu bilgisi yok.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          'Genel Test Barkodları:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Genel test barkodları
            ActionChip(
              label: const Text('Test-1234567890123',
                  style: TextStyle(fontSize: 10)),
              backgroundColor: Colors.blue[100],
              onPressed: () {
                _processBarcodeInput(context, ref, order, '1234567890123');
              },
            ),
            ActionChip(
              label: const Text('Test-2345678901234',
                  style: TextStyle(fontSize: 10)),
              backgroundColor: Colors.blue[100],
              onPressed: () {
                _processBarcodeInput(context, ref, order, '2345678901234');
              },
            ),
            ActionChip(
              label: const Text('Test-3456789012345',
                  style: TextStyle(fontSize: 10)),
              backgroundColor: Colors.blue[100],
              onPressed: () {
                _processBarcodeInput(context, ref, order, '3456789012345');
              },
            ),
          ],
        ),
      ],
    );
  }

  void _processBarcodeInput(
      BuildContext context, WidgetRef ref, Order order, String barcode) {
    // Screen dispose kontrolü
    if (!mounted) return;

    // Barkod işleme öncesi mevcut state'i kaydet
    final currentState =
        ref.read(orderDetailNotifierProvider(widget.orderCode));
    final currentItemDetails = currentState.orderItemDetails ?? [];

    ref.read(barcodeNotifierProvider.notifier).processBarcode(
          barcode: barcode,
          orderId: order.id,
          customerName: order.customerName,
          boxNumber: _selectedBoxNumber,
          context: context,
          onShowOverlay: (context, status, message) {
            // Screen hala mount edilmiş mi kontrol et
            if (!mounted) return;

            // Success durumunda overlay gösterme, sadece hata/uyarılarda göster
            if (status == BarcodeStatus.success) return;

            // Overlay service'i kullanarak göster
            BarcodeOverlayService.instance.showBarcodeStatus(
              context,
              status,
              message,
              duration: const Duration(seconds: 3),
            );
          },
          onOrderUpdated: () {
            // Screen hala mount edilmiş mi kontrol et
            if (!mounted) return;

            ref
                .read(orderDetailNotifierProvider(widget.orderCode).notifier)
                .refreshOrderDetails();

            // Başarılı okuma sonrası animasyonu tetikle
            _triggerQuantityAnimation(currentItemDetails, barcode);
          },
        );
  }

  /// Başarılı barkod okuma sonrası miktar animasyonunu tetikler
  void _triggerQuantityAnimation(
      List<OrderItemDetail> previousItemDetails, String barcode) {
    // Screen dispose kontrolü
    if (!mounted) return;

    // Kısa bir gecikme sonrası yeni state'i kontrol et
    Future.delayed(const Duration(milliseconds: 100), () {
      // Async gecikme sonrası tekrar kontrol et
      if (!mounted) return;

      final newState = ref.read(orderDetailNotifierProvider(widget.orderCode));
      final newItemDetails = newState.orderItemDetails ?? [];

      // Hangi ürünün miktarı arttı bul
      for (int i = 0;
          i < newItemDetails.length && i < previousItemDetails.length;
          i++) {
        final oldQuantity = previousItemDetails[i].orderItem.scannedQuantity;
        final newQuantity = newItemDetails[i].orderItem.scannedQuantity;

        if (newQuantity > oldQuantity) {
          if (!mounted) return; // setState öncesi son kontrol

          setState(() {
            _lastUpdatedProductId = newItemDetails[i].orderItem.productId;
          });

          // Animasyonu başlat
          _quantityAnimationController.forward().then((_) {
            if (mounted) {
              // Animation complete callback'inde de kontrol
              _quantityAnimationController.reverse();
            }
          });
          break;
        }
      }
    });
  }

  /// Animasyonlu miktar gösterici widget'ı
  Widget _buildAnimatedQuantityText(String text, int? productId) {
    final isAnimating = _lastUpdatedProductId == productId;

    if (!isAnimating) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _quantityScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _quantityScaleAnimation.value,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _quantityScaleAnimation.value > 1.1
                  ? Colors.green[600]
                  : null,
            ),
          ),
        );
      },
    );
  }

  /// Büyük animasyonlu miktar gösterici (recent product cards için)
  Widget _buildAnimatedQuantityTextLarge(String text, int? productId) {
    final isAnimating = _lastUpdatedProductId == productId;

    if (!isAnimating) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _quantityScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _quantityScaleAnimation.value,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _quantityScaleAnimation.value > 1.1
                  ? Colors.green[600]
                  : null,
            ),
          ),
        );
      },
    );
  }
}
