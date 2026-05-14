#!/bin/bash
# Verify all services after updates

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

log_info "Verifying Python services..."

# Verify Python services
if [ -z "$PYTHON_SERVICES" ]; then
    PYTHON_SERVICES=$(find "$SERVICE_ROOT" -mindepth 1 -maxdepth 1 -type d -exec test -f "{}/pyproject.toml" \; -print | sed "s#^$SERVICE_ROOT/##" | tr '\n' ' ')
fi
for service in $PYTHON_SERVICES; do
    if [ -d "$SERVICE_ROOT/$service" ]; then
        cd "$SERVICE_ROOT/$service"

        if uv run python -c "import sys; sys.exit(0)" 2>/dev/null; then
            log_info "✅ $service: environment OK"
        else
            log_error "❌ $service: environment check failed"
            EXIT_CODE=1
        fi

        cd "$REPO_ROOT"
    fi
done

# Verify frontend
if [ -d "$FRONTEND_DIR" ]; then
    log_info "Verifying frontend build..."
    cd "$FRONTEND_DIR"

    if [ -z "$SKIP_BUILD" ]; then
        if npm run build &>/dev/null; then
            log_info "✅ Frontend: build OK"
        else
            log_error "❌ Frontend: build failed"
            EXIT_CODE=1
        fi
    else
        log_info "⏭  Frontend: build skipped"
    fi

    cd "$REPO_ROOT"
fi

if [ $EXIT_CODE -eq 0 ]; then
    log_info "✅ All services verified"
else
    log_error "❌ Some verification checks failed"
fi

exit $EXIT_CODE
