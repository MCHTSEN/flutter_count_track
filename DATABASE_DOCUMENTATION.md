# Paketleme Takip Sistemi - Veritabanı Dokümantasyonu

## 📋 Genel Bakış

Bu dokümantasyon, Paketleme Takip Sistemi'nin SQLite veritabanı yapısını detaylandırmaktadır. Sistem, üretim fabrikasında paketleme süreçlerini otomatikleştirmek ve takip etmek için tasarlanmıştır.

### Teknoloji Stack
- **Veritabanı**: SQLite
- **ORM**: Drift (Moor)
- **Dil**: Dart
- **Framework**: Flutter Desktop

### Veritabanı Dosyası
- **Dosya Adı**: `paketleme_takip.db`
- **Konum**: Application Documents Directory
- **Şema Versiyonu**: 2

---

## 📊 Tablo Yapısı ve İlişkiler

### Entity Relationship Diagram (ERD)

```
┌─────────────┐    1:N    ┌──────────────┐    N:1    ┌─────────────┐
│   Orders    │◄──────────┤ OrderItems   ├──────────►│  Products   │
│             │           │              │           │             │
│ - id (PK)   │           │ - id (PK)    │           │ - id (PK)   │
│ - orderCode │           │ - orderId    │           │ - ourProdCode│
│ - customer  │           │ - productId  │           │ - name      │
│ - status    │           │ - quantity   │           │ - barcode   │
│ - createdAt │           │ - scannedQty │           │ - isUnique  │
│ - updatedAt │           └──────────────┘           └─────────────┘
└─────────────┘                                             │
       │                                                    │ 1:N
       │ 1:N                                                ▼
       ▼                                          ┌─────────────────┐
┌─────────────┐                                  │ProductCodeMaps  │
│ BarcodeReads│                                  │                 │
│             │                                  │ - id (PK)       │
│ - id (PK)   │                                  │ - customerCode  │
│ - orderId   │                                  │ - productId     │
│ - productId │                                  │ - customerName  │
│ - barcode   │                                  └─────────────────┘
│ - readAt    │
└─────────────┘
       │
       │ 1:N
       ▼
┌─────────────┐    1:N    ┌──────────────┐    N:1    ┌─────────────┐
│ Deliveries  │◄──────────┤DeliveryItems ├──────────►│  Products   │
│             │           │              │           │             │
│ - id (PK)   │           │ - id (PK)    │           │ (same as    │
│ - orderId   │           │ - deliveryId │           │  above)     │
│ - delivDate │           │ - productId  │           │             │
└─────────────┘           │ - quantity   │           └─────────────┘
                          └──────────────┘
```

---

## 🗂️ Tablo Detayları

### 1. Orders (Siparişler)

Sistem içindeki tüm siparişlerin ana bilgilerini tutar.

| Sütun | Tip | Kısıtlamalar | Açıklama |
|-------|-----|-------------|----------|
| `id` | INTEGER | PRIMARY KEY, AUTO_INCREMENT | Benzersiz sipariş ID'si |
| `orderCode` | TEXT | NOT NULL | Sipariş kodu (örn: SIP001) |
| `customerName` | TEXT | NOT NULL | Müşteri adı |
| `status` | TEXT | NOT NULL | Sipariş durumu (enum) |
| `createdAt` | DATETIME | DEFAULT CURRENT_TIMESTAMP | Oluşturulma tarihi |
| `updatedAt` | DATETIME | DEFAULT CURRENT_TIMESTAMP | Güncellenme tarihi |

#### Sipariş Durumları (OrderStatus Enum)
- `pending`: Bekliyor
- `partial`: Kısmen Gönderildi  
- `completed`: Tamamlandı

#### Örnek Veriler
```sql
INSERT INTO orders (orderCode, customerName, status) VALUES 
('SIP001', 'ABC Şirketi', 'pending'),
('SIP002', 'XYZ Ltd.', 'partial'),
('SIP003', 'DEF A.Ş.', 'completed');
```

---

### 2. Products (Ürünler)

Firma içi ürün tanımlarını ve barkod bilgilerini tutar.

| Sütun | Tip | Kısıtlamalar | Açıklama |
|-------|-----|-------------|----------|
| `id` | INTEGER | PRIMARY KEY, AUTO_INCREMENT | Benzersiz ürün ID'si |
| `ourProductCode` | TEXT | NOT NULL | Firma içi ürün kodu |
| `name` | TEXT | NOT NULL | Ürün adı |
| `barcode` | TEXT | NOT NULL | Ürün barkodu |
| `isUniqueBarcodeRequired` | BOOLEAN | DEFAULT FALSE | Benzersiz barkod gereksinimi |

#### Benzersiz Barkod Kontrolü
- `isUniqueBarcodeRequired = true`: Aynı barkod tekrar okutulamaz
- `isUniqueBarcodeRequired = false`: Aynı barkod birden fazla kez okutulabilir

#### Örnek Veriler
```sql
INSERT INTO products (ourProductCode, name, barcode, isUniqueBarcodeRequired) VALUES 
('PRD001', 'Ürün 1 - Standart Paket', '1234567890123', 0),
('PRD002', 'Ürün 2 - Premium Paket', '2345678901234', 1),
('PRD005', 'Ürün 5 - Özel Seri', '5678901234567', 1);
```

---

### 3. OrderItems (Sipariş Kalemleri)

Her siparişte bulunan ürünlerin detaylarını ve sayım durumunu tutar.

| Sütun | Tip | Kısıtlamalar | Açıklama |
|-------|-----|-------------|----------|
| `id` | INTEGER | PRIMARY KEY, AUTO_INCREMENT | Benzersiz kalem ID'si |
| `orderId` | INTEGER | FOREIGN KEY → Orders(id) | Bağlı sipariş ID'si |
| `productId` | INTEGER | FOREIGN KEY → Products(id) | Bağlı ürün ID'si |
| `quantity` | INTEGER | NOT NULL | İstenen miktar |
| `scannedQuantity` | INTEGER | DEFAULT 0 | Okutulan miktar |

#### İş Mantığı
- `scannedQuantity < quantity`: Eksik sayım
- `scannedQuantity = quantity`: Tamamlanmış sayım
- `scannedQuantity > quantity`: Fazla sayım (uyarı)

#### Progress Hesaplama
```dart
double progress = scannedQuantity / quantity;
bool isCompleted = scannedQuantity >= quantity;
```

---

### 4. ProductCodeMappings (Ürün Kodu Eşleştirmeleri)

Müşteri ürün kodları ile firma içi ürün kodları arasındaki eşleştirmeleri tutar.

| Sütun | Tip | Kısıtlamalar | Açıklama |
|-------|-----|-------------|----------|
| `id` | INTEGER | PRIMARY KEY, AUTO_INCREMENT | Benzersiz eşleştirme ID'si |
| `customerProductCode` | TEXT | NOT NULL | Müşteriye ait ürün kodu |
| `productId` | INTEGER | FOREIGN KEY → Products(id) | Firma içi ürün ID'si |
| `customerName` | TEXT | NOT NULL | Müşteri adı |

#### Kullanım Senaryosu
1. Barkod okutulduğunda müşteri ürün kodu gelir
2. Bu kod ile firma içi ürün kodu eşleştirilir
3. Doğru ürün için sayım yapılır

#### Örnek Veriler
```sql
INSERT INTO product_code_mappings (customerProductCode, productId, customerName) VALUES 
('ABC-001', 1, 'ABC Şirketi'),
('XYZ-A1', 3, 'XYZ Ltd.'),
('DEF-SPECIAL', 5, 'DEF A.Ş.');
```

---

### 5. BarcodeReads (Barkod Okuma Kayıtları)

Okutulan her barkodun detaylı kaydını tutar (loglama ve unique kontrol için).

| Sütun | Tip | Kısıtlamalar | Açıklama |
|-------|-----|-------------|----------|
| `id` | INTEGER | PRIMARY KEY, AUTO_INCREMENT | Benzersiz okuma ID'si |
| `orderId` | INTEGER | FOREIGN KEY → Orders(id) | Hangi sipariş için okutuldu |
| `productId` | INTEGER | NULLABLE, FOREIGN KEY → Products(id) | Eşleştirilen ürün (varsa) |
| `barcode` | TEXT | NOT NULL | Okutulan barkod |
| `readAt` | DATETIME | DEFAULT CURRENT_TIMESTAMP | Okutulma zamanı |

#### Kullanım Amaçları
1. **Unique Barkod Kontrolü**: Aynı barkodun tekrar okutulup okutulmadığını kontrol
2. **Audit Trail**: Tüm barkod okuma işlemlerinin kaydı
3. **Hata Analizi**: Yanlış okutulan barkodların tespiti

---

### 6. Deliveries (Teslimatlar)

Yapılan teslimatların ana bilgilerini tutar.

| Sütun | Tip | Kısıtlamalar | Açıklama |
|-------|-----|-------------|----------|
| `id` | INTEGER | PRIMARY KEY, AUTO_INCREMENT | Benzersiz teslimat ID'si |
| `orderId` | INTEGER | FOREIGN KEY → Orders(id) | Hangi sipariş için teslimat |
| `deliveryDate` | DATETIME | DEFAULT CURRENT_TIMESTAMP | Teslimat tarihi |

#### Kısmi Teslimat Desteği
- Bir sipariş için birden fazla teslimat yapılabilir
- Her teslimat ayrı bir kayıt olarak tutulur

---

### 7. DeliveryItems (Teslimat Kalemleri)

Her teslimatın detaylarını (hangi üründen ne kadar gönderildi) tutar.

| Sütun | Tip | Kısıtlamalar | Açıklama |
|-------|-----|-------------|----------|
| `id` | INTEGER | PRIMARY KEY, AUTO_INCREMENT | Benzersiz teslimat kalemi ID'si |
| `deliveryId` | INTEGER | FOREIGN KEY → Deliveries(id) | Bağlı teslimat ID'si |
| `productId` | INTEGER | FOREIGN KEY → Products(id) | Gönderilen ürün ID'si |
| `quantity` | INTEGER | NOT NULL | Gönderilen miktar |

---

## 🔄 Veritabanı Migrasyonları

### Şema Versiyonu 1 → 2
```dart
onUpgrade: (Migrator m, int from, int to) async {
  if (from == 1 && to == 2) {
    // Barkod alanını Products tablosuna ekle
    await m.addColumn(products, products.barcode);
  }
}
```

### Gelecek Migrasyonlar
- Şema versiyonu artırılarak yeni alanlar eklenebilir
- Mevcut veriler korunarak yapı güncellenebilir

---

## 📈 Performans ve İndeksler

### Önerilen İndeksler
```sql
-- Sipariş kodu ile hızlı arama
CREATE INDEX idx_orders_order_code ON orders(orderCode);

-- Müşteri adı ile filtreleme
CREATE INDEX idx_orders_customer_name ON orders(customerName);

-- Ürün barkodu ile hızlı arama
CREATE INDEX idx_products_barcode ON products(barcode);

-- Sipariş kalemlerinde sipariş ID'si ile filtreleme
CREATE INDEX idx_order_items_order_id ON order_items(orderId);

-- Barkod okumalarında sipariş ve tarih filtreleme
CREATE INDEX idx_barcode_reads_order_date ON barcode_reads(orderId, readAt);

-- Ürün kodu eşleştirmelerinde müşteri kodu arama
CREATE INDEX idx_product_mappings_customer_code ON product_code_mappings(customerProductCode);
```

---

## 🔍 Örnek Sorgular

### 1. Sipariş Durumu Raporu
```sql
SELECT 
    o.orderCode,
    o.customerName,
    o.status,
    COUNT(oi.id) as totalItems,
    SUM(oi.quantity) as totalQuantity,
    SUM(oi.scannedQuantity) as scannedQuantity,
    ROUND(
        (SUM(oi.scannedQuantity) * 100.0 / SUM(oi.quantity)), 2
    ) as completionPercentage
FROM orders o
LEFT JOIN order_items oi ON o.id = oi.orderId
GROUP BY o.id, o.orderCode, o.customerName, o.status;
```

### 2. Ürün Bazında Sayım Durumu
```sql
SELECT 
    p.ourProductCode,
    p.name,
    oi.quantity as required,
    oi.scannedQuantity as scanned,
    (oi.quantity - oi.scannedQuantity) as remaining
FROM order_items oi
JOIN products p ON oi.productId = p.id
JOIN orders o ON oi.orderId = o.id
WHERE o.orderCode = 'SIP001'
ORDER BY p.ourProductCode;
```

### 3. Barkod Okuma Geçmişi
```sql
SELECT 
    br.barcode,
    br.readAt,
    o.orderCode,
    p.name as productName,
    p.ourProductCode
FROM barcode_reads br
JOIN orders o ON br.orderId = o.id
LEFT JOIN products p ON br.productId = p.id
WHERE o.orderCode = 'SIP001'
ORDER BY br.readAt DESC;
```

### 4. Teslimat Geçmişi
```sql
SELECT 
    d.deliveryDate,
    o.orderCode,
    o.customerName,
    p.ourProductCode,
    p.name,
    di.quantity as deliveredQuantity
FROM deliveries d
JOIN orders o ON d.orderId = o.id
JOIN delivery_items di ON d.id = di.deliveryId
JOIN products p ON di.productId = p.id
WHERE o.orderCode = 'SIP002'
ORDER BY d.deliveryDate DESC;
```

### 5. Müşteri Ürün Kodu Eşleştirme
```sql
SELECT 
    pcm.customerProductCode,
    p.ourProductCode,
    p.name,
    pcm.customerName
FROM product_code_mappings pcm
JOIN products p ON pcm.productId = p.id
WHERE pcm.customerName = 'ABC Şirketi';
```

---

## 🛡️ Veri Bütünlüğü ve Kısıtlamalar

### Foreign Key Kısıtlamaları
- `order_items.orderId` → `orders.id`
- `order_items.productId` → `products.id`
- `product_code_mappings.productId` → `products.id`
- `barcode_reads.orderId` → `orders.id`
- `barcode_reads.productId` → `products.id` (nullable)
- `deliveries.orderId` → `orders.id`
- `delivery_items.deliveryId` → `deliveries.id`
- `delivery_items.productId` → `products.id`

### İş Kuralları
1. **Sipariş Durumu**: Otomatik güncelleme
   - Tüm kalemler tamamlandığında: `completed`
   - Bazı kalemler tamamlandığında: `partial`
   - Hiç kalem tamamlanmadığında: `pending`

2. **Unique Barkod Kontrolü**: 
   - `isUniqueBarcodeRequired = true` olan ürünler için aynı barkod tekrar okutulamaz

3. **Miktar Kontrolü**:
   - `scannedQuantity` negatif olamaz
   - `quantity` sıfırdan büyük olmalı

---

## 🔧 Bakım ve Optimizasyon

### Düzenli Bakım İşlemleri
1. **Eski Barkod Kayıtlarını Temizleme**:
   ```sql
   DELETE FROM barcode_reads 
   WHERE readAt < datetime('now', '-30 days');
   ```

2. **Veritabanı Boyutu Optimizasyonu**:
   ```sql
   VACUUM;
   ```

3. **İstatistik Güncelleme**:
   ```sql
   ANALYZE;
   ```

### Yedekleme Stratejisi
- Günlük otomatik yedekleme
- Kritik işlemler öncesi manuel yedekleme
- Yedek dosyaları farklı konumda saklama

---

## 📝 Notlar ve Önemli Bilgiler

### Drift ORM Özellikleri
- Type-safe SQL sorguları
- Otomatik kod üretimi
- Migration desteği
- Stream-based reactive queries

### Performans İpuçları
1. Büyük veri setleri için sayfalama kullanın
2. Gereksiz JOIN'lerden kaçının
3. İndeksleri düzenli kontrol edin
4. EXPLAIN QUERY PLAN ile sorgu performansını analiz edin

### Güvenlik Notları
- SQL injection saldırılarına karşı Drift'in parametreli sorgularını kullanın
- Hassas verileri şifreleyerek saklayın
- Veritabanı dosyasına erişimi kısıtlayın

---

## 📞 Destek ve İletişim

Bu dokümantasyon hakkında sorularınız için:
- Proje deposu: [GitHub Repository]
- Geliştirici: [Developer Contact]
- Dokümantasyon versiyonu: 1.0
- Son güncelleme: [Current Date] 