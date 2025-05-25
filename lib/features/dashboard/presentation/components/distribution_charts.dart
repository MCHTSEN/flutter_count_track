import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// En çok yapılan ürünler pasta grafiği
class TopProductsPieChart extends StatelessWidget {
  final Map<String, int> topProducts;
  final String title;

  const TopProductsPieChart({
    super.key,
    required this.topProducts,
    this.title = 'En Çok Yapılan Ürünler',
  });

  @override
  Widget build(BuildContext context) {
    final chartData = topProducts.entries
        .map((entry) => _ChartData(entry.key, entry.value))
        .toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCircularChart(
                legend: const Legend(
                  isVisible: true,
                  position: LegendPosition.right,
                  overflowMode: LegendItemOverflowMode.wrap,
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CircularSeries>[
                  PieSeries<_ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (_ChartData data, _) => data.label,
                    yValueMapper: (_ChartData data, _) => data.value,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                    ),
                    enableTooltip: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// En çok sipariş veren müşteriler bar grafiği
class TopCustomersBarChart extends StatelessWidget {
  final Map<String, int> topCustomers;
  final String title;

  const TopCustomersBarChart({
    super.key,
    required this.topCustomers,
    this.title = 'En Çok Sipariş Veren Müşteriler',
  });

  @override
  Widget build(BuildContext context) {
    final chartData = topCustomers.entries
        .map((entry) => _ChartData(entry.key, entry.value))
        .toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: const CategoryAxis(
                  labelRotation: -45,
                  labelStyle: TextStyle(fontSize: 10),
                ),
                primaryYAxis: const NumericAxis(
                  title: AxisTitle(text: 'Sipariş Sayısı'),
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  BarSeries<_ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (_ChartData data, _) => data.label,
                    yValueMapper: (_ChartData data, _) => data.value,
                    color: Colors.orange,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Sipariş durumu dağılımı donut grafiği
class OrderStatusDonutChart extends StatelessWidget {
  final int completedOrders;
  final int pendingOrders;
  final int partialOrders;
  final String title;

  const OrderStatusDonutChart({
    super.key,
    required this.completedOrders,
    required this.pendingOrders,
    required this.partialOrders,
    this.title = 'Sipariş Durumu Dağılımı',
  });

  @override
  Widget build(BuildContext context) {
    final chartData = [
      _ChartData('Tamamlanan', completedOrders),
      _ChartData('Bekliyor', pendingOrders),
      _ChartData('Kısmi', partialOrders),
    ];

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCircularChart(
                legend: const Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CircularSeries>[
                  DoughnutSeries<_ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (_ChartData data, _) => data.label,
                    yValueMapper: (_ChartData data, _) => data.value,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                    ),
                    pointColorMapper: (_ChartData data, _) {
                      switch (data.label) {
                        case 'Tamamlanan':
                          return Colors.green;
                        case 'Bekliyor':
                          return Colors.orange;
                        case 'Kısmi':
                          return Colors.blue;
                        default:
                          return Colors.grey;
                      }
                    },
                    enableTooltip: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Yardımcı veri sınıfı
class _ChartData {
  final String label;
  final int value;

  _ChartData(this.label, this.value);
}
