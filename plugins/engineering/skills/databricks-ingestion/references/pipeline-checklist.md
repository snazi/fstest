# Pipeline Validation Checklist

- Config reads secrets from Databricks secret scope, not plain text.
- API extraction enforces source scope filters/time windows and handles pagination + retry/backoff.
- For API-based sources, confirm property/field extraction approach matches the source contract.
- Landing output writes raw payloads without destructive transforms.
- Bronze physical columns use deterministic Delta-safe normalized names for expected source fields.
- Base + `%` metric collisions are promoted to semantic aliases (`*_count`, `*_pct`) before any hashed fallback.
- `_rescued_data` is used for drift/unmapped payload only (not expected baseline fields).
- Auto Loader writes to expected Bronze table and checkpoint locations.
- Watermark and extraction metrics update only on success.
- Backfill checkpoints match source contract.
- Failure path leaves enough logs to resume/replay safely.
