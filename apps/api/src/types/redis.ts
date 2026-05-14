export interface PurchaseDecision {
  code: number;
  remainingStock: number;
  purchaseId: string | null;
  decidedAt: string;
}
