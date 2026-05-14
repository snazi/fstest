#!/bin/bash
# Update a single Python service

set -e

SERVICE="$1"
REPO_ROOT=$(pwd)

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

log_info "Updating service: $SERVICE"

cd "app/$SERVICE"

if [[ "$2" == "--sync-only" ]]; then
    log_info "Syncing dependencies (no upgrade)..."
    uv sync
else
    log_info "Upgrading and syncing dependencies..."
    uv lock --upgrade
    uv sync
fi

log_info "✅ $SERVICE updated successfully"
