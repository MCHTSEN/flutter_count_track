import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_count_track/core/database/database_provider.dart';
import 'package:flutter_count_track/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:flutter_count_track/features/order_management/presentation/screens/order_list_screen.dart';
import 'package:flutter_count_track/features/supabase_test_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[50]!,
              Colors.blue[100]!,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Üst başlık bölümü
              _buildHeader(context),

              // Ana içerik bölümü
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Hoş geldiniz kartı
                      _buildWelcomeCard(context),
                      const SizedBox(height: 32),

                      // Ana menü kartları
                      Expanded(
                        child: _buildMainMenuGrid(context, ref),
                      ),

                      // Alt bilgi
                      _buildFooter(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue[700],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.inventory_2,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paketleme Takip Sistemi',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Üretim ve Paketleme Süreçleri Yönetimi',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.blue[600]!,
              Colors.blue[700]!,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.waving_hand,
                  color: Colors.amber,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'Hoş Geldiniz!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Paketleme takip sisteminize hoş geldiniz. Siparişlerinizi yönetin, istatistikleri görüntüleyin ve süreçlerinizi optimize edin.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainMenuGrid(BuildContext context, WidgetRef ref) {
    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 1.1,
      children: [
        _buildMenuCard(
          context: context,
          title: 'Dashboard',
          subtitle: 'Genel Bakış ve İstatistikler',
          icon: Icons.dashboard,
          color: Colors.blue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(),
              ),
            );
          },
        ),
        _buildMenuCard(
          context: context,
          title: 'Sipariş Yönetimi',
          subtitle: 'Siparişleri Görüntüle ve Yönet',
          icon: Icons.list_alt,
          color: Colors.green,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const OrderListScreen(),
              ),
            );
          },
        ),
        _buildMenuCard(
          context: context,
          title: 'Supabase Test',
          subtitle: 'Supabase Bağlantı ve Veri Testi',
          icon: Icons.cloud_sync,
          color: Colors.teal,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SupabaseTestScreen(),
              ),
            );
          },
        ),
        _buildMenuCard(
          context: context,
          title: 'Raporlar',
          subtitle: 'Detaylı Raporlar ve Analizler',
          icon: Icons.analytics,
          color: Colors.orange,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Raporlar modülü yakında eklenecek'),
                backgroundColor: Colors.orange,
              ),
            );
          },
        ),
        // Debug butonu
        _buildMenuCard(
          context: context,
          title: 'DB Reset',
          subtitle: 'Veritabanını Sıfırla (Debug)',
          icon: Icons.refresh,
          color: Colors.red,
          onTap: () async {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Veritabanını Sıfırla'),
                content: const Text(
                    'Bu işlem tüm verileri silip yeni örnek veriler oluşturacak. Devam etmek istiyor musunuz?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('İptal'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      // Loading göster
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );

                      try {
                        // Database reset
                        final db = ref.read(appDatabaseProvider);
                        await db.resetDatabase();

                        Navigator.pop(context); // Loading'i kapat

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Veritabanı başarıyla sıfırlandı!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        Navigator.pop(context); // Loading'i kapat

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('❌ Hata: $e'),
                            backgroundColor: Colors.red,
                            action: SnackBarAction(
                              label: 'Kopyala ',
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: e.toString()));
                              },
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Sıfırla'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Colors.grey[500],
          ),
          const SizedBox(width: 8),
          Text(
            'Paketleme Takip Sistemi v1.0.0',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }
}
