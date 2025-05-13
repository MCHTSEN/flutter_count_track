class AppConstants {
  static const String appTitle = 'Paketleme Takip Sistemi';

  // Rota isimleri
  static const String routeHome = '/';
  static const String routeOrderList = '/orders';
  static const String routeOrderDetail = '/order-detail';
  static const String routeDeliveryHistory = '/delivery-history';

  // Asset yolları
  static const String soundSuccess = 'assets/sounds/success.mp3';
  static const String soundWarning = 'assets/sounds/warning.mp3';
  static const String soundError = 'assets/sounds/error.mp3';

  // Sipariş durumu metinleri
  static const String statusPending = 'Bekliyor';
  static const String statusPartial = 'Kısmen Gönderildi';
  static const String statusCompleted = 'Tamamlandı';

  // Hata mesajları
  static const String errorBarcodeNotFound = 'Barkod bulunamadı!';
  static const String errorProductNotInOrder = 'Ürün siparişte yok!';
  static const String errorDuplicateBarcode = 'Bu barkod zaten okutuldu!';
  static const String errorExcelImport =
      'Excel dosyası içe aktarılırken hata oluştu!';

  // Başarı mesajları
  static const String successBarcodeRead = 'Barkod başarıyla okundu';
  static const String successExcelImport =
      'Excel dosyası başarıyla içe aktarıldı';
  static const String successDeliveryComplete = 'Teslimat başarıyla tamamlandı';

  // Buton metinleri
  static const String buttonImportExcel = 'Excel İçe Aktar';
  static const String buttonCompleteDelivery = 'Teslimatı Tamamla';
  static const String buttonCreatePackingList = 'Çeki Listesi Oluştur';
  static const String buttonViewDeliveryHistory = 'Teslimat Geçmişi';
}
