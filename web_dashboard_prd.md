# Web Dashboard PRD - Paketleme Takip Sistemi Sipariş Yönetimi

## 1. Proje Genel Bakışı

### 1.1 Amaç
Mevcut Excel tabanlı sipariş ekleme sistemini, modern web teknolojileri kullanarak daha verimli, kullanıcı dostu ve gerçek zamanlı bir sipariş yönetim dashboarduna dönüştürmek.

### 1.2 Hedefler
- Excel import sürecini ortadan kaldırarak manuel hataları azaltmak
- Gerçek zamanlı sipariş takibi ve yönetimi sağlamak
- Çoklu kullanıcı desteği ile yetki tabanlı erişim kontrolü
- Flutter uygulaması ile seamless entegrasyon
- Merkezi veri yönetimi ve synchronization

### 1.3 Kapsam
- **Dahil**: Sipariş CRUD işlemleri, ürün yönetimi, müşteri kod eşleştirme, kullanıcı yönetimi, dashboard analytics
- **Hariç**: Barkod okuma işlemleri (Flutter app'de kalacak), PDF/Excel export (gelecek iterasyonda)

## 2. Teknik Mimari

### 2.1 Technology Stack

#### Frontend (Next.js 14)
- **Framework**: Next.js 14 (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind CSS + shadcn/ui
- **State Management**: Zustand / React Context
- **Authentication**: Firebase Auth
- **Real-time**: Firebase Firestore listeners
- **Deployment**: Vercel

#### Backend (Firebase)
- **Database**: Firestore (NoSQL)
- **Authentication**: Firebase Authentication
- **Storage**: Firebase Storage (gelecekte dosya yükleme için)
- **Functions**: Firebase Cloud Functions (business logic)
- **Hosting**: Firebase Hosting (backup deployment option)

### 2.2 Sistem Mimarisi

```
┌─────────────────────┐    ┌─────────────────────┐    ┌──────────────────────┐
│   Flutter Mobile    │    │   Next.js Web       │    │    Firebase          │
│   App (Existing)    │◄──►│   Dashboard         │◄──►│    Backend           │
│                     │    │                     │    │                      │
│ - Barcode Scanning  │    │ - Order Management  │    │ - Firestore DB       │
│ - Progress Tracking │    │ - User Management   │    │ - Authentication     │
│ - Local SQLite      │    │ - Analytics         │    │ - Cloud Functions    │
└─────────────────────┘    └─────────────────────┘    └──────────────────────┘
```

## 3. Veri Modelleri (Firestore Collections)

### 3.1 Users Collection
```typescript
interface User {
  uid: string;                    // Firebase Auth UID
  email: string;
  displayName: string;
  role: UserRole;
  company?: string;
  isActive: boolean;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  lastLoginAt?: Timestamp;
}

enum UserRole {
  ADMIN = 'admin',
  MANAGER = 'manager',
  OPERATOR = 'operator'
}
```

### 3.2 Orders Collection
```typescript
interface Order {
  id: string;                     // Firestore document ID
  orderCode: string;              // Benzersiz sipariş kodu (SIP001, SIP002, vb.)
  customerName: string;
  status: OrderStatus;
  priority: OrderPriority;
  dueDate?: Timestamp;
  notes?: string;
  createdBy: string;              // User UID
  updatedBy: string;              // User UID
  createdAt: Timestamp;
  updatedAt: Timestamp;
  
  // Analytics fields
  estimatedCompletionDate?: Timestamp;
  actualCompletionDate?: Timestamp;
  
  // Sync fields (Flutter app ile senkronizasyon için)
  syncedToMobile: boolean;
  lastSyncAt?: Timestamp;
}

enum OrderStatus {
  DRAFT = 'draft',
  PENDING = 'pending',
  IN_PROGRESS = 'in_progress',
  PARTIAL = 'partial',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled'
}

enum OrderPriority {
  LOW = 'low',
  NORMAL = 'normal',
  HIGH = 'high',
  URGENT = 'urgent'
}
```

### 3.3 OrderItems SubCollection (orders/{orderId}/items)
```typescript
interface OrderItem {
  id: string;
  productId: string;              // Products collection reference
  quantity: number;
  scannedQuantity: number;        // Flutter app'den gelecek
  customerProductCode: string;    // Müşteriye özel ürün kodu
  unitPrice?: number;
  totalPrice?: number;
  notes?: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  
  // Calculated fields (Firestore'da hesaplanmayacak, client-side)
  // progress: number;            // scannedQuantity / quantity
  // isCompleted: boolean;        // scannedQuantity >= quantity
}
```

### 3.4 Products Collection
```typescript
interface Product {
  id: string;
  ourProductCode: string;         // Firma içi ürün kodu (PRD001, PRD002, vb.)
  name: string;
  description?: string;
  barcode: string;
  isUniqueBarcodeRequired: boolean;
  category?: string;
  unitPrice?: number;
  stockQuantity?: number;
  minStockLevel?: number;
  isActive: boolean;
  createdBy: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  
  // SEO/Search fields
  searchKeywords: string[];       // name, ourProductCode, barcode'dan oluşacak
}
```

### 3.5 ProductCodeMappings Collection
```typescript
interface ProductCodeMapping {
  id: string;
  customerName: string;
  customerProductCode: string;
  productId: string;              // Products collection reference
  isActive: boolean;
  createdBy: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

### 3.6 BarcodeReads Collection (Flutter app'den gelecek)
```typescript
interface BarcodeRead {
  id: string;
  orderId: string;
  productId: string;
  barcode: string;
  readAt: Timestamp;
  deviceId?: string;              // Flutter app device identifier
  userId?: string;                // Okuma yapan kullanıcı
}
```

### 3.7 Deliveries Collection
```typescript
interface Delivery {
  id: string;
  orderId: string;
  deliveryCode: string;           // TES001, TES002, vb.
  deliveryDate: Timestamp;
  status: DeliveryStatus;
  notes?: string;
  createdBy: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

enum DeliveryStatus {
  PREPARING = 'preparing',
  READY = 'ready',
  SHIPPED = 'shipped',
  DELIVERED = 'delivered'
}
```

### 3.8 DeliveryItems SubCollection (deliveries/{deliveryId}/items)
```typescript
interface DeliveryItem {
  id: string;
  productId: string;
  quantity: number;
  actualQuantity?: number;        // Gerçek gönderilen miktar
  notes?: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

### 3.9 AuditLogs Collection
```typescript
interface AuditLog {
  id: string;
  userId: string;
  action: string;                 // CREATE, UPDATE, DELETE, etc.
  collection: string;             // orders, products, etc.
  documentId: string;
  oldData?: any;
  newData?: any;
  timestamp: Timestamp;
  userAgent?: string;
  ipAddress?: string;
}
```

## 4. API Tasarımı (Firebase Cloud Functions)

### 4.1 Authentication & Authorization
```typescript
// Middleware function for route protection
export const requireAuth = (allowedRoles?: UserRole[]) => { ... }

// Custom claims for role-based access
export const setUserRole = async (uid: string, role: UserRole) => { ... }
```

### 4.2 Order Management Functions
```typescript
// GET /api/orders
export const getOrders = functions.https.onCall(async (data, context) => {
  // Query parameters: status, customerName, dateRange, limit, lastVisible
});

// POST /api/orders
export const createOrder = functions.https.onCall(async (data, context) => {
  // Validation + Transaction + Order Code Generation
});

// PUT /api/orders/{orderId}
export const updateOrder = functions.https.onCall(async (data, context) => {
  // Update with audit logging
});

// DELETE /api/orders/{orderId}
export const deleteOrder = functions.https.onCall(async (data, context) => {
  // Soft delete with audit logging
});

// POST /api/orders/{orderId}/items
export const addOrderItems = functions.https.onCall(async (data, context) => {
  // Batch add order items with validation
});
```

### 4.3 Product Management Functions
```typescript
// Bulk product operations
export const importProducts = functions.https.onCall(async (data, context) => {
  // CSV/Excel import with validation
});

// Product search with indexing
export const searchProducts = functions.https.onCall(async (data, context) => {
  // Full-text search implementation
});
```

### 4.4 Synchronization Functions
```typescript
// Mobile app synchronization
export const syncToMobile = functions.https.onCall(async (data, context) => {
  // Return delta changes since last sync
});

export const updateFromMobile = functions.https.onCall(async (data, context) => {
  // Update scanned quantities from mobile app
});
```

### 4.5 Analytics Functions
```typescript
export const getDashboardStats = functions.https.onCall(async (data, context) => {
  // Return aggregated statistics
});

export const getOrderAnalytics = functions.https.onCall(async (data, context) => {
  // Return order completion metrics
});
```

## 5. Next.js Web Dashboard - Sayfa Yapısı

### 5.1 Routing Structure
```
/
├── / (Dashboard Home)
├── /login
├── /orders
│   ├── /orders (List)
│   ├── /orders/new (Create)
│   ├── /orders/[id] (Detail)
│   └── /orders/[id]/edit (Edit)
├── /products
│   ├── /products (List)
│   ├── /products/new (Create)
│   └── /products/[id]/edit (Edit)
├── /customers
│   ├── /customers (List)
│   └── /customers/mappings (Product Code Mappings)
├── /deliveries
│   ├── /deliveries (List)
│   └── /deliveries/[id] (Detail)
├── /analytics
├── /settings
│   ├── /settings/users (User Management - Admin only)
│   └── /settings/profile
└── /api/auth/[...nextauth] (Authentication)
```

### 5.2 Sayfa Bileşenleri

#### Dashboard Home (`/`)
- **Widgets**: Sipariş durumu özeti, günlük istatistikler, son aktiviteler
- **Charts**: Sipariş tamamlanma grafikleri, ürün dağılımı
- **Quick Actions**: Yeni sipariş oluştur, acil siparişler listesi

#### Orders Management (`/orders`)
- **List View**: DataTable with filtering, sorting, pagination
- **Search**: Sipariş kodu, müşteri adı, durum filtresi
- **Bulk Operations**: Toplu durum güncelleme, silme
- **Export**: CSV/Excel export (gelecek iterasyon)

#### Order Detail (`/orders/[id]`)
- **Order Info**: Temel bilgiler düzenleme
- **Items Management**: Ürün ekleme/çıkarma, miktar güncelleme
- **Progress Tracking**: Real-time progress bars
- **History**: Barkod okuma geçmişi, değişiklik logları

#### Products Management (`/products`)
- **CRUD Operations**: Ürün ekleme, düzenleme, silme
- **Bulk Import**: CSV/Excel import
- **Code Mapping**: Müşteri ürün kodu eşleştirme

## 6. Güvenlik ve Yetkilendirme

### 6.1 Kullanıcı Rolleri ve İzinler
```typescript
const permissions = {
  ADMIN: ['*'], // Tüm işlemler
  MANAGER: [
    'orders:read', 'orders:create', 'orders:update',
    'products:read', 'products:create', 'products:update',
    'deliveries:read', 'deliveries:create', 'deliveries:update',
    'analytics:read'
  ],
  OPERATOR: [
    'orders:read', 'orders:update:scanned_quantity',
    'products:read',
    'deliveries:read'
  ]
};
```

### 6.2 Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - only authenticated users can read their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'manager'];
    }
    
    // Orders collection - role-based access
    match /orders/{orderId} {
      allow read: if request.auth != null;
      allow create, update: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'manager'];
      allow delete: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
        
      // Order items subcollection
      match /items/{itemId} {
        allow read, write: if request.auth != null;
      }
    }
    
    // Products collection
    match /products/{productId} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'manager'];
    }
  }
}
```

### 6.3 Authentication Flow
1. **Email/Password Authentication** (Firebase Auth)
2. **Role-based Custom Claims** (Cloud Functions)
3. **JWT Token Validation** (Next.js middleware)
4. **Session Management** (NextAuth.js integration)

## 7. Özellik Listesi

### 7.1 MVP (Phase 1) Özellikleri
- [x] Kullanıcı authentication ve role management
- [x] Sipariş CRUD işlemleri
- [x] Ürün yönetimi ve kod eşleştirme
- [x] Real-time sipariş durumu takibi
- [x] Temel dashboard analytics
- [x] Mobile app synchronization API

### 7.2 Phase 2 Özellikleri
- [ ] Excel/CSV import/export
- [ ] Detaylı analytics ve raporlama
- [ ] Email notification sistemi
- [ ] Teslimat yönetimi
- [ ] Çeki listesi (PDF) oluşturma
- [ ] Sistem ayarları ve konfigürasyon

### 7.3 Phase 3 Özellikleri
- [ ] Multi-tenant architecture (çoklu şirket desteği)
- [ ] REST API for third-party integrations
- [ ] Advanced search ve filtering
- [ ] Workflow automation
- [ ] Mobile responsive improvements

## 8. Performans ve Ölçeklenebilirlik

### 8.1 Firestore Optimizasyonları
- **Composite Indexes**: Query performance için
- **Pagination**: Large datasets için limit/offset
- **Denormalization**: Read performance için calculated fields
- **Batch Operations**: Write performance için

### 8.2 Next.js Optimizasyonları
- **SSR/SSG**: SEO ve performance için
- **Image Optimization**: Next.js Image component
- **Code Splitting**: Route-based lazy loading
- **Caching**: SWR/TanStack Query ile data caching

### 8.3 Monitoring ve Analytics
- **Firebase Analytics**: User behavior tracking
- **Performance Monitoring**: Web vitals tracking
- **Error Tracking**: Sentry entegrasyonu
- **Custom Metrics**: Business metrics dashboard

## 9. Development Roadmap

### 9.1 Phase 1 (2-3 hafta)
1. **Week 1**: Firebase setup, authentication, basic CRUD
2. **Week 2**: Next.js dashboard, order management
3. **Week 3**: Mobile synchronization, testing

### 9.2 Phase 2 (2-3 hafta)
1. **Week 4**: Analytics dashboard, import/export
2. **Week 5**: Notification sistem, delivery management
3. **Week 6**: UI/UX improvements, performance optimization

### 9.3 Phase 3 (Gelecek iterasyonlar)
- Multi-tenant architecture
- Advanced features
- Third-party integrations

## 10. Teknik Gereksinimler

### 10.1 Development Environment
- **Node.js**: 18.x veya üzeri
- **npm/yarn**: Package management
- **Firebase CLI**: Development ve deployment
- **Git**: Version control
- **VS Code**: Recommended editor

### 10.2 Dependencies
```json
{
  "dependencies": {
    "next": "^14.0.0",
    "react": "^18.0.0",
    "typescript": "^5.0.0",
    "firebase": "^10.0.0",
    "firebase-admin": "^11.0.0",
    "@next/font": "^14.0.0",
    "tailwindcss": "^3.0.0",
    "@radix-ui/react-*": "latest",
    "zustand": "^4.0.0",
    "zod": "^3.0.0",
    "react-hook-form": "^7.0.0",
    "date-fns": "^2.0.0",
    "recharts": "^2.0.0"
  }
}
```

### 10.3 Environment Variables
```env
# Firebase Configuration
NEXT_PUBLIC_FIREBASE_API_KEY=
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=
NEXT_PUBLIC_FIREBASE_PROJECT_ID=
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=
NEXT_PUBLIC_FIREBASE_APP_ID=

# Firebase Admin (Server-side)
FIREBASE_ADMIN_PROJECT_ID=
FIREBASE_ADMIN_CLIENT_EMAIL=
FIREBASE_ADMIN_PRIVATE_KEY=

# Application
NEXTAUTH_URL=
NEXTAUTH_SECRET=
```

## 11. Testing Strategy

### 11.1 Unit Tests
- **Component Tests**: React Testing Library
- **Function Tests**: Jest
- **API Tests**: Firebase emulator

### 11.2 Integration Tests
- **End-to-End**: Playwright/Cypress
- **API Integration**: Supertest
- **Database Tests**: Firebase emulator

### 11.3 Performance Tests
- **Load Testing**: k6
- **Performance Monitoring**: Lighthouse CI
- **Firebase Performance**: Firebase Performance Monitoring

## 12. Deployment ve DevOps

### 12.1 CI/CD Pipeline
```yaml
# .github/workflows/deploy.yml
name: Deploy to Production
on:
  push:
    branches: [main]
  
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm test
      
  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm run build
      - run: firebase deploy
```

### 12.2 Environment Management
- **Development**: Firebase Emulator Suite
- **Staging**: Firebase Staging Project
- **Production**: Firebase Production Project

## 13. Migration Plan (Excel'den Web Dashboard'a Geçiş)

### 13.1 Data Migration
1. **Existing SQLite Data**: Firebase'e migration script
2. **Excel Templates**: Web form conversion
3. **User Training**: Dashboard kullanım eğitimi

### 13.2 Rollout Strategy
1. **Pilot Testing**: Seçili kullanıcılar ile test
2. **Parallel Run**: Excel ve web dashboard birlikte
3. **Full Migration**: Excel kullanımını sonlandırma

### 13.3 Rollback Plan
- Excel import functionality temporary backup
- Data export capabilities
- Manual intervention procedures

## 14. Success Metrics

### 14.1 Technical Metrics
- **Response Time**: < 2 seconds for all operations
- **Uptime**: 99.9% availability
- **Error Rate**: < 1% for critical operations

### 14.2 Business Metrics
- **User Adoption**: 90% of users using web dashboard
- **Data Accuracy**: 99% reduction in manual entry errors
- **Process Efficiency**: 50% reduction in order processing time

### 14.3 User Experience Metrics
- **User Satisfaction**: > 4.5/5 rating
- **Task Completion Rate**: > 95%
- **Training Time**: < 2 hours for new users

---

Bu PRD dokümantasyonu, mevcut Flutter uygulamanızın sipariş yönetimi modülünü destekleyecek modern web dashboard sisteminin tüm gereksinimlerini kapsamaktadır. Firebase backend ile Next.js frontend kullanarak ölçeklenebilir, güvenli ve kullanıcı dostu bir sistem oluşturulacaktır. 