---
name: pytest-unit-testing
description: "Write, structure, and debug Python pytest unit tests using the AAA (Arrange-Act-Assert) pattern, boundary mocking, descriptive naming, parametrize, and fixture-based isolation for fast test suites. Use when writing or fixing unit tests for Python modules, FastAPI services, or utility functions. Do not use for API integration tests (use pytest-api-testing instead) or browser E2E tests."
---

# Pytest Unit Testing

## When to Use This Skill

Use when writing or fixing unit tests for Python modules: FastAPI service code, utility functions, data transformation logic, or standalone Python business logic. Do not use for tests that require a running server or real database — see `$pytest-api-testing` for those.

## Process

### 1. Understand the Module Under Test

Read the target source files and identify:
- Function signatures, return types, and async vs sync behavior
- External dependencies that must be mocked: database sessions, HTTP clients, external APIs, file I/O, time functions
- All business logic paths and error conditions

### 2. Review Existing Tests

Read `tests/unit/` and `tests/conftest.py` to match:
- Naming conventions and file structure in use
- Existing fixtures and mocking strategies already established
- Already-covered scenarios — do not duplicate

### 3. Write Tests

**File placement:** `tests/unit/test_<source_file>.py`

**Naming:** `test_<function>_<condition>_<expected_outcome>`

**Structure (AAA pattern):**

```python
import pytest
from unittest.mock import patch, MagicMock

from src.<module>.<file> import <function_or_class>


@pytest.fixture
def mock_dependency():
    with patch("src.<module>.<file>.<Dependency>") as mock:
        yield mock


def test_function_returns_expected_value(mock_dependency):
    # Arrange
    mock_dependency.return_value = ...
    # Act
    result = function(valid_input)
    # Assert
    assert result == expected


def test_function_raises_on_invalid_input():
    with pytest.raises(ValueError, match="expected message"):
        function(invalid_input)
```

**Mock these:** external API calls, database sessions, file system operations, third-party services, time (`datetime.now`, `time.sleep`).

**Do not mock:** the code under test, pure functions with no side effects, simple data structures.

**Mock at the boundary:** patch at the point of import in the module under test, not at the definition site.

Use `@pytest.mark.parametrize` for similar cases with different inputs — never repeat test bodies.

### 4. Coverage Requirements

Every test file must cover:
- Happy path: valid inputs produce the expected output
- Edge cases: empty inputs, None, boundary values
- Error conditions: exceptions raised on invalid input
- External failures: mocked dependency errors (timeout, bad response, connection error)

### 5. Run and Verify

Run the unit test command (check `Makefile` for the project convention, e.g., `uv run pytest tests/unit/ -q`). Fix all failures before marking generation complete.

## Safety Guards

- Each test must pass in isolation — no shared mutable state between tests
- Do not call real external services, databases, or file system in unit tests
- Do not use `time.sleep` — mock timing dependencies
- If a test is correct but production code has a genuine bug, mark with `pytest.mark.skip(reason="...")` — never change test expectations to mask real bugs
