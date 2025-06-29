-- Supabase Güvenli Temizlik Script'i
-- Bu script önce tabloların varlığını kontrol eder

-- 1. Hangi tabloların mevcut olduğunu görelim
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- 2. Sadece mevcut olan gereksiz tabloları sil
DO $$
BEGIN
    -- delivery_items tablosunu sil (eğer varsa)
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'delivery_items') THEN
        DROP TABLE delivery_items CASCADE;
        RAISE NOTICE 'delivery_items tablosu silindi';
    END IF;

    -- deliveries tablosunu sil (eğer varsa)
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'deliveries') THEN
        DROP TABLE deliveries CASCADE;
        RAISE NOTICE 'deliveries tablosu silindi';
    END IF;

    -- box_items tablosunu sil (eğer varsa)
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'box_items') THEN
        DROP TABLE box_items CASCADE;
        RAISE NOTICE 'box_items tablosu silindi';
    END IF;

    -- boxes tablosunu sil (eğer varsa)
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'boxes') THEN
        DROP TABLE boxes CASCADE;
        RAISE NOTICE 'boxes tablosu silindi';
    END IF;

    -- barcode_reads tablosunu sil (eğer varsa)
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'barcode_reads') THEN
        DROP TABLE barcode_reads CASCADE;
        RAISE NOTICE 'barcode_reads tablosu silindi';
    END IF;

END $$;

-- 3. Gereksiz sütunları temizle (eğer varsa)
DO $$
BEGIN
    -- orders tablosundaki gereksiz sütunlar
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='orders' AND column_name='priority') THEN
        ALTER TABLE orders DROP COLUMN priority;
        RAISE NOTICE 'orders.priority sütunu silindi';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='orders' AND column_name='delivery_date') THEN
        ALTER TABLE orders DROP COLUMN delivery_date;
        RAISE NOTICE 'orders.delivery_date sütunu silindi';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='orders' AND column_name='total_boxes') THEN
        ALTER TABLE orders DROP COLUMN total_boxes;
        RAISE NOTICE 'orders.total_boxes sütunu silindi';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='orders' AND column_name='completed_boxes') THEN
        ALTER TABLE orders DROP COLUMN completed_boxes;
        RAISE NOTICE 'orders.completed_boxes sütunu silindi';
    END IF;

    -- products tablosundaki gereksiz sütunlar
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='products' AND column_name='weight') THEN
        ALTER TABLE products DROP COLUMN weight;
        RAISE NOTICE 'products.weight sütunu silindi';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='products' AND column_name='dimensions') THEN
        ALTER TABLE products DROP COLUMN dimensions;
        RAISE NOTICE 'products.dimensions sütunu silindi';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='products' AND column_name='category') THEN
        ALTER TABLE products DROP COLUMN category;
        RAISE NOTICE 'products.category sütunu silindi';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='products' AND column_name='supplier') THEN
        ALTER TABLE products DROP COLUMN supplier;
        RAISE NOTICE 'products.supplier sütunu silindi';
    END IF;

    -- order_items tablosundaki gereksiz sütunlar
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='order_items' AND column_name='box_number') THEN
        ALTER TABLE order_items DROP COLUMN box_number;
        RAISE NOTICE 'order_items.box_number sütunu silindi';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='order_items' AND column_name='box_label') THEN
        ALTER TABLE order_items DROP COLUMN box_label;
        RAISE NOTICE 'order_items.box_label sütunu silindi';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='order_items' AND column_name='packed_quantity') THEN
        ALTER TABLE order_items DROP COLUMN packed_quantity;
        RAISE NOTICE 'order_items.packed_quantity sütunu silindi';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='order_items' AND column_name='is_packed') THEN
        ALTER TABLE order_items DROP COLUMN is_packed;
        RAISE NOTICE 'order_items.is_packed sütunu silindi';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='order_items' AND column_name='packing_notes') THEN
        ALTER TABLE order_items DROP COLUMN packing_notes;
        RAISE NOTICE 'order_items.packing_notes sütunu silindi';
    END IF;

END $$;

-- 4. Sonuç - Kalan tabloları göster
SELECT 'Temizlik tamamlandı! Kalan tablolar:' as message;
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_type = 'BASE TABLE'
ORDER BY table_name; 