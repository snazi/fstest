---
name: databricks-data-quality
description: "Add and maintain data quality (DQ) gates and operational checks for Databricks pipelines across Bronze, Silver, Mart, and presentation layers. Covers uniqueness, completeness, validity, timeliness, consistency checks, expectations, reconciliation, freshness monitoring, and observability. Use when implementing or reviewing DQ rules in Databricks. Do not use for application-level input validation."
---

# Databricks Data Quality Gates

## When to Use This Skill

Use when adding or maintaining data quality checks across pipeline layers: uniqueness, completeness, validity, timeliness, and consistency checks, plus reconciliation and freshness monitoring.

## Checklist

- [ ] Cover all relevant dimensions: uniqueness, completeness, validity, timeliness, consistency.
- [ ] Add reconciliation checks for impacted layer transitions.
- [ ] Mark expected-fail checks and follow-up actions explicitly.
- [ ] Include observability/alert expectations.

## Quality Dimensions

| Dimension | What it checks |
|---|---|
| **Uniqueness** | Primary/composite keys in mart and dedup tables have no duplicates |
| **Completeness** | Required PK/FK and critical business fields are non-null |
| **Validity** | Format, range, referential integrity, enum domain checks |
| **Timeliness** | Ingestion lag, source freshness, new-data arrival |
| **Consistency** | Row-count reconciliation across layers, cross-source attribute alignment |

## Workflow

1. Select applicable checks from [DQ Matrix](references/dq-matrix.md).
2. Place checks at the lowest-cost layer for defect detection.
3. Add reconciliation checks for `raw -> dedup -> mart` where impacted.
4. Configure/validate alerts using [Operational Alerts](references/operational-alerts.md).

## Done Criteria

- Pass/fail logic is explicit and deterministic.
- Expected variance is separated from true defects.
- Validation and monitoring notes are documented.

## References

- [DQ Matrix](references/dq-matrix.md) — required checks by dimension
- [Operational Alerts](references/operational-alerts.md) — alert expectations
- [Data Quality Observability](references/data-quality-observability.md) — system table queries and traceability
- $databricks-medallion — layer context
