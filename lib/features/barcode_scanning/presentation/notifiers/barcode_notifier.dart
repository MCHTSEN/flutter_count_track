import 'package:flutter/material.dart';
import 'package:flutter_count_track/core/database/database_provider.dart';
import 'package:flutter_count_track/features/barcode_scanning/data/repositories/barcode_repository_impl.dart';
import 'package:flutter_count_track/features/barcode_scanning/data/services/sound_service.dart';
import 'package:flutter_count_track/features/barcode_scanning/domain/usecases/process_barcode_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BarcodeStatus {
  none,
  processing,
  success,
  warning,
  error,
}

class BarcodeState {
  final BarcodeStatus status;
  final String message;
  final bool isProcessing;

  BarcodeState({
    this.status = BarcodeStatus.none,
    this.message = '',
    this.isProcessing = false,
  });

  BarcodeState copyWith({
    BarcodeStatus? status,
    String? message,
    bool? isProcessing,
  }) {
    return BarcodeState(
      status: status ?? this.status,
      message: message ?? this.message,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

// Overlay gösterme callback tipi
typedef OverlayCallback = void Function(
  BuildContext context,
  BarcodeStatus status,
  String message,
);

class BarcodeNotifier extends StateNotifier<BarcodeState> {
  final ProcessBarcodeUseCase _processBarcodeUseCase;
  final SoundService _soundService;

  BarcodeNotifier(this._processBarcodeUseCase, this._soundService)
      : super(BarcodeState());

  Future<void> processBarcode({
    required String barcode,
    required int orderId,
    required String customerName,
    required VoidCallback onOrderUpdated,
    int? boxNumber,
    OverlayCallback? onShowOverlay,
    BuildContext? context,
  }) async {
    // Mounted kontrolü - dispose edildiyse işlem yapma
    if (!mounted) return;

    if (state.isProcessing) return;

    state = state.copyWith(isProcessing: true);

    final result = await _processBarcodeUseCase(
      orderId: orderId,
      barcode: barcode,
      customerName: customerName,
      boxNumber: boxNumber,
    );

    // Async işlem sonrası mounted kontrolü
    if (!mounted) return;

    String message;
    BarcodeStatus status;

    switch (result) {
      case BarcodeProcessResult.success:
        message = 'Barkod başarıyla okundu.';
        status = BarcodeStatus.success;
        // Başarı için sadece ses çal, overlay gösterme
        await _soundService.playSound(SoundType.success);
        onOrderUpdated(); // Sipariş verilerini güncelle
        break;
      case BarcodeProcessResult.duplicateUniqueBarcode:
        message = 'Bu barkod zaten okutuldu!';
        status = BarcodeStatus.warning;
        // Hata durumları için hem ses hem overlay
        await _soundService.playSound(SoundType.warning);
        break;
      case BarcodeProcessResult.productNotFound:
        message = 'Barkod bulunamadı!';
        status = BarcodeStatus.error;
        // Hata durumları için hem ses hem overlay
        await _soundService.playSound(SoundType.error);
        break;
      case BarcodeProcessResult.productNotInOrder:
        message = 'Ürün bu siparişte bulunmuyor!';
        status = BarcodeStatus.error;
        // Hata durumları için hem ses hem overlay
        await _soundService.playSound(SoundType.error);
        break;
      case BarcodeProcessResult.orderItemAlreadyComplete:
        message = 'Bu ürün için gerekli miktar zaten okutuldu!';
        status = BarcodeStatus.warning;
        // Hata durumları için hem ses hem overlay
        await _soundService.playSound(SoundType.warning);
        break;
    }

    // State güncelleme öncesi mounted kontrolü
    if (!mounted) return;

    // State'i güncelle
    state = state.copyWith(
      status: status,
      message: message,
      isProcessing: false,
    );

    // Overlay callback'i varsa çağır
    if (onShowOverlay != null && context != null) {
      onShowOverlay(context, status, message);
    }

    // State'i temizle (geçici durum için)
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        state = state.copyWith(
          status: BarcodeStatus.none,
          message: '',
        );
      }
    });
  }

  void clearStatus() {
    if (!mounted) return;

    state = state.copyWith(
      status: BarcodeStatus.none,
      message: '',
    );
  }
}

// Yönlendirici provider
final barcodeNotifierProvider =
    StateNotifierProvider.autoDispose<BarcodeNotifier, BarcodeState>((ref) {
  final processBarcodeUseCase = ref.watch(processBarcodeUseCaseProvider);
  final soundService = ref.watch(soundServiceProvider);
  return BarcodeNotifier(processBarcodeUseCase, soundService);
});

// Bağımlılık sağlayıcılar
final processBarcodeUseCaseProvider = Provider((ref) {
  final barcodeRepository = ref.watch(barcodeRepositoryProvider);
  return ProcessBarcodeUseCase(barcodeRepository);
});

final barcodeRepositoryProvider = Provider((ref) {
  final database = ref.watch(appDatabaseProvider);
  return BarcodeRepositoryImpl(database);
});

final soundServiceProvider = Provider((ref) {
  return SoundService();
});
