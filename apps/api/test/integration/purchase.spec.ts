import { beforeAll, afterAll, describe, expect, it } from 'vitest';
import { buildApp } from '../../src/app';

const cfg = {
  NODE_ENV: 'test',
  PORT: 3101,
  REDIS_URL: process.env.REDIS_URL || 'redis://127.0.0.1:6379',
  SALE_ID: `integration-sale-${Date.now()}`,
  SALE_STOCK: 2,
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

describe('purchase flow', () => {
  it('enforces idempotency and one-per-user', async () => {
    const req1 = await app.inject({
      method: 'POST',
      url: '/api/v1/purchase',
      headers: { 'idempotency-key': 'key-a' },
      payload: { userId: 'u1' }
    });
    expect(req1.statusCode).toBe(200);

    const req1Replay = await app.inject({
      method: 'POST',
      url: '/api/v1/purchase',
      headers: { 'idempotency-key': 'key-a' },
      payload: { userId: 'u1' }
    });
    expect(req1Replay.json()).toEqual(req1.json());

    const req2 = await app.inject({
      method: 'POST',
      url: '/api/v1/purchase',
      headers: { 'idempotency-key': 'key-b' },
      payload: { userId: 'u1' }
    });
    expect(req2.json().outcome).toBe('ALREADY_PURCHASED');
  });
});
