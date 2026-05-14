import type { FastifyInstance } from 'fastify';
import { computeSaleStatus } from '../domain/outcomes';

export const registerSaleRoutes = (app: FastifyInstance): void => {
  app.get('/api/v1/sale/status', async () => {
    const nowMs = Date.now();
    const remainingStock = await app.redisService.getRemainingStock(app.cfg.SALE_ID);
    const status = computeSaleStatus({
      nowMs,
      startAtMs: new Date(app.cfg.SALE_START_AT).getTime(),
      endAtMs: new Date(app.cfg.SALE_END_AT).getTime(),
      remainingStock
    });

    return {
      saleId: app.cfg.SALE_ID,
      serverTime: new Date(nowMs).toISOString(),
      startAt: app.cfg.SALE_START_AT,
      endAt: app.cfg.SALE_END_AT,
      status,
      remainingStock
    };
  });
};
