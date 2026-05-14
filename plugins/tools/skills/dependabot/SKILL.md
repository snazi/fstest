---
name: dependabot
description: "End-to-end Dependabot vulnerability remediation workflow — fetch and prioritize GitHub Dependabot security alerts, apply targeted dependency updates, verify fixes, and prepare commits. Use when the user asks to fix Dependabot alerts, remediate dependency vulnerabilities, run a dependency security audit, update insecure packages, or review GitHub security advisories. Handles Python (uv) and Node.js (npm) dependencies. This skill does NOT cover Snyk, Renovate, or non-GitHub dependency scanners."
---

# Dependabot Vulnerability Remediation

Use this skill when the user asks to fix Dependabot alerts, remediate security vulnerabilities in dependencies, or run a dependency security audit.

## Required Skills

This skill orchestrates two sub-skills for applying and verifying updates. Load each before using its commands:

| Skill | Purpose |
|---|---|
| **update-dependencies** | Apply security updates across services |
| **verify-dependency-updates** | Confirm versions changed as expected |

## Script Setup

Before running the discovery pipeline in Phase 1, read `references/scripts.md` and extract each script to a `scripts/analyze-vulnerabilities/` directory in the target repository's working directory. Make all `.sh` files executable with `chmod +x scripts/analyze-vulnerabilities/*.sh`.

## Phase 1 — Discovery and Analysis

### 1.1 Fetch and analyze vulnerabilities

Run the vulnerability analysis pipeline using the extracted scripts:

1. `scripts/analyze-vulnerabilities/fetch-alerts.sh` — pull Dependabot alerts from GitHub
2. `python3 scripts/analyze-vulnerabilities/filter-alerts.py alerts.json > filtered.json` — keep only critical/high severity, open state
3. `python3 scripts/analyze-vulnerabilities/generate-summary.py filtered.json` — human-readable report
4. `cat filtered.json | python3 scripts/analyze-vulnerabilities/prioritize-vulnerabilities.py` — rank by EPSS score and risk
5. `python3 scripts/analyze-vulnerabilities/generate-update-plan.py filtered.json` — actionable plan with target versions

### 1.2 Present findings to the user

Report:
- Number of critical and high severity vulnerabilities
- Affected packages and which services use them
- CVE details and whether patches are available
- Prioritized list by risk score

## Phase 2 — Remediation Planning

### 2.1 Review the update plan

For each affected package, determine:
- Which services are affected
- Whether a patch is available
- Whether a major version bump is required (breaking change risk)

### 2.2 Select update strategy

| Strategy | When to use |
|---|---|
| **Targeted** (single package) | One package, low risk, business-critical service |
| **Service-level** (all packages in one service) | Multiple vulnerabilities in one service, patches available |
| **Full** (all services) | Multiple services affected, all patches available, dev/test environment |

### 2.3 Stop and ask when

- No patch available for a critical vulnerability
- Major version update required (e.g. 2.x → 3.x)
- Known breaking changes in release notes
- Version conflicts that cannot be auto-resolved

Proceed automatically when patches are available, only minor/patch updates are needed, and release notes show no breaking changes.

## Phase 3 — Apply Updates

### 3.1 Create backup

Load the **update-dependencies** skill. Always create a backup first:

```bash
bash scripts/update-dependencies/create-backup.sh
```

### 3.2 Apply updates

Choose the appropriate command based on the strategy from Phase 2.2:

- **All services:** `bash scripts/update-dependencies/update-all-services.sh`
- **Single Python service:** `bash scripts/update-dependencies/update-python-service.sh <service>`
- **Single package:** `bash scripts/update-dependencies/update-specific-package.sh <service> <package> [version]`
- **UI dependencies:** `bash scripts/update-dependencies/update-ui-dependencies.sh`

### Manual fallback commands

**Python (uv):**
```bash
cd <service-path> && uv lock --upgrade-package <package> && uv sync
```

**Node.js (npm):**
```bash
cd <ui-path> && npm update && npm audit fix
```

## Phase 4 — Verification

### 4.1 Verify package versions

Load the **verify-dependency-updates** skill:

```bash
bash scripts/verify-dependency-updates/check-package-version.sh <service> <package>
bash scripts/verify-dependency-updates/compare-versions.sh <backup-dir> [service]
```

### 4.2 Re-fetch alerts

Run `scripts/analyze-vulnerabilities/fetch-alerts.sh` again and compare against the original alert set to confirm vulnerabilities are resolved.

### 4.3 If updates fail

1. Restore from backup: `bash scripts/update-dependencies/restore-backup.sh <timestamp>`
2. Try incremental approach — update one service or package at a time
3. If tests fail or service won't start, restore and ask the user for guidance

## Phase 5 — Documentation and Commit

Generate a commit summary file `commit-dependabot.txt` at the repository root:

```
security: Fix [N] critical/high severity vulnerabilities

Addressed Dependabot alerts:
- [SEVERITY] [Package]: [CVE] - [Brief description]

Updated packages:
- [package]: [old] → [new] (in [services])

Affected services:
- [service]: [N] vulnerabilities fixed

Backup: [backup location]
```

## Handoff

Report to the user:

1. How many vulnerabilities were found and how many were fixed.
2. Which packages were updated and to which versions.
3. Any remaining alerts that could not be auto-remediated.
4. Backup location for rollback if needed.
5. The commit summary file path.
