# Ingestion Contracts

## Source contracts

Define source-specific extraction contracts below. Each source should specify:

- **Mode**: incremental, full extraction, or scoped backfill.
- **Scope filters**: tenant scope, time windows, entity boundaries.
- **Pagination**: page-based, cursor-based, or offset-based with page size limits.
- **Rate limits**: API rate limit guards and backoff strategy.
- **Expected raw outputs**: target `raw.<source>_<entity>` Bronze tables.
- **Checkpoint contract**: checkpoint semantics for resume-after-failure.

### Example source contract template

```
### <Source Name>

- Mode: <incremental|full|scoped backfill>
- Scope filters: <required filters>
- Pagination: <type and size limits>
- Rate limits: <rate limit guards>
- Expected raw outputs: `raw.<source>_<entity>`
- Checkpoint contract: <checkpoint semantics>
```

Add project-specific source contracts below this line.

---

## Required pipeline script shape (5 steps)

Execution format default:
- Prefer Python `.py` files with `# %%` cells for local notebook-style development.

1. Configuration: load secrets from the configured scope, read source watermark/control state, set extraction window.
2. Extraction: call source API with contract-required scope filters/time windows, pagination/retry/backoff, attach `_ingestion_ts`.
3. Landing: write raw data to the landing path (e.g., `/bronze/{source}/landing/{yyyy-mm-dd}/`).
4. Bronze load: Auto Loader (`cloudFiles`) consumes landing files and writes Delta Bronze.
5. Watermark/checkpoint update: update control state only after successful load and metrics logging.

## Metadata and target requirements

- Every Bronze row must include `_ingestion_ts` and `_source_file`.
- Bronze FQN format: `{catalog}.{schema}.{table_name}` using the project's catalog naming convention.
- For first-write/bootstrap paths, physical Delta column names must remain Delta-compatible.
  - Do not create Bronze tables with raw source field names that contain spaces/special characters.
  - Normalize source keys to deterministic Delta-safe column names.
  - Resolve semantic collisions before hash fallback so expected metrics stay human-readable.
  - Use hashed suffix fallback only for residual true collisions after semantic aliasing.
  - Preserve only drift/unmapped source fields in `_rescued_data`.

## Backfill contract

- Use source-specific checkpoint semantics.
- Resume from the last successful source-specific checkpoint after failure.
- Validate each checkpointed unit with source-vs-loaded row count checks.

## Cost-aware advisory (warning only, not a hard rule)

- Prefer Auto Loader directory-listing mode by default when notification mode is not required.
- Prefer batch-style scheduled runs (`availableNow` style) over long-lived streaming-style compute unless near-real-time behavior is explicitly required.
- Keep Bronze ingestion idempotent, but avoid unnecessary full reload/merge patterns when incremental loads are sufficient.
- If a higher-cost pattern materially improves reliability, latency, or recovery posture, it is acceptable — include a short note describing the tradeoff.
