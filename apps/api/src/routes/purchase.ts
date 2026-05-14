import type { FastifyInstance } from 'fastify';
import { PurchaseOutcome } from '@flashsale/shared';
import { mapDecisionCodeToOutcome } from '../domain/outcomes';

export const registerPurchaseRoutes = (app: FastifyInstance): void => {
  app.post('/api/v1/purchase', async (request, reply) => {
    const header = request.headers['idempotency-key'];
    const idempotencyKey = typeof header === 'string' ? header.trim() : '';
    const body = request.body as { userId?: string };

    if (!idempotencyKey || !body?.userId || typeof body.userId !== 'string') {
      return reply.status(400).send({ error: 'INVALID_REQUEST' });
    }

    try {
      const decision = await app.redisService.attemptPurchase({
        saleId: app.cfg.SALE_ID,
        userId: body.userId,
        nowMs: Date.now(),
        startAtMs: new Date(app.cfg.SALE_START_AT).getTime(),
        endAtMs: new Date(app.cfg.SALE_END_AT).getTime(),
        idempotencyKey,
        idempotencyTtlSeconds: app.cfg.IDEMPOTENCY_TTL_SECONDS
      });

      return {
        outcome: mapDecisionCodeToOutcome(decision.code),
        purchaseId: decision.purchaseId,
        remainingStock: decision.remainingStock,
        serverTime: decision.decidedAt
      };
    } catch {
      return reply.status(503).send({
        outcome: PurchaseOutcome.TEMPORARILY_UNAVAILABLE,
        purchaseId: null,
        remainingStock: -1,
        serverTime: new Date().toISOString()
      });
    }
  });

  app.get('/api/v1/purchase/result/:userId', async (request) => {
    const userId = (request.params as { userId: string }).userId;
    const result = await app.redisService.getUserResult(app.cfg.SALE_ID, userId);

    if (!result) {
      return {
        userId,
        outcome: PurchaseOutcome.NOT_PURCHASED,
        purchaseId: null,
        decidedAt: new Date().toISOString()
      };
    }

    return {
      userId,
      outcome: result.outcome,
      purchaseId: result.purchaseId,
      decidedAt: result.decidedAt
    };
  });
};
