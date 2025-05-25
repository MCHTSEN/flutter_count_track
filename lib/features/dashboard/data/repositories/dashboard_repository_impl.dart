import 'package:drift/drift.dart';
import 'package:flutter_count_track/core/database/app_database.dart';
import 'package:flutter_count_track/features/dashboard/data/models/dashboard_stats.dart';
import 'package:flutter_count_track/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final AppDatabase _db;

  DashboardRepositoryImpl(this._db);

  @override
  Future<DashboardStats> getDashboardStats() async {
    // Toplam sipariş sayıları
    final totalOrders =
        await _db.select(_db.orders).get().then((orders) => orders.length);

    final completedOrders = await (_db.select(_db.orders)
          ..where((o) => o.status.equals(OrderStatus.completed.name)))
        .get()
        .then((orders) => orders.length);

    final pendingOrders = await (_db.select(_db.orders)
          ..where((o) => o.status.equals(OrderStatus.pending.name)))
        .get()
        .then((orders) => orders.length);

    final partialOrders = await (_db.select(_db.orders)
          ..where((o) => o.status.equals(OrderStatus.partial.name)))
        .get()
        .then((orders) => orders.length);

    // Toplam ürün ve müşteri sayıları
    final totalProducts = await _db
        .select(_db.products)
        .get()
        .then((products) => products.length);

    final allOrders = await _db.select(_db.orders).get();
    final uniqueCustomers = allOrders.map((o) => o.customerName).toSet();
    final totalCustomers = uniqueCustomers.length;

    // Tamamlanma oranı
    final completionRate =
        totalOrders > 0 ? (completedOrders / totalOrders) * 100 : 0.0;

    // En çok yapılan ürünler
    final topProducts = await _getTopProductsMap();

    // En çok sipariş veren müşteriler
    final topCustomers = await _getTopCustomersMap();

    // Zaman bazlı veriler
    final monthlyData = await getMonthlyOrderData();
    final weeklyData = await getWeeklyOrderData();
    final dailyData = await getDailyOrderData();

    return DashboardStats(
      totalOrders: totalOrders,
      completedOrders: completedOrders,
      pendingOrders: pendingOrders,
      partialOrders: partialOrders,
      totalProducts: totalProducts,
      totalCustomers: totalCustomers,
      completionRate: completionRate,
      topProducts: topProducts,
      topCustomers: topCustomers,
      monthlyOrderData: monthlyData,
      weeklyOrderData: weeklyData,
      dailyOrderData: dailyData,
    );
  }

  @override
  Future<List<ProductStats>> getTopProductsByQuantity({int limit = 10}) async {
    // Ürün bazında toplam miktar hesaplama
    final query = _db.select(_db.products).join([
      leftOuterJoin(
          _db.orderItems, _db.orderItems.productId.equalsExp(_db.products.id)),
      leftOuterJoin(_db.deliveryItems,
          _db.deliveryItems.productId.equalsExp(_db.products.id)),
    ]);

    final results = await query.get();
    final Map<int, ProductStats> productStatsMap = {};

    for (final row in results) {
      final product = row.readTable(_db.products);
      final orderItem = row.readTableOrNull(_db.orderItems);
      final deliveryItem = row.readTableOrNull(_db.deliveryItems);

      if (!productStatsMap.containsKey(product.id)) {
        productStatsMap[product.id] = ProductStats(
          productName: product.name,
          productCode: product.ourProductCode,
          totalQuantity: 0,
          orderCount: 0,
          averageQuantityPerOrder: 0.0,
        );
      }

      if (deliveryItem != null) {
        final current = productStatsMap[product.id]!;
        productStatsMap[product.id] = ProductStats(
          productName: current.productName,
          productCode: current.productCode,
          totalQuantity: current.totalQuantity + deliveryItem.quantity,
          orderCount: current.orderCount + 1,
          averageQuantityPerOrder: current.averageQuantityPerOrder,
        );
      }
    }

    // Ortalama hesaplama ve sıralama
    final productStatsList = productStatsMap.values.map((stats) {
      return ProductStats(
        productName: stats.productName,
        productCode: stats.productCode,
        totalQuantity: stats.totalQuantity,
        orderCount: stats.orderCount,
        averageQuantityPerOrder:
            stats.orderCount > 0 ? stats.totalQuantity / stats.orderCount : 0.0,
      );
    }).toList();

    productStatsList.sort((a, b) => b.totalQuantity.compareTo(a.totalQuantity));
    return productStatsList.take(limit).toList();
  }

  @override
  Future<List<CustomerStats>> getTopCustomersByOrderCount(
      {int limit = 10}) async {
    final orders = await _db.select(_db.orders).get();
    final Map<String, CustomerStats> customerStatsMap = {};

    for (final order in orders) {
      if (!customerStatsMap.containsKey(order.customerName)) {
        customerStatsMap[order.customerName] = CustomerStats(
          customerName: order.customerName,
          orderCount: 0,
          totalQuantity: 0,
          lastOrderDate: order.createdAt,
          averageOrderSize: 0.0,
        );
      }

      final current = customerStatsMap[order.customerName]!;

      // Sipariş toplam miktarını hesapla
      final orderItems = await (_db.select(_db.orderItems)
            ..where((oi) => oi.orderId.equals(order.id)))
          .get();

      final orderTotalQuantity =
          orderItems.fold<int>(0, (sum, item) => sum + item.quantity);

      customerStatsMap[order.customerName] = CustomerStats(
        customerName: current.customerName,
        orderCount: current.orderCount + 1,
        totalQuantity: current.totalQuantity + orderTotalQuantity,
        lastOrderDate: order.createdAt.isAfter(current.lastOrderDate)
            ? order.createdAt
            : current.lastOrderDate,
        averageOrderSize: current.averageOrderSize,
      );
    }

    // Ortalama hesaplama ve sıralama
    final customerStatsList = customerStatsMap.values.map((stats) {
      return CustomerStats(
        customerName: stats.customerName,
        orderCount: stats.orderCount,
        totalQuantity: stats.totalQuantity,
        lastOrderDate: stats.lastOrderDate,
        averageOrderSize:
            stats.orderCount > 0 ? stats.totalQuantity / stats.orderCount : 0.0,
      );
    }).toList();

    customerStatsList.sort((a, b) => b.orderCount.compareTo(a.orderCount));
    return customerStatsList.take(limit).toList();
  }

  @override
  Future<List<MonthlyData>> getMonthlyOrderData({int monthCount = 12}) async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - monthCount + 1, 1);

    final orders = await (_db.select(_db.orders)
          ..where((o) => o.createdAt.isBiggerOrEqualValue(startDate)))
        .get();

    final Map<String, MonthlyData> monthlyMap = {};

    for (final order in orders) {
      final monthKey =
          '${order.createdAt.year}-${order.createdAt.month.toString().padLeft(2, '0')}';

      if (!monthlyMap.containsKey(monthKey)) {
        monthlyMap[monthKey] = MonthlyData(
          month: monthKey,
          orderCount: 0,
          completedCount: 0,
          totalQuantity: 0,
        );
      }

      final current = monthlyMap[monthKey]!;
      final isCompleted = order.status == OrderStatus.completed;

      // Sipariş toplam miktarını hesapla
      final orderItems = await (_db.select(_db.orderItems)
            ..where((oi) => oi.orderId.equals(order.id)))
          .get();

      final orderTotalQuantity =
          orderItems.fold<int>(0, (sum, item) => sum + item.quantity);

      monthlyMap[monthKey] = MonthlyData(
        month: current.month,
        orderCount: current.orderCount + 1,
        completedCount: current.completedCount + (isCompleted ? 1 : 0),
        totalQuantity: current.totalQuantity + orderTotalQuantity,
      );
    }

    final result = monthlyMap.values.toList();
    result.sort((a, b) => a.month.compareTo(b.month));
    return result;
  }

  @override
  Future<List<WeeklyData>> getWeeklyOrderData({int weekCount = 12}) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: weekCount * 7));

    final orders = await (_db.select(_db.orders)
          ..where((o) => o.createdAt.isBiggerOrEqualValue(startDate)))
        .get();

    final Map<String, WeeklyData> weeklyMap = {};

    for (final order in orders) {
      final weekNumber = _getWeekNumber(order.createdAt);
      final weekKey =
          '${order.createdAt.year}-W${weekNumber.toString().padLeft(2, '0')}';

      if (!weeklyMap.containsKey(weekKey)) {
        weeklyMap[weekKey] = WeeklyData(
          week: weekKey,
          orderCount: 0,
          completedCount: 0,
          totalQuantity: 0,
        );
      }

      final current = weeklyMap[weekKey]!;
      final isCompleted = order.status == OrderStatus.completed;

      // Sipariş toplam miktarını hesapla
      final orderItems = await (_db.select(_db.orderItems)
            ..where((oi) => oi.orderId.equals(order.id)))
          .get();

      final orderTotalQuantity =
          orderItems.fold<int>(0, (sum, item) => sum + item.quantity);

      weeklyMap[weekKey] = WeeklyData(
        week: current.week,
        orderCount: current.orderCount + 1,
        completedCount: current.completedCount + (isCompleted ? 1 : 0),
        totalQuantity: current.totalQuantity + orderTotalQuantity,
      );
    }

    final result = weeklyMap.values.toList();
    result.sort((a, b) => a.week.compareTo(b.week));
    return result;
  }

  @override
  Future<List<DailyData>> getDailyOrderData({int dayCount = 30}) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: dayCount));

    final orders = await (_db.select(_db.orders)
          ..where((o) => o.createdAt.isBiggerOrEqualValue(startDate)))
        .get();

    final Map<String, DailyData> dailyMap = {};

    for (final order in orders) {
      final dateKey =
          '${order.createdAt.year}-${order.createdAt.month.toString().padLeft(2, '0')}-${order.createdAt.day.toString().padLeft(2, '0')}';
      final date = DateTime(
          order.createdAt.year, order.createdAt.month, order.createdAt.day);

      if (!dailyMap.containsKey(dateKey)) {
        dailyMap[dateKey] = DailyData(
          date: date,
          orderCount: 0,
          completedCount: 0,
          totalQuantity: 0,
        );
      }

      final current = dailyMap[dateKey]!;
      final isCompleted = order.status == OrderStatus.completed;

      // Sipariş toplam miktarını hesapla
      final orderItems = await (_db.select(_db.orderItems)
            ..where((oi) => oi.orderId.equals(order.id)))
          .get();

      final orderTotalQuantity =
          orderItems.fold<int>(0, (sum, item) => sum + item.quantity);

      dailyMap[dateKey] = DailyData(
        date: current.date,
        orderCount: current.orderCount + 1,
        completedCount: current.completedCount + (isCompleted ? 1 : 0),
        totalQuantity: current.totalQuantity + orderTotalQuantity,
      );
    }

    final result = dailyMap.values.toList();
    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  @override
  Future<DashboardStats> getDashboardStatsForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Bu metod belirli tarih aralığı için istatistikleri döndürür
    // Şimdilik basit implementasyon, gerekirse genişletilebilir
    return getDashboardStats();
  }

  @override
  Future<List<CustomerStats>> getCustomerStats() async {
    return getTopCustomersByOrderCount(limit: 1000); // Tüm müşteriler
  }

  @override
  Future<List<ProductStats>> getProductStats() async {
    return getTopProductsByQuantity(limit: 1000); // Tüm ürünler
  }

  // Yardımcı metodlar
  Future<Map<String, int>> _getTopProductsMap() async {
    final topProducts = await getTopProductsByQuantity(limit: 5);
    final Map<String, int> result = {};
    for (final product in topProducts) {
      result[product.productName] = product.totalQuantity;
    }
    return result;
  }

  Future<Map<String, int>> _getTopCustomersMap() async {
    final topCustomers = await getTopCustomersByOrderCount(limit: 5);
    final Map<String, int> result = {};
    for (final customer in topCustomers) {
      result[customer.customerName] = customer.orderCount;
    }
    return result;
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay + firstDayOfYear.weekday - 1) / 7).ceil();
  }
}
