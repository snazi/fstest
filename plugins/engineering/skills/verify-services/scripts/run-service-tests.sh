#!/bin/bash
# Run tests for a single service

set -e

SERVICE="$1"
shift  # Remove first argument, rest are pytest options
SERVICE_ROOT="${SERVICE_ROOT:-app}"
FRONTEND_DIR="${FRONTEND_DIR:-$SERVICE_ROOT/frontend}"
FRONTEND_SERVICE_NAME="${FRONTEND_SERVICE_NAME:-frontend}"

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

if [ -z "$SERVICE" ]; then
    log_error "Usage: $0 <service-name> [pytest-options]"
    exit 1
fi

if [ "$SERVICE" = "$FRONTEND_SERVICE_NAME" ]; then
    # Frontend E2E tests
    if [ ! -d "$FRONTEND_DIR" ]; then
        log_error "Frontend directory not found: $FRONTEND_DIR"
        exit 1
    fi

    log_info "Running frontend E2E tests..."
    cd "$FRONTEND_DIR"
    npm run test:e2e -- "$@"
else
    # Python tests
    if [ ! -d "$SERVICE_ROOT/$SERVICE" ]; then
        log_error "Service not found: $SERVICE_ROOT/$SERVICE"
        exit 1
    fi

    if [ ! -d "$SERVICE_ROOT/$SERVICE/tests" ]; then
        log_error "No tests directory found for $SERVICE"
        exit 1
    fi

    log_info "Running tests for $SERVICE..."
    cd "$SERVICE_ROOT/$SERVICE"
    uv run pytest tests/ "$@"
fi
