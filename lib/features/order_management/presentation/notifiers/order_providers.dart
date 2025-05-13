import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_count_track/core/database/app_database.dart';
import 'package:flutter_count_track/features/order_management/data/repositories/order_repository_impl.dart';
import 'package:flutter_count_track/features/order_management/domain/repositories/order_repository.dart';

// Assuming appDatabaseProvider is defined elsewhere, e.g., in core/database/database_providers.dart
// For example:
// final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());
// If not, it needs to be created and imported.
// For now, let's assume it will be available.
import 'package:flutter_count_track/core/database/database_provider.dart'; // Placeholder for actual db provider

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final appDatabase = ref.watch(appDatabaseProvider);
  return OrderRepositoryImpl(appDatabase);
});

// You might also have other providers related to orders here in the future.
