#!/bin/bash
# Update a specific package in a service

set -e

SERVICE="$1"
PACKAGE="$2"
VERSION="$3"

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

if [ -z "$SERVICE" ] || [ -z "$PACKAGE" ]; then
    log_error "Usage: $0 <service> <package> [version]"
    exit 1
fi

if [ ! -d "app/$SERVICE" ]; then
    log_error "Service not found: app/$SERVICE"
    exit 1
fi

log_info "Updating $PACKAGE in $SERVICE"

cd "app/$SERVICE"

if [ -n "$VERSION" ]; then
    log_info "Updating to specific version: $VERSION"
    # Note: You may need to manually edit pyproject.toml for specific versions
    uv add "$PACKAGE==$VERSION"
else
    log_info "Updating to latest version"
    uv lock --upgrade-package "$PACKAGE"
fi

uv sync

log_info "✅ $PACKAGE updated in $SERVICE"
