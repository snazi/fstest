import { PurchaseOutcome, SaleStatus } from '@flashsale/shared';

export const mapDecisionCodeToOutcome = (code: number): PurchaseOutcome => {
  switch (code) {
    case 5:
      return PurchaseOutcome.SUCCESS;
    case 4:
      return PurchaseOutcome.SOLD_OUT;
    case 3:
      return PurchaseOutcome.ALREADY_PURCHASED;
    case 2:
      return PurchaseOutcome.SALE_ENDED;
    case 1:
      return PurchaseOutcome.SALE_NOT_STARTED;
    default:
      return PurchaseOutcome.TEMPORARILY_UNAVAILABLE;
  }
};

export const computeSaleStatus = (args: {
  nowMs: number;
  startAtMs: number;
  endAtMs: number;
  remainingStock: number;
}): SaleStatus => {
  if (args.nowMs < args.startAtMs) return SaleStatus.UPCOMING;
  if (args.nowMs > args.endAtMs) return SaleStatus.ENDED;
  if (args.remainingStock <= 0) return SaleStatus.SOLD_OUT;
  return SaleStatus.ACTIVE;
};
