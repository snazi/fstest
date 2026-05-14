import http from 'k6/http';
import { check } from 'k6';

export const options = {
  scenarios: {
    ramp: {
      executor: 'ramping-arrival-rate',
      startRate: 100,
      timeUnit: '1s',
      preAllocatedVUs: 200,
      maxVUs: 3000,
      stages: [
        { target: 2000, duration: '30s' },
        { target: 2000, duration: '60s' },
        { target: 0, duration: '10s' }
      ]
    }
  }
};

const BASE = __ENV.BASE_URL || 'http://localhost:3001';

export default function () {
  const userId = `k6-${__VU}-${__ITER}`;
  const res = http.post(`${BASE}/api/v1/purchase`, JSON.stringify({ userId }), {
    headers: {
      'Content-Type': 'application/json',
      'Idempotency-Key': `${userId}-idemp`
    }
  });

  check(res, {
    'status 200 or 503': (r) => r.status === 200 || r.status === 503
  });
}
