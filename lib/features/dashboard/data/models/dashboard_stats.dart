class DashboardStats {
  final int totalOrders;
  final int completedOrders;
  final int pendingOrders;
  final int partialOrders;
  final int totalProducts;
  final int totalCustomers;
  final double completionRate;
  final Map<String, int> topProducts; // Ürün adı -> Miktar
  final Map<String, int> topCustomers; // Müşteri adı -> Sipariş sayısı
  final List<MonthlyData> monthlyOrderData;
  final List<WeeklyData> weeklyOrderData;
  final List<DailyData> dailyOrderData;

  DashboardStats({
    required this.totalOrders,
    required this.completedOrders,
    required this.pendingOrders,
    required this.partialOrders,
    required this.totalProducts,
    required this.totalCustomers,
    required this.completionRate,
    required this.topProducts,
    required this.topCustomers,
    required this.monthlyOrderData,
    required this.weeklyOrderData,
    required this.dailyOrderData,
  });
}

class MonthlyData {
  final String month; // "2024-01", "2024-02" formatında
  final int orderCount;
  final int completedCount;
  final int totalQuantity;

  MonthlyData({
    required this.month,
    required this.orderCount,
    required this.completedCount,
    required this.totalQuantity,
  });
}

class WeeklyData {
  final String week; // "2024-W01", "2024-W02" formatında
  final int orderCount;
  final int completedCount;
  final int totalQuantity;

  WeeklyData({
    required this.week,
    required this.orderCount,
    required this.completedCount,
    required this.totalQuantity,
  });
}

class DailyData {
  final DateTime date;
  final int orderCount;
  final int completedCount;
  final int totalQuantity;

  DailyData({
    required this.date,
    required this.orderCount,
    required this.completedCount,
    required this.totalQuantity,
  });
}

class ProductStats {
  final String productName;
  final String productCode;
  final int totalQuantity;
  final int orderCount;
  final double averageQuantityPerOrder;

  ProductStats({
    required this.productName,
    required this.productCode,
    required this.totalQuantity,
    required this.orderCount,
    required this.averageQuantityPerOrder,
  });
}

class CustomerStats {
  final String customerName;
  final int orderCount;
  final int totalQuantity;
  final DateTime lastOrderDate;
  final double averageOrderSize;

  CustomerStats({
    required this.customerName,
    required this.orderCount,
    required this.totalQuantity,
    required this.lastOrderDate,
    required this.averageOrderSize,
  });
}
