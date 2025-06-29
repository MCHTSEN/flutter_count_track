import 'package:flutter/material.dart';
import 'package:flutter_count_track/core/utils/sample_data_generator.dart';
import 'package:flutter_count_track/features/dashboard/presentation/components/charts_section.dart';
import 'package:flutter_count_track/features/dashboard/presentation/components/dashboard_header.dart';
import 'package:flutter_count_track/features/dashboard/presentation/components/dashboard_state_widgets.dart';
import 'package:flutter_count_track/features/dashboard/presentation/components/stats_section.dart';
import 'package:flutter_count_track/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with WidgetsBindingObserver {
  bool _isGeneratingData = false;

  @override
  void initState() {
    super.initState();
    // App lifecycle observer'ı kaydet
    WidgetsBinding.instance.addObserver(this);

    // Dashboard verilerini yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onScreenFocus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Uygulama foreground'a geçtiğinde refresh et
    if (state == AppLifecycleState.resumed) {
      _onScreenFocus();
    }
  }

  /// Ekran focus alındığında çağrılır
  void _onScreenFocus() {
    print('👁️ DashboardScreen: Focus alındı, verileri yenileniyor');
    ref.read(dashboardNotifierProvider.notifier).onScreenFocus();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardNotifierProvider);
    final isLoading = dashboardState.isLoading;
    final error = dashboardState.error;
    final stats = dashboardState.stats;
    final lastRefreshTime = dashboardState.lastRefreshTime;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard - Genel Bakış'),
            if (lastRefreshTime != null)
              Text(
                'Son güncelleme: ${lastRefreshTime.hour.toString().padLeft(2, '0')}:${lastRefreshTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          // Real-time status indicator
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.5)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.update, size: 14, color: Colors.green),
                SizedBox(width: 4),
                Text(
                  '60s',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: isLoading
                ? null
                : () {
                    ref.read(dashboardNotifierProvider.notifier).refreshData();
                  },
            tooltip: 'Verileri Yenile',
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'generate_sample_data') {
                await _generateSampleData();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'generate_sample_data',
                child: Row(
                  children: [
                    Icon(Icons.data_usage),
                    SizedBox(width: 8),
                    Text('Örnek Veri Oluştur'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(dashboardNotifierProvider.notifier).refreshData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık ve tarih
              const DashboardHeader(),
              const SizedBox(height: 20),

              // Hata durumu
              if (error != null)
                DashboardErrorWidget(
                  error: error,
                  onDismiss: () {
                    ref.read(dashboardNotifierProvider.notifier).clearError();
                  },
                ),

              // Yükleme durumu
              if (isLoading && stats == null) const DashboardLoadingWidget(),

              // Veri oluşturma durumu
              if (_isGeneratingData) const GeneratingDataWidget(),

              // Ana içerik
              if (stats != null) ...[
                // Genel istatistikler kartları
                StatsSection(stats: stats),
                const SizedBox(height: 24),

                // Grafik bölümü
                ChartsSection(stats: stats),
              ],

              // Veri yoksa bilgi mesajı
              if (!isLoading && stats != null && stats.totalOrders == 0)
                DashboardNoDataWidget(
                  onGenerateSampleData: _generateSampleData,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generateSampleData() async {
    setState(() {
      _isGeneratingData = true;
    });

    try {
      final database = ref.read(databaseProvider);
      final generator = SampleDataGenerator(database);

      await generator.generateSampleData();

      // Verileri yenile
      await ref.read(dashboardNotifierProvider.notifier).refreshData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Örnek veriler başarıyla oluşturuldu!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Örnek veri oluşturulurken hata: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingData = false;
        });
      }
    }
  }
}
