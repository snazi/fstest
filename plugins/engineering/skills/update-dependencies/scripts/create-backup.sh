#!/bin/bash
# Create backup of dependency files

set -e

BACKUP_DIR="${1:-/tmp/dependency_updates_$(date +%Y%m%d_%H%M%S)/backup}"

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_info "Creating backup in $BACKUP_DIR..."

mkdir -p "$BACKUP_DIR"

# Backup Python dependency files
find app -name "pyproject.toml" -o -name "uv.lock" | \
    grep -v node_modules | while read file; do
    mkdir -p "$BACKUP_DIR/$(dirname $file)"
    cp "$file" "$BACKUP_DIR/$file"
done

# Backup Node.js dependency files
find app -name "package.json" -o -name "package-lock.json" | \
    grep -v node_modules | while read file; do
    mkdir -p "$BACKUP_DIR/$(dirname $file)"
    cp "$file" "$BACKUP_DIR/$file"
done

FILE_COUNT=$(find "$BACKUP_DIR" -type f | wc -l)
log_info "Backed up $FILE_COUNT files"
log_info "Backup complete: $BACKUP_DIR"

echo "$BACKUP_DIR"
