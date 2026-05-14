# Naming Conventions

## Databricks objects

- Catalog pattern: `{project}-{layer}-{environment}`
- Schema: `dev` or `prod` (matching the target)
- Table pattern: `{source}_{entity}` for raw ingestion, domain names for mart/presentation
- Workflow pattern: `{project}_{purpose}`
- Pipeline script pattern: `{layer}_{source}_{action}.py` (use `# %%` cells for notebook-style local execution)

## Examples

- Bronze FQN: `{project}-bronze-{env}.{schema}.{table}`
- Silver FQN: `{project}-silver-{env}.{schema}.{table}`
- Gold FQN: `{project}-gold-{env}.{schema}.{table}`
- Daily workflow: `{project}_daily_ingestion`
- Backfill workflow: `{project}_backfill_{source}`
- Pipeline script: `bronze_{source}_ingest.py`

## Logical layer aliases used in modeling docs

- Raw layer aliases: `raw.*`
- Standardized and dedup aliases: `std.*`, `dedup.*`
- Mart aliases: `mart.*`
- Presentation aliases: `presentation.*`
