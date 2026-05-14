import { beforeAll, afterAll, describe, expect, it } from 'vitest';
import { buildApp } from '../../src/app';

const STOCK = 500;
const ATTEMPTS = 5000;

const cfg = {
  NODE_ENV: 'test',
  PORT: 3102,
  REDIS_URL: process.env.REDIS_URL || 'redis://127.0.0.1:6379',
  SALE_ID: `concurrency-sale-${Date.now()}`,
  SALE_STOCK: STOCK,
  SALE_START_AT: '2020-01-01T00:00:00.000Z',
  SALE_END_AT: '2030-01-01T00:00:00.000Z',
  IDEMPOTENCY_TTL_SECONDS: 86400
};

const app = buildApp(cfg);

beforeAll(async () => {
  await app.ready();
});

afterAll(async () => {
  await app.close();
});

describe('no oversell under concurrency', () => {
  it('caps success at stock', async () => {
    const attempts = Array.from({ length: ATTEMPTS }, (_, i) => app.inject({
      method: 'POST',
      url: '/api/v1/purchase',
      headers: { 'idempotency-key': `k-${i}` },
      payload: { userId: `u-${i}` }
    }));

    const responses = await Promise.all(attempts);
    const payloads = responses.map((r) => r.json() as { outcome: string });
    const success = payloads.filter((p) => p.outcome === 'SUCCESS').length;
    const soldOut = payloads.filter((p) => p.outcome === 'SOLD_OUT').length;

    expect(success).toBe(STOCK);
    expect(soldOut).toBe(ATTEMPTS - STOCK);

    const status = await app.inject({ method: 'GET', url: '/api/v1/sale/status' });
    expect(status.json().remainingStock).toBe(0);
  }, 30000);
});
