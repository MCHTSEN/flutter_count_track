Projenizin "Paketleme Takip Sistemi" için özellik modüllerine ait detaylı yapılacaklar listesi:

**Önemli Not:** Bu checklist, MVVM, Riverpod, Repository Pattern mimarisi ve Drift, Syncfusion vb. teknolojiler göz önünde bulundurularak hazırlanmıştır.

### Modül 1: Sipariş Yönetimi (Order Management)

- [x] **F1.1: Excel Dosyasından Sipariş Verilerini İçe Aktarma**
    - [x] **UI:** "Excel İçe Aktar" butonu oluştur.
    - [x] **İşlevsellik:** Butona tıklandığında dosya seçici açılacak (file\_picker vb.).
    - [x] **Servis/Repository:**
        - [x] Excel okuma servisi (excel ile) oluştur.
        - [x] Servis, seçilen Excel dosyasını okuyacak.
        - [x] Gerekli sütunları (Sipariş Kodu, Müşteri Adı, Müşteri Ürün Kodu, Ürün Miktarı) parse et.
        - [x] Okunan verileri geçici `Order` ve `OrderItem` model nesnelerine dönüştür.
    - [x] **Veritabanı (DAO/Repository):**
        - [x] Her `Order` için veritabanında kayıt oluştur (aynı `orderCode` ile mükerrer kayıt önlenecek).
        - [x] Her `OrderItem` için ilgili `Order`'a bağlı olarak veritabanında kayıt oluştur.
        - [ ] *(Opsiyonel)* Müşteri ürün kodlarını, `Product` ve `ProductCodeMapping` tablolarına bu aşamada işle (veya daha sonraki bir adımda).
    - [x] **ViewModel/Notifier:** İçe aktarma işlemini tetikleyecek ve sonucunu (başarılı/hatalı) UI'a bildirecek mantık ekle.
    - [x] **UI Geri Bildirimi:** İçe aktarma sonucunu kullanıcıya göster (örn: Snackbar, Toast).
    - [x] **Hata Yönetimi:** Geçersiz dosya formatı, eksik sütun gibi hataları yakalayıp kullanıcıya bildir.

- [x] **F1.2: İçe Aktarılan Siparişleri Listeleme**
    - [x] **UI Ekranı:** `OrderListScreen` adında yeni bir ekran oluştur.
    - [x] **Veritabanı (DAO/Repository):** Tüm `Order` kayıtlarını (gerekli alanlarla: durum, tarih vb.) getirecek bir fonksiyon yaz.
    - [x] **ViewModel/Notifier:** Sipariş listesini (Riverpod `FutureProvider` veya `StateNotifierProvider` ile) UI'a sağla.
    - [x] **UI Widget (Liste Elemanı):** Her bir sipariş için Sipariş Kodu, Müşteri Adı, Durum, Tarih bilgilerini gösterecek `OrderListItemWidget` oluştur.
    - [x] **UI Widget (Liste):** `ListView.builder` ile `OrderListItemWidget`'lar kullanılarak sipariş listesi oluştur.
    - [ ] **Navigasyon:** Bir `OrderListItemWidget`'a tıklandığında `OrderDetailScreen`'e (ilgili `orderId` ile) yönlendirme yap.

- [ ] **F1.3: Sipariş Detaylarını Görüntüleme**
    - [ ] **UI Ekranı:** `OrderDetailScreen` adında yeni bir ekran oluştur (veya mevcut bir ekranı geliştir).
    - [ ] **Veritabanı (DAO/Repository):**
        - [ ] Belirli bir `orderId`'ye ait `Order` bilgilerini getirecek fonksiyon yaz.
        - [ ] Belirli bir `orderId`'ye ait tüm `OrderItem`'ları (ürün detayları, istenen/okunan miktar ile) getirecek fonksiyon yaz (gerekirse `Product` ve `ProductCodeMapping` ile `JOIN` yapılacak).
    - [ ] **ViewModel/Notifier:** Seçilen siparişin detaylarını (`Order` ve `OrderItem` listesi) UI'a sağla.
    - [ ] **UI:** Siparişin genel bilgilerini (kod, müşteri, tarih, durum) ekranda göster.
    - [ ] **UI (Ürün Tablosu/Listesi):** Siparişteki ürünleri (Müşteri Ürün Kodu, Bizim Ürün Kodumuz, İstenen Miktar, Okunan Miktar, Kalan Miktar, İlerleme Barı) bir tablo veya liste yapısında göster.

- [x] **F1.4: Sipariş Durumunu Gösterme ve Otomatik Güncelleme**
    - [x] **UI:** Sipariş listesinde ve detay ekranında sipariş durumunu (Bekliyor, Kısmen Gönderildi, Tamamlandı) ikon veya renk ile görselleştir.
    - [x] **Model (Order):** `status` alanı için bir enum (`OrderStatus`) veya sabit string değerleri tanımla.
    - [x] **İş Mantığı (ViewModel/Servis):**
        - [x] Bir siparişteki tüm `OrderItem`'ların `scannedQuantity` değerleri `quantity` değerlerine ulaştığında `Order.status` "Tamamlandı" olarak güncelle.
        - [x] Kısmi sevkiyat yapıldığında ve sipariş tamamlanmadığında `Order.status` "Kısmen Gönderildi" olarak güncelle (F3.2 ile koordineli).
        - [x] Yeni siparişlerin varsayılan durumunu "Bekliyor" olarak ayarla.
    - [x] **Veritabanı (DAO/Repository):** `Order` tablosundaki `status` alanını güncelleyecek fonksiyon yaz.

- [x] **F1.5: Sipariş Listesinde Arama Yapabilme**
    - [x] **UI:** `OrderListScreen`'e bir arama çubuğu (`TextField`) ekle.
    - [x] **ViewModel/Notifier:** Arama metnini tutacak bir state (`StateProvider` veya `StateNotifier` içinde) oluştur.
    - [x] **Veritabanı (DAO/Repository):** `orderCode` veya `customerName` alanlarında `LIKE %searchText%` ile arama yapacak sorgu ekle/fonksiyon yaz.
    - [x] **ViewModel/Notifier:** Arama metni değiştikçe sipariş listesini (filtrelenmiş olarak) güncelle.

- [x] **F1.6: Sipariş Listesini Filtreleyebilme**
    - [x] **UI:** `OrderListScreen`'e durum filtreleme seçenekleri (örn: `DropdownButton`, `ChoiceChip`'ler - "Tümü", "Bekliyor", "Kısmi", "Tamamlandı") ekle.
    - [x] **ViewModel/Notifier:** Seçili filtre durumunu tutacak bir state oluştur.
    - [x] **Veritabanı (DAO/Repository):** Belirli bir `status`'e sahip siparişleri getirecek sorgu ekle/fonksiyon yaz.
    - [x] **ViewModel/Notifier:** Filtre seçimi değiştikçe sipariş listesini (filtrelenmiş olarak) güncelle.

### Modül 2: Barkod Okuma ve Sayım (Barcode Scanning & Counting)

- [ ] **F2.1: Barkod Okuyucudan Gelen Veriyi Yakalama**
    - [ ] **UI:** `OrderDetailScreen`'de barkod girişi için bir `TextField` oluştur (`autofocus: true` ve klavye gibi davranan barkod okuyucu için `onSubmitted` veya `onChanged` ile veri alınacak).
    - [ ] **ViewModel/Notifier:** Okunan barkod değerini alıp işleyecek bir fonksiyon (`processBarcode(String barcode)`) tanımla.

- [ ] **F2.2: Okunan Barkodu Ürün Kodu Eşleştirme (Mapping) ile Eşleştirme**
    - [ ] **İş Mantığı (ViewModel/Servis):** `processBarcode` fonksiyonu içinde:
        - [ ] Okunan barkod değerini (müşteri ürün kodu) al.
        - [ ] **Veritabanı (DAO/Repository - `ProductCodeMapping`, `Product`):**
            - [ ] `ProductCodeMapping` tablosunda `customerProductCode` (ve gerekirse siparişin müşterisine göre `customerName`) ile eşleşen kayıt ara.
            - [ ] Eşleşen kayıttan `productId` al.
            - [ ] `Product` tablosundan bu `productId`'ye ait ürün detaylarını (`ourProductCode`, `isUniqueBarcodeRequired`) çek.
        - [ ] **Hata Yönetimi:** Eşleşme bulunamazsa veya ürün o anki siparişte yoksa uygun bir hata durumu oluştur (F2.5'e yönlendirilecek).

- [ ] **F2.3: Eşleşen Ürün İçin Siparişteki Okunan Miktarı Artırma**
    - [ ] **İş Mantığı (ViewModel/Servis - F2.2 başarılıysa):**
        - [ ] Eşleşen ürünün, aktif siparişteki ilgili `OrderItem`'ının `scannedQuantity` değerini 1 artır.
        - [ ] `scannedQuantity`'nin `quantity`'yi geçmemesini sağla.
        - [ ] **Veritabanı (DAO/Repository - `OrderItem`):** İlgili `OrderItem`'ın `scannedQuantity` değerini güncelle.
        - [ ] **Veritabanı (DAO/Repository - `BarcodeRead`):** Okunan her barkodu (başarılı/başarısız eşleşme) `BarcodeRead` tablosuna logla (`orderId`, `productId` (varsa), `barcode`, `timestamp`).
        - [ ] **ViewModel/Notifier:** UI'daki `OrderItem` listesini güncelle.
        - [ ] **Durum Güncelleme Tetikleme:** Sipariş durumu (F1.4) ve teslimat durumu kontrol et/güncelle.

- [ ] **F2.4: Sayım İlerlemesini Görsel Olarak Gösterme**
    - [ ] **UI (`OrderDetailScreen` - Ürün Listesi):** Her ürün kalemi için:
        - [ ] `LinearProgressIndicator` ekle (değeri: `scannedQuantity / quantity`).
        - [ ] "Okunan / Toplam" (örn: "5 / 10") metnini göster.
        - [ ] **UI (Opsiyonel):** Siparişin geneli için bir ilerleme göstergesi ekle.

- [ ] **F2.5: Sesli ve Renkli Bildirimler**
    - [ ] **Assets:** Kısa onay, uyarı ve hata ses dosyalarını (`.mp3`, `.wav`) `assets/sounds/` klasörüne ekle ve `pubspec.yaml`'da deklare et.
    - [ ] **Servis (Ses Çalma):** `audioplayers` paketi ile sesi çalacak bir yardımcı fonksiyon/servis oluştur.
    - [ ] **UI Geri Bildirimi (ViewModel/Notifier aracılığıyla):**
        - [ ] **Başarılı Okuma:** Ekranda geçici yeşil renkli bildirim göster (örn: `Snackbar`) ve onay sesi çal.
        - [ ] **Benzersiz Barkod Tekrarı:** Ekranda geçici sarı renkli bildirim ("Bu barkod zaten okutuldu!") ve uyarı sesi çal.
        - [ ] **Tanımsız/Hatalı Barkod/Eşleşme Yok:** Ekranda geçici kırmızı renkli bildirim ("Barkod bulunamadı!" veya "Ürün siparişte yok!") ve hata sesi çal.
    - [ ] **UI (Bildirim Alanı):** `OrderDetailScreen`'de bu bildirimlerin gösterileceği bir alan (örn: ekranın üstünde/altında bir bar) tasarla.

- [ ] **F2.6: Benzersiz Barkod Kontrolü**
    - [ ] **Model (Product):** `isUniqueBarcodeRequired` (boolean) alanı ekle.
    - [ ] **İş Mantığı (ViewModel/Servis - F2.2'den sonra, F2.3'ten önce):**
        - [ ] Eşleşen ürünün `isUniqueBarcodeRequired` özelliği `true`