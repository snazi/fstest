# Stress Tests and Expected Outcomes

## 1) Purpose of Stress Testing
Stress testing validates that the flash-sale purchase flow remains correct and stable under heavy concurrency. For this project, the primary goals are:
- Preserve correctness under load (no oversell, one item per user).
- Maintain acceptable latency during sustained high request rates.
- Confirm graceful degradation and recovery during dependency faults (Redis disruptions).

## 2) Test Scenarios and Methodology
This document is grounded in existing project artifacts:
- `stress/purchase.js` (k6 load profile)
- `apps/api/test/integration/concurrency.spec.ts` (concurrency correctness test)
- `README.md` stress-testing guidance
- `docs/plan/2026-05-10_high_throughput_flash_sale_system_001.md` acceptance targets

### Scenario A: Concurrency Correctness (Deterministic)
- Tool: integration/concurrency test suite
- Setup: initial stock = 500, 5,000 concurrent purchase attempts, unique users
- Method:
  1. Run API + Redis in active sale window.
  2. Fire concurrent purchase requests.
  3. Assert aggregate outcomes and stock invariants.

### Scenario B: Sustained Throughput Stress (k6 Ramp)
- Tool: `k6 run stress/purchase.js`
- Current profile in repo:
  - Ramp arrival rate from 100 RPS to 2,000 RPS over 30s
  - Sustain at 2,000 RPS for 60s
  - Ramp down to 0 over 10s
- Request model:
  - `POST /api/v1/purchase`
  - Unique user IDs per iteration
  - Idempotency key set per request

### Scenario C: Spike Stress (Planned/Recommended)
- Tool: k6 (separate spike profile)
- Target pattern (from plan): short burst from 0 to ~5,000 VUs
- Method:
  1. Start from near-idle traffic.
  2. Inject sharp burst.
  3. Observe admission behavior, latency blow-up boundary, and recovery.

### Scenario D: Fault-Tolerance Under Load (Planned/Recommended)
- Tool: k6 + controlled Redis disruption
- Method:
  1. Run sustained load.
  2. Restart or temporarily disconnect Redis.
  3. Verify API returns temporary `503` during impact window.
  4. Verify clean recovery once Redis is healthy.

## 3) Key Metrics to Monitor
- Correctness metrics:
  - Success count
  - Sold-out count
  - Remaining stock
  - Unique successful users
  - Duplicate-success incidents (must be zero)
- Performance metrics:
  - Throughput (RPS)
  - p95 latency for `POST /api/v1/purchase`
  - p99 latency (recommended for spike analysis)
- Reliability metrics:
  - 5xx error rate
  - `503` rate during fault windows (expected only when fault is injected)
  - Redis connectivity/command error rate
- Behavior metrics:
  - Outcome mix over time (`SUCCESS`, `SOLD_OUT`, and other business outcomes)
  - Idempotency replay consistency

## 4) Expected Outcomes by Scenario
### Scenario A: Concurrency Correctness
- Expected:
  - `success_count = 500`
  - `sold_out_or_late_count = 4500`
  - `remaining_stock = 0`
  - `unique_success_users = 500`
  - No user receives duplicate success
- Interpretation: core no-oversell and one-per-user invariants hold.

### Scenario B: Sustained Throughput Stress
- Expected:
  - No oversell at any point.
  - High `SOLD_OUT` volume after stock reaches 0.
  - p95 latency under target during sustain.
  - 5xx near-zero under normal dependency health.

### Scenario C: Spike Stress
- Expected:
  - Temporary latency increase is acceptable.
  - Correctness invariants still hold (no oversell, no duplicate success).
  - Service recovers to baseline latency/error levels after burst.

### Scenario D: Fault-Tolerance Under Load
- Expected:
  - During Redis impact: temporary `503` responses may occur.
  - After Redis recovery: API resumes normal operation without data corruption.
  - Idempotent retries remain consistent and do not consume extra stock.

## 5) Pass/Fail Criteria
Use these practical gates for release confidence:
- Hard correctness gates (must pass):
  - No oversell in any test run.
  - No duplicate successful purchase per user.
  - Concurrency test exact totals match expected values.
- Performance gates (baseline, tunable by environment):
  - Sustained-load p95 latency < 120ms.
  - 5xx error rate < 0.5% when no fault is injected.
- Resilience gates:
  - Under injected Redis fault, failures are bounded and mainly `503`.
  - Service recovers cleanly after dependency restoration.

A run fails if any hard correctness gate fails, or if performance/reliability gates exceed thresholds without an accepted environmental explanation.

## 6) Risks and Follow-up Actions
### Key Risks
- Current k6 script validates HTTP status only (`200` or `503`) and does not assert outcome payload invariants.
- Spike profile and chaos/fault scenarios are defined in planning docs but not yet codified in dedicated scripts.
- No persistent audit store in critical path limits post-incident forensic depth.
- Rate limiting is not enabled, which may amplify non-business traffic during extreme spikes.

### Follow-up Actions
1. Add dedicated k6 scripts for spike and fault-injection scenarios.
2. Extend k6 checks to validate response body outcomes and idempotency replay behavior.
3. Capture and store run artifacts (latency percentiles, error rates, outcome distribution) per test run.
4. Add dashboards/alerts for p95 latency, 5xx rate, and Redis error rates.
5. Define environment-specific SLO thresholds (local, staging, production-like).

## Assumptions
- The sale is configured as single-SKU, quantity-per-purchase = 1.
- Concurrency and stress expectations are based on current repository defaults and documented plan targets.
- Thresholds are baseline targets and may require calibration by environment capacity.
