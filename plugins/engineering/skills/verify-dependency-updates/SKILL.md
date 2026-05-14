---
name: verify-dependency-updates
description: "Verify dependency updates were applied correctly by checking package versions, comparing before/after changes, and validating lock file integrity. Use when confirming that dependency version changes took effect after an update. Do not use for applying updates (use update-dependencies instead)."
---

# Verify Dependency Updates

Confirm that dependency updates were applied as expected.

## Prerequisites

- Project's prescribed dependency managers installed
- Updates already applied (or a backup to compare against)

## Script Commands

```bash
# Check installed version of a specific package
bash scripts/check-package-version.sh <service> <package>

# Compare package versions before/after update
bash scripts/compare-versions.sh <backup-dir> [service]
```

## Manual Verification

### Python services

```bash
cd <service-path>

# Check version in lock file
grep -A 3 'name = "<package>"' uv.lock | grep version

# Check runtime version
uv run python -c "import <package>; print(<package>.__version__)"

# Check dependency tree
uv pip show <package>

# Verify lock file integrity
uv sync --check
```

### Node.js

```bash
cd <ui-path>

# Check installed version
npm list <package> --depth=0

# List outdated packages
npm outdated
```

## Quick Workflows

### Verify a specific package was updated

```bash
bash scripts/check-package-version.sh <service> <package>
```

### Compare all versions after an update

```bash
LATEST_BACKUP=$(ls -td /tmp/dependency_updates_*/backup 2>/dev/null | head -1)
bash scripts/compare-versions.sh "$LATEST_BACKUP"
```

### Verify a specific service only

```bash
bash scripts/compare-versions.sh "$LATEST_BACKUP" <service>
```

## Verification Checklist

After dependency updates:

- [ ] Package versions match expected target versions
- [ ] All targeted vulnerabilities resolved
- [ ] No unexpected version changes
- [ ] Lock files updated and committed

## Troubleshooting

### Version not updated

```bash
# Force upgrade
cd <service-path>
uv sync --upgrade-package <package>
```

### Version conflict

```bash
# Check what requires the package
cd <service-path>
uv pip show <package>
grep -B 5 -A 5 "<package>" pyproject.toml
```

### Versions inconsistent across services

Update each affected service individually using the same upgrade command, then verify each one.

## Related Skills

- **dependabot**: Identify which packages need updating
- **$update-dependencies**: Apply the updates
- **$verify-services**: Test service health after updates
