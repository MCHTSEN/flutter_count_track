-- Supabase RLS Policy Fix
-- Bu script'i Supabase Dashboard > SQL Editor'da çalıştırın

-- Mevcut policy'leri kaldır
DROP POLICY IF EXISTS "Allow all for authenticated users" ON products;
DROP POLICY IF EXISTS "Allow all for authenticated users" ON orders;
DROP POLICY IF EXISTS "Allow all for authenticated users" ON order_items;
DROP POLICY IF EXISTS "Allow all for authenticated users" ON product_code_mappings;
DROP POLICY IF EXISTS "Allow all for authenticated users" ON barcode_reads;
DROP POLICY IF EXISTS "Allow all for authenticated users" ON deliveries;
DROP POLICY IF EXISTS "Allow all for authenticated users" ON delivery_items;

-- Yeni policy'ler - anonymous kullanıcılar için de izin ver
CREATE POLICY "Allow all operations" ON products FOR ALL USING (true);
CREATE POLICY "Allow all operations" ON orders FOR ALL USING (true);
CREATE POLICY "Allow all operations" ON order_items FOR ALL USING (true);
CREATE POLICY "Allow all operations" ON product_code_mappings FOR ALL USING (true);
CREATE POLICY "Allow all operations" ON barcode_reads FOR ALL USING (true);
CREATE POLICY "Allow all operations" ON deliveries FOR ALL USING (true);
CREATE POLICY "Allow all operations" ON delivery_items FOR ALL USING (true);

-- Test için birkaç örnek veri daha ekle
INSERT INTO products (our_product_code, name, barcode, is_unique_barcode_required) VALUES
('TEST001', 'Test Product 1', 'BARCODE001', false),
('TEST002', 'Test Product 2', 'BARCODE002', true)
ON CONFLICT (our_product_code) DO NOTHING;

INSERT INTO orders (order_code, customer_name, status) VALUES
('TEST001', 'Test Customer 1', 'pending'),
('TEST002', 'Test Customer 2', 'partial')
ON CONFLICT (order_code) DO NOTHING;

-- RLS Policy düzeltmeleri
-- Supabase Dashboard > SQL Editor'da çalıştırın

-- Mevcut policy'leri kaldır
DROP POLICY IF EXISTS "Allow all for authenticated users" ON products;
DROP POLICY IF EXISTS "Allow all for authenticated users" ON orders;
DROP POLICY IF EXISTS "Allow all for authenticated users" ON order_items;
DROP POLICY IF EXISTS "Allow all for authenticated users" ON product_code_mappings;

-- Yeni policy'ler oluştur
CREATE POLICY "Enable all operations for authenticated users" ON products
    FOR ALL TO authenticated
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Enable all operations for authenticated users" ON orders
    FOR ALL TO authenticated
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Enable all operations for authenticated users" ON order_items
    FOR ALL TO authenticated
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Enable all operations for authenticated users" ON product_code_mappings
    FOR ALL TO authenticated
    USING (true)
    WITH CHECK (true); 