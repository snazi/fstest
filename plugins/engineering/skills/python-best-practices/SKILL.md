---
name: python-best-practices
description: "Python best practices for backend services using uv, ruff, type hints, pytest, FastAPI, async/await, and packaging. Use when writing or reviewing Python service code, setting up Python projects, or improving Python code quality. Do not use for frontend JavaScript/TypeScript projects."
---

You are an expert Python engineer with deep experience in FastAPI, LLM/ML workloads, and data pipelines.

## Technology Stack

- **Python:** 3.12+
- **Dependency management:** `uv`
- **Formatting/linting:** Black, isort, flake8
- **Type hinting:** comprehensive annotations using the `typing` module
- **Testing:** pytest, pytest-asyncio, pytest-cov
- **Web framework:** FastAPI with Uvicorn
- **Async:** async/await throughout

## Code Quality

- Follow PEP 8; favor explicit over implicit — code should clearly communicate its intent.
- Add comprehensive type annotations on all functions, methods, and class members using the `typing` module.
- Docstrings on all functions, methods, and classes — purpose, parameters, return values, exceptions.
- Use `pytest` for testing; `pytest-asyncio` for async code;
- Use `tenacity` for retrying transient failures (LLM APIs, external services).
- Use structured logging with appropriate log levels and context.
- Use `ABC` and `@abstractmethod` for creating abstract classes and methods.

## FastAPI Development

- Use Pydantic models for all request and response validation.
- Use FastAPI's dependency injection for managing dependencies.
- Organize routes using `APIRouter` with appropriate prefixes and tags.
- Implement streaming responses using FastAPI `StreamingResponse`.
- Implement middleware for cross-cutting concerns (auth, CORS).
- Avoid direct module imports across service boundaries — use HTTP endpoints for inter-service communication.

## Error Handling

- Raise `HTTPException` with explicit `status_code` and safe `detail` messages for expected client and domain errors.
- Catch `HTTPException` explicitly in route boundaries and re-raise unchanged.
- Catch broad exceptions only at API boundaries, log structured context, and return a safe `500` response.
- Do not leak stack traces, internal paths, secrets, or raw upstream error payloads to clients.
- Use consistent error response shapes across endpoints to keep client handling predictable.

## Performance

- Use `asyncio.gather(...)` for independent parallel work.
- Use `asyncio.Semaphore(...)` to control external-call concurrency.
- Apply caching strategies (`asyncache`, `cachetools`) where appropriate.
- Design database schemas efficiently and optimize queries.

## Security

- **Input validation** — validate and sanitize all inputs with Pydantic; use parameterized queries (no string concatenation).
- **LLM-specific** — implement prompt injection detection; sanitize inputs before LLM APIs; set token limits and timeouts.
- **Auth strategy** — validate authentication up front and fail closed.
- **JWT vs signatures** — use JWT validation for user-facing routes; use digital signature validation for trusted internal routes/service callbacks.
