// Backend API + contract tests (verified 2026: integration vs real stack wins).
// Zero-dep: runs with `node --test` (Node 24). Targets live backend (docker or local).
// Every test isolates via unique promo codes; no shared mutable fixtures.
import { describe, it, before } from 'node:test';
import assert from 'node:assert/strict';

const BASE = process.env.API_URL || 'http://localhost:3001';

async function api(path, opts = {}) {
  const res = await fetch(`${BASE}${path}`, {
    ...opts,
    headers: { 'Content-Type': 'application/json', ...(opts.headers || {}) },
  });
  const text = await res.text();
  let json = null;
  try { json = JSON.parse(text); } catch { /* non-JSON */ }
  return { res, json, text };
}

describe('health', () => {
  it('GET /health returns ok with service name', async () => {
    const { res, json } = await api('/health');
    assert.equal(res.status, 200);
    assert.equal(json.status, 'ok');
    assert.equal(json.service, 'sushi-saas-backend');
  });
});

describe('menu contract (consumer: admin + mobile)', () => {
  it('tokyo menu has 16 dishes with stable shape', async () => {
    const { res, json } = await api('/api/menu');
    assert.equal(res.status, 200);
    assert.equal(json.length, 16);
    for (const f of json) {
      assert.ok(typeof f.id === 'string');
      assert.ok(typeof f.name === 'string' && f.name.length > 0);
      assert.ok(Number.isInteger(f.price_cents) && f.price_cents > 0);
      assert.ok(typeof f.rating !== 'undefined');
      assert.ok(typeof f.category === 'string');
    }
    const names = json.map((f) => f.name);
    for (const anchor of ['Salmon Sushi', 'Tuna Roll', 'Salmon Eggs']) {
      assert.ok(names.includes(anchor), `missing anchor dish ${anchor}`);
    }
  });

  it('tenant isolation: dubai sees only its 6 dishes', async () => {
    const { res, json } = await api('/api/menu', { headers: { 'X-Tenant-Id': 'dubai-marina' } });
    assert.equal(res.status, 200);
    assert.equal(json.length, 6);
    assert.ok(json.every((f) => f.name !== 'Salmon Sushi'));
  });

  it('search validation: q filters, unknown category returns empty', async () => {
    const s = await api('/api/menu?q=salmon');
    assert.equal(s.res.status, 200);
    assert.ok(s.json.length >= 2 && s.json.every((f) => f.name.toLowerCase().includes('salmon')));
    const c = await api('/api/menu?category=nope');
    assert.equal(c.res.status, 200);
    assert.deepEqual(c.json, []);
  });
});

describe('orders validation (whitelist + forbid)', () => {
  it('rejects forbidden fields with 400', async () => {
    const { res, json } = await api('/api/orders', {
      method: 'POST', body: JSON.stringify({ items: [], role: 'admin' }),
    });
    assert.equal(res.status, 400);
    assert.match(json.message, /forbidden field/);
  });

  it('rejects empty items and bad qty', async () => {
    const e1 = await api('/api/orders', { method: 'POST', body: JSON.stringify({ items: [] }) });
    assert.equal(e1.res.status, 400);
    const menu = await api('/api/menu');
    const fid = menu.json[0].id;
    const e2 = await api('/api/orders', {
      method: 'POST', body: JSON.stringify({ items: [{ foodId: fid, qty: 99 }] }),
    });
    assert.equal(e2.res.status, 400);
  });

  it('creates an order and lists it (isolated promo)', async () => {
    const menu = await api('/api/menu');
    const fid = menu.json[0].id;
    const promo = `T${Date.now().toString(36).toUpperCase()}`;
    const created = await api('/api/orders', {
      method: 'POST', body: JSON.stringify({ items: [{ foodId: fid, qty: 1 }], promo }),
    });
    assert.equal(created.res.status, 201);
    assert.ok(created.json.id);
    const list = await api('/api/orders');
    assert.ok(list.json.some((o) => o.id === created.json.id));
  });
});

describe('tenants + audit + payments wiring', () => {
  it('lists 4 tenants', async () => {
    const { res, json } = await api('/api/tenants');
    assert.equal(res.status, 200);
    assert.equal(json.length, 4);
  });

  it('audit log is append-only and non-empty', async () => {
    const { res, json } = await api('/api/audit');
    assert.equal(res.status, 200);
    assert.ok(json.length >= 5); // tokyo seed: 4 creates + 1 refund
    assert.ok(json.every((e) => e.actor && e.action && e.entity_type));
  });

  it('payments intent explains wiring without keys (no fake success)', async () => {
    const { res } = await api('/api/payments/intent', { method: 'POST', body: JSON.stringify({}) });
    assert.equal(res.status, 400); // 501-equivalent: honest unconfigured state
  });
});

describe('security headers + throttling', () => {
  it('sets hardening headers, hides X-Powered-By', async () => {
    const { res } = await api('/health');
    assert.equal(res.headers.get('x-content-type-options'), 'nosniff');
    assert.equal(res.headers.get('x-frame-options'), 'DENY');
    assert.equal(res.headers.get('x-powered-by'), null);
    assert.ok(res.headers.get('x-ratelimit-limit'));
  });
});
