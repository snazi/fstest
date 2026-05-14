# Medallion Boundaries

## Bronze (raw only)

Bronze tables follow the pattern `raw.<source>_<entity>`. Define project-specific Bronze tables per the ingestion contracts.

Rules:
- Keep payloads source-faithful; no business logic, no scoring.
- Preserve source timestamps plus `_ingestion_ts` and `_source_file`.
- Schema evolution is allowed.

## Silver (standardize and dedup only)

Silver views and tables follow the patterns `std.<source>` and `dedup.<source>`. Define project-specific Silver objects per the data model.

Rules:
- Standardize names/types and deduplicate only.
- Do not compute business features, scores, or status flags in Silver.
- Dedup precedence: use source-specific recency fields when available, with `_ingestion_ts` as deterministic tie-breaker.

## Gold mart (normalized 3NF)

Mart tables follow the pattern `mart.<entity>`. Define project-specific mart tables per the data model.

Grain and semantics:
- Define grain per entity (e.g., one row per primary key, one row per composite key).
- Event-level tables use event-level grain.
- Dimension tables use entity-level grain.

Rules:
- Preserve normalized reusable entities for downstream outputs.
- Do not emit business scoring or status columns in mart.

## Presentation (business logic only)

Presentation tables contain business logic built **from mart only**.

Rules:
- Presentation grain and output tables are defined by the project's domain requirements.
- Must be built from mart tables only — no direct dependencies on Bronze/Silver objects.
- Feature engineering and business scoring logic belongs here.
