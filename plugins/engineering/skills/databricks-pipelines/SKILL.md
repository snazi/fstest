---
name: databricks-pipelines
description: "Develop Lakeflow Spark Declarative Pipelines (formerly Delta Live Tables / DLT) on Databricks for batch and streaming data pipelines. Covers streaming tables, materialized views, temporary views, Auto Loader, Auto CDC, expectations, sinks, and append flows using Python or SQL. Use when building or modifying Databricks pipeline code. Do not use for general PySpark or non-pipeline Databricks tasks."
---

# Lakeflow Spark Declarative Pipelines Development

**FIRST**: Use the parent `$databricks-core` skill for CLI basics, authentication, profile selection, and data discovery commands.

## Decision Tree

Use this tree to determine which dataset type and features to use. Multiple features can apply to the same dataset — e.g., a Streaming Table can use Auto Loader for ingestion, Append Flows for fan-in, and Expectations for data quality. Choose the dataset type first, then layer on applicable features.

```
User request -> What kind of output?
+-- Intermediate/reusable logic (not persisted) -> Temporary View
|   +-- Preprocessing/filtering before Auto CDC -> Temporary View feeding CDC flow
|   +-- Shared intermediate streaming logic reused by multiple downstream tables
|   +-- Pipeline-private helper logic (not published to catalog)
|   +-- Published to UC for external queries -> Persistent View (SQL only)
+-- Persisted dataset
|   +-- Source is streaming/incremental/continuously growing -> Streaming Table
|   |   +-- File ingestion (cloud storage, Volumes) -> Auto Loader
|   |   +-- Message bus (Kafka, Kinesis, Pub/Sub, Pulsar, Event Hubs) -> streaming source read
|   |   +-- Existing streaming/Delta table -> streaming read from table
|   |   +-- CDC / upserts / track changes / keep latest per key / SCD Type 1 or 2 -> Auto CDC
|   |   +-- Multiple sources into one table -> Append Flows (NOT union)
|   |   +-- Historical backfill + live stream -> one-time Append Flow + regular flow
|   |   +-- Windowed aggregation with watermark -> stateful streaming
|   +-- Source is batch/historical/full scan -> Materialized View
|       +-- Aggregation/join across full dataset (GROUP BY, SUM, COUNT, etc.)
|       +-- Gold layer aggregation from streaming table -> MV with batch read (spark.read / no STREAM)
|       +-- JDBC/Federation/external batch sources
|       +-- Small static file load (reference data, no streaming read)
+-- Output to external system (Python only) -> Sink
|   +-- Existing external table not managed by this pipeline -> Sink with format="delta"
|   +-- Kafka / Event Hubs -> Sink with format="kafka" + @dp.append_flow(target="sink_name")
|   +-- Custom destination not natively supported -> Sink with custom format
|   +-- Custom merge/upsert logic per batch -> ForEachBatch Sink (Public Preview)
|   +-- Multiple destinations per batch -> ForEachBatch Sink (Public Preview)
+-- Data quality constraints -> Expectations (on any dataset type)
```

## Common Traps

- **"Create a table"** without specifying type -> ask whether the source is streaming or batch
- **Materialized View from streaming source** is an error -> use a Streaming Table instead, or switch to a batch read
- **Streaming Table from batch source** is an error -> use a Materialized View instead, or switch to a streaming read
- **Aggregation over streaming table** -> use a Materialized View with batch read (`spark.read.table` / `SELECT FROM` without `STREAM`), NOT a Streaming Table. This is the correct pattern for Gold layer aggregation.
- **Aggregation over batch/historical data** -> use a Materialized View, not a Streaming Table. MVs recompute or incrementally refresh aggregates to stay correct; STs are append-only and don't recompute when source data changes.
- **Preprocessing before Auto CDC** -> use a Temporary View to filter/transform the source before feeding into the CDC flow. SQL: the CDC flow reads from the view via `STREAM(view_name)`. Python: use `spark.readStream.table("view_name")`.
- **Intermediate logic -> default to Temporary View** -> Use a Temporary View for intermediate/preprocessing logic, even when reused by multiple downstream tables. Only consider a Private MV/ST (`private=True` / `CREATE PRIVATE ...`) when the computation is expensive and materializing once would save significant reprocessing.
- **View vs Temporary View** -> Persistent Views publish to Unity Catalog (SQL only), Temporary Views are pipeline-private
- **Union of streams** -> use multiple Append Flows. Do NOT present UNION as an alternative — it is an anti-pattern for streaming sources.
- **Changing dataset type** -> cannot change ST->MV or MV->ST without manually dropping the existing table first. Full refresh does NOT help. Rename the new dataset instead.
- **SQL `OR REFRESH`** -> Prefer `CREATE OR REFRESH` over bare `CREATE` for SQL dataset definitions. Both work identically, but `OR REFRESH` is the idiomatic convention. For PRIVATE datasets: `CREATE OR REFRESH PRIVATE STREAMING TABLE` / `CREATE OR REFRESH PRIVATE MATERIALIZED VIEW`.
- **Kafka/Event Hubs sink serialization** -> The `value` column is mandatory. Use `to_json(struct(*)) AS value` to serialize the entire row as JSON. Read the sink skill for details.
- **Multi-column sequencing** in Auto CDC -> SQL: `SEQUENCE BY STRUCT(col1, col2)`. Python: `sequence_by=struct("col1", "col2")`. Read the auto-cdc skill for details.
- **Auto CDC supports TRUNCATE** (SCD Type 1 only) -> SQL: `APPLY AS TRUNCATE WHEN condition`. Python: `apply_as_truncates=expr("condition")`. Do NOT say truncate is unsupported.
- **Python-only features** -> Sinks, ForEachBatch Sinks, CDC from snapshots, and custom data sources are Python-only. When the user is working in SQL, explicitly clarify this and suggest switching to Python.
- **MV incremental refresh** -> Materialized Views on **serverless** pipelines support automatic incremental refresh for aggregations. Mention the serverless requirement when discussing incremental refresh.
- **Recommend ONE clear approach** -> Present a single recommended approach. Do NOT present anti-patterns or significantly inferior alternatives — it confuses users. Only mention alternatives if they are genuinely viable for different trade-offs.

## Publishing Modes

Pipelines use a **default catalog and schema** configured in the pipeline settings. All datasets are published there unless overridden.

- **Fully-qualified names**: Use `catalog.schema.table` in the dataset name to write to a different catalog/schema than the pipeline default. The pipeline creates the dataset there directly — no Sink needed.
- **USE CATALOG / USE SCHEMA**: SQL commands that change the current catalog/schema for all subsequent definitions in the same file.
- **LIVE prefix**: Deprecated. Ignored in the default publishing mode.
- When reading or defining datasets within the pipeline, use the dataset name only — do NOT use fully-qualified names unless the pipeline already does so or the user explicitly requests a different target catalog/schema.

## Comprehensive API Reference

**MANDATORY:** Before implementing, editing, or suggesting any code for a feature, you MUST read the linked reference file for that feature. NO exceptions — always look up the reference before writing code.

Some features require reading multiple skills together:

- **Auto Loader** -> also read the streaming-table skill (Auto Loader produces a streaming DataFrame, so the target is a streaming table) and look up format-specific options for the file format being loaded
- **Auto CDC** -> also read the streaming-table skill (Auto CDC always targets a streaming table)
- **Sinks** -> also read the streaming-table skill (sinks use streaming append flows)
- **Expectations** -> also read the corresponding dataset definition skill to ensure constraints are correctly placed

### Dataset Definition APIs

| Feature                    | Python (current)                     | Python (deprecated)                   | SQL (current)                               | SQL (deprecated)              |
| -------------------------- | ------------------------------------ | ------------------------------------- | ------------------------------------------- | ----------------------------- |
| Streaming Table            | `@dp.table()` returning streaming DF | `@dlt.table()` returning streaming DF | `CREATE OR REFRESH STREAMING TABLE`         | `CREATE STREAMING LIVE TABLE` |
| Materialized View          | `@dp.materialized_view()`            | `@dlt.table()` returning batch DF     | `CREATE OR REFRESH MATERIALIZED VIEW`       | `CREATE LIVE TABLE` (batch)   |
| Temporary View             | `@dp.temporary_view()`               | `@dlt.view()`, `@dp.view()`           | `CREATE TEMPORARY VIEW`                     | `CREATE TEMPORARY LIVE VIEW`  |
| Persistent View (UC)       | N/A — SQL only                       | —                                     | `CREATE VIEW`                               | —                             |
| Streaming Table (explicit) | `dp.create_streaming_table()`        | `dlt.create_streaming_table()`        | `CREATE OR REFRESH STREAMING TABLE` (no AS) | —                             |

### Flow and Sink APIs

| Feature                      | Python (current)             | Python (deprecated)           | SQL (current)                          | SQL (deprecated) |
| ---------------------------- | ---------------------------- | ----------------------------- | -------------------------------------- | ---------------- |
| Append Flow                  | `@dp.append_flow()`          | `@dlt.append_flow()`          | `CREATE FLOW ... INSERT INTO`          | —                |
| Backfill Flow                | `@dp.append_flow(once=True)` | `@dlt.append_flow(once=True)` | `CREATE FLOW ... INSERT INTO ... ONCE` | —                |
| Sink (Delta/Kafka/EH/custom) | `dp.create_sink()`           | `dlt.create_sink()`           | N/A — Python only                      | —                |
| ForEachBatch Sink            | `@dp.foreach_batch_sink()`   | —                             | N/A — Python only                      | —                |

### Import / Module APIs

| Current                                           | Deprecated                                                            | Notes                                                                                                  |
| ------------------------------------------------- | --------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| `from pyspark import pipelines as dp`             | `import dlt`                                                          | Both work. Prefer `dp`. Do NOT change existing `dlt` imports.                                          |
| `spark.read.table()` / `spark.readStream.table()` | `dp.read()` / `dp.read_stream()` / `dlt.read()` / `dlt.read_stream()` | Deprecated reads still work. Prefer `spark.*`.                                                         |
| —                                                 | `LIVE.` prefix                                                        | Fully deprecated. NEVER use. Causes errors in newer pipelines.                                         |
| —                                                 | `CREATE LIVE TABLE` / `CREATE LIVE VIEW`                              | Fully deprecated. Use `CREATE STREAMING TABLE` / `CREATE MATERIALIZED VIEW` / `CREATE TEMPORARY VIEW`. |

## Scaffolding a New Pipeline Project

Use `databricks bundle init` with a config file to scaffold non-interactively. This creates a project in the `<project_name>/` directory:

```bash
databricks bundle init lakeflow-pipelines --config-file <(echo '{"project_name": "my_pipeline", "language": "python", "serverless": "yes"}') --profile <PROFILE> < /dev/null
```

## Pipeline Structure

- Follow the medallion architecture pattern (Bronze -> Silver -> Gold) unless the user specifies otherwise
- Use the convention of 1 dataset per file, named after the dataset
- Place transformation files in a `src/` or `transformations/` folder

## Development Workflow

1. **Validate**: `databricks bundle validate --profile <profile>`
2. **Deploy**: `databricks bundle deploy -t dev --profile <profile>`
3. **Run pipeline**: `databricks bundle run <pipeline_name> -t dev --profile <profile>`
4. **Check status**: `databricks pipelines get --pipeline-id <id> --profile <profile>`

## Pipeline API Reference

Detailed reference guides for each pipeline API. **Read the relevant guide before writing pipeline code.**

- [Write Spark Declarative Pipelines](references/write-spark-declarative-pipelines.md)
- [Streaming Tables](references/streaming-table.md) ([Python](references/streaming-table-python.md), [SQL](references/streaming-table-sql.md))
- [Materialized Views](references/materialized-view.md) ([Python](references/materialized-view-python.md), [SQL](references/materialized-view-sql.md))
- [Views](references/view.md) ([SQL](references/view-sql.md))
- [Temporary Views](references/temporary-view.md) ([Python](references/temporary-view-python.md), [SQL](references/temporary-view-sql.md))
- [Auto Loader](references/auto-loader.md) ([Python](references/auto-loader-python.md), [SQL](references/auto-loader-sql.md))
- [Auto CDC](references/auto-cdc.md) ([Python](references/auto-cdc-python.md), [SQL](references/auto-cdc-sql.md))
- [Expectations](references/expectations.md) ([Python](references/expectations-python.md), [SQL](references/expectations-sql.md))
- [Sinks](references/sink.md) ([Python](references/sink-python.md))
- [ForEachBatch Sinks](references/foreach-batch-sink.md) ([Python](references/foreach-batch-sink-python.md))
