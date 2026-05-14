---
name: databricks-presentation
description: "Implement and update the Databricks presentation layer including phase/stage outputs, status thresholds, mart-level aggregations, feature engineering, dashboards, BI visualization, and scoring logic. Use when changing scoring columns, downstream presentation grain, or mart-sourced business logic. Do not use for Bronze/Silver transformations or raw data ingestion."
---

# Databricks Presentation Layer

## When to Use This Skill

Use when implementing or modifying the presentation layer: feature engineering from mart tables, scoring/classification logic, status thresholds, phase/stage outputs, or mart-level aggregations for downstream consumption.

## Checklist

- [ ] Read [Medallion Boundaries](references/presentation-patterns.md) — presentation rules.
- [ ] Build all presentation features from mart tables only.
- [ ] Preserve the output grain as defined by the project's domain requirements.
- [ ] Keep threshold handling configurable.
- [ ] Run deterministic quality checks (recommended):
  - `ruff format --check .`
  - `ruff check .`
  - `pytest -q`
  - If SQL changed: `sqlfluff lint --dialect databricks <sql-files>`

## Workflow

1. Review predictor/feature definitions from [Presentation Patterns](references/presentation-patterns.md).
2. Build/adjust feature logic from mart entities.
3. Compute phase/stage outputs and status fields.
4. Validate output contract against defined grain and required fields.

## Done Criteria

- Output contract preserved.
- Phase/scoring logic is mart-sourced and deterministic.
- Nullability/grain checks completed.

## References

- [Presentation Patterns](references/presentation-patterns.md) — predictor definitions and output contract templates
- $databricks-medallion — mart sourcing rules
- $databricks-unit-testing — transform unit test patterns
