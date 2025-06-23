import 'package:flutter/material.dart';
import 'package:flutter_count_track/core/config/supabase_config.dart';
import 'package:flutter_count_track/core/constants/app_constants.dart';
import 'package:flutter_count_track/core/services/supabase_service.dart';
import 'package:flutter_count_track/core/theme/app_theme.dart';
import 'package:flutter_count_track/features/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logging/logging.dart';

void main() async {
  // Flutter binding'lerini başlat
  WidgetsFlutterBinding.ensureInitialized();

  // Logging'i yapılandır
  _setupLogging();

  // Türkçe locale verilerini başlat
  await initializeDateFormatting('tr_TR', null);

  // Supabase'i başlat
  try {
    await SupabaseService.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    Logger('main').info('✅ Supabase başarıyla başlatıldı');
  } catch (e) {
    Logger('main').severe('💥 Supabase başlatma hatası: $e');
    // Supabase hata durumunda da uygulamayı başlat (offline-first)
  }

  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

/// Logging sistemini yapılandırır
void _setupLogging() {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    // Console log format
    final logMessage =
        '${record.time} [${record.level.name}] ${record.loggerName}: ${record.message}';
    print(logMessage);

    // Hata durumunda stack trace'i de yazdır
    if (record.error != null) {
      print('Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      print('Stack Trace: ${record.stackTrace}');
    }
  });
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
