-- Sushi SaaS demo dataset v2 — "best seed ever" rules (verified 2026):
-- synthetic only (example.com, no real PII) • deterministic (fixed slugs/names/counts)
-- idempotent (scoped cleanup + reinsert in one txn) • FK-ordered • tenant-scoped FKs
-- scenario journeys (placed→preparing→delivered + 1 cancelled/refund) • dinner-rush timestamps
BEGIN;

-- 1) Reference tenants (upsert by natural key slug)
INSERT INTO tenants (slug, name, primary_color, secondary_color, currency, plan) VALUES
  ('tokyo-main','Sushi Man Tokyo','#7B1E1E','#E8A93D','USD','pro'),
  ('osaka-branch','Sushi Man Osaka','#1E3A7B','#3DD8A9','USD','pro'),
  ('nyc-flagship','Sushi Man NYC','#111111','#E8A93D','USD','enterprise'),
  ('dubai-marina','Sushi Man Dubai','#0E4D4A','#E8C93D','AED','pro')
ON CONFLICT (slug) DO UPDATE SET name=EXCLUDED.name, primary_color=EXCLUDED.primary_color,
  secondary_color=EXCLUDED.secondary_color, currency=EXCLUDED.currency, plan=EXCLUDED.plan;

-- 2) Scoped cleanup (demo tenants only — never touch other data)
DELETE FROM order_items WHERE tenant_id IN (SELECT id FROM tenants WHERE slug IN ('tokyo-main','osaka-branch','nyc-flagship','dubai-marina'));
DELETE FROM orders WHERE tenant_id IN (SELECT id FROM tenants WHERE slug IN ('tokyo-main','osaka-branch','nyc-flagship','dubai-marina'));
DELETE FROM audit_events WHERE tenant_id IN (SELECT id FROM tenants WHERE slug IN ('tokyo-main','osaka-branch','nyc-flagship','dubai-marina'));
DELETE FROM cart_items WHERE tenant_id IN (SELECT id FROM tenants WHERE slug IN ('tokyo-main','osaka-branch','nyc-flagship','dubai-marina'));
DELETE FROM foods WHERE tenant_id IN (SELECT id FROM tenants WHERE slug IN ('tokyo-main','osaka-branch','nyc-flagship','dubai-marina'));
DELETE FROM users WHERE tenant_id IN (SELECT id FROM tenants WHERE slug IN ('tokyo-main','osaka-branch','nyc-flagship','dubai-marina'));

-- 3) Users + roles (synthetic example.com)
INSERT INTO users (tenant_id, email, role) VALUES
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'admin@tokyo.example.com','admin'),
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'manager@tokyo.example.com','manager'),
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'chef@tokyo.example.com','support'),
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'guest@tokyo.example.com','customer'),
  ((SELECT id FROM tenants WHERE slug='osaka-branch'),'admin@osaka.example.com','admin'),
  ((SELECT id FROM tenants WHERE slug='osaka-branch'),'staff@osaka.example.com','support'),
  ((SELECT id FROM tenants WHERE slug='nyc-flagship'),'admin@nyc.example.com','admin'),
  ((SELECT id FROM tenants WHERE slug='nyc-flagship'),'ops@nyc.example.com','manager'),
  ((SELECT id FROM tenants WHERE slug='dubai-marina'),'admin@dubai.example.com','admin'),
  ((SELECT id FROM tenants WHERE slug='dubai-marina'),'concierge@dubai.example.com','support');

-- 4) Tokyo flagship menu (16 — first 4 keep legacy names/prices for stable tests)
INSERT INTO foods (tenant_id, name, price_cents, image, rating, category, sort_order) VALUES
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'Salmon Sushi',2100,'🍣',4.9,'sushi',1),
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'Tuna Roll',1900,'🍱',4.8,'rolls',2),
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'Salmon Eggs',2100,'🍳',4.7,'popular',3),
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'Mini Sushi Set',1500,'🍙',4.6,'sets',4),
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'Spicy Tuna Nigiri',2200,'🔥',4.7,'sushi',5),
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'Tamago Nigiri',1400,'🥚',4.5,'sushi',6),
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'California Roll',1600,'🦀',4.6,'rolls',7),
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'Dragon Roll',2400,'🐲',4.8,'rolls',8),
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'Chirashi Bowl',2600,'🍚',4.9,'popular',9),
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'Omakase Set',4500,'👑',5.0,'popular',10),
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'Family Boat',5200,'🚤',4.8,'sets',11),
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'Miso Soup Set',900,'🍲',4.3,'sets',12),
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'Yuzu Lemonade',700,'🍋',4.4,'drinks',13),
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'Matcha Latte',800,'🍵',4.6,'drinks',14),
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'Mochi Trio',950,'🍡',4.7,'desserts',15),
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'Dorayaki',650,'🥞',4.4,'desserts',16);

-- 5) Osaka branch menu (8)
INSERT INTO foods (tenant_id, name, price_cents, image, rating, category, sort_order) VALUES
  ((SELECT id FROM tenants WHERE slug='osaka-branch'),'Battera Mackerel',1800,'🐟',4.6,'sushi',1),
  ((SELECT id FROM tenants WHERE slug='osaka-branch'),'Eel Nigiri',2300,'🐍',4.8,'sushi',2),
  ((SELECT id FROM tenants WHERE slug='osaka-branch'),'Takoyaki Roll',1500,'🐙',4.5,'rolls',3),
  ((SELECT id FROM tenants WHERE slug='osaka-branch'),'Shrimp Tempura Roll',2000,'🍤',4.7,'rolls',4),
  ((SELECT id FROM tenants WHERE slug='osaka-branch'),'Crab Chirashi',2800,'🦀',4.8,'popular',5),
  ((SELECT id FROM tenants WHERE slug='osaka-branch'),'Osaka Feast Set',3200,'🎏',4.7,'sets',6),
  ((SELECT id FROM tenants WHERE slug='osaka-branch'),'Ramune Soda',500,'🥤',4.3,'drinks',7),
  ((SELECT id FROM tenants WHERE slug='osaka-branch'),'Red Bean Mochi',750,'🫘',4.5,'desserts',8);

-- 6) NYC flagship menu (8)
INSERT INTO foods (tenant_id, name, price_cents, image, rating, category, sort_order) VALUES
  ((SELECT id FROM tenants WHERE slug='nyc-flagship'),'Wagyu Nigiri',3900,'🥩',4.9,'sushi',1),
  ((SELECT id FROM tenants WHERE slug='nyc-flagship'),'Spicy Salmon Crunch',2100,'🌶️',4.6,'sushi',2),
  ((SELECT id FROM tenants WHERE slug='nyc-flagship'),'Rainbow Roll',2200,'🌈',4.7,'rolls',3),
  ((SELECT id FROM tenants WHERE slug='nyc-flagship'),'Bagel Roll',1700,'🥯',4.4,'rolls',4),
  ((SELECT id FROM tenants WHERE slug='nyc-flagship'),'Poke Bowl',1900,'🥗',4.5,'popular',5),
  ((SELECT id FROM tenants WHERE slug='nyc-flagship'),'NYC Deluxe Platter',4800,'🗽',4.8,'sets',6),
  ((SELECT id FROM tenants WHERE slug='nyc-flagship'),'Cold Brew',600,'☕',4.2,'drinks',7),
  ((SELECT id FROM tenants WHERE slug='nyc-flagship'),'Cheesecake Mochi',850,'🍰',4.6,'desserts',8);

-- 7) Dubai marina menu (6, AED)
INSERT INTO foods (tenant_id, name, price_cents, image, rating, category, sort_order) VALUES
  ((SELECT id FROM tenants WHERE slug='dubai-marina'),'Gold Salmon Nigiri',2900,'✨',4.9,'sushi',1),
  ((SELECT id FROM tenants WHERE slug='dubai-marina'),'Saffron Roll',2400,'🌾',4.7,'rolls',2),
  ((SELECT id FROM tenants WHERE slug='dubai-marina'),'Royal Omakase',6500,'💎',5.0,'popular',3),
  ((SELECT id FROM tenants WHERE slug='dubai-marina'),'Desert Feast Set',4200,'🏜️',4.7,'sets',4),
  ((SELECT id FROM tenants WHERE slug='dubai-marina'),'Karak Chai',500,'🫖',4.5,'drinks',5),
  ((SELECT id FROM tenants WHERE slug='dubai-marina'),'Date Mochi',800,'🌴',4.6,'desserts',6);

-- 8) Orders: full journeys (deterministic UUIDs, dinner-rush timestamps, promos, 1 cancelled)
INSERT INTO orders (id, tenant_id, promo, status, created_at) VALUES
  ('11111111-1111-1111-1111-111111111111',(SELECT id FROM tenants WHERE slug='tokyo-main'),'SAVE10','delivered',now()-interval '6 days' - interval '2 hours'),
  ('22222222-2222-2222-2222-222222222222',(SELECT id FROM tenants WHERE slug='tokyo-main'),'','delivered',now()-interval '3 days' - interval '1 hour'),
  ('33333333-3333-3333-3333-333333333333',(SELECT id FROM tenants WHERE slug='tokyo-main'),'WELCOME15','preparing',now()-interval '25 minutes'),
  ('44444444-4444-4444-4444-444444444444',(SELECT id FROM tenants WHERE slug='tokyo-main'),'','placed',now()-interval '6 minutes'),
  ('55555555-5555-5555-5555-555555555555',(SELECT id FROM tenants WHERE slug='tokyo-main'),'SAVE10','cancelled',now()-interval '2 days' - interval '3 hours'),
  ('66666666-6666-6666-6666-666666666666',(SELECT id FROM tenants WHERE slug='osaka-branch'),'','delivered',now()-interval '5 days' - interval '2 hours'),
  ('77777777-7777-7777-7777-777777777777',(SELECT id FROM tenants WHERE slug='osaka-branch'),'WELCOME15','preparing',now()-interval '40 minutes'),
  ('88888888-8888-8888-8888-888888888888',(SELECT id FROM tenants WHERE slug='osaka-branch'),'','placed',now()-interval '9 minutes'),
  ('99999999-9999-9999-9999-999999999999',(SELECT id FROM tenants WHERE slug='nyc-flagship'),'','delivered',now()-interval '4 days' - interval '1 hour'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',(SELECT id FROM tenants WHERE slug='nyc-flagship'),'SAVE10','delivered',now()-interval '1 day' - interval '4 hours'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',(SELECT id FROM tenants WHERE slug='nyc-flagship'),'','placed',now()-interval '12 minutes'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc',(SELECT id FROM tenants WHERE slug='dubai-marina'),'WELCOME15','delivered',now()-interval '2 days' - interval '5 hours');

-- 9) Order lines (tenant-scoped FKs only)
INSERT INTO order_items (tenant_id, order_id, food_id, qty) VALUES
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'11111111-1111-1111-1111-111111111111',(SELECT id FROM foods WHERE name='Salmon Sushi' AND tenant_id=(SELECT id FROM tenants WHERE slug='tokyo-main')),2),
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'11111111-1111-1111-1111-111111111111',(SELECT id FROM foods WHERE name='Miso Soup Set' AND tenant_id=(SELECT id FROM tenants WHERE slug='tokyo-main')),1),
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'22222222-2222-2222-2222-222222222222',(SELECT id FROM foods WHERE name='Omakase Set' AND tenant_id=(SELECT id FROM tenants WHERE slug='tokyo-main')),1),
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'33333333-3333-3333-3333-333333333333',(SELECT id FROM foods WHERE name='Dragon Roll' AND tenant_id=(SELECT id FROM tenants WHERE slug='tokyo-main')),2),
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'33333333-3333-3333-3333-333333333333',(SELECT id FROM foods WHERE name='Yuzu Lemonade' AND tenant_id=(SELECT id FROM tenants WHERE slug='tokyo-main')),2),
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'44444444-4444-4444-4444-444444444444',(SELECT id FROM foods WHERE name='Chirashi Bowl' AND tenant_id=(SELECT id FROM tenants WHERE slug='tokyo-main')),1),
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'55555555-5555-5555-5555-555555555555',(SELECT id FROM foods WHERE name='Family Boat' AND tenant_id=(SELECT id FROM tenants WHERE slug='tokyo-main')),1),
  ((SELECT id FROM tenants WHERE slug='osaka-branch'),'66666666-6666-6666-6666-666666666666',(SELECT id FROM foods WHERE name='Eel Nigiri' AND tenant_id=(SELECT id FROM tenants WHERE slug='osaka-branch')),2),
  ((SELECT id FROM tenants WHERE slug='osaka-branch'),'66666666-6666-6666-6666-666666666666',(SELECT id FROM foods WHERE name='Ramune Soda' AND tenant_id=(SELECT id FROM tenants WHERE slug='osaka-branch')),2),
  ((SELECT id FROM tenants WHERE slug='osaka-branch'),'77777777-7777-7777-7777-777777777777',(SELECT id FROM foods WHERE name='Takoyaki Roll' AND tenant_id=(SELECT id FROM tenants WHERE slug='osaka-branch')),3),
  ((SELECT id FROM tenants WHERE slug='osaka-branch'),'88888888-8888-8888-8888-888888888888',(SELECT id FROM foods WHERE name='Crab Chirashi' AND tenant_id=(SELECT id FROM tenants WHERE slug='osaka-branch')),1),
  ((SELECT id FROM tenants WHERE slug='nyc-flagship'),'99999999-9999-9999-9999-999999999999',(SELECT id FROM foods WHERE name='Wagyu Nigiri' AND tenant_id=(SELECT id FROM tenants WHERE slug='nyc-flagship')),2),
  ((SELECT id FROM tenants WHERE slug='nyc-flagship'),'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',(SELECT id FROM foods WHERE name='Rainbow Roll' AND tenant_id=(SELECT id FROM tenants WHERE slug='nyc-flagship')),2),
  ((SELECT id FROM tenants WHERE slug='nyc-flagship'),'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',(SELECT id FROM foods WHERE name='Cheesecake Mochi' AND tenant_id=(SELECT id FROM tenants WHERE slug='nyc-flagship')),1),
  ((SELECT id FROM tenants WHERE slug='nyc-flagship'),'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',(SELECT id FROM foods WHERE name='Poke Bowl' AND tenant_id=(SELECT id FROM tenants WHERE slug='nyc-flagship')),1),
  ((SELECT id FROM tenants WHERE slug='dubai-marina'),'cccccccc-cccc-cccc-cccc-cccccccccccc',(SELECT id FROM foods WHERE name='Royal Omakase' AND tenant_id=(SELECT id FROM tenants WHERE slug='dubai-marina')),1),
  ((SELECT id FROM tenants WHERE slug='dubai-marina'),'cccccccc-cccc-cccc-cccc-cccccccccccc',(SELECT id FROM foods WHERE name='Karak Chai' AND tenant_id=(SELECT id FROM tenants WHERE slug='dubai-marina')),2);

-- 10) Audit trail (one event per order + a refund for the cancelled one)
INSERT INTO audit_events (tenant_id, actor, action, entity_type, entity_id, metadata) VALUES
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'api','order.create','orders','11111111-1111-1111-1111-111111111111','{"items":2,"promo":"SAVE10"}'),
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'api','order.create','orders','22222222-2222-2222-2222-222222222222','{"items":1,"promo":""}'),
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'api','order.create','orders','33333333-3333-3333-3333-333333333333','{"items":2,"promo":"WELCOME15"}'),
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'api','order.create','orders','44444444-4444-4444-4444-444444444444','{"items":1,"promo":""}'),
  ((SELECT id FROM tenants WHERE slug='tokyo-main'),'manager@tokyo.example.com','order.refund','orders','55555555-5555-5555-5555-555555555555','{"reason":"customer cancelled, full refund"}'),
  ((SELECT id FROM tenants WHERE slug='osaka-branch'),'api','order.create','orders','66666666-6666-6666-6666-666666666666','{"items":2,"promo":""}'),
  ((SELECT id FROM tenants WHERE slug='osaka-branch'),'api','order.create','orders','77777777-7777-7777-7777-777777777777','{"items":1,"promo":"WELCOME15"}'),
  ((SELECT id FROM tenants WHERE slug='osaka-branch'),'api','order.create','orders','88888888-8888-8888-8888-888888888888','{"items":1,"promo":""}'),
  ((SELECT id FROM tenants WHERE slug='nyc-flagship'),'api','order.create','orders','99999999-9999-9999-9999-999999999999','{"items":1,"promo":""}'),
  ((SELECT id FROM tenants WHERE slug='nyc-flagship'),'api','order.create','orders','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','{"items":2,"promo":"SAVE10"}'),
  ((SELECT id FROM tenants WHERE slug='nyc-flagship'),'api','order.create','orders','bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb','{"items":1,"promo":""}'),
  ((SELECT id FROM tenants WHERE slug='dubai-marina'),'api','order.create','orders','cccccccc-cccc-cccc-cccc-cccccccccccc','{"items":2,"promo":"WELCOME15"}');

COMMIT;
