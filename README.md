# Flash Sale System (Docker-first)

High-throughput single-product flash sale with strict one-item-per-user and no oversell under heavy concurrency.

## Architecture

- `apps/api`: Fastify + TypeScript API
- `apps/web`: Next.js (App Router) + TypeScript + Tailwind CSS frontend
- `packages/shared`: shared TypeScript enums/types used by API + web
- `redis`: authoritative store for purchase decisioning

### Tradeoffs

- Redis + Lua is the authoritative write path to guarantee atomic checks/mutations under concurrency.
- API returns `503` on purchase when Redis is unavailable (no uncertain writes).
- Optional durable audit DB is intentionally excluded from decisioning to keep correctness and throughput deterministic.

### Mermaid Diagram

```mermaid
flowchart LR
  B[Browser Next.js] -->|GET /api/v1/sale/status| A[Fastify API]
  B -->|POST /api/v1/purchase\nIdempotency-Key| A
  B -->|GET /api/v1/purchase/result/:userId| A

  A -->|EVAL Lua Atomic Script| R[(Redis)]

  subgraph Redis Keys
    K1[sale:{id}:stock]
    K2[sale:{id}:buyers]
    K3[sale:{id}:attempt:{idempotencyKey}]
    K4[sale:{id}:result:{userId}]
  end

  R --- K1
  R --- K2
  R --- K3
  R --- K4
```

## Outcome precedence

`SALE_NOT_STARTED -> SALE_ENDED -> ALREADY_PURCHASED -> SOLD_OUT -> SUCCESS`

## APIs

1. `GET /api/v1/sale/status`
2. `POST /api/v1/purchase` (requires `Idempotency-Key`)
3. `GET /api/v1/purchase/result/:userId`

## Local run (one command)

```bash
docker compose up --build
```

- API: `http://localhost:3001`
- Web: `http://localhost:3000`

Stop:

```bash
docker compose down -v
```

Logs:

```bash
docker compose logs -f --tail=200
```

## Config

Compose defaults in `docker-compose.yml`:
- `SALE_STOCK=500`
- `SALE_START_AT=2026-01-01T00:00:00.000Z`
- `SALE_END_AT=2027-01-01T00:00:00.000Z`
- `IDEMPOTENCY_TTL_SECONDS=86400`

## Tests

Prereq (for non-docker test run): running Redis on `localhost:6379`.

Unit tests:

```bash
npm run test:unit
```

Integration tests:

```bash
npm run test:integration
```

Concurrency proof test (stock 500, attempts 5000):

```bash
npm run test:concurrency
```

Expected key result:
- Success count = 500
- Sold out count = 4500
- Remaining stock = 0

## Stress test (k6)

```bash
k6 run stress/purchase.js
```

Optional base URL:

```bash
BASE_URL=http://localhost:3001 k6 run stress/purchase.js
```

Expected behavior:
- No oversell
- High volume of `SOLD_OUT` once stock reaches 0
- 5xx should be near-zero unless Redis fault is injected

## NPM helper scripts

- `npm run up`
- `npm run down`
- `npm run logs`
- `npm run test:unit`
- `npm run test:integration`
- `npm run test:concurrency`
- `npm run stress`

## Known limitations

- No authentication/authorization (userId is trusted input).
- No persistent audit store in this implementation.
- Rate-limiting not enabled.

## Additional docs

- [design-decisions.md](docs/design-decisions.md)
- [STRESS_TESTS_AND_EXPECTED_OUTCOMES.md](docs/STRESS_TESTS_AND_EXPECTED_OUTCOMES.md)
