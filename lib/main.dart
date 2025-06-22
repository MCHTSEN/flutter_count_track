import 'package:flutter/material.dart';
import 'package:flutter_count_track/core/constants/app_constants.dart';
import 'package:flutter_count_track/core/services/firebase_service.dart';
import 'package:flutter_count_track/core/theme/app_theme.dart';
import 'package:flutter_count_track/features/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // Flutter binding'lerini başlat
  WidgetsFlutterBinding.ensureInitialized();

  // Türkçe locale verilerini başlat
  await initializeDateFormatting('tr_TR', null);

  // Firebase'i başlat
  try {
    await FirebaseService.initialize();
    print('✅ Firebase başarıyla başlatıldı');
  } catch (e) {
    print('💥 Firebase başlatma hatası: $e');
    // Firebase hata durumunda da uygulamayı başlat (offline-first)
  }

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
