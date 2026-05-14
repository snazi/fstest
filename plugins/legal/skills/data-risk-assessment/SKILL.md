---
name: data-risk-assessment
description: "Classify data by sensitivity level (PII, PHI, financial, credentials, trade secrets) and flag high-risk datasets that require explicit user acknowledgement before processing. Use for data risk assessment, privacy evaluation, GDPR compliance checks, data classification, and PII detection in API responses, files, database queries, and logs. Scope: data sensitivity classification and risk flagging only -- not security scanning or penetration testing."
---

# Data Risk Assessment

## When to Use This Skill

Use when inspecting data from any source — API responses, uploaded files, database query results, CSV/JSON exports, logs — to determine whether it contains high-risk or sensitive information that requires explicit acknowledgement before the agent continues processing it.

## Process

### 1. Identify Data Sources

Determine what data is being assessed. Accepted sources:

| Source type | How to inspect |
|-------------|---------------|
| API response | Read the response body — check field names, sample values, and schema |
| Uploaded file | Read the file contents — check headers, column names, and sample rows |
| Database query | Read the query results — check column names, data types, and sample values |
| Log output | Scan for patterns matching sensitive data (emails, tokens, IDs) |
| In-memory data | Inspect variable contents or data structures passed by the calling agent |

### 2. Classify Data Sensitivity

Scan the data for the following risk categories. A dataset is **high risk** if it contains any of these:

| Risk category | Examples | Severity |
|---------------|----------|----------|
| **PII (Personally Identifiable Information)** | Full names + contact info, national IDs, passport numbers, birth dates, home addresses, phone numbers | HIGH |
| **PHI (Protected Health Information)** | Medical records, diagnoses, prescriptions, health insurance IDs, lab results | CRITICAL |
| **Financial data** | Bank account numbers, credit card numbers, salary/compensation, tax records, financial statements | HIGH |
| **Authentication credentials** | Passwords, API keys, tokens, private keys, secrets, connection strings | CRITICAL |
| **Trade secrets / proprietary data** | Unreleased product plans, proprietary algorithms, internal pricing models, client contracts | HIGH |
| **Client-confidential data** | Data owned by a client that has not been explicitly cleared for use outside the client engagement | HIGH |
| **Biometric data** | Fingerprints, facial recognition data, voiceprints, retinal scans | CRITICAL |
| **Minor/child data** | Any data identifiable to individuals under 18 | CRITICAL |

A dataset is **low risk** if it contains only:
- Publicly available information (public APIs, open datasets)
- Aggregated/anonymized data with no re-identification path
- Internal operational data (non-confidential)
- Synthetic/test data explicitly labeled as such

### 3. Flag High-Risk Data

For every high-risk dataset found, produce a risk flag with:

- **Data source** — where the data came from (API name, file path, database table, etc.)
- **Dataset name** — a descriptive label for the dataset
- **Risk category** — which category from step 2 applies
- **Risk description** — a one-sentence explanation of what sensitive data was found and why it is risky
- **Sample evidence** — redacted examples showing the pattern (e.g., "Column `ssn` contains values matching XXX-XX-XXXX pattern") — never display actual sensitive values

### 4. Require User Acknowledgement

For each flagged dataset, the agent **must halt processing and display the following confirmation message**. Do not continue until the user explicitly confirms.

```
------------------------------------------------------------
DATA RISK NOTICE
------------------------------------------------------------
Dataset:     [Dataset Name]
Source:      [Data Source]
Risk:        [Risk Category] — [Risk Description]

By proceeding, you acknowledge that this dataset is HIGH RISK
in nature and confirm that it is OK for use in this context.

If you are unsure, please file a Legal Request before
proceeding.

Do you confirm? (yes / no)
------------------------------------------------------------
```

- If the user confirms **yes**: record the acknowledgement and continue processing.
- If the user confirms **no**: stop processing the flagged dataset. Do not pass it to downstream agents or tools.
- If there are **multiple flagged datasets**, present them all at once and require confirmation for each individually.

### 5. Record in Data Checklist

After the user acknowledges (or rejects) each dataset, update the data checklist file at `docs/legal/data-checklist.md` relative to the current working directory.

If the file does not exist, create it with this structure:

```markdown
# Data Risk Checklist

| Date | Data Source | Dataset Name | Risk Description | Signoff |
|------|-------------|--------------|------------------|---------|
```

For each acknowledged dataset, append a row:

| Field | Value |
|-------|-------|
| Date | Today's date in YYYY-MM-DD format |
| Data Source | The origin (API, file path, database, etc.) |
| Dataset Name | Descriptive label |
| Risk Description | One-sentence summary of the risk |
| Signoff | The name or email of the person who confirmed |

If the user does not provide their name, use the git user name (`git config user.name`) or the authenticated user identity from the current session.

This file is **append-only** — never remove or modify existing rows. Each assessment adds to the running record.

## Constraints

- Never display actual sensitive data values in risk flags or logs. Always redact or use pattern descriptions.
- Never silently skip a high-risk dataset. Every flagged dataset must be acknowledged or rejected.
- Never continue processing a rejected dataset.
- The data checklist must be updated for every assessment, even if no high-risk data was found (add a row noting "No high-risk data detected" for audit trail purposes).
