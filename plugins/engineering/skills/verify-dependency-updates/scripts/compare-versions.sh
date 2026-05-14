#!/bin/bash
# Compare package versions before and after update

set -e

BACKUP_DIR="$1"
SERVICE_FILTER="$2"
SERVICE_ROOT="${SERVICE_ROOT:-app}"
FRONTEND_DIR="${FRONTEND_DIR:-$SERVICE_ROOT/frontend}"
FRONTEND_SERVICE_NAME="${FRONTEND_SERVICE_NAME:-frontend}"
PYTHON_SERVICES="${PYTHON_SERVICES:-}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ -z "$BACKUP_DIR" ]; then
    echo "Usage: $0 <backup-dir> [service-name]"
    exit 1
fi

if [ ! -d "$BACKUP_DIR" ]; then
    echo "Backup directory not found: $BACKUP_DIR"
    exit 1
fi

compare_python_versions() {
    local service=$1
    local backup_lock="$BACKUP_DIR/$SERVICE_ROOT/$service/uv.lock"
    local current_lock="$SERVICE_ROOT/$service/uv.lock"

    if [ ! -f "$backup_lock" ] || [ ! -f "$current_lock" ]; then
        return
    fi

    echo -e "\n=== Version Changes: $service ==="
    echo ""

    # Extract package versions from backup
    grep -A 3 'name = ' "$backup_lock" | grep -E 'name =|version =' | \
        paste -d ' ' - - | sed 's/name = "//g; s/"//g; s/version = //g' | \
        while read pkg version; do
            # Get current version
            current_version=$(grep -A 3 "name = \"$pkg\"" "$current_lock" 2>/dev/null | \
                grep "^version" | cut -d'"' -f2 || echo "removed")

            if [ "$version" != "$current_version" ]; then
                echo -e "${pkg}: ${version} → ${current_version}"
            fi
        done
}

compare_node_versions() {
    local backup_json="$BACKUP_DIR/$FRONTEND_DIR/package.json"
    local current_json="$FRONTEND_DIR/package.json"

    if [ ! -f "$backup_json" ] || [ ! -f "$current_json" ]; then
        return
    fi

    echo -e "\n=== Version Changes: $FRONTEND_SERVICE_NAME ==="
    echo ""

    # Compare package.json versions
    # This is simplified; for full comparison, use jq
    diff <(jq -S '.dependencies' "$backup_json" 2>/dev/null) \
         <(jq -S '.dependencies' "$current_json" 2>/dev/null) || true
}

# Compare services
if [ -n "$SERVICE_FILTER" ]; then
    compare_python_versions "$SERVICE_FILTER"
else
    if [ -z "$PYTHON_SERVICES" ]; then
        PYTHON_SERVICES=$(find "$SERVICE_ROOT" -mindepth 1 -maxdepth 1 -type d -exec test -f "{}/pyproject.toml" \; -print | sed "s#^$SERVICE_ROOT/##" | tr '\n' ' ')
    fi
    for service in $PYTHON_SERVICES; do
        if [ -d "$SERVICE_ROOT/$service" ]; then
            compare_python_versions "$service"
        fi
    done

    if [ -d "$FRONTEND_DIR" ]; then
        compare_node_versions
    fi
fi
