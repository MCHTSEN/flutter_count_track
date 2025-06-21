import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart'; // Assuming app_database.dart is in the same directory

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
