import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_count_track/core/database/app_database.dart';
import 'package:flutter_count_track/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:flutter_count_track/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:flutter_count_track/features/dashboard/presentation/notifiers/dashboard_notifier.dart';

// Database provider (bu zaten başka yerde tanımlı olabilir, gerekirse import edin)
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// Dashboard repository provider
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return DashboardRepositoryImpl(database);
});

// Dashboard notifier provider
final dashboardNotifierProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return DashboardNotifier(repository);
});

// Dashboard state provider (sadece state'i okumak için)
final dashboardStateProvider = Provider<DashboardState>((ref) {
  return ref.watch(dashboardNotifierProvider);
});

// Loading state provider
final dashboardLoadingProvider = Provider<bool>((ref) {
  return ref.watch(dashboardNotifierProvider).isLoading;
});

// Error state provider
final dashboardErrorProvider = Provider<String?>((ref) {
  return ref.watch(dashboardNotifierProvider).error;
});

// Stats provider
final dashboardStatsProvider = Provider((ref) {
  return ref.watch(dashboardNotifierProvider).stats;
});

// Top products provider
final topProductsProvider = Provider((ref) {
  return ref.watch(dashboardNotifierProvider).topProducts;
});

// Top customers provider
final topCustomersProvider = Provider((ref) {
  return ref.watch(dashboardNotifierProvider).topCustomers;
});
