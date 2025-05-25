import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_count_track/features/dashboard/data/models/dashboard_stats.dart';
import 'package:flutter_count_track/features/dashboard/domain/repositories/dashboard_repository.dart';

// Dashboard state sınıfı
class DashboardState {
  final DashboardStats? stats;
  final bool isLoading;
  final String? error;
  final List<ProductStats> topProducts;
  final List<CustomerStats> topCustomers;

  const DashboardState({
    this.stats,
    this.isLoading = false,
    this.error,
    this.topProducts = const [],
    this.topCustomers = const [],
  });

  DashboardState copyWith({
    DashboardStats? stats,
    bool? isLoading,
    String? error,
    List<ProductStats>? topProducts,
    List<CustomerStats>? topCustomers,
  }) {
    return DashboardState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      topProducts: topProducts ?? this.topProducts,
      topCustomers: topCustomers ?? this.topCustomers,
    );
  }
}

// Dashboard notifier
class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRepository _repository;

  DashboardNotifier(this._repository) : super(const DashboardState());

  // Dashboard verilerini yükle
  Future<void> loadDashboardData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
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
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Dashboard verileri yüklenirken hata oluştu: ${e.toString()}',
      );
    }
  }

  // Verileri yenile
  Future<void> refreshData() async {
    await loadDashboardData();
  }

  // Belirli tarih aralığı için veriler
  Future<void> loadDataForDateRange(
      DateTime startDate, DateTime endDate) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final stats = await _repository.getDashboardStatsForDateRange(
        startDate: startDate,
        endDate: endDate,
      );

      state = state.copyWith(
        stats: stats,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error:
            'Tarih aralığı verileri yüklenirken hata oluştu: ${e.toString()}',
      );
    }
  }

  // Hata durumunu temizle
  void clearError() {
    state = state.copyWith(error: null);
  }
}
