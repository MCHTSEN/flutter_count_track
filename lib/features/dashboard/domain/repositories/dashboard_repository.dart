import 'package:flutter_count_track/features/dashboard/data/models/dashboard_stats.dart';

abstract class DashboardRepository {
  // Genel istatistikler
  Future<DashboardStats> getDashboardStats();

  // En çok yapılan ürünler (miktar bazında)
  Future<List<ProductStats>> getTopProductsByQuantity({int limit = 10});

  // En çok sipariş veren müşteriler
  Future<List<CustomerStats>> getTopCustomersByOrderCount({int limit = 10});

  // Aylık veriler (son 12 ay)
  Future<List<MonthlyData>> getMonthlyOrderData({int monthCount = 12});

  // Haftalık veriler (son 12 hafta)
  Future<List<WeeklyData>> getWeeklyOrderData({int weekCount = 12});

  // Günlük veriler (son 30 gün)
  Future<List<DailyData>> getDailyOrderData({int dayCount = 30});

  // Belirli tarih aralığındaki veriler
  Future<DashboardStats> getDashboardStatsForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  // Müşteri bazında detaylı istatistikler
  Future<List<CustomerStats>> getCustomerStats();

  // Ürün bazında detaylı istatistikler
  Future<List<ProductStats>> getProductStats();
}
