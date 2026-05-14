#!/bin/bash
# Update UI dependencies

set -e

FRONTEND_DIR="${FRONTEND_DIR:-app/frontend}"

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

if [ ! -d "$FRONTEND_DIR" ]; then
    log_error "Frontend directory not found: $FRONTEND_DIR"
    exit 1
fi

log_info "Updating frontend dependencies..."

cd "$FRONTEND_DIR"

if [[ "$1" == "--audit-only" ]]; then
    log_info "Running npm audit fix only..."
    npm audit fix
else
    log_info "Updating packages..."
    npm update

    log_info "Running npm audit fix..."
    npm audit fix || log_info "npm audit fix completed with warnings"
fi

log_info "✅ Frontend dependencies updated"
