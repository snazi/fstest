---
name: pytest-api-testing
description: "Write, structure, and debug FastAPI integration tests using a real TestClient, real test database, and mocked downstream services to verify full HTTP contracts including status codes, response bodies, auth, and validation. Use when writing API integration tests for FastAPI endpoints. Do not use for unit tests (use pytest-unit-testing instead) or browser E2E tests."
---

# Pytest API Testing

## When to Use This Skill

Use when writing integration tests for FastAPI endpoints — tests that exercise real HTTP handlers, real database state, and verify the full response contract (status code, body, side effects). Use for new endpoints, changed behavior, auth failures, and validation edge cases.

## Process

### 1. Understand the Endpoint Under Test

Read the router and handler source files to identify:
- HTTP method, path, and route parameters
- Request schema (Pydantic model or body params)
- Response schema, status codes, and error responses
- Auth/authz requirements (protected vs public)
- Database writes and side effects that must be verified
- Downstream service calls that must be mocked

### 2. Review Existing Integration Tests

Read `tests/integration/` and `tests/conftest.py` to match:
- Test client setup and how to obtain it
- Database fixture pattern in use (transaction rollback or explicit teardown)
- Auth header fixture pattern (`auth_headers`, `test_user`, etc.)
- Existing conventions for mocking downstream HTTP services

### 3. Write Tests

**File placement:** `tests/integration/test_<feature>.py`

**Naming:** `test_<endpoint>_<condition>_<expected_outcome>`

**Structure:**

```python
import pytest


def test_endpoint_returns_expected_response(client, db_session, auth_headers):
    # Arrange
    seed_data = ...
    db_session.add(seed_data)
    db_session.commit()

    # Act
    response = client.post("/endpoint", json={...}, headers=auth_headers)

    # Assert
    assert response.status_code == 200
    assert response.json() == {...}


def test_endpoint_returns_401_when_unauthenticated(client):
    response = client.post("/endpoint", json={...})
    assert response.status_code == 401


def test_endpoint_returns_422_on_missing_field(client, auth_headers):
    response = client.post("/endpoint", json={}, headers=auth_headers)
    assert response.status_code == 422
```

**Use real:** HTTP test client, test database, auth tokens (via fixture).

**Mock:** downstream HTTP services, email/notification services, payment processors, any external I/O not under test.

### 4. Coverage Requirements

Every test file must cover:
- Happy path: valid request produces correct response body and DB side effects
- Auth failure: 401 for unauthenticated, 403 for unauthorized roles
- Validation failure: 422 for malformed or missing required fields
- Not found: 404 when the requested resource does not exist
- Downstream failure: correct error handling when a mocked dependency fails or times out

### 5. Run and Verify

Run the integration test command (check `Makefile`). Fix all failures before marking generation complete.

## Safety Guards

- Never use production databases or real external services directly
- Each test must clean up its own DB state or rely on transaction rollback fixtures — leaking state causes hard-to-debug cascading failures
- Do not change test expectations to mask genuine production bugs; mark with `pytest.mark.skip(reason="...")` until the bug is separately fixed
- Verify DB teardown/rollback is working correctly after each test run
