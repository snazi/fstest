# Change Safety

## Scope control

- Do not refactor unrelated files in the same change.
- Prefer additive and reversible updates.
- Keep migration and backfill steps explicit.
- Run deterministic quality checks before PR (recommended):
  - `ruff format --check .`
  - `ruff check .`
  - `pytest -q`
  - if SQL changed: `sqlfluff lint --dialect databricks <sql-files>`

## Unknowns

- If source contracts or API behavior are unknown, mark assumptions clearly.
- Record open questions and required owner follow-ups.

## Production caution

- Any production-impacting job or model change must include rollback notes.
- Any destructive operation requires explicit user approval and manual control.
