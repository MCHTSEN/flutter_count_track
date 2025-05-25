import 'package:flutter/material.dart';
import 'package:flutter_count_track/features/dashboard/data/models/dashboard_stats.dart';
import 'package:flutter_count_track/features/dashboard/presentation/components/stats_card.dart';

class StatsSection extends StatelessWidget {
  final DashboardStats stats;

  const StatsSection({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genel İstatistikler',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),

        // İlk satır - Ana istatistikler
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Toplam Sipariş',
                value: stats.totalOrders.toString(),
                icon: Icons.shopping_cart,
                color: Colors.blue,
                subtitle: 'Tüm zamanlar',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Toplam Müşteri',
                value: stats.totalCustomers.toString(),
                icon: Icons.people,
                color: Colors.purple,
                subtitle: 'Aktif müşteriler',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Toplam Ürün',
                value: stats.totalProducts.toString(),
                icon: Icons.inventory,
                color: Colors.orange,
                subtitle: 'Katalogda',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // İkinci satır - Sipariş durumları
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Tamamlanan',
                value: stats.completedOrders.toString(),
                icon: Icons.check_circle,
                color: Colors.green,
                subtitle: 'Sipariş',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Bekleyen',
                value: stats.pendingOrders.toString(),
                icon: Icons.pending,
                color: Colors.orange,
                subtitle: 'Sipariş',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Kısmi',
                value: stats.partialOrders.toString(),
                icon: Icons.hourglass_empty,
                color: Colors.blue,
                subtitle: 'Sipariş',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Üçüncü satır - Tamamlanma oranı
        ProgressStatsCard(
          title: 'Tamamlanma Oranı',
          value: '${stats.completionRate.toStringAsFixed(1)}%',
          progress: stats.completionRate / 100,
          icon: Icons.trending_up,
          color: Colors.green,
          subtitle: 'Genel başarı oranı',
        ),
      ],
    );
  }
}
