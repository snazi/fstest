import Redis from 'ioredis';
import { existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
import { randomUUID } from 'node:crypto';
import type { PurchaseDecision } from '../types/redis';

export class RedisService {
  private client: Redis;
  private script: string;

  constructor(redisUrl: string) {
    this.client = new Redis(redisUrl, { maxRetriesPerRequest: 1 });
    const distPath = join(__dirname, '..', 'lua', 'purchase.lua');
    const srcPath = join(process.cwd(), 'src', 'lua', 'purchase.lua');
    this.script = readFileSync(existsSync(distPath) ? distPath : srcPath, 'utf8');
  }

  async close(): Promise<void> {
    await this.client.quit();
  }

  async ping(): Promise<string> {
    return this.client.ping();
  }

  getKey(saleId: string, suffix: string): string {
    return `sale:${saleId}:${suffix}`;
  }

  async seedSale(args: { saleId: string; stock: number }): Promise<void> {
    const stockKey = this.getKey(args.saleId, 'stock');
    const existing = await this.client.exists(stockKey);
    if (!existing) {
      await this.client.set(stockKey, args.stock);
    }
  }

  async getRemainingStock(saleId: string): Promise<number> {
    const raw = await this.client.get(this.getKey(saleId, 'stock'));
    return Number(raw ?? '0');
  }

  async getUserResult(saleId: string, userId: string): Promise<{ outcome: string; purchaseId: string | null; decidedAt: string } | null> {
    const raw = await this.client.get(this.getKey(saleId, `result:${userId}`));
    if (!raw) return null;
    const [outcome, purchaseId, decidedAt] = raw.split('|');
    return { outcome, purchaseId: purchaseId || null, decidedAt: new Date(Number(decidedAt)).toISOString() };
  }

  async attemptPurchase(args: {
    saleId: string;
    userId: string;
    nowMs: number;
    startAtMs: number;
    endAtMs: number;
    idempotencyKey: string;
    idempotencyTtlSeconds: number;
  }): Promise<PurchaseDecision> {
    const keys = [
      this.getKey(args.saleId, 'stock'),
      this.getKey(args.saleId, 'buyers'),
      this.getKey(args.saleId, `attempt:${args.idempotencyKey}`),
      this.getKey(args.saleId, `result:${args.userId}`)
    ];

    const purchaseId = randomUUID();
    const result = await this.client.eval(
      this.script,
      keys.length,
      ...keys,
      String(args.nowMs),
      String(args.startAtMs),
      String(args.endAtMs),
      args.userId,
      purchaseId,
      String(args.idempotencyTtlSeconds)
    ) as [number, number, string, string];

    return {
      code: Number(result[0]),
      remainingStock: Number(result[1]),
      purchaseId: result[2] ? String(result[2]) : null,
      decidedAt: new Date(Number(result[3])).toISOString()
    };
  }
}
