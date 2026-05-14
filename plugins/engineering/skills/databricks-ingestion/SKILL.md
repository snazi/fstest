---
name: databricks-ingestion
description: "Build or modify Databricks Bronze ingestion pipelines using landing-zone plus Auto Loader patterns, watermarking, retry/backoff handling, backfill chunking, schema drift handling, and source connector configuration. Use when implementing API-based or file-based data ingestion into Databricks. Do not use for Silver/Gold transformation logic or non-Databricks ingestion tools."
---

# Databricks Ingestion Pipeline

## When to Use This Skill

Use when implementing or modifying source extraction and Bronze loading behavior: API-based ingestion, file-based ingestion via Auto Loader, watermark management, backfill operations, or schema drift handling.

## Checklist

- [ ] Read [Ingestion Contracts](references/ingestion-contracts.md).
- [ ] Read [Source Scope Guardrails](references/source-scope-guardrails.md).
- [ ] Read [Backfill Guardrails](references/backfill-guardrails.md) during planning for preventive guardrails, then reuse for debugging when needed.
- [ ] Prefer Python `.py` files with `# %%` cells for repo-managed ingestion workflows; notebooks are allowed when useful.
- [ ] Confirm source mode (incremental vs full).
- [ ] Confirm source scope filters/windows are explicit in request builders and checkpoints.
- [ ] For API-based sources, confirm property/field extraction approach matches source contract.
- [ ] If using local Python run-cell (`# %%` + Databricks Connect), rely on injected runtime globals (`spark/sql`) — do not scaffold `DatabricksSession`.
- [ ] Preserve `_ingestion_ts` and `_source_file` in Bronze.
- [ ] Handle schema drift in Bronze by persisting `_rescued_data` (JSON) for source-only fields.
- [ ] Keep bootstrap table creation Delta-safe: never `CTAS SELECT *` from raw source columns when table may not exist; normalize source keys to deterministic Delta-safe column names and route only drift/unmapped fields to `_rescued_data`.
- [ ] Build MERGE SQL with explicit, quoted column mappings; avoid `UPDATE SET *` and `INSERT *`.
- [ ] De-duplicate source rows by merge key before MERGE to avoid ambiguous updates.
- [ ] Ensure watermark update happens only after successful load.
- [ ] Validate against [Pipeline Checklist](references/pipeline-checklist.md).
- [ ] Run deterministic quality checks (recommended):
  - `ruff format --check .`
  - `ruff check .`
  - `pytest -q`
  - If SQL changed: `sqlfluff lint --dialect databricks <sql-files>`

## Workflow

1. Confirm source contract from ingestion contracts reference.
2. Confirm source scope guardrails (scope filters + time windows as defined in contracts).
3. Implement ingestion pipeline flow in order:
   - Config and secret loading (via Databricks secret scope)
   - Extraction with pagination/retries
   - Landing writes
   - Auto Loader or batch JSON fallback to Bronze (runtime dependent)
   - Delta-safe table bootstrap for first-write paths (compatible column set only)
   - Semantic alias promotion for metric collisions before hash fallback
   - Source de-duplication + explicit MERGE mapping
   - Schema drift capture in `_rescued_data`
   - Watermark/control-table updates
4. Add structured run metrics and failure logs.

## Done Criteria

- Source-specific extraction contract preserved.
- Metadata columns and watermark semantics preserved.
- Validation evidence recorded.

## References

- [Ingestion Contracts](references/ingestion-contracts.md) — source contract templates and pipeline shape
- [Source Scope Guardrails](references/source-scope-guardrails.md) — extraction boundaries
- [Backfill Guardrails](references/backfill-guardrails.md) — planning prevention and runtime diagnosis
- [Pipeline Checklist](references/pipeline-checklist.md) — validation checklist
- $databricks-core — CLI and auth
- $databricks-medallion — layer rules
