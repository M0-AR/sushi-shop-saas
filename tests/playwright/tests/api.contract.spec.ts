// API contract tests (Playwright APIRequestContext — no browser).
// Same guarantees as backend/test/api.test.js, runnable in the E2E lane.
import { test, expect } from '@playwright/test';

test('health is ok', async ({ request }) => {
  const res = await request.get('/health');
  expect(res.ok()).toBeTruthy();
  const body = await res.json();
  expect(body.status).toBe('ok');
});

test('menu contract: shape + anchors + isolation', async ({ request }) => {
  const res = await request.get('/api/menu');
  expect(res.ok()).toBeTruthy();
  const menu = await res.json();
  expect(menu.length).toBe(16);
  for (const name of ['Salmon Sushi', 'Tuna Roll', 'Salmon Eggs']) {
    expect(menu.map((f: any) => f.name)).toContain(name);
  }
  const dxb = await request.get('/api/menu', { headers: { 'X-Tenant-Id': 'dubai-marina' } });
  expect(dxb.ok()).toBeTruthy();
  expect((await dxb.json()).length).toBe(6);
});

test('orders validation rejects bad input', async ({ request }) => {
  const bad = await request.post('/api/orders', { data: { items: [], role: 'admin' } });
  expect(bad.status()).toBe(400);
});

test('tenants + audit + security headers', async ({ request }) => {
  const tenants = await request.get('/api/tenants');
  expect((await tenants.json()).length).toBe(4);
  const audit = await request.get('/api/audit');
  expect((await audit.json()).length).toBeGreaterThanOrEqual(5);
  const health = await request.get('/health');
  expect(health.headers()['x-content-type-options']).toBe('nosniff');
  expect(health.headers()['x-powered-by']).toBeUndefined();
});
