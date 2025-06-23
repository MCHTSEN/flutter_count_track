-- Supabase Database Schema for Flutter Count Track
-- Bu script'i Supabase Dashboard > SQL Editor'da çalıştırın

-- 1. Products tablosu (Ürünler)
CREATE TABLE IF NOT EXISTS products (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    our_product_code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    barcode TEXT,
    is_unique_barcode_required BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Orders tablosu (Siparişler)
CREATE TABLE IF NOT EXISTS orders (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    order_code TEXT NOT NULL UNIQUE,
    customer_name TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_sync_at TIMESTAMPTZ DEFAULT NOW(),
    device_id TEXT
);

-- 3. Order Items tablosu (Sipariş Kalemleri)
CREATE TABLE IF NOT EXISTS order_items (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    customer_product_code TEXT,
    quantity INTEGER NOT NULL DEFAULT 0,
    scanned_quantity INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(order_id, product_id)
);

-- 4. Product Code Mapping tablosu (Müşteri Ürün Kodu Eşleştirme)
CREATE TABLE IF NOT EXISTS product_code_mappings (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    customer_product_code TEXT NOT NULL,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    customer_name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(customer_product_code, customer_name)
);

-- 5. Barcode Reads tablosu (Barkod Okuma Kayıtları)
CREATE TABLE IF NOT EXISTS barcode_reads (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id BIGINT REFERENCES products(id) ON DELETE SET NULL,
    barcode TEXT NOT NULL,
    read_at TIMESTAMPTZ DEFAULT NOW(),
    device_id TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Deliveries tablosu (Teslimatlar)
CREATE TABLE IF NOT EXISTS deliveries (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    delivery_date TIMESTAMPTZ DEFAULT NOW(),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Delivery Items tablosu (Teslimat Kalemleri)
CREATE TABLE IF NOT EXISTS delivery_items (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    delivery_id BIGINT NOT NULL REFERENCES deliveries(id) ON DELETE CASCADE,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(delivery_id, product_id)
);

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_customer ON orders(customer_name);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_barcode_reads_order_id ON barcode_reads(order_id);
CREATE INDEX IF NOT EXISTS idx_barcode_reads_barcode ON barcode_reads(barcode);

-- Row Level Security (RLS) Policies
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_code_mappings ENABLE ROW LEVEL SECURITY;
ALTER TABLE barcode_reads ENABLE ROW LEVEL SECURITY;
ALTER TABLE deliveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE delivery_items ENABLE ROW LEVEL SECURITY;

-- Allow all operations for authenticated users (şimdilik basit policy)
CREATE POLICY "Allow all for authenticated users" ON products FOR ALL TO authenticated USING (true);
CREATE POLICY "Allow all for authenticated users" ON orders FOR ALL TO authenticated USING (true);
CREATE POLICY "Allow all for authenticated users" ON order_items FOR ALL TO authenticated USING (true);
CREATE POLICY "Allow all for authenticated users" ON product_code_mappings FOR ALL TO authenticated USING (true);
CREATE POLICY "Allow all for authenticated users" ON barcode_reads FOR ALL TO authenticated USING (true);
CREATE POLICY "Allow all for authenticated users" ON deliveries FOR ALL TO authenticated USING (true);
CREATE POLICY "Allow all for authenticated users" ON delivery_items FOR ALL TO authenticated USING (true);

-- Updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to tables with updated_at column
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_order_items_updated_at BEFORE UPDATE ON order_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_product_code_mappings_updated_at BEFORE UPDATE ON product_code_mappings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_deliveries_updated_at BEFORE UPDATE ON deliveries
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Sample test data
INSERT INTO products (our_product_code, name, barcode, is_unique_barcode_required) VALUES
('PRD001', 'Test Ürün 1', '1234567890123', false),
('PRD002', 'Test Ürün 2', '9876543210987', true),
('PRD003', 'Test Ürün 3', '5555555555555', false)
ON CONFLICT (our_product_code) DO NOTHING;

INSERT INTO orders (order_code, customer_name, status) VALUES
('ORD001', 'Test Müşteri A', 'pending'),
('ORD002', 'Test Müşteri B', 'partial'),
('ORD003', 'Test Müşteri C', 'completed')
ON CONFLICT (order_code) DO NOTHING;

-- Test için order items
INSERT INTO order_items (order_id, product_id, customer_product_code, quantity, scanned_quantity)
SELECT 
    o.id,
    p.id,
    'CUST_' || p.our_product_code,
    10,
    CASE WHEN o.status = 'completed' THEN 10 
         WHEN o.status = 'partial' THEN 5 
         ELSE 0 END
FROM orders o, products p
WHERE o.order_code IN ('ORD001', 'ORD002', 'ORD003')
AND p.our_product_code IN ('PRD001', 'PRD002')
ON CONFLICT (order_id, product_id) DO NOTHING; 