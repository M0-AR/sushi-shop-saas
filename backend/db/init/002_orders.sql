-- Verified 2026: orders + append-only audit, tenant-leading indexes, RLS backstop
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  promo TEXT NOT NULL DEFAULT '',
  status TEXT NOT NULL DEFAULT 'placed',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  food_id UUID NOT NULL REFERENCES foods(id),
  qty INT NOT NULL CHECK (qty BETWEEN 1 AND 10)
);
CREATE TABLE IF NOT EXISTS audit_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  actor TEXT NOT NULL,
  action TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id TEXT,
  metadata JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_orders_tenant ON orders(tenant_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_items_tenant ON order_items(tenant_id, order_id);
CREATE INDEX IF NOT EXISTS idx_audit_tenant ON audit_events(tenant_id, created_at DESC);

ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders FORCE ROW LEVEL SECURITY;
ALTER TABLE order_items FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS tenant_isolation_select ON orders;
CREATE POLICY tenant_isolation_select ON orders FOR SELECT
USING (tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::uuid);
DROP POLICY IF EXISTS tenant_isolation_write ON orders;
CREATE POLICY tenant_isolation_write ON orders FOR ALL
USING (tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::uuid)
WITH CHECK (tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::uuid);
DROP POLICY IF EXISTS tenant_isolation_select ON order_items;
CREATE POLICY tenant_isolation_select ON order_items FOR SELECT
USING (tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::uuid);
DROP POLICY IF EXISTS tenant_isolation_write ON order_items;
CREATE POLICY tenant_isolation_write ON order_items FOR ALL
USING (tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::uuid)
WITH CHECK (tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::uuid);
