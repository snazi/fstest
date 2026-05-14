# Environment Target Mapping

## Purpose

Define how bundle targets map to data-write destinations and runtime state so `dev` and `prod` stay isolated.

## Target to write mapping

- Target `dev` writes only to `*.dev.*` schemas/tables.
- Target `prod` writes only to `*.prod.*` schemas/tables.
- Catalog names can remain the same while schema changes by target.
  - Example dev FQN: `{catalog}.dev.{table}`
  - Example prod FQN: `{catalog}.prod.{table}`

## Runtime state isolation

- Keep target-specific checkpoint locations (do not share `checkpointLocation` across targets).
- Keep target-specific schema tracking/state locations (e.g., Auto Loader `schemaLocation`).
- Keep target-specific control/watermark tables.
- Do not point a dev run at prod state paths/tables (or vice versa).

## Command and target gating

- Use only targets currently defined in `databricks.yml`.
- Do not run deploy/run commands on a target until that target is explicitly defined and approved.

## Promotion semantics

- Promotion means deploying the same logic to prod-mapped resources, not manually overriding dev jobs to write to prod paths.
- Before promotion, verify:
  - target exists in `databricks.yml`,
  - write destinations map to `*.prod.*`,
  - checkpoints/control tables are prod-isolated,
  - approval is explicit for prod deploy/run.
