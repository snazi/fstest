---
name: dagster-best-practices
description: "Dagster best practices for implementing data orchestration pipelines, assets, jobs, ops, resources, and configuration. Covers DynamicOut fan-out, ConfigurableResource, ABC contracts, and idempotent operations. Use when working with Dagster pipeline code, job definitions, or resource configuration. Do not use for Airflow, Prefect, or non-Dagster orchestrators."
---

## Core Principles

- Keep architecture boundaries clear: `jobs` orchestrate, `ops` transform, `resources` wrap external systems, and `settings` own configuration.
- Prefer explicit, strongly typed, deterministic code.
- Keep operations idempotent and safe to retry.
- Follow existing local patterns before introducing new abstractions.

## Imports and Module Layout

- Keep orchestration files thin (`src/jobs/**`, `src/definitions.py`); place reusable logic in `src/ops/**` and `src/utils/**`.

## Dagster Patterns

- Use `@op` for pipeline steps and declare `required_resource_keys`, `ins`, `out`, and tags when needed.
- If an op uses resources, accept `context` as the first argument.
- Prefer `DynamicOut`/`DynamicOutput` with `.map()` for fan-out parallel orchestration.
- Use `ConfigurableResource` with typed fields for runtime config.
- Use `ABC` contracts when multiple resource implementations are expected.

## Error Handling

- Catch exceptions at operation and external I/O boundaries, log context, and fail/continue intentionally based on pipeline semantics.

## Example

```python
# BAD
@op
def parse_docs(paths):
    print("Parsing documents")
    return do_parse(paths)

# GOOD
@op(required_resource_keys={"config_resource"})
def parse_docs(context, paths: list[str]) -> list[dict]:
    logger.info("Parsing documents", instance_name="dagster-docs-parse")
    return do_parse(paths)
```
