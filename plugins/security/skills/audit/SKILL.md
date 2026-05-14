---
name: audit
description: "Run comprehensive security audit: static analysis, dependency vulnerabilities, DAST scanning, license compliance, code review. Do not use for feature implementation."
---

# Audit

Run a comprehensive security audit of the current repository, infrastructure, or application.

## Purpose

Use `$audit` to scan for vulnerabilities across multiple dimensions — static analysis (SonarQube), dependency vulnerabilities (Dependabot), dynamic application testing (DAST), license compliance, and code security review. After the audit, a prioritization review grades findings by severity. Output is a structured audit report with R1-R5 severity ratings.

## Usage

- `$audit` — full audit across all dimensions
- `$audit sonarqube` — run only static analysis
- `$audit dependabot` — run only dependency vulnerability remediation
- `$audit dast` — run only dynamic application security testing
- `$audit license` — run only license compliance
- `$audit code-review` — run only code security review

---

## Phase 1 — Security Audit

If a specific audit type is given as an argument, run only that function. Otherwise run the **Full Audit Workflow** at the bottom of this phase.

### Static Analysis (SonarQube)

Scan the repository with SonarQube to find and fix vulnerabilities, bugs, and security hotspots.

#### 1. Load Skill

Read `$sonarqube`. Follow its phases exactly.

#### 2. Setup and Scan

- Start the SonarQube server via Docker.
- Validate or generate the authentication token.
- Set up the Python virtual environment for the reporting scripts.
- Run the SonarQube scan on the repository. Ask the user for the `SONAR_PROJECT_KEY` if not obvious from the repo name.

#### 3. Triage Findings

- Export findings to CSV.
- Generate the agent TODO file (critical/high severity).
- Generate the human review file (medium/low severity).
- Present a summary: count of bugs, vulnerabilities, and hotspots by severity.

#### 4. Remediate

- Resolve each finding from the TODO file, respecting the **Allowed files** constraint.
- For false positives, suppress with `NOSONAR` and note the reasoning.
- Re-scan and report remaining findings.

#### 5. Cleanup

- Shut down the SonarQube server and Docker network.
- Write `commit-sonarqube.txt` with the remediation summary.

### Dependency Vulnerability Remediation (Dependabot)

Identify and fix critical and high severity dependency vulnerabilities reported by GitHub Dependabot.

#### 1. Load Skills

Read `$dependabot`. It orchestrates two sub-skills:

- `$update-dependencies` — apply updates
- `$verify-dependency-updates` — verify changes

#### 2. Discover and Prioritize

- Fetch Dependabot alerts from GitHub.
- Filter to critical/high severity, open state.
- Rank by EPSS score and risk factors.
- Generate an update plan with target versions.

#### 3. Apply Updates

- Create a backup before any changes.
- Apply targeted updates, starting with the highest-risk packages.
- Stop and ask the user if: no patch is available, a major version bump is required, or tests fail after updates.

#### 4. Verify and Report

- Confirm package versions match expected targets.
- Re-fetch alerts to verify vulnerabilities are resolved.
- Write `commit-dependabot.txt` with the remediation summary.

### Dynamic Application Security Testing (DAST)

Run dynamic security scans against a running application using OWASP ZAP.

#### 1. Load Skill

Read `$vapt`. Follow its process for DAST scanning.

#### 2. Confirm Target

Ask the user for:

- The target application URL (local dev server or staging environment).
- Whether authentication is required and how to obtain a session.
- Any paths or endpoints to include or exclude from scanning.

#### 3. Scan and Report

- Run the DAST scan following the VAPT skill process.
- Analyze results and categorize findings by severity.
- Guide remediation for confirmed vulnerabilities.

### License Compliance Audit

Verify that all project dependencies use licenses compatible with proprietary client delivery.

#### 1. Load Skill

Read `$license-audit`. Apply its classification tables and rubric.

#### 2. Scan Dependencies

- Identify all dependency manifests in the repository (lockfiles for Python, Node.js, Go, Rust, etc.).
- Classify each dependency's license against the audit rubric.

#### 3. Report Findings

- Flag copyleft (GPL, AGPL, LGPL) or unknown-license packages.
- For each flagged package, suggest a permissive alternative.
- Write `commit-license.txt` with findings and recommendations.

### Code Security Review

Review the codebase for security issues that static analysis tools may miss — hardcoded secrets, auth/authz gaps, injection vectors, and insecure patterns.

#### 1. Load Skill

Read `$code-review`. Apply the security-focused sections of its review schema.

#### 2. Review Scope

Determine what to review:

- If the user specifies files or a branch diff, review those.
- If running as part of a full audit, review files flagged by other functions (SonarQube, Dependabot) plus any security-sensitive paths: authentication, authorization, API routes, middleware, environment configuration.

#### 3. Check For

- Hardcoded secrets, API keys, or credentials in source or config files.
- Missing or incomplete authentication and authorization checks.
- Input validation gaps at system boundaries (user input, external APIs).
- SQL injection, XSS, command injection, and other OWASP Top 10 vectors.
- PII or sensitive data in logs or error messages.
- Insecure cryptographic practices or deprecated algorithms.

#### 4. Report Findings

Report all findings using the severity schema from the code-review skill (`R1` through `R5`). Be specific and actionable in recommendations.

### Full Audit Workflow

When running all functions together, follow this order:

1. **Static Analysis** and **Dependency Remediation** — run these first (they can run in parallel if the tooling supports it).
2. **DAST** — run after code fixes from step 1 are applied, so the scan reflects the remediated state.
3. **License Compliance** — runs independently of the others.
4. **Code Security Review** — run last, incorporating context from all previous findings.

After all functions complete, produce a consolidated `commit-audit.txt` at the repository root:

```
=== Test Status ===
[Run project tests and report pass/fail status]

=== Dependabot ===
[commit-dependabot.txt content]

=== SonarQube ===
[commit-sonarqube.txt content]

=== License ===
[commit-license.txt content]

=== DAST ===
[Summary of DAST findings, or "Skipped" if no running app was available]

=== Code Review ===
[Summary of manual review findings by severity]
```

Collect all findings from each audit function. Each finding must include: source (SonarQube / Dependabot / DAST / License / Code Review), affected file or resource, description, and a preliminary severity.

---

## Phase 2 — Prioritization Review

Load `$code-review` for the shared severity schema. Assess each finding in the context of:

- Business impact and exploitability
- Whether the affected code is in a critical path
- Effort to remediate vs risk of deferring
- Dependencies between findings (fixing one may resolve others)

Propose severity adjustments with reasoning. Then make the **final severity decision** for each finding:

- **R1** (critical) — must fix before merge or deploy
- **R2** (high) — should fix in this cycle
- **R3** (medium) — fix when convenient, moderate risk to defer
- **R4** (low) — minor improvement, low risk to defer
- **R5** (informational) — noted for awareness, no action required

---

## Phase 3 — Audit Report

Write `audit-report.md` at the repository root with this structure:

```markdown
# Security Audit Report

**Date:** YYYY-MM-DD
**Scope:** [full / specific audit type]
**Repository:** [repo name]

## Summary

| Severity | Count | Description |
|----------|-------|-------------|
| R1 | N | Critical — must fix |
| R2 | N | High — fix this cycle |
| R3 | N | Medium — defer with moderate risk |
| R4 | N | Low — minor, defer safely |
| R5 | N | Informational — no action required |

## Findings

### R1 — Critical

#### Finding 1: [title]
- **Source:** [SonarQube / Dependabot / DAST / License / Code Review]
- **File/Resource:** [path or identifier]
- **Description:** [what the issue is]
- **Recommendation:** [how to fix]
- **Prioritization note:** [reasoning, if any adjustment was discussed]

### R2 — High
...

### R3 — Medium
...

### R4 — Low
...

### R5 — Informational
...

## Per-Function Summaries

### Static Analysis (SonarQube)
[Summary or "Skipped"]

### Dependency Vulnerabilities (Dependabot)
[Summary or "Skipped"]

### DAST
[Summary or "Skipped — no running application target"]

### License Compliance
[Summary or "Skipped"]

### Code Security Review
[Summary or "Skipped"]
```

Tell the user the report file path and the finding counts by severity.

---

## Phase 4 — Remediation Offer

Ask the user:
> "The audit found **N** R1 and **M** R2 findings. Would you like to create a remediation plan via `$plan`? (Default: no — the report is the deliverable.)"

If the user says yes, invoke `$plan` with the R1 and R2 findings as the input user story. If the user says no or does not respond, end here. The audit report is the final deliverable.

## Constraints

- Do not skip any audit function during a full audit unless a prerequisite is unavailable (e.g., DAST requires a running application — skip gracefully and note "Skipped" in the report).
- The security auditor perspective has **final authority** on severity classification. The prioritization review provides input but does not override.
- Do not automatically fix any findings. Remediation only happens if the user explicitly opts in via `$plan`.
- All findings must use the R1-R5 severity schema from the code-review skill.
- Do not commit, push, or modify source files as part of the audit itself — the audit is read-only by default.
