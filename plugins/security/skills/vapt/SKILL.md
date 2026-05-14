---
name: vapt
description: "Run VAPT (Vulnerability Assessment and Penetration Testing) using OWASP ZAP DAST scans via Docker, process results into tiered reports (bronze/silver/gold), analyze vulnerabilities, and guide remediation. Use for dynamic application security testing, web application security scanning, vulnerability triage, and penetration testing workflows. Scope: DAST scanning and vulnerability analysis only -- not static analysis, dependency scanning, or infrastructure security."
---

# VAPT (Vulnerability Assessment and Penetration Testing)

## When to Use This Skill

Use when a team needs to perform Dynamic Application Security Testing (DAST) on a web application — triggering ZAP scans, analyzing scan results, triaging vulnerabilities, or guiding remediation.

## Prerequisites

- Docker installed and running
- Python 3 with `pandas` installed (for report processing)
- Target application must be deployed and accessible via URL

## Script Setup

Before running any commands, read `references/scripts.md` and extract each script to a `scripts/vapt/` directory in the target repository's working directory. Create the directory structure:

```
scripts/vapt/
  run-zap-scan.sh
  zap-automation.yaml
  zap-automation-quick.yaml
  process-zap-report.py
```

Make all `.sh` files executable with `chmod +x scripts/vapt/*.sh`.

## Report Output Directory

All scan artifacts are written to `docs/security-reports/<date>-vapt-<target>/` in the repository root. The `run-zap-scan.sh` script creates this directory automatically. The structure is:

```
docs/security-reports/YYYY-MM-DD-vapt-<target>/
  bronze_zap-report.json          # Raw ZAP output (machine-readable)
  bronze_zap-report-html/         # Raw ZAP output (human-readable)
  output/
    silver_zap-detailed.csv       # Instance-level vulnerability details
    gold_vapt-fill-up.csv         # Summary sheet for triage
  audit-report.md                 # Final findings report (written manually)
```

## Process

### 1. Determine Scan Mode

Ask the user whether they want a **full scan** or a **quick scan**.

| Mode | Ajax Spider | Active Scan | Use When |
|------|-------------|-------------|----------|
| **Full** | 5 min | 60 min max | First scan, comprehensive audit, pre-delivery |
| **Quick** | 3 min | 5 min max | Re-scan after fixes, time-constrained checks |

### 2. Run the DAST Scan

```bash
# Full scan (default) — writes to docs/security-reports/<date>-vapt-<sanitized-target>/
bash scripts/vapt/run-zap-scan.sh <TARGET_URL>

# Quick scan
bash scripts/vapt/run-zap-scan.sh <TARGET_URL> quick
```

The scan creates a dated directory under `docs/security-reports/` and writes:
- `bronze_zap-report.json` — raw ZAP output (machine-readable)
- `bronze_zap-report-html/` — raw ZAP output (human-readable)

Full scans typically take 15-30 minutes. Quick scans take 5-10 minutes.

### 3. Process Reports

```bash
pip install pandas  # if not already installed
python3 scripts/vapt/process-zap-report.py docs/security-reports/<date>-vapt-<target>/bronze_zap-report.json
```

This produces three tiers of reports, all in the same dated directory:

| Tier | File | Purpose |
|------|------|---------|
| Bronze | `bronze_zap-report.json` | Raw ZAP output (machine-readable) |
| Bronze | `bronze_zap-report-html/` | Raw ZAP output (human-readable) |
| Silver | `output/silver_zap-detailed.csv` | Instance-level vulnerability details |
| Gold | `output/gold_vapt-fill-up.csv` | Summary sheet for triage and remediation tracking |

### 4. Analyze Vulnerabilities

Read `output/silver_zap-detailed.csv` and `output/gold_vapt-fill-up.csv` in the report directory to understand the findings.

For each vulnerability, extract:
- **vuln_type** and **vuln_name**: What was found
- **riskdesc** and **riskcode**: Severity (3=High, 2=Medium, 1=Low, 0=Informational)
- **confidence**: How certain ZAP is about the finding
- **description**: What the vulnerability means
- **solution**: Recommended fix from ZAP
- **instance_uri**, **instance_method**, **instance_param**: Where the vulnerability was found
- **instance_attack** and **instance_evidence**: Proof of the vulnerability

Sort and prioritize by risk code descending, then confidence descending.

### 5. Triage and Classify Findings

Apply the following risk policy:

| Risk Level | Action Required |
|------------|----------------|
| Critical / High (riskcode 3) | Must be remediated before delivery |
| Medium (riskcode 2) | Acceptable only with documented compensating control and DevSecOps approval |
| Low (riskcode 1) | Acceptable with compensating control documented in the gold report |
| Informational (riskcode 0) | Document if relevant, no action required |

For each finding, determine if it is:
- **True positive** — a real vulnerability requiring a fix
- **False positive** — flag it in the `Compensating Control` column of `gold_vapt-fill-up.csv` with justification

Cross-reference findings with the [Validation and Fixes sheet](https://docs.google.com/spreadsheets/d/1YL9aK8_4GP0QiU9ZxHciKsvw9GSmeHU2LGWuG5jJafA/) for known resolutions and guidance.

Update `output/gold_vapt-fill-up.csv` in the report directory with compensating controls and false positive justifications as you triage.

### 6. Guide Remediation

For each true positive, provide:
1. A clear explanation of the vulnerability in context of the scanned application
2. The specific endpoint/parameter affected (from instance details)
3. A concrete code fix or configuration change
4. A reference to the OWASP guidance for the vulnerability type

Common vulnerability categories from ZAP scans:
- **Missing security headers** (CSP, X-Frame-Options, HSTS, etc.)
- **Cookie security** (missing Secure/HttpOnly/SameSite flags)
- **Information disclosure** (server version, stack traces, directory listings)
- **Injection flaws** (SQL injection, XSS, command injection)
- **Authentication issues** (weak session management, missing CSRF tokens)

### 7. Re-scan After Fixes

After remediation, re-run the scan to verify fixes:

```bash
bash scripts/vapt/run-zap-scan.sh <TARGET_URL> quick
```

Compare new results against the previous scan to confirm vulnerabilities are resolved.

### 8. Prepare Final Report

Write `audit-report.md` in the report directory with all findings graded by severity (R1-R5), recommendations, and positive security observations.

Update `output/gold_vapt-fill-up.csv` with:
- Compensating controls for accepted risks
- False positive justifications
- Confirmation that critical/high findings are resolved

The full deliverable is the dated directory under `docs/security-reports/` containing the audit report, gold CSV, and bronze HTML report.

## Reference

- **ZAP Documentation**: https://www.zaproxy.org/docs/
- **Validation and Fixes Sheet**: https://docs.google.com/spreadsheets/d/1YL9aK8_4GP0QiU9ZxHciKsvw9GSmeHU2LGWuG5jJafA/
- **Related Skill**: `$dependabot` — for Dependabot/SCA vulnerability analysis (complementary, not overlapping)
