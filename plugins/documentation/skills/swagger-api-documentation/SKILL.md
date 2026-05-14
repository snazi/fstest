---
name: swagger-api-documentation
description: "Create and maintain Swagger/OpenAPI API documentation from implementation code. Use for documenting REST endpoints, generating OpenAPI specs, and updating API docs after endpoint changes. Scope: API endpoint documentation only -- not feature docs, architecture docs, or MOPs."
---

# Swagger API Documentation

Produce accurate OpenAPI documentation grounded in the service implementation.

## Scope

Use this skill when asked to:
- Document existing API endpoints
- Update OpenAPI specs after endpoint changes
- Generate endpoint docs for a service

## Workflow

1. Identify target service and endpoints
   - Service root: `<service-root>/`
   - Router/controller files: `<router-path>/`
2. Trace implementation before writing
   - Methods and paths
   - Request params, query params, headers, body
   - Response schemas and status codes
   - Authentication and authorization behavior
3. Write or update docs
   - Save under `docs/apis/<service-name>/`
   - Prefer updating existing docs over creating new ones
4. Validate
   - Paths and methods match implementation exactly
   - Schemas map to real models/types
   - Public vs protected endpoints are explicit

## Output Files

Use one of these unless instructed otherwise:
- `docs/apis/<service-name>/openapi.yaml` — no frontmatter (must be valid OpenAPI)
- `docs/apis/<service-name>/README.md` — must begin with YAML frontmatter:

```yaml
---
name: <service-name>-api
description: <one-sentence description of the API documented in this file>
---
```

- `name`: Use `<service-name>-api` in kebab-case (e.g., `builder-api`, `planner-api`).
- `description`: One sentence summarizing what service or endpoints this document covers.

## Endpoint Requirements

For each endpoint, include:
- Method and path
- Purpose/summary
- Request contract
  - Path parameters
  - Query parameters
  - Headers
  - Request body schema
- Response contract
  - Success responses
  - Known error responses
- Auth requirement
- Code reference path

## OpenAPI Defaults

Use these defaults unless code indicates otherwise:
- `openapi: 3.1.0`
- Global security for protected endpoints
- Endpoint-level overrides for public routes
- Reusable components under `components.schemas`

## Quality Requirements

- Do not invent fields or response codes
- Keep terminology consistent
- Ensure examples are realistic and implementation-aligned
- Call out assumptions and unknowns explicitly
