---
name: verify-services
description: "Verify and test services including health checks, build validation, test suite execution, and service startup verification. Use when checking service health, running test suites, verifying builds, or validating that Python and Node.js services start correctly. Do not use for dependency version management (use update-dependencies instead)."
---

# Verify Services

Verify that services are healthy and tests pass.

## Prerequisites

- Project's prescribed dependency managers installed
- Services to verify are configured

## Script Commands

```bash
# Health check all services
bash scripts/verify-all-updates.sh
bash scripts/verify-all-updates.sh  # SKIP_BUILD=1 for faster checks

# Verify a single Python service
bash scripts/verify-python-service.sh <service-name>

# Verify UI build
bash scripts/verify-ui-build.sh [--prod]

# Run all tests
bash scripts/run-all-tests.sh [--fast] [--fail-fast]

# Run tests for a single service
bash scripts/run-service-tests.sh <service-name> [test-options]
```

## Manual Commands

### Python services

```bash
cd <service-path>

# Check environment
uv run python -c "import sys; print(sys.version)"

# Run all tests
uv run pytest tests/ -v

# Run specific test
uv run pytest tests/test_api.py::test_endpoint -v

# Run with coverage
uv run pytest tests/ --cov=src --cov-report=html
```

### Node.js / UI

```bash
cd <ui-path>

# Build
npm run build

# Run E2E tests (headless)
npm run test:e2e

# Run with visible browser
npm run test:e2e:headed

# Debug mode
npm run test:e2e:debug

# Run specific test file
npm run test:e2e -- <file>.spec.ts
```

## Verification Checklist

Before committing changes:

- [ ] All services load without errors
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] UI builds successfully
- [ ] No new linter errors

## Troubleshooting

### Python environment won't load

```bash
cd <service-path>
rm -rf .venv
uv sync
```

### Tests failing

```bash
# Run with verbose output
uv run pytest tests/ -v --tb=short

# Clear Python cache
find . -type d -name __pycache__ -exec rm -r {} +
```

### UI build fails

```bash
cd <ui-path>
rm -rf node_modules .next
npm install
npm run build
```

### UI E2E tests fail

```bash
# Run in UI mode for debugging
npm run test:e2e:ui

# View trace from failed test
npx playwright show-trace test-results/*/trace.zip
```

## Related Skills

- **$verify-dependency-updates**: Verify dependency version changes specifically
- **$update-dependencies**: Apply dependency updates
