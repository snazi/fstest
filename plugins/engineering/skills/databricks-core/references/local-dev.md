# Databricks Connect Local Development

## Baseline setup expectations

- Local development assumes Databricks Connect is configured.
- Python minor version must match Databricks Connect requirement.
- Databricks Connect major/minor should match Databricks Runtime major/minor used by target compute.
- Match `databricks-connect` version to the target cluster's Databricks Runtime version.
- Use `pyproject.toml` as the dependency source of truth.
- Default dependency groups must include both `dev` and `databricks` so sync installs DBX dependencies.
- Keep local-only settings out of committed files unless explicitly intended.
- Use project-level `databricks.yml` for shared bundle definition.
- Do not install standalone `pyspark` in the same environment when using Databricks Connect.

## Execution conventions (canonical)

Preferred notebook-style local execution:
- Use Python files with `# %%` cells.
- Execute cells via IDE Databricks Connect run-cell command.
- In this mode, Databricks injects notebook globals (`spark`, `sql`, `display`, `dbutils`).
- Do not scaffold `DatabricksSession.builder.getOrCreate()` for run-cell code paths.

Script-mode execution through Databricks Connect:
- Use the Databricks Connect bootstrap script for script-mode execution.

Agent code-generation policy:
- For `# %%` run-cell workflows, prefer injected `spark/sql` and do not add explicit DatabricksSession scaffolding unless the user explicitly asks for plain-Python-only execution.

## Local validation patterns

Before PR:
- Run deterministic local checks (recommended):
  - `ruff format --check .`
  - `ruff check .`
  - `pytest -q`
- If SQL files changed, run:
  - `sqlfluff lint --dialect databricks <sql-files>`
- Run `databricks bundle validate` for bundle changes.
- If running bundle operations, validate target/environment explicitly.
- If running remote data checks, use read-only SQL only (`SELECT`, `WITH`, `SHOW`, `DESCRIBE`, `EXPLAIN`) on `*.dev.*`.

## Safety

- Do not run destructive workspace/file operations via agent.
- Do not run SQL DDL/DML for agent-driven verification.
- Require explicit confirmation for production-targeted deploy operations.
