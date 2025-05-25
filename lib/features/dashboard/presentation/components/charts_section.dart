import 'package:flutter/material.dart';
import 'package:flutter_count_track/features/dashboard/data/models/dashboard_stats.dart';
import 'package:flutter_count_track/features/dashboard/presentation/components/distribution_charts.dart';
import 'package:flutter_count_track/features/dashboard/presentation/components/time_based_charts.dart';

class ChartsSection extends StatelessWidget {
  final DashboardStats stats;

  const ChartsSection({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Grafikler ve Analizler',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),

        // Sipariş durumu donut grafiği
        OrderStatusDonutChart(
          completedOrders: stats.completedOrders,
          pendingOrders: stats.pendingOrders,
          partialOrders: stats.partialOrders,
        ),
        const SizedBox(height: 16),

        // En çok yapılan ürünler ve müşteriler
        if (stats.topProducts.isNotEmpty || stats.topCustomers.isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (stats.topProducts.isNotEmpty)
                Expanded(
                  child: TopProductsPieChart(
                    topProducts: stats.topProducts,
                  ),
                ),
              if (stats.topProducts.isNotEmpty && stats.topCustomers.isNotEmpty)
                const SizedBox(width: 16),
              if (stats.topCustomers.isNotEmpty)
                Expanded(
                  child: TopCustomersBarChart(
                    topCustomers: stats.topCustomers,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Zaman bazlı grafikler
        if (stats.monthlyOrderData.isNotEmpty)
          MonthlyOrderChart(data: stats.monthlyOrderData),
        const SizedBox(height: 16),

        if (stats.weeklyOrderData.isNotEmpty)
          WeeklyOrderChart(data: stats.weeklyOrderData),
        const SizedBox(height: 16),

        if (stats.dailyOrderData.isNotEmpty)
          DailyOrderChart(data: stats.dailyOrderData),
      ],
    );
  }
}
