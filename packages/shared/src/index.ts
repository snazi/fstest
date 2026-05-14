export enum PurchaseOutcome {
  SUCCESS = 'SUCCESS',
  ALREADY_PURCHASED = 'ALREADY_PURCHASED',
  SOLD_OUT = 'SOLD_OUT',
  SALE_NOT_STARTED = 'SALE_NOT_STARTED',
  SALE_ENDED = 'SALE_ENDED',
  TEMPORARILY_UNAVAILABLE = 'TEMPORARILY_UNAVAILABLE',
  NOT_PURCHASED = 'NOT_PURCHASED'
}

export enum SaleStatus {
  UPCOMING = 'UPCOMING',
  ACTIVE = 'ACTIVE',
  ENDED = 'ENDED',
  SOLD_OUT = 'SOLD_OUT'
}

export interface SaleStatusResponse {
  saleId: string;
  serverTime: string;
  startAt: string;
  endAt: string;
  status: SaleStatus;
  remainingStock: number;
}

export interface PurchaseRequest {
  userId: string;
}

export interface PurchaseResponse {
  outcome: PurchaseOutcome;
  purchaseId: string | null;
  remainingStock: number;
  serverTime: string;
}

export interface PurchaseResultResponse {
  userId: string;
  outcome: PurchaseOutcome;
  purchaseId: string | null;
  decidedAt: string;
}
