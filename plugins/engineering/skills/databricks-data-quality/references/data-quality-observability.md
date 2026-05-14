# Data Quality and Observability

## Required quality dimensions

- Uniqueness
- Completeness
- Validity
- Timeliness
- Consistency

## Required check matrix

- Uniqueness: `mart.*` primary/composite keys (expected fail: `False`).
- Uniqueness: `dedup.*` dedup keys (expected fail: `False`).
- Completeness: `mart.*` required PK/FK/critical business fields (expected fail: `False`).
- Completeness: `raw.*` metadata fields `_ingestion_ts`, `_source_file` (expected fail: `False`).
- Validity: Bronze normalized physical columns should capture expected source fields; `_rescued_data` should primarily contain drift/unmapped payload (expected fail: `False`).
- Validity: `mart.*` date ranges and referential dates (expected fail: `False`).
- Validity: `mart.*` foreign-key integrity (expected fail: `False`).
- Validity: `mart.*` enum/status allowed values (expected fail: `False`).
- Validity: `mart.*` numeric bounds on transactional fields (expected fail: `False`).
- Timeliness: `raw.*` ingestion lag from `_ingestion_ts` (expected fail: `False`).
- Timeliness: `raw.*` source freshness timestamps (expected fail: `False`).
- Timeliness: `raw.*` new-data arrival checks (expected fail: `False`).
- Consistency: row-count reconciliation `raw → dedup → mart` (expected fail: `False`).
- Consistency: cross-source shared attributes (expected fail: `True` initially; investigate/document differences).
- Consistency: cross-source common dimensions (expected fail: `False`).
- Consistency: cross-run key stability (expected fail: `False`).

## Observability

- Keep run diagnostics queryable via Databricks system tables:
  - `system.workflow.job_runs`
  - `system.billing.usage`
  - `system.compute.clusters`
  - `system.access.audit`
- Use ingestion metadata (`_ingestion_ts`, `_source_file`) and watermark logs for source-to-record traceability.
- Ensure DQ failures can be tied back to specific run/job IDs and impacted table/layer.
