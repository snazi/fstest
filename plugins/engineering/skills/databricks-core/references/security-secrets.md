# Security and Secrets

## Secret scope contract

- Never commit API keys, tokens, or credentials.
- Use a Databricks secret scope for source credentials.
- Pipeline script access pattern:
  - `dbutils.secrets.get(scope="<scope-name>", key="<key-name>")`
- Use environment secret stores for CI/CD workflows.

## Key management

- Define required secret keys per source in the ingestion contracts.
- Hardening path: move to cloud key vault-backed secret scope if required.

## Data handling

- Treat user/profile attributes as sensitive.
- Avoid logging PII payloads or full raw records.
- Redact sensitive values in debug outputs and review comments.

## Access and boundary

- Keep data processing within the project's managed cloud/Databricks boundaries.
