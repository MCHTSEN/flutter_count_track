Projenizin "Paketleme Takip Sistemi" için özellik modüllerine ait detaylı yapılacaklar listesi:

**Önemli Not:** Bu checklist, MVVM, Riverpod, Repository Pattern mimarisi ve Drift, Syncfusion vb. teknolojiler göz önünde bulundurularak hazırlanmıştır.

### Modül 1: Sipariş Yönetimi (Order Management)

- [ ] **F1.1: Excel Dosyasından Sipariş Verilerini İçe Aktarma**
    - [ ] **UI:** "Excel İçe Aktar" butonu oluştur.
    - [ ] **İşlevsellik:** Butona tıklandığında dosya seçici açılacak (file\_picker vb.).
    - [ ] **Servis/Repository:**
        - [ ] Excel okuma servisi (syncfusion\_flutter\_xlsio veya excel ile) oluştur.
        - [ ] Servis, seçilen Excel dosyasını okuyacak.
        - [ ] Gerekli sütunları (Sipariş Kodu, Müşteri Adı, Müşteri Ürün Kodu, Ürün Miktarı) parse et.
        - [ ] Okunan verileri geçici `Order` ve `OrderItem` model nesnelerine dönüştür.
    - [ ] **Veritabanı (DAO/Repository):**
        - [ ] Her `Order` için veritabanında kayıt oluştur (aynı `orderCode` ile mükerrer kayıt önlenecek).
        - [ ] Her `OrderItem` için ilgili `Order`'a bağlı olarak veritabanında kayıt oluştur.
        - [ ] *(Opsiyonel)* Müşteri ürün kodlarını, `Product` ve `ProductCodeMapping` tablolarına bu aşamada işle (veya daha sonraki bir adımda).
    - [ ] **ViewModel/Notifier:** İçe aktarma işlemini tetikleyecek ve sonucunu (başarılı/hatalı) UI'a bildirecek mantık ekle.
    - [ ] **UI Geri Bildirimi:** İçe aktarma sonucunu kullanıcıya göster (örn: Snackbar, Toast).
    - [ ] **Hata Yönetimi:** Geçersiz dosya formatı, eksik sütun gibi hataları yakalayıp kullanıcıya bildir.

- [ ] **F1.2: İçe Aktarılan Siparişleri Listeleme**
    - [ ] **UI Ekranı:** `OrderListScreen` adında yeni bir ekran oluştur.
    - [ ] **Veritabanı (DAO/Repository):** Tüm `Order` kayıtlarını (gerekli alanlarla: durum, tarih vb.) getirecek bir fonksiyon yaz.
    - [ ] **ViewModel/Notifier:** Sipariş listesini (Riverpod `FutureProvider` veya `StateNotifierProvider` ile) UI'a sağla.
    - [ ] **UI Widget (Liste Elemanı):** Her bir sipariş için Sipariş Kodu, Müşteri Adı, Durum, Tarih bilgilerini gösterecek `OrderListItemWidget` oluştur.
    - [ ] **UI Widget (Liste):** `ListView.builder` ile `OrderListItemWidget`'lar kullanılarak sipariş listesi oluştur.
    - [ ] **Navigasyon:** Bir `OrderListItemWidget`'a tıklandığında `OrderDetailScreen`'e (ilgili `orderId` ile) yönlendirme yap.

- [ ] **F1.3: Sipariş Detaylarını Görüntüleme**
    - [ ] **UI Ekranı:** `OrderDetailScreen` adında yeni bir ekran oluştur (veya mevcut bir ekranı geliştir).
    - [ ] **Veritabanı (DAO/Repository):**
        - [ ] Belirli bir `orderId`'ye ait `Order` bilgilerini getirecek fonksiyon yaz.
        - [ ] Belirli bir `orderId`'ye ait tüm `OrderItem`'ları (ürün detayları, istenen/okunan miktar ile) getirecek fonksiyon yaz (gerekirse `Product` ve `ProductCodeMapping` ile `JOIN` yapılacak).
    - [ ] **ViewModel/Notifier:** Seçilen siparişin detaylarını (`Order` ve `OrderItem` listesi) UI'a sağla.
    - [ ] **UI:** Siparişin genel bilgilerini (kod, müşteri, tarih, durum) ekranda göster.
    - [ ] **UI (Ürün Tablosu/Listesi):** Siparişteki ürünleri (Müşteri Ürün Kodu, Bizim Ürün Kodumuz, İstenen Miktar, Okunan Miktar, Kalan Miktar, İlerleme Barı) bir tablo veya liste yapısında göster.

- [ ] **F1.4: Sipariş Durumunu Gösterme ve Otomatik Güncelleme**
    - [ ] **UI:** Sipariş listesinde ve detay ekranında sipariş durumunu (Bekliyor, Kısmen Gönderildi, Tamamlandı) ikon veya renk ile görselleştir.
    - [ ] **Model (Order):** `status` alanı için bir enum (`OrderStatus`) veya sabit string değerleri tanımla.
    - [ ] **İş Mantığı (ViewModel/Servis):**
        - [ ] Bir siparişteki tüm `OrderItem`'ların `scannedQuantity` değerleri `quantity` değerlerine ulaştığında `Order.status` "Tamamlandı" olarak güncelle.
        - [ ] Kısmi sevkiyat yapıldığında ve sipariş tamamlanmadığında `Order.status` "Kısmen Gönderildi" olarak güncelle (F3.2 ile koordineli).
        - [ ] Yeni siparişlerin varsayılan durumunu "Bekliyor" olarak ayarla.
    - [ ] **Veritabanı (DAO/Repository):** `Order` tablosundaki `status` alanını güncelleyecek fonksiyon yaz.

- [ ] **F1.5: Sipariş Listesinde Arama Yapabilme**
    - [ ] **UI:** `OrderListScreen`'e bir arama çubuğu (`TextField`) ekle.
    - [ ] **ViewModel/Notifier:** Arama metnini tutacak bir state (`StateProvider` veya `StateNotifier` içinde) oluştur.
    - [ ] **Veritabanı (DAO/Repository):** `orderCode` veya `customerName` alanlarında `LIKE %searchText%` ile arama yapacak sorgu ekle/fonksiyon yaz.
    - [ ] **ViewModel/Notifier:** Arama metni değiştikçe sipariş listesini (filtrelenmiş olarak) güncelle.

- [ ] **F1.6: Sipariş Listesini Filtreleyebilme**
    - [ ] **UI:** `OrderListScreen`'e durum filtreleme seçenekleri (örn: `DropdownButton`, `ChoiceChip`'ler - "Tümü", "Bekliyor", "Kısmi", "Tamamlandı") ekle.
    - [ ] **ViewModel/Notifier:** Seçili filtre durumunu tutacak bir state oluştur.
    - [ ] **Veritabanı (DAO/Repository):** Belirli bir `status`'e sahip siparişleri getirecek sorgu ekle/fonksiyon yaz.
    - [ ] **ViewModel/Notifier:** Filtre seçimi değiştikçe sipariş listesini (filtrelenmiş olarak) güncelle.

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
        - [ ] Eşleşen ürünün `isUniqueBarcodeRequired` özelliği `true` ise:
            - [ ] **Veritabanı (DAO/Repository - `BarcodeRead`):** Mevcut `orderId` ve okunan `barcode` ile `BarcodeRead` tablosunda daha önce bir kayıt olup olmadığını kontrol et.
            - [ ] **Kayıt varsa:** F2.5'teki "Benzersiz Barkod Tekrarı" bildirimi tetikle, sayım artırma.
            - [ ] **Kayıt yoksa:** Sayım artırma işlemine (F2.3) devam et.

### Modül 3: Teslimat ve Kısmi Gönderim Yönetimi

- [ ] **F3.1: Sipariş Durumunu Otomatik "Tamamlandı" Olarak İşaretleme**
    - [ ] Bu, F1.4'ün bir parçası olarak ele alınmıştır. Tüm ürünlerin `scannedQuantity == quantity` olması durumunda `Order.status` "completed" olur.

- [ ] **F3.2: Kısmi Gönderim Durumunu ve Kaydını Yönetme**
    - [ ] **UI:** `OrderDetailScreen`'e "Kısmi Teslimatı Tamamla" butonu ekle (en az bir ürün okutulduğunda aktif olacak).
    - [ ] **İş Mantığı (ViewModel/Servis - Butona Tıklandığında):**
        - [ ] **Veritabanı (DAO/Repository - `Delivery`):** Yeni bir `Delivery` kaydı oluştur (ilgili `orderId` ve `deliveryDate` ile).
        - [ ] **Veritabanı (DAO/Repository - `DeliveryItem`):** O ana kadar okutulmuş ve o anki teslimatta gönderilecek ürünler ve miktarları (o anki `scannedQuantity` - önceki teslimatlardaki toplamı) yeni `DeliveryItem` kayıtları olarak oluştur (yeni `deliveryId` ve `productId` ile).
        - [ ] `Order.status`, eğer siparişin tamamı bitmemişse "partial" olarak güncelle (F1.4).
        - [ ] **ViewModel/Notifier:** İşlem sonrası UI'ı güncelle (sipariş durumu, belki bir onay mesajı).

- [ ] **F3.3: Her Teslimatın Tarih/Saat Kaydını Tutma**
    - [ ] **Model (Delivery):** `deliveryDate` (`DATETIME`) alanı, kayıt oluşturulurken `DateTime.now()` ile otomatik olarak atanacak. Bu, F3.2'de `Delivery` kaydı oluşturulurken sağlanır.

- [ ] **F3.4: Sipariş Bazında Teslimat Geçmişini Görüntüleme**
    - [ ] **UI:** `OrderDetailScreen`'e "Teslimat Geçmişi" butonu/sekmesi ekle.
    - [ ] **UI Ekranı/Modal:** Teslimat geçmişini listeleyecek yeni bir ekran veya modal diyalog tasarla (`DeliveryHistoryScreen`).
    - [ ] **Veritabanı (DAO/Repository):**
        - [ ] Belirli bir `orderId`'ye ait tüm `Delivery` kayıtlarını çek.
        - [ ] Her bir `Delivery` kaydı için ilgili `DeliveryItem`'ları (ürün adı, miktar ile birlikte) çek.
        - [ ] **ViewModel/Notifier:** Teslimat geçmişi verisini (`List<Delivery>` ve içindeki `List<DeliveryItem>`) UI'a sağla.
        - [ ] **UI (Liste Elemanı):** Her teslimat için tarih, teslim edilen ürünler (isim, kod) ve miktarlarını gösteren `DeliveryHistoryItemWidget` oluştur.

- [ ] **F3.5: Çeki Listesi (Packing List) Oluşturma (PDF/Excel)**
    - [ ] **UI:** `OrderDetailScreen`'e "Çeki Listesi Oluştur" butonu ekle (sipariş "Kısmen Gönderildi" veya "Tamamlandı" durumundayken veya son teslimatı baz alacak şekilde aktif olacak).
    - [ ] **Veri Hazırlama (ViewModel/Servis):**
        - [ ] Çeki listesi için gerekli verileri topla: Sipariş bilgileri (kod, müşteri), (son) teslimat tarihi, (son) teslimattaki ürünler (Müşteri Kodu, Bizim Kodumuz, Adı, Gönderilen Miktar).
    - [ ] **Servis (PDF Oluşturma):** `pdf` paketini kullanarak toplanan verilerle PDF dokümanı oluşturacak bir fonksiyon yaz (başlık, sipariş bilgileri, ürün tablosu vb. içerecek).
    - [ ] **Servis (Excel Oluşturma - Opsiyonel):** `syncfusion_flutter_xlsio` veya `excel` ile aynı verilerle Excel dosyası oluşturacak fonksiyon yaz.
    - [ ] **Dosya İşlemleri:** Oluşturulan PDF/Excel dosyasının kullanıcıya indirilmesi/paylaşılması sağla (`path_provider`, `open_file`, `printing` paketleri).
    - [ ] **ViewModel/Notifier:** Çeki listesi oluşturma işlemini yönet ve sonucunu (başarılı indirme/hata) bildir.

### Modül 4: Ürün Kodu Eşleştirme (Code Mapping)

- [ ] **F4.1: Eşleştirme Veri Kaynağı Kullanma**
    - [ ] **Veritabanı Modeli (`ProductCodeMapping`):** `customerProductCode`, `productId`, `customerName` (opsiyonel, müşteri bazlı eşleştirme için) alanlarını içeren tablo Drift'te tanımlanacak.
    - [ ] **Veritabanı Modeli (`Product`):** İç ürün kodlarını ve ürün adlarını tutan `Product` tablosu Drift'te tanımlanacak.
    - [ ] *(Opsiyonel)* **Excel'den Eşleştirme Verisi Yükleme:**
        - [ ] Ayarlar veya özel bir yönetici ekranında eşleştirme verilerini içeren Excel dosyasını yükleme butonu ekle.
        - [ ] Excel'i okuyup `Product` (yeni ürünler için) ve `ProductCodeMapping` tablolarını dolduracak/güncelleyecek bir servis yaz.
        - [ ] *(Alternatif)* **Manuel Eşleştirme Arayüzü:** Sistem üzerinden manuel olarak `Product` ve `ProductCodeMapping` kayıtları ekleyip düzenlenebilecek bir yönetici arayüzü tasarla (MVP sonrası).

- [ ] **F4.2: Barkod Okutulduğunda Eşleştirme Yapma**
    - [ ] Bu, F2.2'nin bir parçası olarak ele alınmıştır. Okunan `customerProductCode` (ve gerekirse aktif siparişin müşteri bilgisi) `ProductCodeMapping` tablosunda aranır, bulunan `productId` ile `Product` tablosundan iç ürün bilgisi çekilir.

- [ ] **F4.3: Eşleşme Bulunamadığında Uyarı Verme**
    - [ ] Bu, F2.5'in bir parçası olarak ele alınmıştır. F4.2'deki eşleştirme başarısız olursa, kırmızı bildirim ve hata sesi ile kullanıcı bilgilendirilir.

### Modül 5: Kullanıcı Arayüzü (UI)

- [ ] **F5.1 (Ana Ekran/Dashboard):** F1.2, F1.3, F1.5, F1.6, F2.1, F2.4, F2.5'teki UI elemanlarını mantıklı ve kullanıcı dostu bir şekilde yerleştir.

- [ ] **F5.2 (İlerleme Göstergeleri):** F2.4'te belirtildiği gibi net ve anlaşılır olacak.

- [ ] **F5.3 (Sipariş Durumu İkonları/Renkleri):** F1.4'te belirtildiği gibi görsel ipuçları kullan.

- [ ] **F5.4 (Teslimat Geçmişi Ekranı):** F3.4'te belirtildiği gibi kullanıcı dostu bir liste/detay görünümü sağla.

- [ ] **F5.5 (Çeki Listesi Arayüzü):** F3.5'te belirtildiği gibi basit tetikleme ve sonuç akışı olacak.

- [ ] **Genel UI/UX İlkeleri:**
    - [ ] **Tutarlılık:** Renkler, fontlar, buton stilleri, ikonlar uygulama genelinde tutarlı olacak (Material Design veya Fluent Design prensiplerine uygun).
    - [ ] **Duyarlılık (Responsive):** Masaüstü uygulaması için temel pencere boyutlandırmalarına uyum sağla.
    - [ ] **Erişilebilirlik (Accessibility):** Temel erişilebilirlik prensiplerine (kontrast, font büyüklüğü vb.) dikkat et.
    - [ ] **Hata Durumları:** Kullanıcıya net, anlaşılır ve yapıcı hata mesajları göster.
    - [ ] **Yükleme Durumları:** Uzun süren işlemler sırasında (veri çekme, dosya oluşturma) `CircularProgressIndicator` gibi yükleme göstergeleri kullan.
    - [ ] **Kullanıcı Dostu Metinler:** Tüm UI metinleri (butonlar, etiketler, mesajlar) Türkçe ve anlaşılır olacak.

### Modül 6: Veri Depolama ve Yönetimi (Data Storage & Management)

- [ ] **F6.1 (Lokal Veritabanı - SQLite/Drift):**
    - [ ] `AppDatabase.drift` (veya benzeri) dosyasında tüm veri modelleri (`Order`, `OrderItem`, `Product`, `ProductCodeMapping`, `BarcodeRead`, `Delivery`, `DeliveryItem`) için Drift tabloları tanımla.
    - [ ] Drift tarafından generate edilecek `AppDatabase.g.dart` dosyası için build komutu çalıştır.
    - [ ] Veritabanı bağlantısını kuracak ve DAO'ları sağlayacak `AppDatabase` sınıfı oluştur (veya Riverpod provider'ı ile sağlanacak).
    - [ ] Her tablo için DAO (Data Access Object) arayüzleri (`@DriftAccessor`) ve implementasyonları oluştur (CRUD metotları ve özel sorgular içerecek).
    - [ ] Repository sınıfları oluşturularak DAO'lar kullanılacak ve iş mantığına uygun veri erişim metotları sağla (ViewModel'ler bu Repository'leri kullanacak).

- [ ] **F6.2 (Offline Çalışma):** Tüm veri işlemleri öncelikle lokal veritabanı üzerinden yapılacağı için bu doğal olarak desteklenecek.

### Modül 7: Raporlama (MVP için Temel)

- [ ] **F7.1 (Siparişe Özel Çeki Listesi):** F3.5'in tamamlanmasıyla bu madde de tamamlanmış olacak.

- [ ] **F7.2 (Siparişe Özel Teslimat Geçmişi Raporu - Ekranda):** F3.4'ün (ekranda görüntüleme) tamamlanmasıyla bu madde de tamamlanmış olacak. Eğer bu "rapor"dan kasıt indirilebilir bir dosya ise, F3.5 benzeri bir PDF/Excel çıktısı da ayrıca geliştirilebilir.