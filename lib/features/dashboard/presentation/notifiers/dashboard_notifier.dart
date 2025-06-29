import 'dart:async';

import 'package:flutter_count_track/features/dashboard/data/models/dashboard_stats.dart';
import 'package:flutter_count_track/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

// Dashboard state sınıfı
class DashboardState {
  final DashboardStats? stats;
  final bool isLoading;
  final String? error;
  final List<ProductStats> topProducts;
  final List<CustomerStats> topCustomers;
  final DateTime? lastRefreshTime;

  const DashboardState({
    this.stats,
    this.isLoading = false,
    this.error,
    this.topProducts = const [],
    this.topCustomers = const [],
    this.lastRefreshTime,
  });

  DashboardState copyWith({
    DashboardStats? stats,
    bool? isLoading,
    String? error,
    List<ProductStats>? topProducts,
    List<CustomerStats>? topCustomers,
    DateTime? lastRefreshTime,
    bool clearError = false,
  }) {
    return DashboardState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      topProducts: topProducts ?? this.topProducts,
      topCustomers: topCustomers ?? this.topCustomers,
      lastRefreshTime: lastRefreshTime ?? this.lastRefreshTime,
    );
  }
}

// Dashboard notifier
class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRepository _repository;
  final Logger _logger = Logger('DashboardNotifier');
  Timer? _periodicTimer;

  DashboardNotifier(this._repository) : super(const DashboardState()) {
    loadDashboardData();
    _startPeriodicRefresh();
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    super.dispose();
  }

  /// 60 saniyelik periyodik refresh başlatır
  void _startPeriodicRefresh() {
    _periodicTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _logger.info('⏰ DashboardNotifier: 60 saniyelik periyodik refresh');
      loadDashboardData(isPeriodicRefresh: true);
    });
    _logger
        .info('⏰ DashboardNotifier: Periyodik refresh başlatıldı (60 saniye)');
  }

  /// Ekran focus durumunda çağrılacak method
  void onScreenFocus() {
    _logger.info(
        '👁️ DashboardNotifier: Ekran focus alındı, verileri yenileniyor');
    loadDashboardData(isScreenFocus: true);
  }

  // Dashboard verilerini yükle
  Future<void> loadDashboardData({
    bool isPeriodicRefresh = false,
    bool isScreenFocus = false,
  }) async {
    // Periyodik refresh ise loading gösterme
    if (!isPeriodicRefresh && !isScreenFocus) {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      _logger.info('🔄 DashboardNotifier: Dashboard verileri yükleniyor...');

      // Paralel olarak tüm verileri çek
      final futures = await Future.wait([
        _repository.getDashboardStats(),
        _repository.getTopProductsByQuantity(limit: 10),
        _repository.getTopCustomersByOrderCount(limit: 10),
      ]);

      final stats = futures[0] as DashboardStats;
      final topProducts = futures[1] as List<ProductStats>;
      final topCustomers = futures[2] as List<CustomerStats>;

      state = state.copyWith(
        stats: stats,
        topProducts: topProducts,
        topCustomers: topCustomers,
        isLoading: false,
        lastRefreshTime: DateTime.now(),
      );

      _logger.info('✅ DashboardNotifier: Dashboard verileri yüklendi');
    } catch (e) {
      _logger.severe('💥 DashboardNotifier: Veri yükleme hatası', e);
      state = state.copyWith(
        isLoading: false,
        error: 'Dashboard verileri yüklenirken hata oluştu: ${e.toString()}',
      );
    }
  }

  // Verileri yenile
  Future<void> refreshData() async {
    _logger.info('🔄 DashboardNotifier: Manuel refresh tetiklendi');
    await loadDashboardData();
  }

  // Belirli tarih aralığı için veriler
  Future<void> loadDataForDateRange(
      DateTime startDate, DateTime endDate) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      _logger
          .info('🔄 DashboardNotifier: Tarih aralığı verileri yükleniyor...');

      final stats = await _repository.getDashboardStatsForDateRange(
        startDate: startDate,
        endDate: endDate,
      );

      state = state.copyWith(
        stats: stats,
        isLoading: false,
        lastRefreshTime: DateTime.now(),
      );

      _logger.info('✅ DashboardNotifier: Tarih aralığı verileri yüklendi');
    } catch (e) {
      _logger.severe(
          '💥 DashboardNotifier: Tarih aralığı veri yükleme hatası', e);
      state = state.copyWith(
        isLoading: false,
        error:
            'Tarih aralığı verileri yüklenirken hata oluştu: ${e.toString()}',
      );
    }
  }

  // Hata durumunu temizle
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
