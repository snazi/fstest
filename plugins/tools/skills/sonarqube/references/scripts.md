# SonarQube Scripts

These scripts power the SonarQube audit skill. Before execution, extract each script to a `scripts/sonarqube/` directory in the target repository's working directory. All script path references in the SKILL.md assume this layout.

### kill-sonarqube.sh

Stops the SonarQube Docker container and network.

```bash
#!/usr/bin/env bash

# terminate sonarqube server, network
docker rm -f sonarqube 2>/dev/null || true
docker network rm sonar-net 2>/dev/null || true
```

### run-sonarqube-server.sh

Starts SonarQube server via Docker, waits until healthy.

```bash
#!/usr/bin/env bash

# create network
docker network create sonar-net 2>/dev/null || true

docker volume create sonarqube_data 2>/dev/null || true
docker volume create sonarqube_extensions 2>/dev/null || true
docker volume create sonarqube_logs 2>/dev/null || true

# run sonarqube server
if [ "$(docker ps -aq -f name=sonarqube)" ]; then
    docker start sonarqube
else
    docker run -d \
      --name sonarqube \
      --network sonar-net \
      -p 9000:9000 \
      -v sonarqube_data:/opt/sonarqube/data \
      -v sonarqube_extensions:/opt/sonarqube/extensions \
      -v sonarqube_logs:/opt/sonarqube/logs \
      sonarqube:lts-community
fi


# wait for sonarqube to be available
MAX_TRIES=100
COUNT=0

until curl -sf http://localhost:9000/api/system/status | grep -q '"status":"UP"'; do
  COUNT=$((COUNT + 1))

  if [ "$COUNT" -ge "$MAX_TRIES" ]; then
    echo "ERROR: SonarQube did not become ready after $MAX_TRIES attempts."
    exit 1
  fi

  echo "waiting for SonarQube... $COUNT/$MAX_TRIES attempts"
  sleep 10
done
echo "SonarQube is UP"
```

### get-sonarqube-token.sh

Generates a SonarQube API token.

```bash
#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Optional admin env file
if [ -f "${SCRIPT_DIR}/.admin.sh" ]; then
  source "${SCRIPT_DIR}/.admin.sh"
  echo "Loaded admin config from .admin.sh"
else
  echo "No .admin.sh found — using defaults"
fi

# Defaults (can be overridden by .admin.sh file)
SONAR_HOST="${SONAR_HOST:-http://localhost:9000}"
SONAR_ADMIN_USER="${SONAR_ADMIN_USER:-admin}"
SONAR_ADMIN_PASSWORD="${SONAR_ADMIN_PASSWORD:-admin}"

SECRET_PATH="${SCRIPT_DIR}/.secret.sh"

# extract sonar token
if [ -f "${SECRET_PATH}" ]; then
  echo "Already an existing SONAR_TOKEN from .secret.sh"
else
    SONAR_TOKEN=$(curl -s -u ${SONAR_ADMIN_USER}:${SONAR_ADMIN_PASSWORD} \
    -X POST "${SONAR_HOST}/api/user_tokens/generate?name=cursor-token" | sed 's/.*"token":"\([^"]*\)".*/\1/')

  if [ -z "$SONAR_TOKEN" ]; then
    echo "Failed to generate SONAR_TOKEN"
    exit 1
  fi

  cat <<EOF > "${SECRET_PATH}"
#!/usr/bin/env bash
export SONAR_TOKEN="$SONAR_TOKEN"
EOF

  chmod 600 "${SECRET_PATH}"

  echo "Generated new SONAR_TOKEN and saved to .secret.sh"

  cat <<EOF > "${SCRIPT_DIR}/.env"
SONAR_TOKEN="$SONAR_TOKEN"
EOF

  echo "Generated new SONAR_TOKEN and saved to .env"

fi
```

### validate-sonarqube-token.sh

Validates or regenerates the token.

```bash
#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Optional admin env file
if [ -f "${SCRIPT_DIR}/.admin.sh" ]; then
  source "${SCRIPT_DIR}/.admin.sh"
  echo "Loaded admin config from .admin.sh"
else
  echo "No .admin.sh found — using defaults"
fi

# Defaults (can be overridden by .admin.sh file)
SONAR_HOST="${SONAR_HOST:-http://localhost:9000}"
SONAR_ADMIN_USER="${SONAR_ADMIN_USER:-admin}"
SONAR_ADMIN_PASSWORD="${SONAR_ADMIN_PASSWORD:-admin}"

SECRET_PATH="${SCRIPT_DIR}/.secret.sh"

if [ ! -f "${SECRET_PATH}" ]; then
  echo "No ${SECRET_PATH} found; generating SONAR_TOKEN"
  "${SCRIPT_DIR}/get-sonarqube-token.sh"
fi

source "${SECRET_PATH}"

if curl -s -u "${SONAR_TOKEN}:" "${SONAR_HOST}/api/authentication/validate" | grep -q '"valid":true'; then
  echo "Token is valid"
else
  echo "Token is invalid"

  echo "Deleting ${SECRET_PATH}"
  rm -f "${SECRET_PATH}"

  echo "Re-running get-sonarqube-token.sh to create a new token"
  "${SCRIPT_DIR}/get-sonarqube-token.sh"

  source "${SECRET_PATH}"
  curl -s -u "${SONAR_TOKEN}:" "${SONAR_HOST}/api/authentication/validate" | grep -q '"valid":true'
  echo "Token is valid"
fi
```

### setup-python-venv.sh

Creates a Python venv with required dependencies.

```bash
#!/usr/bin/env bash

set -e

VENV_DIR="venv"
PYTHON_BIN="python3"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

check_package() {
    local package=$1
    "${SCRIPT_DIR}/${VENV_DIR}/bin/python" -c "import $package" >/dev/null 2>&1
}

recreate_venv() {
    echo "Recreating virtual environment..."

    rm -rf "${SCRIPT_DIR}/${VENV_DIR}"

    $PYTHON_BIN -m venv "${SCRIPT_DIR}/${VENV_DIR}"

    "${SCRIPT_DIR}/${VENV_DIR}/bin/pip" install --upgrade pip

    if [[ -f "${SCRIPT_DIR}/requirements.txt" ]]; then
        echo "Installing from requirements.txt..."
        "${SCRIPT_DIR}/${VENV_DIR}/bin/pip" install -r "${SCRIPT_DIR}/requirements.txt"
    else
        echo "Installing default dependencies (requests, pandas, dotenv)..."
        "${SCRIPT_DIR}/${VENV_DIR}/bin/pip" install requests pandas python-dotenv
    fi

    echo "Virtual environment recreated successfully."
}

if [[ ! -d "${SCRIPT_DIR}/${VENV_DIR}" ]]; then
    echo "Virtual environment not found. Creating..."
    recreate_venv
    exit 0
fi

echo "Checking dependencies in virtual environment..."

MISSING=0

if ! check_package "requests"; then
    echo "Missing dependency: requests"
    MISSING=1
fi

if ! check_package "pandas"; then
    echo "Missing dependency: pandas"
    MISSING=1
fi

if ! check_package "dotenv"; then
    echo "Missing dependency: dotenv"
    MISSING=1
fi

if [[ "$MISSING" -eq 1 ]]; then
    echo "Dependencies missing. Deleting and reinstalling virtual environment..."
    recreate_venv
else
    echo "All required dependencies are installed."
fi
```

### run-sonarqube-scan.sh

Runs the SonarQube scanner against the repo.

```bash
#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Discover repository root by walking up to the nearest .git directory
REPO_ROOT_PATH="$(cd "${SCRIPT_DIR}" && git rev-parse --show-toplevel 2>/dev/null || pwd)"

# Default project key to the repository directory name; override with SONAR_PROJECT_KEY env var
SONAR_PROJECT_KEY="${SONAR_PROJECT_KEY:-$(basename "${REPO_ROOT_PATH}")}"
SONAR_HOST_URL="http://sonarqube:9000"

echo "REPO_ROOT_PATH: ${REPO_ROOT_PATH}"
echo "SONAR_PROJECT_KEY: ${SONAR_PROJECT_KEY}"

source "${SCRIPT_DIR}/.secret.sh"
if [[ -z "${SONAR_TOKEN:-}" ]]; then
  echo "SONAR_TOKEN is not set"
  exit 1
fi

echo "Starting SonarQube scan..."

# Build a list of common directories to exclude from the scan volume
EXCLUDE_VOLUMES=""
for dir in .git node_modules .next .ruff_cache venv .venv __pycache__; do
  if [ -d "${REPO_ROOT_PATH}/${dir}" ]; then
    EXCLUDE_VOLUMES="${EXCLUDE_VOLUMES} -v /usr/src/${dir}"
  fi
done

# Also exclude nested venvs one level deep
for nested_venv in "${REPO_ROOT_PATH}"/*/.venv "${REPO_ROOT_PATH}"/*/node_modules "${REPO_ROOT_PATH}"/*/.next; do
  if [ -d "${nested_venv}" ]; then
    rel="${nested_venv#${REPO_ROOT_PATH}/}"
    EXCLUDE_VOLUMES="${EXCLUDE_VOLUMES} -v /usr/src/${rel}"
  fi
done

# Run scanner
eval docker run \
  --rm \
  --name sonarqube-scan \
  --network=sonar-net \
  -e SONAR_HOST_URL="${SONAR_HOST_URL}" \
  -v "${REPO_ROOT_PATH}:/usr/src" \
  ${EXCLUDE_VOLUMES} \
  sonarsource/sonar-scanner-cli \
  -Dsonar.projectBaseDir="/usr/src" \
  -Dsonar.projectKey="${SONAR_PROJECT_KEY}" \
  -Dsonar.login="${SONAR_TOKEN}"
```

### get-sonarqube-findings.py

Exports findings to CSV.

```python
import base64
import os
import subprocess
from datetime import datetime
from pathlib import Path
from typing import Dict

import requests
import pandas as pd
from dotenv import load_dotenv

_SCRIPT_DIR = Path(__file__).resolve().parent

# Discover repo root via git
try:
    _REPO_ROOT = Path(
        subprocess.check_output(
            ["git", "rev-parse", "--show-toplevel"],
            cwd=_SCRIPT_DIR,
            text=True,
        ).strip()
    )
except (subprocess.CalledProcessError, FileNotFoundError):
    _REPO_ROOT = _SCRIPT_DIR.parent

load_dotenv(dotenv_path=_REPO_ROOT / ".env", override=True)
load_dotenv(dotenv_path=_SCRIPT_DIR / ".env", override=True)

# Configuration — project key defaults to the repo directory name
SONARQUBE_URL = "http://localhost:9000"
PROJECT_KEY = os.getenv("SONAR_PROJECT_KEY", _REPO_ROOT.name)
PAGE_SIZE = 500

_sonar_token_raw = os.getenv("SONAR_TOKEN")
if not _sonar_token_raw:
    raise ValueError("SONAR_TOKEN is not set (check your .env / environment).")
SONAR_TOKEN = base64.b64encode(f"{_sonar_token_raw}:".encode("utf-8")).decode("ascii")

BUG = "ISSUE"
HOTSPOT = "HOTSPOT"
VULNERABILITY = "VULNERABILITY"


def get_sonar(sonar_type: str) -> Dict:
    if sonar_type == BUG:
        pretty_sonar_type = "issues"
    elif sonar_type == HOTSPOT:
        pretty_sonar_type = "hotspots"
    elif sonar_type == VULNERABILITY:
        pretty_sonar_type = "issues"
    else:
        raise Exception(f"Invalid sonar_type: {sonar_type}")

    sonar_data = []
    page = 1
    headers = {"Authorization": f"Basic {SONAR_TOKEN}"}

    while True:
        params = {"projectKey": PROJECT_KEY, "ps": PAGE_SIZE, "p": page}
        if sonar_type == BUG:
            params["types"] = "BUG"
            params["componentKeys"] = PROJECT_KEY
        elif sonar_type == "VULNERABILITY":
            params["types"] = "VULNERABILITY"
            params["componentKeys"] = PROJECT_KEY

        response = requests.get(
            f"{SONARQUBE_URL}/api/{pretty_sonar_type}/search",
            params=params,
            headers=headers,
        )
        if response.status_code != 200:
            print("Failed to fetch data:", response.text)
            break

        data = response.json()
        sonar_data.extend(data.get(pretty_sonar_type, []))

        print(
            f"Fetched page {page}, total {pretty_sonar_type} so far: {len(sonar_data)}"
        )
        if len(data.get(pretty_sonar_type, [])) < PAGE_SIZE:
            break

        page += 1

    return sonar_data


def save_to_csv(sonar_type: str, sonar_data: Dict):
    if sonar_type == BUG:
        name_sub = "bugs"
    elif sonar_type == HOTSPOT:
        name_sub = "hotspots"
    elif sonar_type == VULNERABILITY:
        name_sub = "vulnerabilities"
    else:
        raise Exception(f"Invalid sonar_type: {sonar_type}")

    df = pd.DataFrame(sonar_data)

    today_str = datetime.now().strftime("%Y-%m-%d")
    datetime_str = datetime.now().strftime("%Y-%m-%d_%H:%M:%S.%f")
    filepath_str = (
        f"{_SCRIPT_DIR}/output/{today_str}/scan_{name_sub}_{datetime_str}.csv"
    )

    filepath = Path(filepath_str)
    filepath.parent.mkdir(parents=True, exist_ok=True)

    print(f"Output file at {filepath_str}")
    df.to_csv(filepath_str, index=False)


sonar_data = get_sonar(BUG)
save_to_csv(BUG, sonar_data)

sonar_data = get_sonar(HOTSPOT)
save_to_csv(HOTSPOT, sonar_data)

sonar_data = get_sonar(VULNERABILITY)
save_to_csv(VULNERABILITY, sonar_data)
```

### get-sonarqube-todo.py

Generates a structured TODO for critical/high findings.

```python
import glob
import ast
import json
from pathlib import Path
from datetime import datetime
from typing import Any

import pandas as pd
from pandas.errors import EmptyDataError

_SCRIPT_DIR = Path(__file__).resolve().parent

BUG = "BUG"
HOTSPOT = "HOTSPOT"
VULNERABILITY = "VULNERABILITY"


def get_latest_df(file_type: str) -> pd.DataFrame:
    if file_type == BUG:
        file_prefix = "bugs"
    elif file_type == VULNERABILITY:
        file_prefix = "vulnerabilities"
    elif file_type == HOTSPOT:
        file_prefix = "hotspots"
    else:
        raise ValueError(f"{file_type} is an invalid file type")

    today_str = datetime.now().strftime("%Y-%m-%d")
    files = glob.glob(f"{_SCRIPT_DIR}/output/{today_str}/scan_{file_prefix}_*.csv")
    latest_file = sorted(files)[-1]

    try:
        df = pd.read_csv(latest_file)
    except EmptyDataError:
        df = pd.DataFrame()
    return df


def get_actionable_issues(df: pd.DataFrame, issue_type) -> list[dict[str, Any]]:
    if df.empty:
        return []

    include = ["MAJOR", "CRITICAL", "BLOCKER"]
    filtered_df = df[df["severity"].isin(include)]
    filtered_df = filtered_df[filtered_df["status"].isin(["OPEN"])]
    if filtered_df.empty:
        return []

    issues = []
    for _, row in filtered_df.iterrows():
        record = {
            "finding_type": issue_type,
            "component": row["component"].split(":")[1],
            "location_in_component": ast.literal_eval(row["textRange"]),
            "message": row["message"],
        }
        issues.append(record)

    return issues


def get_actionable_hotspots(df: pd.DataFrame) -> list[dict[str, Any]]:
    if df.empty:
        return []

    include = ["HIGH"]
    filtered_df = df[df["vulnerabilityProbability"].isin(include)]
    filtered_df = filtered_df[filtered_df["status"].isin(["OPEN"])]
    if filtered_df.empty:
        return []

    hotspots = []
    for _, row in filtered_df.iterrows():
        record = {
            "finding_type": HOTSPOT,
            "component": row["component"].split(":")[1],
            "location_in_component": ast.literal_eval(row["textRange"]),
            "message": row["message"],
        }
        hotspots.append(record)

    return hotspots


def output_todo(findings: list[dict[str, Any]]) -> None:
    allowed_files = sorted({finding["component"] for finding in findings})
    allowed_files_md = "\n".join([f"- `{p}`" for p in allowed_files]) or "- (none)"
    content = f"""# General Instructions
- Under the `JSON to ingest` section is a JSON object that contains SonarQube findings from this repository.
- Ingest the JSON object by parsing it correctly. The instructions for proper parsing are under the `JSON Parsing Instructions` section
- Some SonarQube findings may need resolution while other findings do not need resolution.
- If the SonarQube finding does not require resolution (e.g. it is a false positive), just ignore the finding with `NOSONAR`
- Use context from the code, documentation, and best practices to determine whether resolution is necessary.
- If the JSON file's component or location_in_component key looks invalid or outdated, re-run the SonarQube scan

# Allowed files (hard constraint)
- Only modify files listed below. Do not edit any other files, even if you notice other SonarQube findings.

{allowed_files_md}

# JSON Parsing Instructions
- Use the component key to identify the file in the repository that may need resolving
- Use the location_in_component key to identify the section in the file that may need resolving
- Use the message key to plan a way to resolve the problem in the file, if a resolution is necessary

# JSON to ingest
```json
{json.dumps(findings, indent=4)}
```
    """
    today_str = datetime.now().strftime("%Y-%m-%d")
    datetime_str = datetime.now().strftime("%Y-%m-%d_%H:%M:%S.%f")
    filepath_str = f"{_SCRIPT_DIR}/output/{today_str}/TODO_{datetime_str}.md"

    filepath = Path(filepath_str)
    filepath.parent.mkdir(parents=True, exist_ok=True)

    with open(filepath, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Actionable findings output here: {filepath}")


all_bugs = get_latest_df(BUG)
all_vulns = get_latest_df(VULNERABILITY)
all_hotspots = get_latest_df(HOTSPOT)

actionable_bugs = get_actionable_issues(all_bugs, BUG)
actionable_vulns = get_actionable_issues(all_vulns, VULNERABILITY)
actionable_hotspots = get_actionable_hotspots(all_hotspots)

actionable_findings = actionable_bugs + actionable_vulns + actionable_hotspots
if actionable_findings:
    print("There are actionable bugs, vulnerabilities, and hotspots for the AI Agent")
    output_todo(actionable_findings)
else:
    print(
        "There are no actionable bugs, vulnerabilities, and hotspots for the AI Agent"
    )
```

### get-sonarqube-findings-for-human.py

Exports medium/low findings for human review.

```python
import glob
import ast
import json
from pathlib import Path
from datetime import datetime
from typing import Any

import pandas as pd
from pandas.errors import EmptyDataError

_SCRIPT_DIR = Path(__file__).resolve().parent

BUG = "BUG"
HOTSPOT = "HOTSPOT"
VULNERABILITY = "VULNERABILITY"


def get_latest_df(file_type: str) -> pd.DataFrame:
    if file_type == BUG:
        file_prefix = "bugs"
    elif file_type == VULNERABILITY:
        file_prefix = "vulnerabilities"
    elif file_type == HOTSPOT:
        file_prefix = "hotspots"
    else:
        raise ValueError(f"{file_type} is an invalid file type")

    today_str = datetime.now().strftime("%Y-%m-%d")

    files = glob.glob(f"{_SCRIPT_DIR}/output/{today_str}/scan_{file_prefix}_*.csv")
    latest_file = sorted(files)[-1]

    try:
        df = pd.read_csv(latest_file)
    except EmptyDataError:
        df = pd.DataFrame()
    return df


def get_human_actionable_issues(df: pd.DataFrame, issue_type) -> pd.DataFrame:
    if df.empty:
        return pd.DataFrame()

    include = ["MINOR", "INFO"]
    filtered_df = df[df["severity"].isin(include)]
    filtered_df = filtered_df[filtered_df["status"].isin(["OPEN"])]
    if filtered_df.empty:
        return pd.DataFrame()

    return filtered_df


def get_human_actionable_hotspots(df: pd.DataFrame) -> pd.DataFrame:
    if df.empty:
        return pd.DataFrame()

    include = ["MEDIUM", "LOW"]
    filtered_df = df[df["vulnerabilityProbability"].isin(include)]
    filtered_df = filtered_df[filtered_df["status"].isin(["OPEN"])]
    if filtered_df.empty:
        return pd.DataFrame()

    return filtered_df


def save_to_csv(sonar_type: str, df_sonar: pd.DataFrame):
    if sonar_type == BUG:
        name_sub = "bugs"
    elif sonar_type == HOTSPOT:
        name_sub = "hotspots"
    elif sonar_type == VULNERABILITY:
        name_sub = "vulnerabilities"
    else:
        raise Exception(f"Invalid sonar_type: {sonar_type}")

    today_str = datetime.now().strftime("%Y-%m-%d")
    datetime_str = datetime.now().strftime("%Y-%m-%d_%H:%M:%S.%f")
    filepath_str = f"{_SCRIPT_DIR}/output/{today_str}/for_human_review/scan_{name_sub}_{datetime_str}.csv"

    filepath = Path(filepath_str)
    filepath.parent.mkdir(parents=True, exist_ok=True)

    print(f"Output file at {filepath_str}")
    df_sonar.to_csv(filepath_str, index=False)


all_bugs = get_latest_df(BUG)
all_vulns = get_latest_df(VULNERABILITY)
all_hotspots = get_latest_df(HOTSPOT)

human_bugs = get_human_actionable_issues(all_bugs, BUG)
human_vulns = get_human_actionable_issues(all_vulns, VULNERABILITY)
human_hotspots = get_human_actionable_hotspots(all_hotspots)

save_to_csv(BUG, human_bugs)
save_to_csv(VULNERABILITY, human_vulns)
save_to_csv(HOTSPOT, human_hotspots)
```

### .admin-sample.sh

Sample admin configuration.

```bash
#!/usr/bin/env bash
export SONAR_HOST="http://localhost:9000"
export SONAR_ADMIN_USER="admin"
export SONAR_ADMIN_PASSWORD="admin"
```

### requirements.txt

Python dependencies.

```text
requests>=2.32.5
pandas>=3.0.1
python-dotenv>=1.2.1
```

### .gitignore

```text
scripts/output/
scripts/venv/
scripts/.secret.sh
scripts/.env
scripts/.admin.sh
```
