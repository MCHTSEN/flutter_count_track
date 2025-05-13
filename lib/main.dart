import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_count_track/core/constants/app_constants.dart';
import 'package:flutter_count_track/core/theme/app_theme.dart';
import 'package:flutter_count_track/features/order_management/presentation/screens/order_list_screen.dart';

void main() {
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
      home: const OrderListScreen(),
    );
  }
}
