# Source Scope Guardrails

This file defines the authoritative extraction and backfill scope boundaries for all configured sources.

## General guardrails

- Extraction code should fail fast on out-of-scope filter values.
- Backfill code should make scope parameters explicit in request builders, logs, and checkpoint metadata.
- Reviewer checks should confirm scope guardrails are preserved in code, tests, and runbooks.

## Defining source-specific guardrails

For each source, document:
- **Scope filters**: required filter parameters and allowed values.
- **Time windows**: backfill time boundaries and incremental watermark fields.
- **Pagination guards**: page size limits and cursor/offset constraints.
- **Out-of-scope**: values or ranges that must be explicitly excluded.

### Template

```
## <Source Name>

- Scope filters: <required filters and allowed values>
- Time window: <backfill boundaries and/or incremental watermark field>
- Pagination guard: <page size and offset constraints>
- Out-of-scope: <explicitly excluded values or ranges>
```

Add project-specific source scope guardrails below this line.

---
