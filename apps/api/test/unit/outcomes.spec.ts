import { describe, expect, it } from 'vitest';
import { PurchaseOutcome, SaleStatus } from '@flashsale/shared';
import { computeSaleStatus, mapDecisionCodeToOutcome } from '../../src/domain/outcomes';

describe('mapDecisionCodeToOutcome', () => {
  it('maps all known codes', () => {
    expect(mapDecisionCodeToOutcome(1)).toBe(PurchaseOutcome.SALE_NOT_STARTED);
    expect(mapDecisionCodeToOutcome(2)).toBe(PurchaseOutcome.SALE_ENDED);
    expect(mapDecisionCodeToOutcome(3)).toBe(PurchaseOutcome.ALREADY_PURCHASED);
    expect(mapDecisionCodeToOutcome(4)).toBe(PurchaseOutcome.SOLD_OUT);
    expect(mapDecisionCodeToOutcome(5)).toBe(PurchaseOutcome.SUCCESS);
  });
});

describe('computeSaleStatus', () => {
  it('respects status order', () => {
    expect(computeSaleStatus({ nowMs: 9, startAtMs: 10, endAtMs: 20, remainingStock: 99 })).toBe(SaleStatus.UPCOMING);
    expect(computeSaleStatus({ nowMs: 21, startAtMs: 10, endAtMs: 20, remainingStock: 99 })).toBe(SaleStatus.ENDED);
    expect(computeSaleStatus({ nowMs: 15, startAtMs: 10, endAtMs: 20, remainingStock: 0 })).toBe(SaleStatus.SOLD_OUT);
    expect(computeSaleStatus({ nowMs: 15, startAtMs: 10, endAtMs: 20, remainingStock: 10 })).toBe(SaleStatus.ACTIVE);
  });
});
