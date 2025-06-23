/// Supabase konfigürasyon sabitlerini içeren dosya
class SupabaseConfig {
  // Bu değerler gerçek projede environment variables'dan alınacak
  static const String supabaseUrl = 'https://awmoxgmbhunleqbimzqm.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF3bW94Z21iaHVubGVxYmltenFtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA2MDg5ODMsImV4cCI6MjA2NjE4NDk4M30.oepOnNyeIJ_VBf8iH1MusSX2UtZ_1SRBYpls3O2hPkQ';

  // Sync ayarları
  static const int syncIntervalMinutes = 5;
  static const int maxRetryAttempts = 3;
  static const int connectionTimeoutSeconds = 30;

  // Batch sizes
  static const int batchSizeOrders = 100;
  static const int batchSizeBarcodeReads = 500;

  // Cache ayarları
  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxLocalCacheSize = 1000; // records
}
