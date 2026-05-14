# Pipeline Script and Lakeflow Job Patterns

## Transformation expectations (job-compute pipeline scripts)

Execution format default:
- Prefer Python `.py` files with `# %%` cells for notebook-style local execution.

- Keep transformations deterministic and rerunnable.
- Keep explicit keying/dedup logic in Silver and mart tables.
- Carry lineage/traceability columns where needed for audit and replay.
- Maintain dependency order: Bronze → Silver (`std.*`, `dedup.*`) → mart → presentation.

## Lakeflow job conventions

Define project-specific jobs in `databricks.yml`. Common patterns:

- **Daily pipeline:**
  - Schedule: define a recurring schedule matching business freshness SLA.
  - Timeout: set an appropriate timeout (e.g., 6 hours).
  - Compute: job cluster (auto-terminating).
- **Backfill pipeline:**
  - Name pattern: `{project}_backfill_{source}`
  - Trigger: manual.
  - Timeout: set a generous timeout (e.g., 24 hours).
  - Compute: job cluster (right-sized for the workload).

## Orchestration expectations

- Model task dependencies explicitly between ingestion and downstream transforms.
- Configure retries and timeout boundaries per task criticality.
- For daily runs, enforce this sequence:
  1. Source ingestion to Bronze
  2. Silver standardization/dedup
  3. Gold mart build
  4. Presentation refresh
  5. Data-quality/monitoring checks

## Observability expectations

- Keep run outcomes queryable through Databricks system tables:
  - `system.workflow.job_runs`
  - `system.billing.usage`
  - `system.compute.clusters`
  - `system.access.audit`
- Preserve enough run metadata to debug source, layer, and watermark state.

## Validation

For changes to pipelines/jobs, confirm:
- DAG/task order and dependencies,
- retry/failure behavior,
- timeout and schedule alignment,
- environment-specific target paths/config,
- system-table visibility for run diagnostics.

## Cost-aware advisory (warning only, not a hard rule)

- Prefer job compute for scheduled pipeline tasks and avoid all-purpose/interactive clusters for routine runs.
- Right-size compute for workload bottlenecks:
  - API-bound ingestion usually benefits more from rate-limit handling than from large Spark clusters.
- Prefer practical schedules that match business freshness needs; avoid overly frequent runs without a clear SLA need.
- Use manual/off-peak backfill execution with checkpoints for long historical loads.
- If a more expensive design is selected for reliability or delivery speed, proceed and document:
  - why it was chosen,
  - expected operational benefit,
  - expected cost impact (even if approximate).
