---
name: databricks-medallion
description: "Build and modify Databricks Python/SQL transformations across Bronze, Silver, Gold mart, and presentation layers following the medallion lakehouse architecture. Covers layer boundary rules, deduplication contracts, and normalized warehouse semantics. Use when designing data layer structure or moving logic between medallion tiers. Do not use for non-Databricks data warehouse architectures."
---

# Databricks Medallion Modeling

## When to Use This Skill

Use when building or modifying transformations that cross medallion layer boundaries: Bronze ingestion, Silver standardize/dedup, Gold mart builds, or presentation layer outputs. This skill defines what belongs in each layer and the contracts between them.

## Checklist

- [ ] Read [Medallion Boundaries](references/medallion-boundaries.md) before editing any layer.
- [ ] Prefer Python `.py` files with `# %%` cells for local notebook-style work; notebooks are allowed when useful.
- [ ] Confirm target layer intent before editing.
- [ ] Keep Silver free of business scoring logic.
- [ ] Keep presentation outputs sourced from mart only.
- [ ] When adding or changing transform logic and its tests, follow $databricks-unit-testing: pure DataFrame-in/out functions, thin I/O wrappers, unit tests with in-memory DataFrames only (no table materialization).
- [ ] Run deterministic quality checks (recommended):
  - `ruff format --check .`
  - `ruff check .`
  - `pytest -q`
  - If SQL changed: `sqlfluff lint --dialect databricks <sql-files>`

## Layer Rules

### Bronze (raw only)

Bronze tables follow the pattern `raw.<source>_<entity>`.

- Keep payloads source-faithful; no business logic, no scoring.
- Preserve source timestamps plus `_ingestion_ts` and `_source_file`.
- Schema evolution is allowed.

### Silver (standardize and dedup only)

Silver views/tables follow the patterns `std.<source>` and `dedup.<source>`.

- Standardize names/types and deduplicate only.
- Do not compute business features, scores, or status flags in Silver.
- Dedup precedence: use source-specific recency fields when available, with `_ingestion_ts` as deterministic tie-breaker.

### Gold mart (normalized 3NF)

Mart tables follow the pattern `mart.<entity>`.

- Define grain per entity (one row per primary key or composite key).
- Event-level tables use event-level grain; dimension tables use entity-level grain.
- Preserve normalized reusable entities for downstream outputs.
- Do not emit business scoring or status columns in mart.

### Presentation (business logic only)

Presentation tables contain business logic built **from mart only**.

- Presentation grain and output tables are defined by the project's domain requirements.
- Must be built from mart tables only — no direct dependencies on Bronze/Silver objects.
- Feature engineering and business scoring logic belongs here.

## Workflow

1. Identify impacted entities and their medallion layer.
2. Implement transformation only in the allowed layer.
3. Preserve traceability metadata where needed.
4. Update dedup/key logic in Silver or mart as required.
5. Validate layer boundary compliance.

## Done Criteria

- Layer boundaries preserved.
- Dedup/lineage assumptions documented.
- No direct presentation dependencies on Bronze/Silver.

## References

- [Medallion Boundaries](references/medallion-boundaries.md) — layer rules and patterns
- [Naming Conventions](references/naming-conventions.md) — object naming patterns
- $databricks-unit-testing — transform unit test design
- $databricks-core — CLI and auth
