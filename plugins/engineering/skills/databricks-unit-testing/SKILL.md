---
name: databricks-unit-testing
description: "Write and fix unit tests for Databricks transform pipelines using pure DataFrame-in/out functions, in-memory PySpark DataFrames, pytest fixtures, and no catalog access. Use when creating or debugging tests for Silver/Gold transform code or ingestion wrappers. Do not use for integration tests that require a running Databricks cluster."
---

# Databricks Unit Testing

## When to Use This Skill

Use when writing or fixing unit tests for Silver/Gold transform code, ingestion wrappers, or any Databricks pipeline module that processes DataFrames. Pair with `$databricks-pipelines` when transform logic is also being changed.

## Core Principles

1. **Pure transform functions** — transform logic lives in DataFrame-in, DataFrame-out functions. No I/O inside these functions.
2. **Thin entrypoint wrappers** — production entrypoints (`run()`, `build()`) only: resolve FQNs -> `spark.read.table` -> call pure function -> write table -> log. No transform logic in wrappers.
3. **No catalog in unit tests** — do not use `saveAsTable`, `read.table`, or test catalog setup. Build inputs with `spark.createDataFrame([Row(...), ...])`, call the pure function, assert on the returned DataFrame.
4. **Wrapper tests via mocks** — to verify entrypoint orchestration, mock `spark.read.table`, patch the pure function to return a controlled DataFrame, and assert `write.saveAsTable` was called with the expected table name and mode.
5. **One pure function per output** — for multi-output modules, expose one pure function per output. The `build()` wrapper reads once and calls each. This simplifies tests and future additions.

## Implementation Checklist

### When adding or changing transform logic

- [ ] Extract or preserve a **pure function** that takes input DataFrame(s) and returns the output DataFrame. Keep mapping/dedup/unpivot logic inside this function.
- [ ] Keep the **entrypoint** (e.g. `run()`, `build()`) as: read table(s) -> call pure function(df) -> write result table -> log.
- [ ] If the module has multiple outputs, use one pure function per output (`build_dim_<name>(dedup_df)` pattern); document that new dimensions add a function and a write in `build()`.

### When writing or updating transform unit tests

- [ ] **Pure-function tests:** Construct input with `spark.createDataFrame([Row(...), ...])`. Call the pure function. Assert on the returned DataFrame: column names, row count, key column values, null handling, schema types (e.g. `_created_ts` is timestamp). For timestamp columns, assert presence/type, not exact value, to avoid flakiness.
- [ ] **No catalog in unit tests:** Do not use `saveAsTable`, `read.table`, or test catalog/schema setup in transform unit tests.
- [ ] **Wrapper tests (optional but recommended):** Add a test that mocks `read.table` and the pure function, calls the entrypoint, and asserts `write.saveAsTable` was invoked with the correct table name and mode.
- [ ] **Entrypoint/chain tests:** For orchestration (e.g. `daily_transforms.run()`), use monkeypatches on `standardize.run`, `dedup.run`, mart `build()`, and assert they were called in the expected order; do not materialize tables in the test.

### Test harness (conftest)

- [ ] Provide a **session-scoped `spark` fixture** (e.g. Databricks Connect) for `createDataFrame` in tests.
- [ ] If some tests still need a catalog (e.g. integration), keep that scope separate; transform **unit** tests should remain in-memory only.

## Process

### 1. Understand the Module

Read the source file(s) to identify:
- Pure transform functions and their DataFrame input/output signatures
- Entrypoint wrappers (`run()`, `build()`) and what they orchestrate
- Column names, expected output schema, null and deduplication behavior

### 2. Review Existing Tests

Read `tests/unit/` and `tests/conftest.py` to match:
- Session-scoped `spark` fixture (Databricks Connect)
- File naming: `tests/unit/test_<module>.py`
- Test naming: `test_<function>_<condition>_<expected>`

### 3. Write Tests

**Pure-function tests:**

```python
import pytest
from pyspark.sql import Row

from src.<module>.<file> import <pure_function>


def test_function_returns_expected_output(spark):
    # Arrange
    input_df = spark.createDataFrame(
        [Row(field_a="value", field_b=1)],
        schema="field_a STRING, field_b INT",
    )
    # Act
    result_df = pure_function(input_df)
    # Assert
    assert result_df.count() == 1
    assert set(result_df.columns) == {"expected_col_a", "expected_col_b"}
    row = result_df.collect()[0]
    assert row["expected_col_a"] == "expected_value"


def test_function_handles_empty_input(spark):
    empty_df = spark.createDataFrame([], schema="field_a STRING, field_b INT")
    result_df = pure_function(empty_df)
    assert result_df.count() == 0
    assert set(result_df.columns) == {"expected_col_a", "expected_col_b"}
```

**Wrapper tests (mock-based):**

```python
from unittest.mock import patch

def test_run_reads_and_writes_correct_tables(spark):
    mock_df = spark.createDataFrame([Row(col="val")], schema="col STRING")
    with patch("src.<module>.spark") as mock_spark:
        mock_spark.read.table.return_value = mock_df
        with patch("src.<module>.pure_function", return_value=mock_df) as mock_fn:
            from src.<module> import run
            run()
            mock_fn.assert_called_once_with(mock_df)
            mock_spark.createDataFrame().write.saveAsTable.assert_called_with(
                "<expected_table>", mode="overwrite"
            )
```

**Timestamp assertions:** assert presence and type (`isinstance(val, datetime)`), not exact value.

### 4. Coverage Requirements

Every test file must cover:
- Normal input: expected output columns, row count, and key column values
- Empty input: returns empty DataFrame with the correct schema
- Null handling: nulls are propagated, coalesced, or rejected as the logic requires
- Wrapper orchestration: entrypoint reads from the correct table and writes to the correct target

### 5. Run and Verify

Run `pytest tests/unit/ -q` (the exact runner may vary per project, e.g. `uv run pytest ...`). Fix all failures before marking generation complete.

## Safety Guards

- Do not use `saveAsTable`, `read.table`, or any catalog access in unit test bodies
- Do not set up test catalog schemas or tables
- Each test must run in isolation via the session-scoped `spark` fixture
- If a test is correct but production code has a genuine bug, mark with `pytest.mark.skip(reason="...")` — never change test expectations to mask real bugs

## References

- Medallion layer rules: $databricks-medallion
- Quality checks: `ruff format --check .`, `ruff check .`, `pytest -q`
