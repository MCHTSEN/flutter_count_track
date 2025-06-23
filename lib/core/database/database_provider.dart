import 'package:flutter_count_track/core/database/app_database.dart';
import 'package:flutter_count_track/core/services/supabase_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

// Provider for the AppDatabase instance
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  // You might want to initialize your AppDatabase asynchronously if needed,
  // or if it's a singleton created elsewhere, provide that instance here.
  // For a simple synchronous creation:
  final db = AppDatabase(); // Creates a new instance

  // If you need to dispose of the database when the provider is disposed:
  ref.onDispose(() => db.close());

  return db;
});

// Debug amaçlı - veritabanını temizleyip yeniden oluşturmak için
final resetDatabaseProvider = FutureProvider<void>((ref) async {
  final db = ref.read(appDatabaseProvider);

  print('🔄 DatabaseProvider: Resetting database...');

  // Tüm verileri temizle
  await db.delete(db.barcodeReads).go();
  await db.delete(db.deliveryItems).go();
  await db.delete(db.deliveries).go();
  await db.delete(db.boxes).go();
  await db.delete(db.orderItems).go();
  await db.delete(db.productCodeMappings).go();
  await db.delete(db.orders).go();
  await db.delete(db.products).go();

  print('✅ DatabaseProvider: All data cleared, reinitializing...');

  // Yeniden oluştur
  await db.resetDatabase();

  print('🎉 DatabaseProvider: Database reset completed!');
});

/// Supabase sync service provider'ı
final supabaseSyncServiceProvider = Provider<SupabaseSyncService>((ref) {
  final localDb = ref.watch(appDatabaseProvider);

  // Supabase client'ı almaya çalış
  try {
    final supabaseClient = SupabaseService.client;
    return SupabaseSyncService(
      localDatabase: localDb,
      supabaseClient: supabaseClient,
    );
  } catch (e) {
    // Supabase henüz başlatılmamışsa null döndür
    throw StateError('Supabase henüz başlatılmadı: $e');
  }
});

/// Logger provider'ı
final loggerProvider = Provider.family<Logger, String>((ref, name) {
  return Logger(name);
});

/// Connectivity provider'ı
final connectivityProvider = StreamProvider<bool>((ref) {
  // SupabaseService'den connectivity stream'ini al
  return Stream.periodic(const Duration(seconds: 5))
      .map((_) => SupabaseService.isOnline)
      .distinct();
});
