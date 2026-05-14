import Fastify from 'fastify';
import cors from '@fastify/cors';
import { loadEnv, type EnvConfig } from './config/env';
import { RedisService } from './services/redis';
import { registerSaleRoutes } from './routes/sale';
import { registerPurchaseRoutes } from './routes/purchase';

declare module 'fastify' {
  interface FastifyInstance {
    cfg: EnvConfig;
    redisService: RedisService;
  }
}

export const buildApp = (cfg = loadEnv()) => {
  const app = Fastify({ logger: true });
  const redisService = new RedisService(cfg.REDIS_URL);

  app.decorate('cfg', cfg);
  app.decorate('redisService', redisService);
  app.register(cors, {
    origin: cfg.CORS_ORIGIN
  });

  app.get('/health', async (_request, reply) => {
    try {
      const ping = await app.redisService.ping();
      return { ok: ping === 'PONG' };
    } catch {
      return reply.status(503).send({ ok: false });
    }
  });

  registerSaleRoutes(app);
  registerPurchaseRoutes(app);

  app.addHook('onReady', async () => {
    await app.redisService.seedSale({ saleId: cfg.SALE_ID, stock: cfg.SALE_STOCK });
  });

  app.addHook('onClose', async () => {
    await app.redisService.close();
  });

  return app;
};
