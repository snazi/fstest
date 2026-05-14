#!/bin/bash
# Check installed version of a package

set -e

SERVICE="$1"
PACKAGE="$2"
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

if [ -z "$SERVICE" ] || [ -z "$PACKAGE" ]; then
    log_error "Usage: $0 <service> <package>"
    exit 1
fi

if [ "$SERVICE" = "$FRONTEND_SERVICE_NAME" ]; then
    # Node.js package
    if [ ! -d "$FRONTEND_DIR" ]; then
        log_error "Frontend directory not found: $FRONTEND_DIR"
        exit 1
    fi

    cd "$FRONTEND_DIR"
    VERSION=$(npm list "$PACKAGE" --depth=0 2>/dev/null | grep "$PACKAGE" | cut -d'@' -f2 || echo "not found")

    echo "Package: $PACKAGE"
    echo "Service: $FRONTEND_SERVICE_NAME"
    echo "Installed version: $VERSION"
else
    # Python package
    if [ ! -d "$SERVICE_ROOT/$SERVICE" ]; then
        log_error "Service not found: $SERVICE_ROOT/$SERVICE"
        exit 1
    fi

    cd "$SERVICE_ROOT/$SERVICE"
    VERSION=$(grep -A 3 "name = \"$PACKAGE\"" uv.lock 2>/dev/null | grep "^version" | cut -d'"' -f2 || echo "not found")

    echo "Package: $PACKAGE"
    echo "Service: $SERVICE"
    echo "Installed version: $VERSION"
    echo "Lock file: $SERVICE_ROOT/$SERVICE/uv.lock"
fi
