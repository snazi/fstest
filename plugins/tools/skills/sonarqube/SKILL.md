---
name: sonarqube
description: "Run a local SonarQube server via Docker, scan a repository for security vulnerabilities, bugs, code smells, and security hotspots, export findings to CSV, and remediate critical/high severity issues. Use when the user asks to scan code for vulnerabilities, run static analysis, perform a SonarQube audit, fix SonarQube findings, or assess code quality with SonarQube. Requires Docker and Python 3. This skill does NOT cover other static analysis tools like ESLint, Pylint, or Semgrep."
---

# SonarQube Audit

Use this skill when the user asks to scan a repository for security vulnerabilities, bugs, or hotspots using SonarQube, or when asked to remediate SonarQube findings.

## Prerequisites

- Docker installed and running
- Bash shell
- Python 3

## Script Setup

Before running any commands, read `references/scripts.md` and extract each script to a `scripts/sonarqube/` directory in the target repository's working directory. Create the directory structure:

```
scripts/sonarqube/
  kill-sonarqube.sh
  run-sonarqube-server.sh
  get-sonarqube-token.sh
  validate-sonarqube-token.sh
  setup-python-venv.sh
  run-sonarqube-scan.sh
  get-sonarqube-findings.py
  get-sonarqube-todo.py
  get-sonarqube-findings-for-human.py
  requirements.txt
  output/          (created automatically)
```

Make all `.sh` files executable with `chmod +x scripts/sonarqube/*.sh`.

## Phase 1 — Setup

### 1.1 Kill any existing SonarQube instance

```bash
bash scripts/sonarqube/kill-sonarqube.sh
```

### 1.2 Start SonarQube server

```bash
bash scripts/sonarqube/run-sonarqube-server.sh
```

Waits until SonarQube is healthy at `http://localhost:9000`.

### 1.3 Validate or generate token

```bash
bash scripts/sonarqube/validate-sonarqube-token.sh
```

Writes `SONAR_TOKEN` to `scripts/sonarqube/.secret.sh`. If an existing token is invalid, regenerates it automatically.

### 1.4 Set up Python virtual environment

```bash
bash scripts/sonarqube/setup-python-venv.sh
```

Installs `requests`, `pandas`, `python-dotenv` into a local venv under `scripts/sonarqube/venv/`.

## Phase 2 — Scan and Export

### 2.1 Run the SonarQube scan

Set the project key via environment variable (defaults to the repository directory name):

```bash
SONAR_PROJECT_KEY=my-project bash scripts/sonarqube/run-sonarqube-scan.sh
```

This mounts the repository root into the scanner container. The scan can take up to 20 minutes for large codebases. Wait for `EXECUTION SUCCESS` before proceeding.

**Skip condition:** if a scan was already run recently and the user says to skip, proceed directly to 2.2.

### 2.2 Export findings to CSV

```bash
scripts/sonarqube/venv/bin/python scripts/sonarqube/get-sonarqube-findings.py
```

Writes separate CSV files for bugs, vulnerabilities, and hotspots to `scripts/sonarqube/output/<date>/`.

### 2.3 Generate agent TODO

```bash
scripts/sonarqube/venv/bin/python scripts/sonarqube/get-sonarqube-todo.py
```

Produces a `TODO_<timestamp>.md` file containing critical/high severity findings as a structured JSON payload with:
- **Allowed files** — hard constraint on which files may be modified
- **JSON Parsing Instructions** — how to read the component, location, and message fields

If the output says "no actionable findings", skip Phase 3 and proceed to Phase 4.

### 2.4 Export human-review findings (optional)

```bash
scripts/sonarqube/venv/bin/python scripts/sonarqube/get-sonarqube-findings-for-human.py
```

Exports medium/low severity findings to `scripts/sonarqube/output/<date>/for_human_review/` for manual triage.

## Phase 3 — Remediate Findings

### 3.1 Resolve findings from the TODO file

Use the TODO markdown file from Phase 2.3 as input. For each finding:

1. Read the file at the `component` path.
2. Navigate to the location specified in `location_in_component`.
3. Apply a fix based on the `message` and code context.
4. If the finding is a false positive, suppress it with a `NOSONAR` comment.

**Hard constraint:** only modify files listed in the **Allowed files** section of the TODO file.

### 3.2 Re-scan and verify

After applying fixes:

1. Re-run the scan (Phase 2.1).
2. Re-export findings (Phase 2.2).
3. Report remaining findings to the user.

## Phase 4 — Cleanup

```bash
bash scripts/sonarqube/kill-sonarqube.sh
```

Stops the SonarQube container and removes the Docker network.

## Phase 5 — Documentation

Generate a commit summary file `commit-sonarqube.txt` at the repository root:

```
security: Fix SonarQube findings

Fix [N] major/critical/blocker severity SonarQube issues (bugs/vulnerabilities)
Fix [N] high severity SonarQube hotspots

Addressed SonarQube findings:
- [bug|vulnerability|hotspot][SEVERITY] [File Path]: [Brief description]

Affected services:
- [service]: [N] findings fixed
```

## Configuration

| Variable | Default | Description |
|---|---|---|
| `SONAR_PROJECT_KEY` | Repository directory name | SonarQube project identifier |
| `SONAR_HOST` | `http://localhost:9000` | SonarQube server URL |
| `SONAR_ADMIN_USER` | `admin` | Admin username for token generation |
| `SONAR_ADMIN_PASSWORD` | `admin` | Admin password for token generation |

Override defaults by creating a `.admin.sh` file in `scripts/sonarqube/` (see `references/scripts.md` for the sample).
