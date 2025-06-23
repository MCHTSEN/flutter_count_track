import 'package:flutter_count_track/core/database/database_provider.dart';
import 'package:flutter_count_track/core/services/supabase_service.dart';
import 'package:flutter_count_track/features/order_management/data/repositories/order_repository_impl.dart';
import 'package:flutter_count_track/features/order_management/domain/repositories/order_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

/// Order Repository Provider - Supabase sync ile
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final appDatabase = ref.watch(appDatabaseProvider);
  final logger = Logger('OrderProviders');

  // Supabase sync service'i al (varsa)
  SupabaseSyncService? syncService;
  try {
    syncService = ref.watch(supabaseSyncServiceProvider);
    logger.info('✅ OrderRepository Supabase sync ile oluşturuldu');
  } catch (e) {
    logger.warning('⚠️ Supabase sync mevcut değil, sadece local mode: $e');
    syncService = null;
  }

  return OrderRepositoryImpl(appDatabase, syncService);
});

/// Connectivity durumu provider'ı
final connectivityStatusProvider = StreamProvider<bool>((ref) {
  return Stream.periodic(const Duration(seconds: 3))
      .map((_) => SupabaseService.isOnline)
      .distinct();
});

/// Sync durumu provider'ı
final syncStatusProvider = StateProvider<SyncStatus>((ref) {
  return SyncStatus.idle;
});

/// Sync durumları
enum SyncStatus {
  idle,
  syncing,
  success,
  error,
}
