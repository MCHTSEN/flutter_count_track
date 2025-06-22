import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_count_track/firebase_options.dart';

/// Firebase servislerini yöneten ana sınıf
class FirebaseService {
  static FirebaseFirestore? _firestore;
  static bool _initialized = false;

  /// Firebase'i başlatır
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _firestore = FirebaseFirestore.instance;
      _initialized = true;

      // Offline persistence ayarları
      _firestore?.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      print('✅ Firebase: Başarıyla başlatıldı');
    } catch (e) {
      print('💥 Firebase: Başlatma hatası: $e');
      rethrow;
    }
  }

  /// Firestore instance'ını döndürür
  static FirebaseFirestore get firestore {
    if (!_initialized || _firestore == null) {
      throw StateError(
          'Firebase henüz başlatılmadı. FirebaseService.initialize() çağırın.');
    }
    return _firestore!;
  }

  /// Firebase'in başlatılıp başlatılmadığını kontrol eder
  static bool get isInitialized => _initialized;

  /// Company ID'yi kullanıcının custom claims'inden alır
  static String? get currentCompanyId {
    // TODO: İlerleyde custom claims'den alınacak
    // Şimdilik test için sabit değer döndürüyoruz
    return 'company_test_123';
  }

  /// Device ID oluşturur (local storage'dan alınacak)
  static String generateDeviceId() {
    // TODO: platform_device_id paketi ile gerçek device ID alınacak
    return 'device_${DateTime.now().millisecondsSinceEpoch}';
  }
}
