#!/bin/bash
# Restore from backup

set -e

BACKUP_TIMESTAMP="$1"
BACKUP_DIR="${BACKUP_DIR:-/tmp/dependency_updates_${BACKUP_TIMESTAMP}/backup}"
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

if [ -z "$BACKUP_TIMESTAMP" ]; then
    log_error "Usage: $0 <backup-timestamp>"
    log_info "Available backups:"
    ls -lt /tmp/dependency_updates_*/backup 2>/dev/null || log_info "No backups found"
    exit 1
fi

if [ ! -d "$BACKUP_DIR" ]; then
    log_error "Backup not found: $BACKUP_DIR"
    exit 1
fi

log_warn "This will restore files from: $BACKUP_DIR"
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Restore cancelled"
    exit 0
fi

log_info "Restoring from backup..."

# Restore files
find "$BACKUP_DIR" -type f | while read backup_file; do
    original_file="${backup_file#$BACKUP_DIR/}"
    mkdir -p "$(dirname $original_file)"
    cp "$backup_file" "$original_file"
    log_info "Restored: $original_file"
done

# Resync environments
log_info "Resyncing Python services..."
if [ -z "$PYTHON_SERVICES" ]; then
    PYTHON_SERVICES=$(find "$SERVICE_ROOT" -mindepth 1 -maxdepth 1 -type d -exec test -f "{}/pyproject.toml" \; -print | sed "s#^$SERVICE_ROOT/##" | tr '\n' ' ')
fi
for service in $PYTHON_SERVICES; do
    if [ -d "$SERVICE_ROOT/$service" ]; then
        cd "$SERVICE_ROOT/$service"
        uv sync
        cd ../..
    fi
done

log_info "Reinstalling frontend dependencies..."
if [ -d "$FRONTEND_DIR" ]; then
    cd "$FRONTEND_DIR"
    npm install
    cd ../..
fi

log_info "✅ Restore complete"
