# Web Dashboard - Gerekli Modeller ve API Bilgileri

## Firebase Projesi Bilgileri
- **Project ID**: bursali-otomotiv
- **Auth Domain**: bursali-otomotiv.firebaseapp.com
- **Storage Bucket**: bursali-otomotiv.firebasestorage.app

## TypeScript Modelleri

### 1. Temel Veri Tipleri

```typescript
// types/enums.ts
export enum OrderStatus {
  PENDING = 'pending',
  PARTIAL = 'partial',
  COMPLETED = 'completed'
}

export enum SyncStatus {
  PENDING = 'pending',
  SYNCING = 'syncing',
  COMPLETED = 'completed',
  FAILED = 'failed'
}

export enum SourceType {
  WEB = 'web',
  MOBILE = 'mobile',
  IMPORT = 'import'
}
```

### 2. Ana Veri Modelleri

```typescript
// types/models.ts
import { Timestamp } from 'firebase/firestore';

export interface Company {
  id: string;
  name: string;
  email: string;
  phone: string;
  address: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  settings: {
    syncInterval: number; // dakika
    enableOfflineMode: boolean;
  };
}

export interface Order {
  id: string;
  orderCode: string;
  customerName: string;
  status: OrderStatus;
  companyId: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  lastSyncedAt?: Timestamp;
  source: SourceType;
  metadata: {
    createdBy: string;
    updatedBy?: string;
    deviceId?: string;
  };
  // Calculated fields (not stored in DB)
  totalItems?: number;
  completedItems?: number;
  progress?: number;
}

export interface OrderItem {
  id: string;
  orderId: string;
  productId: string;
  quantity: number;
  scannedQuantity: number;
  companyId: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  lastSyncedAt?: Timestamp;
  // Relations (populated)
  product?: Product;
  progress?: number; // scannedQuantity / quantity
  isCompleted?: boolean;
}

export interface Product {
  id: string;
  ourProductCode: string;
  name: string;
  barcode: string;
  isUniqueBarcodeRequired: boolean;
  companyId: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface ProductCodeMapping {
  id: string;
  customerProductCode: string;
  productId: string;
  customerName: string;
  companyId: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  // Relations
  product?: Product;
}

export interface BarcodeRead {
  id: string;
  orderId: string;
  productId?: string;
  barcode: string;
  companyId: string;
  readAt: Timestamp;
  syncedAt: Timestamp;
  deviceId: string;
  location?: {
    lat: number;
    lng: number;
  };
  // Relations
  order?: Order;
  product?: Product;
}

export interface Delivery {
  id: string;
  orderId: string;
  deliveryDate: Timestamp;
  companyId: string;
  // Relations
  order?: Order;
  items?: DeliveryItem[];
}

export interface DeliveryItem {
  id: string;
  deliveryId: string;
  productId: string;
  quantity: number;
  companyId: string;
  // Relations
  product?: Product;
}
```

### 3. Form Veri Tipleri

```typescript
// types/forms.ts
export interface CreateOrderForm {
  orderCode: string;
  customerName: string;
  items: CreateOrderItemForm[];
}

export interface CreateOrderItemForm {
  productId: string;
  quantity: number;
  customerProductCode?: string;
}

export interface EditOrderForm {
  orderCode: string;
  customerName: string;
  status: OrderStatus;
}

export interface CreateProductForm {
  ourProductCode: string;
  name: string;
  barcode: string;
  isUniqueBarcodeRequired: boolean;
}

export interface ProductMappingForm {
  customerProductCode: string;
  productId: string;
  customerName: string;
}

export interface BulkOrderImport {
  orders: Array<{
    orderCode: string;
    customerName: string;
    items: Array<{
      customerProductCode: string;
      quantity: number;
    }>;
  }>;
}
```

### 4. API Response Tipleri

```typescript
// types/api.ts
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  hasMore: boolean;
}

export interface DashboardStats {
  totalOrders: number;
  pendingOrders: number;
  completedOrders: number;
  partialOrders: number;
  totalProducts: number;
  recentBarcodeReads: number;
  todayStats: {
    ordersCreated: number;
    itemsScanned: number;
    ordersCompleted: number;
  };
}

export interface OrderSummary {
  order: Order;
  items: OrderItem[];
  totalItems: number;
  completedItems: number;
  progress: number;
  recentBarcodeReads: BarcodeRead[];
  deliveries: Delivery[];
}
```

## Firebase Firestore Fonksiyonları

### 1. Temel CRUD İşlemleri

```typescript
// lib/firebase/orders.ts
import { 
  collection, 
  doc, 
  addDoc, 
  updateDoc, 
  deleteDoc, 
  getDoc, 
  getDocs, 
  query, 
  where, 
  orderBy, 
  limit,
  onSnapshot,
  writeBatch,
  Timestamp 
} from 'firebase/firestore';
import { db } from './config';

const COLLECTIONS = {
  ORDERS: 'orders',
  ORDER_ITEMS: 'orderItems',
  PRODUCTS: 'products',
  PRODUCT_MAPPINGS: 'productCodeMappings',
  BARCODE_READS: 'barcodeReads',
  COMPANIES: 'companies'
} as const;

// Orders CRUD
export const createOrder = async (orderData: CreateOrderForm, companyId: string, userId: string) => {
  const batch = writeBatch(db);
  
  try {
    // Sipariş oluştur
    const orderRef = doc(collection(db, COLLECTIONS.ORDERS));
    const order: Omit<Order, 'id'> = {
      orderCode: orderData.orderCode,
      customerName: orderData.customerName,
      status: OrderStatus.PENDING,
      companyId,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      source: SourceType.WEB,
      metadata: {
        createdBy: userId,
      }
    };
    
    batch.set(orderRef, order);
    
    // Sipariş kalemlerini oluştur
    for (const item of orderData.items) {
      const itemRef = doc(collection(db, COLLECTIONS.ORDER_ITEMS));
      const orderItem: Omit<OrderItem, 'id'> = {
        orderId: orderRef.id,
        productId: item.productId,
        quantity: item.quantity,
        scannedQuantity: 0,
        companyId,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      };
      
      batch.set(itemRef, orderItem);
      
      // Müşteri ürün kodu eşleştirmesi (varsa)
      if (item.customerProductCode) {
        const mappingRef = doc(collection(db, COLLECTIONS.PRODUCT_MAPPINGS));
        const mapping: Omit<ProductCodeMapping, 'id'> = {
          customerProductCode: item.customerProductCode,
          productId: item.productId,
          customerName: orderData.customerName,
          companyId,
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        };
        
        batch.set(mappingRef, mapping);
      }
    }
    
    await batch.commit();
    return { success: true, orderId: orderRef.id };
    
  } catch (error) {
    console.error('Order creation error:', error);
    throw error;
  }
};

export const updateOrder = async (orderId: string, updates: Partial<EditOrderForm>) => {
  const orderRef = doc(db, COLLECTIONS.ORDERS, orderId);
  
  await updateDoc(orderRef, {
    ...updates,
    updatedAt: Timestamp.now(),
  });
};

export const deleteOrder = async (orderId: string) => {
  const batch = writeBatch(db);
  
  // Sipariş kalemlerini sil
  const itemsQuery = query(
    collection(db, COLLECTIONS.ORDER_ITEMS),
    where('orderId', '==', orderId)
  );
  const itemsSnapshot = await getDocs(itemsQuery);
  
  itemsSnapshot.docs.forEach(doc => {
    batch.delete(doc.ref);
  });
  
  // Siparişi sil
  const orderRef = doc(db, COLLECTIONS.ORDERS, orderId);
  batch.delete(orderRef);
  
  await batch.commit();
};

export const getOrder = async (orderId: string): Promise<Order | null> => {
  const orderDoc = await getDoc(doc(db, COLLECTIONS.ORDERS, orderId));
  
  if (!orderDoc.exists()) return null;
  
  return { id: orderDoc.id, ...orderDoc.data() } as Order;
};

export const getOrders = async (companyId: string, filters?: {
  status?: OrderStatus;
  search?: string;
  limit?: number;
}): Promise<Order[]> => {
  let q = query(
    collection(db, COLLECTIONS.ORDERS),
    where('companyId', '==', companyId),
    orderBy('createdAt', 'desc')
  );
  
  if (filters?.status) {
    q = query(q, where('status', '==', filters.status));
  }
  
  if (filters?.limit) {
    q = query(q, limit(filters.limit));
  }
  
  const snapshot = await getDocs(q);
  let orders = snapshot.docs.map(doc => ({ 
    id: doc.id, 
    ...doc.data() 
  } as Order));
  
  // Arama filtresi (client-side)
  if (filters?.search) {
    const searchLower = filters.search.toLowerCase();
    orders = orders.filter(order => 
      order.orderCode.toLowerCase().includes(searchLower) ||
      order.customerName.toLowerCase().includes(searchLower)
    );
  }
  
  return orders;
};

export const getOrderSummary = async (orderId: string): Promise<OrderSummary | null> => {
  const order = await getOrder(orderId);
  if (!order) return null;
  
  // Sipariş kalemlerini al
  const itemsQuery = query(
    collection(db, COLLECTIONS.ORDER_ITEMS),
    where('orderId', '==', orderId)
  );
  
  const itemsSnapshot = await getDocs(itemsQuery);
  const items = itemsSnapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  } as OrderItem));
  
  // Ürün bilgilerini al ve ekle
  for (const item of items) {
    const product = await getDoc(doc(db, COLLECTIONS.PRODUCTS, item.productId));
    if (product.exists()) {
      item.product = { id: product.id, ...product.data() } as Product;
    }
    item.progress = item.quantity > 0 ? item.scannedQuantity / item.quantity : 0;
    item.isCompleted = item.scannedQuantity >= item.quantity;
  }
  
  // Son barkod okumalarını al
  const recentReadsQuery = query(
    collection(db, COLLECTIONS.BARCODE_READS),
    where('orderId', '==', orderId),
    orderBy('readAt', 'desc'),
    limit(10)
  );
  
  const readsSnapshot = await getDocs(recentReadsQuery);
  const recentBarcodeReads = readsSnapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  } as BarcodeRead));
  
  const totalItems = items.reduce((sum, item) => sum + item.quantity, 0);
  const completedItems = items.reduce((sum, item) => sum + item.scannedQuantity, 0);
  const progress = totalItems > 0 ? completedItems / totalItems : 0;
  
  return {
    order,
    items,
    totalItems,
    completedItems,
    progress,
    recentBarcodeReads,
    deliveries: [] // TODO: Implement deliveries
  };
};
```

### 2. Real-time Listeners

```typescript
// lib/firebase/realtime.ts
export const useRealtimeOrders = (companyId: string, callback: (orders: Order[]) => void) => {
  const q = query(
    collection(db, COLLECTIONS.ORDERS),
    where('companyId', '==', companyId),
    orderBy('updatedAt', 'desc')
  );
  
  return onSnapshot(q, (snapshot) => {
    const orders = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as Order));
    
    callback(orders);
  });
};

export const useRealtimeOrderSummary = (orderId: string, callback: (summary: OrderSummary | null) => void) => {
  const orderRef = doc(db, COLLECTIONS.ORDERS, orderId);
  
  return onSnapshot(orderRef, async (snapshot) => {
    if (!snapshot.exists()) {
      callback(null);
      return;
    }
    
    const summary = await getOrderSummary(orderId);
    callback(summary);
  });
};

export const useRealtimeBarcodeReads = (orderId: string, callback: (reads: BarcodeRead[]) => void) => {
  const q = query(
    collection(db, COLLECTIONS.BARCODE_READS),
    where('orderId', '==', orderId),
    orderBy('readAt', 'desc'),
    limit(50)
  );
  
  return onSnapshot(q, (snapshot) => {
    const reads = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as BarcodeRead));
    
    callback(reads);
  });
};
```

### 3. Ürün İşlemleri

```typescript
// lib/firebase/products.ts
export const createProduct = async (productData: CreateProductForm, companyId: string) => {
  const productRef = doc(collection(db, COLLECTIONS.PRODUCTS));
  
  const product: Omit<Product, 'id'> = {
    ...productData,
    companyId,
    createdAt: Timestamp.now(),
    updatedAt: Timestamp.now(),
  };
  
  await addDoc(collection(db, COLLECTIONS.PRODUCTS), product);
  return productRef.id;
};

export const getProducts = async (companyId: string): Promise<Product[]> => {
  const q = query(
    collection(db, COLLECTIONS.PRODUCTS),
    where('companyId', '==', companyId),
    orderBy('ourProductCode')
  );
  
  const snapshot = await getDocs(q);
  return snapshot.docs.map(doc => ({ 
    id: doc.id, 
    ...doc.data() 
  } as Product));
};

export const updateProduct = async (productId: string, updates: Partial<CreateProductForm>) => {
  const productRef = doc(db, COLLECTIONS.PRODUCTS, productId);
  
  await updateDoc(productRef, {
    ...updates,
    updatedAt: Timestamp.now(),
  });
};

export const deleteProduct = async (productId: string) => {
  // Önce bu ürünü kullanan aktif siparişler var mı kontrol et
  const activeOrdersQuery = query(
    collection(db, COLLECTIONS.ORDER_ITEMS),
    where('productId', '==', productId)
  );
  
  const activeOrders = await getDocs(activeOrdersQuery);
  
  if (!activeOrders.empty) {
    throw new Error('Bu ürün aktif siparişlerde kullanılıyor, silinemez.');
  }
  
  // Ürün kod eşleştirmelerini sil
  const mappingsQuery = query(
    collection(db, COLLECTIONS.PRODUCT_MAPPINGS),
    where('productId', '==', productId)
  );
  
  const mappingsSnapshot = await getDocs(mappingsQuery);
  const batch = writeBatch(db);
  
  mappingsSnapshot.docs.forEach(doc => {
    batch.delete(doc.ref);
  });
  
  // Ürünü sil
  batch.delete(doc(db, COLLECTIONS.PRODUCTS, productId));
  
  await batch.commit();
};
```

### 4. Dashboard İstatistikleri

```typescript
// lib/firebase/dashboard.ts
export const getDashboardStats = async (companyId: string): Promise<DashboardStats> => {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const todayTimestamp = Timestamp.fromDate(today);
  
  // Paralel sorgular
  const [ordersSnapshot, productsSnapshot, todayReadsSnapshot] = await Promise.all([
    getDocs(query(collection(db, COLLECTIONS.ORDERS), where('companyId', '==', companyId))),
    getDocs(query(collection(db, COLLECTIONS.PRODUCTS), where('companyId', '==', companyId))),
    getDocs(query(
      collection(db, COLLECTIONS.BARCODE_READS),
      where('companyId', '==', companyId),
      where('readAt', '>=', todayTimestamp)
    ))
  ]);
  
  const orders = ordersSnapshot.docs.map(doc => doc.data() as Order);
  
  const stats = {
    totalOrders: orders.length,
    pendingOrders: orders.filter(o => o.status === OrderStatus.PENDING).length,
    completedOrders: orders.filter(o => o.status === OrderStatus.COMPLETED).length,
    partialOrders: orders.filter(o => o.status === OrderStatus.PARTIAL).length,
    totalProducts: productsSnapshot.size,
    recentBarcodeReads: todayReadsSnapshot.size,
    todayStats: {
      ordersCreated: orders.filter(o => o.createdAt >= todayTimestamp).length,
      itemsScanned: todayReadsSnapshot.size,
      ordersCompleted: orders.filter(o => 
        o.status === OrderStatus.COMPLETED && 
        o.updatedAt >= todayTimestamp
      ).length,
    }
  };
  
  return stats;
};
```

### 5. Excel Import/Export

```typescript
// lib/firebase/excel.ts
export const importOrdersFromExcel = async (
  excelData: BulkOrderImport, 
  companyId: string, 
  userId: string
): Promise<{ successful: number; failed: string[] }> => {
  const results = { successful: 0, failed: [] as string[] };
  
  for (const orderData of excelData.orders) {
    try {
      // Ürün kodlarını kontrol et ve eşleştir
      const mappedItems: CreateOrderItemForm[] = [];
      
      for (const item of orderData.items) {
        // Müşteri ürün kodundan productId bul
        const mappingQuery = query(
          collection(db, COLLECTIONS.PRODUCT_MAPPINGS),
          where('customerProductCode', '==', item.customerProductCode),
          where('customerName', '==', orderData.customerName)
        );
        
        const mappingSnapshot = await getDocs(mappingQuery);
        
        if (mappingSnapshot.empty) {
          throw new Error(`Ürün kodu bulunamadı: ${item.customerProductCode}`);
        }
        
        const mapping = mappingSnapshot.docs[0].data() as ProductCodeMapping;
        
        mappedItems.push({
          productId: mapping.productId,
          quantity: item.quantity,
          customerProductCode: item.customerProductCode,
        });
      }
      
      // Siparişi oluştur
      await createOrder({
        orderCode: orderData.orderCode,
        customerName: orderData.customerName,
        items: mappedItems,
      }, companyId, userId);
      
      results.successful++;
      
    } catch (error) {
      results.failed.push(`${orderData.orderCode}: ${error.message}`);
    }
  }
  
  return results;
};

export const exportOrdersToExcel = async (companyId: string, filters?: {
  status?: OrderStatus;
  dateFrom?: Date;
  dateTo?: Date;
}) => {
  // Excel export logic burada implement edilecek
  // SheetJS veya benzer kütüphane kullanılabilir
};
```

## React Hooks

### 1. Özel Hook'lar

```typescript
// hooks/useOrders.ts
import { useState, useEffect } from 'react';

export const useOrders = (companyId: string) => {
  const [orders, setOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  
  useEffect(() => {
    const unsubscribe = useRealtimeOrders(companyId, (newOrders) => {
      setOrders(newOrders);
      setLoading(false);
    });
    
    return unsubscribe;
  }, [companyId]);
  
  return { orders, loading, error };
};

// hooks/useDashboardStats.ts
export const useDashboardStats = (companyId: string) => {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    const fetchStats = async () => {
      try {
        const dashboardStats = await getDashboardStats(companyId);
        setStats(dashboardStats);
      } catch (error) {
        console.error('Dashboard stats error:', error);
      } finally {
        setLoading(false);
      }
    };
    
    fetchStats();
    
    // Her 30 saniyede bir güncelle
    const interval = setInterval(fetchStats, 30000);
    
    return () => clearInterval(interval);
  }, [companyId]);
  
  return { stats, loading };
};
```

### 2. Form Validation (Zod)

```typescript
// lib/validations.ts
import { z } from 'zod';

export const createOrderSchema = z.object({
  orderCode: z.string().min(1, 'Sipariş kodu gerekli').max(50, 'Çok uzun'),
  customerName: z.string().min(1, 'Müşteri adı gerekli').max(100, 'Çok uzun'),
  items: z.array(z.object({
    productId: z.string().min(1, 'Ürün seçimi gerekli'),
    quantity: z.number().min(1, 'Miktar en az 1 olmalı').max(10000, 'Çok büyük'),
    customerProductCode: z.string().optional(),
  })).min(1, 'En az bir ürün eklenmeli'),
});

export const createProductSchema = z.object({
  ourProductCode: z.string().min(1, 'Ürün kodu gerekli').max(50, 'Çok uzun'),
  name: z.string().min(1, 'Ürün adı gerekli').max(200, 'Çok uzun'),
  barcode: z.string().min(1, 'Barkod gerekli').max(50, 'Çok uzun'),
  isUniqueBarcodeRequired: z.boolean(),
});

export type CreateOrderFormData = z.infer<typeof createOrderSchema>;
export type CreateProductFormData = z.infer<typeof createProductSchema>;
```

## Utility Fonksiyonları

```typescript
// lib/utils.ts
export const formatDate = (timestamp: Timestamp): string => {
  return timestamp.toDate().toLocaleDateString('tr-TR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
};

export const formatOrderStatus = (status: OrderStatus): string => {
  const statusMap = {
    [OrderStatus.PENDING]: 'Bekliyor',
    [OrderStatus.PARTIAL]: 'Kısmen Gönderildi',
    [OrderStatus.COMPLETED]: 'Tamamlandı',
  };
  
  return statusMap[status];
};

export const getStatusColor = (status: OrderStatus): string => {
  const colorMap = {
    [OrderStatus.PENDING]: 'bg-yellow-100 text-yellow-800',
    [OrderStatus.PARTIAL]: 'bg-blue-100 text-blue-800',
    [OrderStatus.COMPLETED]: 'bg-green-100 text-green-800',
  };
  
  return colorMap[status];
};

export const calculateProgress = (scanned: number, total: number): number => {
  return total > 0 ? Math.round((scanned / total) * 100) : 0;
};
```

## Örnek Component Yapıları

### 1. Sipariş Listesi Komponenti

```typescript
// components/orders/OrderList.tsx
interface OrderListProps {
  companyId: string;
  onOrderSelect: (order: Order) => void;
}

export const OrderList: React.FC<OrderListProps> = ({ companyId, onOrderSelect }) => {
  const { orders, loading } = useOrders(companyId);
  
  // Component implementation...
};
```

### 2. Sipariş Formu

```typescript
// components/orders/CreateOrderForm.tsx
interface CreateOrderFormProps {
  companyId: string;
  onSuccess: (orderId: string) => void;
  onCancel: () => void;
}

export const CreateOrderForm: React.FC<CreateOrderFormProps> = ({ 
  companyId, 
  onSuccess, 
  onCancel 
}) => {
  // Form implementation with react-hook-form + zod
};
```

## Next.js API Routes (Opsiyonel)

```typescript
// pages/api/orders/index.ts
export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method === 'GET') {
    // Get orders
  } else if (req.method === 'POST') {
    // Create order
  }
}

// pages/api/orders/[id].ts
export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const { id } = req.query;
  
  if (req.method === 'GET') {
    // Get specific order
  } else if (req.method === 'PUT') {
    // Update order
  } else if (req.method === 'DELETE') {
    // Delete order
  }
}
```

## Environment Variables

```env
# .env.local
NEXT_PUBLIC_FIREBASE_API_KEY=AIzaSyARVo82u1MX9loI0FVpxibxs4QOtp4imAM
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=bursali-otomotiv.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=bursali-otomotiv
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=bursali-otomotiv.firebasestorage.app
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=105625220818
NEXT_PUBLIC_FIREBASE_APP_ID=1:105625220818:web:81be6dd5eca6c6d4f85f0b
```

Bu dokümandaki tüm kodlar web dashboard'un sipariş yönetimi özelliklerini implement etmek için gerekli olan temel yapı taşlarını içermektedir. Gerçek implementasyonda bu kodlar Next.js projesi içinde kullanılacaktır. 