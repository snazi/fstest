import { z } from 'zod';

const EnvSchema = z.object({
  NODE_ENV: z.string().default('development'),
  PORT: z.coerce.number().default(3001),
  REDIS_URL: z.string().url(),
  CORS_ORIGIN: z.string().default('http://localhost:3000'),
  SALE_ID: z.string().min(1).default('flashsale-001'),
  SALE_STOCK: z.coerce.number().int().positive().default(500),
  SALE_START_AT: z.string().datetime(),
  SALE_END_AT: z.string().datetime(),
  IDEMPOTENCY_TTL_SECONDS: z.coerce.number().int().positive().default(86400)
}).refine((v) => new Date(v.SALE_START_AT).getTime() < new Date(v.SALE_END_AT).getTime(), {
  message: 'SALE_START_AT must be before SALE_END_AT'
});

export type EnvConfig = z.infer<typeof EnvSchema>;

export const loadEnv = (): EnvConfig => {
  const parsed = EnvSchema.safeParse(process.env);
  if (!parsed.success) {
    throw new Error(parsed.error.message);
  }
  return parsed.data;
};
