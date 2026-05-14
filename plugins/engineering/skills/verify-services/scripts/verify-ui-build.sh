#!/bin/bash
# Verify UI builds successfully

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

log_info "Verifying frontend build..."

cd "$FRONTEND_DIR"

LOG_FILE="/tmp/ui_build_verification.log"

if [[ "$1" == "--prod" ]]; then
    log_info "Running production build..."
    npm run build 2>&1 | tee "$LOG_FILE"
else
    log_info "Running build check..."
    npm run build 2>&1 | tee "$LOG_FILE"
fi

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    log_info "✅ Frontend build successful"
    log_info "Build log: $LOG_FILE"
    exit 0
else
    log_error "❌ Frontend build failed"
    log_error "Check log: $LOG_FILE"
    exit 1
fi
