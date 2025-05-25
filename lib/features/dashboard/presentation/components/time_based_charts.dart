import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_count_track/features/dashboard/data/models/dashboard_stats.dart';
import 'package:intl/intl.dart';

// Aylık sipariş grafiği
class MonthlyOrderChart extends StatelessWidget {
  final List<MonthlyData> data;
  final String title;

  const MonthlyOrderChart({
    super.key,
    required this.data,
    this.title = 'Aylık Sipariş Trendi',
  });

  @override
  Widget build(BuildContext context) {
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
                legend: const Legend(
                    isVisible: true, position: LegendPosition.bottom),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  ColumnSeries<MonthlyData, String>(
                    name: 'Toplam Sipariş',
                    dataSource: data,
                    xValueMapper: (MonthlyData data, _) =>
                        _formatMonth(data.month),
                    yValueMapper: (MonthlyData data, _) => data.orderCount,
                    color: Colors.blue,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                  ColumnSeries<MonthlyData, String>(
                    name: 'Tamamlanan',
                    dataSource: data,
                    xValueMapper: (MonthlyData data, _) =>
                        _formatMonth(data.month),
                    yValueMapper: (MonthlyData data, _) => data.completedCount,
                    color: Colors.green,
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

  String _formatMonth(String month) {
    try {
      final parts = month.split('-');
      final year = int.parse(parts[0]);
      final monthNum = int.parse(parts[1]);
      final date = DateTime(year, monthNum);
      return DateFormat('MMM yyyy', 'tr_TR').format(date);
    } catch (e) {
      return month;
    }
  }
}

// Haftalık sipariş grafiği
class WeeklyOrderChart extends StatelessWidget {
  final List<WeeklyData> data;
  final String title;

  const WeeklyOrderChart({
    super.key,
    required this.data,
    this.title = 'Haftalık Sipariş Trendi',
  });

  @override
  Widget build(BuildContext context) {
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
                legend: const Legend(
                    isVisible: true, position: LegendPosition.bottom),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  LineSeries<WeeklyData, String>(
                    name: 'Toplam Sipariş',
                    dataSource: data,
                    xValueMapper: (WeeklyData data, _) => data.week,
                    yValueMapper: (WeeklyData data, _) => data.orderCount,
                    color: Colors.blue,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                  LineSeries<WeeklyData, String>(
                    name: 'Tamamlanan',
                    dataSource: data,
                    xValueMapper: (WeeklyData data, _) => data.week,
                    yValueMapper: (WeeklyData data, _) => data.completedCount,
                    color: Colors.green,
                    markerSettings: const MarkerSettings(isVisible: true),
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

// Günlük sipariş grafiği
class DailyOrderChart extends StatelessWidget {
  final List<DailyData> data;
  final String title;

  const DailyOrderChart({
    super.key,
    required this.data,
    this.title = 'Günlük Sipariş Trendi (Son 30 Gün)',
  });

  @override
  Widget build(BuildContext context) {
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
                primaryXAxis: DateTimeAxis(
                  dateFormat: DateFormat('dd/MM'),
                  labelRotation: -45,
                  labelStyle: const TextStyle(fontSize: 10),
                ),
                primaryYAxis: const NumericAxis(
                  title: AxisTitle(text: 'Sipariş Sayısı'),
                ),
                legend: const Legend(
                    isVisible: true, position: LegendPosition.bottom),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  AreaSeries<DailyData, DateTime>(
                    name: 'Toplam Sipariş',
                    dataSource: data,
                    xValueMapper: (DailyData data, _) => data.date,
                    yValueMapper: (DailyData data, _) => data.orderCount,
                    color: Colors.blue.withOpacity(0.3),
                    borderColor: Colors.blue,
                    borderWidth: 2,
                  ),
                  LineSeries<DailyData, DateTime>(
                    name: 'Tamamlanan',
                    dataSource: data,
                    xValueMapper: (DailyData data, _) => data.date,
                    yValueMapper: (DailyData data, _) => data.completedCount,
                    color: Colors.green,
                    width: 3,
                    markerSettings: const MarkerSettings(isVisible: true),
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
