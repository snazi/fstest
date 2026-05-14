---
name: update-dependencies
description: "Update Python and Node.js dependencies to remediate vulnerabilities while minimizing regressions. Covers pip, npm, uv package management, security-driven upgrades, backup/restore workflows, and targeted vs blanket updates. Use when applying security fixes or routine dependency upgrades. Do not use for verifying updates (use verify-dependency-updates instead)."
---

# Update Dependencies

Apply dependency updates across services, primarily for security remediation.

## Prerequisites

- Project's prescribed dependency managers installed (e.g., `uv` for Python, `npm` for Node.js)
- Write access to the repository

## Script Commands

- Update all services: `bash scripts/update-all-services.sh`
- Update one service: `bash scripts/update-python-service.sh <service>`
- Update one package: `bash scripts/update-specific-package.sh <service> <package> [version]`
- Update UI dependencies: `bash scripts/update-ui-dependencies.sh [--audit-only]`
- Create backup: `bash scripts/create-backup.sh`
- Restore backup: `bash scripts/restore-backup.sh <backup-timestamp>`

## Recommended Security Workflow

1. Generate an update plan from vulnerability output:
   - Use the `dependabot` skill to identify targets.
2. Create a backup: `bash scripts/create-backup.sh`
3. Start with targeted updates in one service.
4. Verify that service passes tests.
5. Roll out to remaining affected services.
6. Run full verification across all services.

## Manual Fallback Commands

### Python (`uv`)

```bash
# Upgrade all packages in a service
cd <service-path> && uv lock --upgrade && uv sync

# Upgrade a specific package
cd <service-path> && uv lock --upgrade-package <package> && uv sync

# Transitive override (when a direct upgrade isn't possible)
# In pyproject.toml:
# [tool.uv]
# override-dependencies = ["<package>==<version>"]
# Then: uv lock && uv sync
```

### Node.js (`npm`)

```bash
cd <ui-path> && npm update
cd <ui-path> && npm audit fix
# Use --force only when intentionally accepting breaking-change risk
```

## Guardrails

- Prefer targeted, vulnerability-driven updates over blanket upgrades.
- Update and verify one service first, then scale out.
- Keep lockfiles synchronized with manifest changes.
- Commit lockfile updates together with manifest changes.

## Related Skills

- **dependabot**: Identify which packages need updating
- **$verify-services**: Test service health after updates
- **$verify-dependency-updates**: Confirm versions changed as expected
