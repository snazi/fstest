#!/bin/bash
# Run all test suites

set -e

REPO_ROOT=$(pwd)
EXIT_CODE=0
SERVICE_ROOT="${SERVICE_ROOT:-app}"
FRONTEND_DIR="${FRONTEND_DIR:-$SERVICE_ROOT/frontend}"
PYTHON_SERVICES="${PYTHON_SERVICES:-}"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Parse options
FAST_MODE=false
FAIL_FAST=false
for arg in "$@"; do
    case $arg in
        --fast) FAST_MODE=true ;;
        --fail-fast) FAIL_FAST=true ;;
    esac
done

log_info "Running test suites..."

# Python services
if [ -z "$PYTHON_SERVICES" ]; then
    PYTHON_SERVICES=$(find "$SERVICE_ROOT" -mindepth 1 -maxdepth 1 -type d -exec test -d "{}/tests" \; -print | sed "s#^$SERVICE_ROOT/##" | tr '\n' ' ')
fi
for service in $PYTHON_SERVICES; do
    if [ -d "$SERVICE_ROOT/$service/tests" ]; then
        log_info "Testing $service..."
        cd "$SERVICE_ROOT/$service"

        LOG_FILE="/tmp/${service}_tests.log"

        if [ "$FAST_MODE" = true ]; then
            uv run pytest tests/unit/ -v --tb=short 2>&1 | tee "$LOG_FILE"
        else
            uv run pytest tests/ -v --tb=short 2>&1 | tee "$LOG_FILE"
        fi

        if [ ${PIPESTATUS[0]} -eq 0 ]; then
            log_info "✅ $service tests passed"
        else
            log_error "❌ $service tests failed (log: $LOG_FILE)"
            EXIT_CODE=1
            if [ "$FAIL_FAST" = true ]; then
                exit $EXIT_CODE
            fi
        fi

        cd "$REPO_ROOT"
    fi
done

# Frontend E2E tests
if [ -d "$FRONTEND_DIR/e2e" ]; then
    log_info "Testing frontend E2E..."
    cd "$FRONTEND_DIR"

    LOG_FILE="/tmp/ui_tests.log"

    if npm run test:e2e 2>&1 | tee "$LOG_FILE"; then
        log_info "✅ Frontend E2E tests passed"
    else
        log_error "❌ Frontend E2E tests failed (log: $LOG_FILE)"
        EXIT_CODE=1
        if [ "$FAIL_FAST" = true ]; then
            exit $EXIT_CODE
        fi
    fi

    cd "$REPO_ROOT"
fi

if [ $EXIT_CODE -eq 0 ]; then
    log_info "✅ All tests passed"
else
    log_error "❌ Some tests failed"
fi

exit $EXIT_CODE
