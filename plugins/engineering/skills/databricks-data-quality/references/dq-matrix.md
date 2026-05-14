# Data Quality Matrix

## Dimensions
- Uniqueness
- Completeness
- Validity
- Timeliness
- Consistency

## Required checks

- Uniqueness:
  - `mart.*` primary/composite keys (expected fail: `False`)
  - `dedup.*` dedup keys (expected fail: `False`)
- Completeness:
  - `mart.*` required PK/FK and critical business fields (expected fail: `False`)
  - `raw.*` metadata fields `_ingestion_ts`, `_source_file` (expected fail: `False`)
- Validity:
  - `mart.*` format checks on email/identifier fields
  - `mart.*` date ranges, FK integrity, enum/status domains
  - `mart.*` numeric bounds on transactional fields
  - All above expected fail: `False`
- Timeliness:
  - Ingestion lag via `_ingestion_ts`
  - Source freshness timestamps
  - New-data arrival detection
  - Expected fail: `False`
- Consistency:
  - Row count reconciliation `raw → dedup → mart` (expected fail: `False`)
  - Cross-source shared attributes (expected fail: `True` initially; investigate/document)
  - Cross-source common dimensions (expected fail: `False`)
  - Cross-run key stability (expected fail: `False`)
