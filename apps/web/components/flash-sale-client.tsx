'use client';

import { useEffect, useMemo, useState } from 'react';
import type { PurchaseResponse, SaleStatusResponse, PurchaseResultResponse } from '@flashsale/shared';

const API_BASE = process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:3001';

export function FlashSaleClient() {
  const [userId, setUserId] = useState('');
  const [status, setStatus] = useState<SaleStatusResponse | null>(null);
  const [purchase, setPurchase] = useState<PurchaseResponse | null>(null);
  const [lookup, setLookup] = useState<PurchaseResultResponse | null>(null);
  const [error, setError] = useState<string | null>(null);

  const canBuy = useMemo(() => status?.status === 'ACTIVE' && userId.trim().length > 0, [status, userId]);

  const fetchStatus = async () => {
    const res = await fetch(`${API_BASE}/api/v1/sale/status`, { cache: 'no-store' });
    setStatus(await res.json());
  };

  useEffect(() => {
    fetchStatus();
    const id = setInterval(fetchStatus, 1500);
    return () => clearInterval(id);
  }, []);

  const buy = async () => {
    setError(null);
    const idempotency = crypto.randomUUID();
    const res = await fetch(`${API_BASE}/api/v1/purchase`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Idempotency-Key': idempotency
      },
      body: JSON.stringify({ userId })
    });
    if (!res.ok) {
      setError(`Request failed: ${res.status}`);
      return;
    }
    setPurchase(await res.json());
  };

  const lookupResult = async () => {
    if (!userId.trim()) return;
    const res = await fetch(`${API_BASE}/api/v1/purchase/result/${encodeURIComponent(userId)}`, { cache: 'no-store' });
    setLookup(await res.json());
  };

  return (
    <main className="mx-auto flex min-h-screen max-w-2xl flex-col gap-4 p-6">
      <h1 className="text-3xl font-bold">Flash Sale</h1>
      <section className="rounded bg-white p-4 shadow">
        <h2 className="font-semibold">Sale Status</h2>
        {status ? (
          <div className="mt-2 text-sm">
            <p>Status: <strong>{status.status}</strong></p>
            <p>Remaining stock: <strong>{status.remainingStock}</strong></p>
            <p>Start: {status.startAt}</p>
            <p>End: {status.endAt}</p>
            <p>Server time: {status.serverTime}</p>
          </div>
        ) : <p>Loading...</p>}
      </section>

      <section className="rounded bg-white p-4 shadow">
        <h2 className="font-semibold">Purchase</h2>
        <input
          className="mt-2 w-full rounded border p-2"
          placeholder="Enter userId"
          value={userId}
          onChange={(e) => setUserId(e.target.value)}
        />
        <div className="mt-3 flex gap-2">
          <button className="rounded bg-blue-600 px-3 py-2 text-white disabled:bg-slate-400" disabled={!canBuy} onClick={buy}>Buy 1 Item</button>
          <button className="rounded bg-slate-700 px-3 py-2 text-white" onClick={lookupResult}>Check Result</button>
        </div>
        {error && <p className="mt-2 text-red-700">{error}</p>}
      </section>

      <section className="rounded bg-white p-4 shadow">
        <h2 className="font-semibold">Latest Purchase Response</h2>
        <pre className="mt-2 overflow-auto rounded bg-slate-900 p-3 text-xs text-slate-100">{JSON.stringify(purchase, null, 2)}</pre>
      </section>

      <section className="rounded bg-white p-4 shadow">
        <h2 className="font-semibold">Lookup Result</h2>
        <pre className="mt-2 overflow-auto rounded bg-slate-900 p-3 text-xs text-slate-100">{JSON.stringify(lookup, null, 2)}</pre>
      </section>
    </main>
  );
}
