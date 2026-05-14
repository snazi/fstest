#!/bin/bash
# Update all Python and Node.js services

set -e

REPO_ROOT=$(pwd)
BACKUP_DIR="/tmp/dependency_updates_$(date +%Y%m%d_%H%M%S)/backup"
NO_BACKUP=false
SERVICE_ROOT="${SERVICE_ROOT:-app}"
FRONTEND_DIR="${FRONTEND_DIR:-$SERVICE_ROOT/frontend}"
PYTHON_SERVICES="${PYTHON_SERVICES:-}"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Parse arguments
if [[ "$1" == "--no-backup" ]]; then
    NO_BACKUP=true
fi

# Create backup
if [ "$NO_BACKUP" = false ]; then
    log_info "Creating backup..."
    mkdir -p "$BACKUP_DIR"

    find "$SERVICE_ROOT" -name "pyproject.toml" -o -name "uv.lock" -o -name "package.json" -o -name "package-lock.json" | \
        grep -v node_modules | while read file; do
        mkdir -p "$BACKUP_DIR/$(dirname $file)"
        cp "$file" "$BACKUP_DIR/$file"
    done

    log_info "Backup created in $BACKUP_DIR"
fi

# Update Python services
if [ -z "$PYTHON_SERVICES" ]; then
    PYTHON_SERVICES=$(find "$SERVICE_ROOT" -mindepth 1 -maxdepth 1 -type d -exec test -f "{}/pyproject.toml" \; -print | sed "s#^$SERVICE_ROOT/##" | tr '\n' ' ')
fi
for service in $PYTHON_SERVICES; do
    if [ -d "$SERVICE_ROOT/$service" ]; then
        log_info "Updating $service..."
        cd "$SERVICE_ROOT/$service"

        if uv lock --upgrade && uv sync; then
            log_info "✅ $service updated successfully"
        else
            log_error "❌ Failed to update $service"
        fi

        cd "$REPO_ROOT"
    fi
done

# Update Node.js frontend
if [ -d "$FRONTEND_DIR" ]; then
    log_info "Updating frontend..."
    cd "$FRONTEND_DIR"

    if npm update && npm audit fix; then
        log_info "✅ Frontend updated successfully"
    else
        log_warn "⚠️  Frontend update completed with warnings"
    fi

    cd "$REPO_ROOT"
fi

log_info "Update process complete!"
if [ "$NO_BACKUP" = false ]; then
    log_info "Backup location: $BACKUP_DIR"
fi
