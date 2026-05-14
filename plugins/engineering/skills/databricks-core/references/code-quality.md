# Python and SQL Style Quality Defaults

## Scope

Applies to Databricks pipeline code (`.py` with `# %%`, SQL models/queries, and validation scripts).

## Python defaults (Databricks pipelines)

- Prefer Python `.py` files with `# %%` cells for local notebook-style execution.
- Isolate I/O from business logic:
  - keep extract/load side effects in thin orchestration cells/functions
  - keep transforms in small, testable, deterministic functions
- Use explicit type hints on new/modified Python functions.
- Avoid broad exception handling (`except Exception:`) unless re-raising with context.
- Keep idempotency explicit for ingestion and backfill flows.
- Avoid hidden mutable global state; pass config/state explicitly.
- Ensure deterministic transformation behavior:
  - use explicit dedup precedence ordering
  - use stable tie-breakers in window functions
  - avoid nondeterministic behavior unless documented and justified
- Log operational metadata, not sensitive payloads:
  - include source/layer/table/run identifiers and row-count metrics
  - never log secrets or full sensitive records

## SQL defaults (Databricks SQL)

- Avoid `SELECT *` for Silver/mart/presentation logic.
- Use explicit projection and clear aliases.
- Keep join intent explicit with declared keys and expected grain.
- Use deterministic dedup patterns (`ROW_NUMBER` with full ordering precedence).
- Cast types explicitly at layer boundaries when source typing can drift.
- Keep verification SQL read-only unless explicitly approved otherwise.

## Recommended deterministic checks (before final handoff and PR)

Run these from repo root:

```bash
ruff format --check .
ruff check .
pytest -q
```

If SQL files are touched:

```bash
sqlfluff lint --dialect databricks <sql-files>
```

## Optional auto-fix commands

```bash
ruff format .
ruff check . --fix
sqlfluff fix --dialect databricks <sql-files>
```

Auto-fix output must still be reviewed for semantic correctness.
