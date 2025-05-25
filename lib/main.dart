import 'package:flutter/material.dart';
import 'package:flutter_count_track/features/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_count_track/core/constants/app_constants.dart';
import 'package:flutter_count_track/core/theme/app_theme.dart';
import 'package:flutter_count_track/features/order_management/presentation/screens/order_list_screen.dart';
import 'package:flutter_count_track/features/barcode_scanning/presentation/screens/barcode_test_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // Flutter binding'lerini başlat
  WidgetsFlutterBinding.ensureInitialized();

  // Türkçe locale verilerini başlat
  await initializeDateFormatting('tr_TR', null);

  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appTitle,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
