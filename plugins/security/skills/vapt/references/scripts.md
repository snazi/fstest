# VAPT Scripts

These scripts power the VAPT (DAST) skill. Before execution, extract each script to a `scripts/vapt/` directory in the target repository's working directory. All script path references in the SKILL.md assume this layout.

### run-zap-scan.sh

Launches OWASP ZAP via Docker against a target URL. Creates a dated report directory under `docs/security-reports/` and writes all scan artifacts there.

```bash
#!/usr/bin/env bash
set -euo pipefail

TARGET_URL="${1:?Usage: run-zap-scan.sh <TARGET_URL> [quick]}"
MODE="${2:-full}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Derive report directory name from target URL
SANITIZED_TARGET=$(echo "$TARGET_URL" | sed 's|https\?://||; s|/.*||; s|[^a-zA-Z0-9._-]|-|g')
DATE=$(date +%Y-%m-%d)
REPORT_DIR="docs/security-reports/${DATE}-vapt-${SANITIZED_TARGET}"

mkdir -p "$REPORT_DIR"
echo "Report directory: $REPORT_DIR"

# Create Docker network (idempotent)
docker network create dastnet 2>/dev/null || true

# Copy automation configs to report dir so Docker can mount them
cp "$SCRIPT_DIR/zap-automation.yaml" "$REPORT_DIR/"
cp "$SCRIPT_DIR/zap-automation-quick.yaml" "$REPORT_DIR/"

# Select automation config
if [ "$MODE" = "quick" ]; then
  CONFIG_FILE="zap-automation-quick.yaml"
else
  CONFIG_FILE="zap-automation.yaml"
fi

echo "Starting ZAP scan against $TARGET_URL (mode: $MODE)..."

set +e
docker run --rm \
    --network dastnet \
    -e target="$TARGET_URL" \
    -v "$PWD/$REPORT_DIR:/zap/wrk:rw" \
    ghcr.io/zaproxy/zaproxy:stable \
    bash -c "chmod 777 /zap/wrk && \
             mkdir -p /zap/wrk/bronze_zap-report-html && \
             zap.sh -cmd -autorun /zap/wrk/$CONFIG_FILE"
STATUS=$?
set -e

# Clean up copied configs
rm -f "$REPORT_DIR/zap-automation.yaml" "$REPORT_DIR/zap-automation-quick.yaml"

echo "ZAP exited with code $STATUS"
if [ "$STATUS" -le 2 ]; then
  echo "Scan complete. Reports written to $REPORT_DIR/"
else
  echo "Unexpected exit code ($STATUS), failing."
  exit $STATUS
fi
```

### zap-automation.yaml

Full ZAP automation framework config. Ajax Spider (5 min) + Active Scan (60 min max). Produces JSON and HTML reports.

```yaml
env:
  vars:
    target: ""

  contexts:
    - name: "default"
      urls:
        - "${target}"

parameters:
  progressToStdout: true
  failOnError: false

jobs:
  - type: passiveScan-config
    parameters:
      maxAlertsPerRule: 10

  - type: spiderAjax
    parameters:
      url: "${target}"
      maxDuration: 5

  - type: activeScan
    parameters:
      policy: "Default Policy"
      maxScanDurationInMins: 60
      maxRuleDurationInMins: 5

  - type: report
    parameters:
      template: traditional-json
      reportDir: /zap/wrk
      reportFile: bronze_zap-report.json

  - type: report
    parameters:
      template: traditional-html-plus
      reportDir: /zap/wrk/bronze_zap-report-html
      reportFile: bronze_zap-report.html
```

### zap-automation-quick.yaml

Quick ZAP automation config for faster scans. Ajax Spider (3 min) + Active Scan (5 min max). Use when a full scan is too slow or for iterative re-scans after fixes.

```yaml
env:
  vars:
    target: ""

  contexts:
    - name: "default"
      urls:
        - "${target}"

parameters:
  progressToStdout: true
  failOnError: false

jobs:
  - type: passiveScan-config
    parameters:
      maxAlertsPerRule: 10

  - type: spiderAjax
    parameters:
      url: "${target}"
      maxDuration: 3

  - type: activeScan
    parameters:
      policy: "Default Policy"
      maxScanDurationInMins: 5
      maxRuleDurationInMins: 2

  - type: report
    parameters:
      template: traditional-json
      reportDir: /zap/wrk
      reportFile: bronze_zap-report.json

  - type: report
    parameters:
      template: traditional-html-plus
      reportDir: /zap/wrk/bronze_zap-report-html
      reportFile: bronze_zap-report.html
```

### process-zap-report.py

Parses the bronze JSON report into silver (instance-level CSV) and gold (summary CSV) tiers. Requires `pandas`.

```python
#!/usr/bin/env python3
"""Parse ZAP bronze JSON report into silver (detailed) and gold (summary) CSVs."""

import json
import sys
import os

try:
    import pandas as pd
except ImportError:
    print("ERROR: pandas is required. Install with: pip install pandas", file=sys.stderr)
    sys.exit(1)


def parse_zap_report(input_file):
    with open(input_file, "r", encoding="utf-8") as f:
        data = json.load(f)

    def get_base_record(alert):
        return {
            "vuln_type": "DAST ZAP",
            "riskdesc": alert.get("riskdesc", ""),
            "riskcode": alert.get("riskcode", ""),
            "confidence": alert.get("confidence", ""),
            "vuln_name": alert.get("alert", ""),
            "description": alert.get("desc", ""),
            "solution": alert.get("solution", ""),
        }

    # Silver tier — instance-level details
    detailed_rows = []
    for site in data.get("site", []):
        for alert in site.get("alerts", []):
            base = get_base_record(alert)
            for instance in alert.get("instances", []):
                row = dict(base)
                row["instance_uri"] = instance.get("uri", "")
                row["instance_method"] = instance.get("method", "")
                row["instance_param"] = instance.get("param", "")
                row["instance_attack"] = instance.get("attack", "")
                row["instance_evidence"] = instance.get("evidence", "")
                row["instance_otherinfo"] = instance.get("otherinfo", "")
                detailed_rows.append(row)

    df_detailed = pd.DataFrame(detailed_rows)
    if not df_detailed.empty:
        df_detailed = df_detailed.sort_values(
            by=["riskcode", "confidence", "vuln_name", "instance_method"],
            ascending=False,
        )

    # Gold tier — summary with compensating control column
    summary_rows = []
    for site in data.get("site", []):
        for alert in site.get("alerts", []):
            base = get_base_record(alert)
            base.pop("solution", None)
            base["Compensating Control"] = ""
            summary_rows.append(base)

    df_summary = pd.DataFrame(summary_rows)
    if not df_summary.empty:
        df_summary = df_summary.sort_values(
            by=["riskcode", "confidence", "vuln_name"],
            ascending=False,
        )

    return df_detailed, df_summary


if __name__ == "__main__":
    input_file = sys.argv[1] if len(sys.argv) > 1 else "bronze_zap-report.json"

    if not os.path.exists(input_file):
        print(f"ERROR: Input file not found: {input_file}", file=sys.stderr)
        sys.exit(1)

    # Write output/ alongside the input file (in the same report directory)
    report_dir = os.path.dirname(os.path.abspath(input_file))
    output_dir = os.path.join(report_dir, "output")
    os.makedirs(output_dir, exist_ok=True)

    df_detailed, df_summary = parse_zap_report(input_file)

    silver_path = os.path.join(output_dir, "silver_zap-detailed.csv")
    gold_path = os.path.join(output_dir, "gold_vapt-fill-up.csv")

    df_detailed.to_csv(silver_path, index=False, encoding="utf-8")
    df_summary.to_csv(gold_path, index=False, encoding="utf-8")

    print(f"Silver report: {silver_path} ({len(df_detailed)} instances)")
    print(f"Gold report:   {gold_path} ({len(df_summary)} unique alerts)")
```
