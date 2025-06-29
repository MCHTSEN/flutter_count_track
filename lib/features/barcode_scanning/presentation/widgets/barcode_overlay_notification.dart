import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_count_track/features/barcode_scanning/presentation/notifiers/barcode_notifier.dart';

class BarcodeOverlayService {
  static BarcodeOverlayService? _instance;
  static BarcodeOverlayService get instance =>
      _instance ??= BarcodeOverlayService._();
  BarcodeOverlayService._();

  OverlayEntry? _currentOverlay;
  Timer? _autoCloseTimer;

  /// Barkod status overlay'ini gösterir
  void showBarcodeStatus(
    BuildContext context,
    BarcodeStatus status,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    // Önceki overlay varsa kapat
    _closeCurrentOverlay();

    // Yeni overlay oluştur
    final overlayEntry = _createOverlayEntry(status, message);

    // Overlay'i göster
    Overlay.of(context).insert(overlayEntry);
    _currentOverlay = overlayEntry;

    // Otomatik kapanma timer'ı başlat
    _autoCloseTimer = Timer(duration, () {
      _closeCurrentOverlay();
    });
  }

  /// Mevcut overlay'i kapatır
  void _closeCurrentOverlay() {
    _autoCloseTimer?.cancel();
    _autoCloseTimer = null;

    if (_currentOverlay != null) {
      _currentOverlay!.remove();
      _currentOverlay = null;
    }
  }

  /// Overlay entry oluşturur
  OverlayEntry _createOverlayEntry(BarcodeStatus status, String message) {
    return OverlayEntry(
      builder: (context) => BarcodeOverlayNotification(
        status: status,
        message: message,
        onClose: _closeCurrentOverlay,
      ),
    );
  }

  /// Servis temizleme
  void dispose() {
    _closeCurrentOverlay();
  }
}

class BarcodeOverlayNotification extends StatefulWidget {
  final BarcodeStatus status;
  final String message;
  final VoidCallback onClose;

  const BarcodeOverlayNotification({
    super.key,
    required this.status,
    required this.message,
    required this.onClose,
  });

  @override
  State<BarcodeOverlayNotification> createState() =>
      _BarcodeOverlayNotificationState();
}

class _BarcodeOverlayNotificationState extends State<BarcodeOverlayNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Animasyonu başlat
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.status) {
      case BarcodeStatus.success:
        return Colors.green[600]!;
      case BarcodeStatus.warning:
        return Colors.orange[600]!;
      case BarcodeStatus.error:
        return Colors.red[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  IconData _getIcon() {
    switch (widget.status) {
      case BarcodeStatus.success:
        return Icons.check_circle_outline;
      case BarcodeStatus.warning:
        return Icons.warning_amber_outlined;
      case BarcodeStatus.error:
        return Icons.error_outline;
      default:
        return Icons.info_outline;
    }
  }

  String _getTitle() {
    switch (widget.status) {
      case BarcodeStatus.success:
        return 'Başarılı!';
      case BarcodeStatus.warning:
        return 'Uyarı!';
      case BarcodeStatus.error:
        return 'Hata!';
      default:
        return 'Bilgi';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final overlayWidth = screenSize.width * 0.7;
    final overlayHeight = screenSize.height * 0.7;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: widget.onClose,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: Container(
                      width: overlayWidth,
                      height: overlayHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Başlık bölümü
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            decoration: BoxDecoration(
                              color: _getBackgroundColor(),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  _getIcon(),
                                  size: 80,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _getTitle(),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // İçerik bölümü
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.message,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[800],
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 40),

                                  // Kapatma butonu
                                  ElevatedButton.icon(
                                    onPressed: widget.onClose,
                                    icon: const Icon(Icons.close, size: 24),
                                    label: const Text(
                                      'Kapat',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _getBackgroundColor(),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
