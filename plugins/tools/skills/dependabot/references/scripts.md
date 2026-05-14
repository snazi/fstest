# Vulnerability Analysis Scripts

These scripts power the discovery and analysis phase of the Dependabot skill. They were consolidated from the former `analyze-vulnerabilities` skill. Before execution, extract each script to a `scripts/analyze-vulnerabilities/` directory in the target repository's working directory.

### fetch-alerts.sh

**Usage:** `scripts/analyze-vulnerabilities/fetch-alerts.sh [output-file]`

```bash
#!/bin/bash
# Fetch Dependabot alerts from GitHub

set -e

# Configuration
REPO_OWNER="${REPO_OWNER:-your-org}"
REPO_NAME="${REPO_NAME:-your-repo}"
OUTPUT_FILE="${1:-alerts.json}"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check GitHub CLI authentication
if ! gh auth status &>/dev/null; then
    log_error "GitHub CLI not authenticated. Run 'gh auth login' first."
    exit 1
fi

log_info "Fetching Dependabot alerts from $REPO_OWNER/$REPO_NAME..."

# Fetch alerts
gh api /repos/$REPO_OWNER/$REPO_NAME/dependabot/alerts \
    --paginate > "$OUTPUT_FILE"

# Validate output
if [ ! -s "$OUTPUT_FILE" ]; then
    log_error "Failed to fetch alerts or no alerts found"
    exit 1
fi

FILE_SIZE=$(stat -f%z "$OUTPUT_FILE" 2>/dev/null || stat -c%s "$OUTPUT_FILE" 2>/dev/null)
ALERT_COUNT=$(jq length "$OUTPUT_FILE" 2>/dev/null || echo "0")

log_info "Fetched $ALERT_COUNT alerts ($FILE_SIZE bytes)"
log_info "Saved to: $OUTPUT_FILE"
```

### filter-alerts.py

**Usage:** `python3 scripts/analyze-vulnerabilities/filter-alerts.py alerts.json > filtered.json`

```python
#!/usr/bin/env python3
"""Filter Dependabot alerts by severity."""

import json
import sys

def filter_alerts(input_file):
    """Filter for critical and high severity open alerts."""
    with open(input_file, 'r') as f:
        data = json.load(f)

    filtered = [
        alert for alert in data
        if alert.get('security_advisory', {}).get('severity', '').lower() in ['critical', 'high']
        and alert.get('state') == 'open'
    ]

    return filtered

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: filter-alerts.py <input_file>", file=sys.stderr)
        sys.exit(1)

    filtered_alerts = filter_alerts(sys.argv[1])
    print(json.dumps(filtered_alerts, indent=2))
```

### generate-summary.py

**Usage:** `python3 scripts/analyze-vulnerabilities/generate-summary.py filtered.json`

```python
#!/usr/bin/env python3
"""Generate a vulnerability summary from filtered alerts."""

import json
import sys
from collections import defaultdict

def generate_summary(input_file):
    """Create a summary of vulnerabilities grouped by package and CVE."""
    with open(input_file, 'r') as f:
        data = json.load(f)

    # Group by package and CVE
    grouped = defaultdict(lambda: {
        'count': 0,
        'severity': '',
        'cve': '',
        'summary': '',
        'affected_manifests': [],
        'patched_version': '',
        'vulnerable_range': ''
    })

    for alert in data:
        pkg_name = alert['dependency']['package']['name']
        cve_id = alert['security_advisory'].get('cve_id', 'N/A')
        key = f"{pkg_name}|{cve_id}"

        if grouped[key]['count'] == 0:
            grouped[key]['severity'] = alert['security_advisory']['severity']
            grouped[key]['cve'] = cve_id
            grouped[key]['summary'] = alert['security_advisory']['summary']
            grouped[key]['vulnerable_range'] = alert['security_vulnerability']['vulnerable_version_range']
            patched = alert['security_vulnerability'].get('first_patched_version')
            grouped[key]['patched_version'] = patched['identifier'] if patched else 'No patch available'

        grouped[key]['count'] += 1
        manifest = alert['dependency']['manifest_path']
        if manifest not in grouped[key]['affected_manifests']:
            grouped[key]['affected_manifests'].append(manifest)

    # Print summary
    print(f'Total Critical/High Alerts: {len(data)}')
    print(f'Unique Vulnerabilities: {len(grouped)}')
    print('=' * 100)

    for key, info in sorted(grouped.items(), key=lambda x: (x[1]['severity'], x[0])):
        pkg_name = key.split('|')[0]
        print(f"\n[{info['severity'].upper()}] {pkg_name} - {info['cve']}")
        print(f"  Summary: {info['summary'][:80]}...")
        print(f"  Vulnerable: {info['vulnerable_range']}")
        print(f"  Patched: {info['patched_version']}")
        print(f"  Occurrences: {info['count']} (in {len(info['affected_manifests'])} manifests)")
        for manifest in info['affected_manifests']:
            print(f"    - {manifest}")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: generate-summary.py <input_file>", file=sys.stderr)
        sys.exit(1)

    generate_summary(sys.argv[1])
```

### prioritize-vulnerabilities.py

**Usage:** `cat filtered.json | python3 scripts/analyze-vulnerabilities/prioritize-vulnerabilities.py`

```python
#!/usr/bin/env python3
"""Prioritize vulnerabilities based on multiple factors."""

import json
import sys

def prioritize_vulnerabilities(alerts):
    """Prioritize vulnerabilities based on severity, EPSS, dependency type, and scope."""

    priority_scores = []

    for alert in alerts:
        score = 0

        # Severity scoring
        severity = alert['security_advisory']['severity'].lower()
        if severity == 'critical':
            score += 100
        elif severity == 'high':
            score += 75
        elif severity == 'medium':
            score += 50
        else:
            score += 25

        # EPSS scoring (if available)
        epss = alert['security_advisory'].get('epss', {})
        if epss and 'percentage' in epss:
            score += epss['percentage'] * 100

        # Dependency type
        if alert['dependency'].get('relationship') == 'direct':
            score += 20

        # Scope
        if alert['dependency'].get('scope') == 'runtime':
            score += 10

        priority_scores.append({
            'alert': alert,
            'score': score
        })

    # Sort by score descending
    priority_scores.sort(key=lambda x: x['score'], reverse=True)

    return priority_scores

if __name__ == '__main__':
    data = json.load(sys.stdin)
    prioritized = prioritize_vulnerabilities(data)

    print("=== Prioritized Vulnerabilities ===\n")
    for i, item in enumerate(prioritized[:20], 1):  # Top 20
        alert = item['alert']
        pkg = alert['dependency']['package']['name']
        cve = alert['security_advisory'].get('cve_id', 'N/A')
        severity = alert['security_advisory']['severity']
        score = item['score']

        print(f"{i}. [{severity.upper()}] {pkg} - {cve}")
        print(f"   Priority Score: {score:.2f}")
        print(f"   {alert['security_advisory']['summary'][:80]}...")
        print()
```

### generate-update-plan.py

**Usage:** `python3 scripts/analyze-vulnerabilities/generate-update-plan.py filtered.json`

```python
#!/usr/bin/env python3
"""Generate an update plan from filtered Dependabot alerts."""

import json
import sys
from collections import defaultdict

def generate_plan(input_file):
    """Generate a human-readable update plan."""
    with open(input_file, 'r') as f:
        data = json.load(f)

    packages = defaultdict(lambda: {
        'services': set(),
        'severity': '',
        'cve': '',
        'version': ''
    })

    for alert in data:
        pkg = alert['dependency']['package']['name']
        manifest = alert['dependency']['manifest_path']
        service = manifest.split('/')[1] if manifest.startswith('app/') else 'root'

        packages[pkg]['services'].add(service)
        packages[pkg]['severity'] = alert['security_advisory']['severity']
        packages[pkg]['cve'] = alert['security_advisory'].get('cve_id', 'N/A')
        vuln = alert['security_vulnerability'].get('first_patched_version')
        packages[pkg]['version'] = vuln['identifier'] if vuln else 'No patch'

    print("Package Update Plan")
    print("=" * 80)
    for pkg, info in sorted(packages.items()):
        print(f"\n{pkg}")
        print(f"  Severity: {info['severity']}")
        print(f"  CVE: {info['cve']}")
        print(f"  Target Version: {info['version']}")
        print(f"  Services: {', '.join(sorted(info['services']))}")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: generate-update-plan.py <input_file>", file=sys.stderr)
        sys.exit(1)

    generate_plan(sys.argv[1])
```
