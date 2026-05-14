# DBX CLI and Asset Bundles Reference

## Core commands

```bash
# auth/profile
databricks auth profiles

# bundle checks
databricks bundle validate -t dev
databricks bundle summary -t dev

# job inspection
databricks jobs list
databricks jobs get <job-id>
```

## Job checks

- Verify expected workflows exist and match names as defined in `databricks.yml`.
- When validating generated jobs from bundles, confirm schedule/timeout matches the project's orchestration conventions.

## Guardrails

- Confirm target explicitly for bundle commands.
- Use only targets currently defined in `databricks.yml` unless the bundle config is intentionally updated.
- Confirm target-to-write mapping before deploy/run:
  - `dev` target writes only to `*.dev.*` destinations/state
  - `prod` target writes only to `*.prod.*` destinations/state
- Do not run destructive operations through agents.
- Require explicit approval before production-target deploy/run.

## Read-only data verification (dev)

- Use read-only SQL for table checks:
  - allowed: `SELECT`, `WITH`, `SHOW`, `DESCRIBE`, `EXPLAIN`
  - prohibited: `INSERT`, `UPDATE`, `DELETE`, `MERGE`, `COPY INTO`
  - prohibited: `CREATE`, `ALTER`, `DROP`, `TRUNCATE`, `OPTIMIZE`, `VACUUM`, `GRANT`, `REVOKE`
- Query only `*.dev.*` objects during agent-driven verification.
- Prefer bounded checks (`LIMIT`, filtered predicates, aggregates) over full scans.
- Anything outside read-only verification requires explicit user approval and manual control.

## Typical local workflow

1. Run local code tests/lint.
   - Python local validation default: `# %%` + Databricks Connect run-cell (injected `spark/sql` runtime globals; no DatabricksSession scaffold needed for run-cell mode).
   - Script-mode execution: run via bootstrap script.
   - Deterministic checks (recommended):
     - `ruff format --check .`
     - `ruff check .`
     - `pytest -q`
   - If SQL files changed:
     - `sqlfluff lint --dialect databricks <sql-files>`
2. `databricks bundle validate -t dev`.
3. `databricks bundle summary -t dev`.
4. If remote table verification is needed, run read-only checks against `*.dev.*`.
5. If approved for remote execution, run target-specific commands.
