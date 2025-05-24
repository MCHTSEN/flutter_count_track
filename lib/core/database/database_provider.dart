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
