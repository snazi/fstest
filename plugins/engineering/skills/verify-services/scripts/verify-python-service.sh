#!/bin/bash
# Verify a single Python service

set -e

SERVICE="$1"

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
    log_error "Usage: $0 <service-name>"
    exit 1
fi

if [ ! -d "app/$SERVICE" ]; then
    log_error "Service not found: app/$SERVICE"
    exit 1
fi

log_info "Verifying service: $SERVICE"

cd "app/$SERVICE"

# Check lock file
if [ ! -f "uv.lock" ]; then
    log_error "❌ Lock file not found"
    exit 1
fi

# Check environment
if uv run python -c "import sys; print(f'Python {sys.version}')" 2>&1; then
    log_info "✅ Environment OK"
else
    log_error "❌ Environment check failed"
    exit 1
fi

log_info "✅ $SERVICE verified successfully"
