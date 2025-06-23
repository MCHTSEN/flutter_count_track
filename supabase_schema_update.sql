-- Supabase Schema Update for Box Management (Kolileme)
-- Bu script'i Supabase Dashboard > SQL Editor'da çalıştırın

-- Orders tablosuna kolileme alanları ekle
ALTER TABLE orders ADD COLUMN IF NOT EXISTS priority TEXT DEFAULT 'normal';
ALTER TABLE orders ADD COLUMN IF NOT EXISTS delivery_date TIMESTAMPTZ;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS notes TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS total_boxes INTEGER DEFAULT 0;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS completed_boxes INTEGER DEFAULT 0;

-- Products tablosuna ek bilgiler
ALTER TABLE products ADD COLUMN IF NOT EXISTS weight DECIMAL(10,3);
ALTER TABLE products ADD COLUMN IF NOT EXISTS dimensions TEXT; -- JSON formatında {"width": 10, "height": 5, "depth": 8}
ALTER TABLE products ADD COLUMN IF NOT EXISTS category TEXT;
ALTER TABLE products ADD COLUMN IF NOT EXISTS supplier TEXT;

-- Order Items tablosuna kolileme bilgileri
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS box_number INTEGER;
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS box_label TEXT;
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS packed_quantity INTEGER DEFAULT 0;
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS is_packed BOOLEAN DEFAULT FALSE;
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS packing_notes TEXT;

-- 8. Boxes tablosu (Koliler) - Yeni tablo
CREATE TABLE IF NOT EXISTS boxes (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    box_number INTEGER NOT NULL,
    box_label TEXT,
    status TEXT DEFAULT 'empty', -- empty, packing, packed, shipped
    total_weight DECIMAL(10,3),
    total_items INTEGER DEFAULT 0,
    packed_by TEXT,
    packed_at TIMESTAMPTZ,
    shipped_at TIMESTAMPTZ,
    tracking_number TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(order_id, box_number)
);

-- 9. Box Items tablosu (Koli Kalemleri) - Yeni tablo
CREATE TABLE IF NOT EXISTS box_items (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    box_id BIGINT NOT NULL REFERENCES boxes(id) ON DELETE CASCADE,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    order_item_id BIGINT REFERENCES order_items(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 0,
    weight DECIMAL(10,3),
    packed_by TEXT,
    packed_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(box_id, product_id)
);

-- Indexes for new tables and columns
CREATE INDEX IF NOT EXISTS idx_orders_priority ON orders(priority);
CREATE INDEX IF NOT EXISTS idx_orders_delivery_date ON orders(delivery_date);
CREATE INDEX IF NOT EXISTS idx_order_items_box_number ON order_items(box_number);
CREATE INDEX IF NOT EXISTS idx_order_items_is_packed ON order_items(is_packed);
CREATE INDEX IF NOT EXISTS idx_boxes_order_id ON boxes(order_id);
CREATE INDEX IF NOT EXISTS idx_boxes_status ON boxes(status);
CREATE INDEX IF NOT EXISTS idx_box_items_box_id ON box_items(box_id);
CREATE INDEX IF NOT EXISTS idx_box_items_product_id ON box_items(product_id);

-- RLS Policies for new tables
ALTER TABLE boxes ENABLE ROW LEVEL SECURITY;
ALTER TABLE box_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all operations" ON boxes FOR ALL USING (true);
CREATE POLICY "Allow all operations" ON box_items FOR ALL USING (true);

-- Updated_at triggers for new tables
CREATE TRIGGER update_boxes_updated_at BEFORE UPDATE ON boxes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Sample box data
INSERT INTO boxes (order_id, box_number, box_label, status, total_items) 
SELECT 
    o.id,
    1,
    o.order_code || '-BOX-001',
    CASE WHEN o.status = 'completed' THEN 'packed' 
         WHEN o.status = 'partial' THEN 'packing' 
         ELSE 'empty' END,
    CASE WHEN o.status = 'completed' THEN 2 
         WHEN o.status = 'partial' THEN 1 
         ELSE 0 END
FROM orders o
WHERE o.order_code IN ('ORD001', 'ORD002', 'ORD003')
ON CONFLICT (order_id, box_number) DO NOTHING;

-- Update existing orders with box counts
UPDATE orders SET 
    total_boxes = 1,
    completed_boxes = CASE 
        WHEN status = 'completed' THEN 1 
        WHEN status = 'partial' THEN 0 
        ELSE 0 
    END; 