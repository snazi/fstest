# Operational Alert Expectations

- Alert on job failure and include source/layer context.
- Alert on unusual run duration increases.
- Alert when freshness SLA is breached.
- Keep run metadata queryable from Databricks system tables:
  - `system.workflow.job_runs`
  - `system.billing.usage`
  - `system.compute.clusters`
