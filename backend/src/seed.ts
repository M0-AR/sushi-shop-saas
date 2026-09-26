import { Pool } from 'pg';

const pool = new Pool({ connectionString: process.env.DATABASE_URL });

async function main() {
  // Idempotent seed for demo tenants (multi-tenant showcase)
  await pool.query(`
    INSERT INTO tenants (slug, name, primary_color, secondary_color, currency) VALUES
      ('tokyo-main','Sushi Man Tokyo','#7B1E1E','#E8A93D','USD'),
      ('osaka-branch','Sushi Man Osaka','#1E3A7B','#3DD8A9','USD'),
      ('nyc-flagship','Sushi Man NYC','#111111','#E8A93D','USD')
    ON CONFLICT (slug) DO NOTHING;
  `);
  const t = await pool.query(`SELECT id FROM tenants WHERE slug='tokyo-main'`);
  const tenantId = t.rows[0]?.id;
  if (tenantId) {
    await pool.query(
      `INSERT INTO foods (tenant_id, name, price_cents, image, rating, category, sort_order) VALUES
        ($1,'Salmon Sushi',2100,'salmon.png',4.9,'sushi',1),
        ($1,'Tuna Roll',1900,'tuna.png',4.8,'rolls',2),
        ($1,'Salmon Eggs',2100,'eggs.png',4.7,'popular',3),
        ($1,'Mini Sushi Set',1500,'mini.png',4.6,'sets',4)
       ON CONFLICT DO NOTHING`,
      [tenantId],
    );
  }
  console.log('seed done');
  await pool.end();
}
main();
