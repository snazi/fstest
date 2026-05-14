---
name: fastapi-best-practices
description: "FastAPI best practices for building Python async REST APIs with Pydantic validation, dependency injection, middleware, streaming responses, and security patterns. Use when working on FastAPI services, route design, or API error handling. Do not use for Django, Flask, or non-Python web frameworks."
---

## FastAPI Development

- Use Pydantic models for all request and response validation.
- Use FastAPI's dependency injection for managing dependencies.
- Organize routes using `APIRouter` with appropriate prefixes and tags.
- Implement streaming responses using FastAPI `StreamingResponse`.
- Implement middleware for cross-cutting concerns (auth, CORS).
- Avoid direct module imports across service boundaries — use HTTP endpoints for inter-service communication.

## Security

- **Input validation** — validate and sanitize all inputs with Pydantic; use parameterized queries (no string concatenation).
- **Auth strategy** — validate authentication up front and fail closed.
- **JWT vs signatures** — use JWT validation for user-facing routes; use digital signature validation for trusted internal routes/service callbacks.

## Error Handling

- Raise `HTTPException` with explicit `status_code` and safe `detail` messages for expected client and domain errors.
- Catch `HTTPException` explicitly in route boundaries and re-raise unchanged.
- Catch broad exceptions only at API boundaries, log structured context, and return a safe `500` response.
- Do not leak stack traces, internal paths, secrets, or raw upstream error payloads to clients.
- Use consistent error response shapes across endpoints to keep client handling predictable.
