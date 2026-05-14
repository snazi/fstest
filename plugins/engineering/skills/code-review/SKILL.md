---
name: code-review
description: "Shared review standards for all specialist reviewers. Defines the R1-R5 severity finding schema, review contract rules, deduplication, cross-domain expectations, and specialist domain boundaries for PR review and code review workflows. Use when running specialist review agents, conducting code reviews, or producing structured review findings. Do not use for writing tests or generating new code."
---

# Review Standards

Shared baseline for all specialist reviewers. Defines review contract rules, severity schema, and cross-domain expectations that apply before any domain-specific checks.

## Required Consumption Workflow

1. Read this file first and treat it as the shared baseline.
2. Load domain-specific rules after this baseline (e.g. UI rules, Python rules, skill-specific checks).
3. Review only your assigned specialist domain; avoid overlap where possible.
4. Report findings using the shared review contract below.

## Universal Review Contract

### Finding Schema

Each finding must include:

| Field | Description |
|---|---|
| `id` | Unique identifier |
| `severity` | `R1`, `R2`, `R3`, `R4`, or `R5` |
| `title` | Short description |
| `why_it_matters` | Business/user impact |
| `root_cause` | Technical cause |
| `primary_file` | Main file affected |
| `impact` | Consequence if unaddressed |
| `file_paths` | All affected files |
| `evidence` | Specific code reference |
| `recommended_fix` | Concrete fix |
| `owner_agent` | Which specialist owns it |
| `confidence` | `high`, `medium`, or `low` |

### Example Finding

```json
{
  "id": "security-authz-missing-check",
  "severity": "R1",
  "title": "Missing authorization check on delete endpoint",
  "why_it_matters": "A user can delete resources outside their scope.",
  "root_cause": "Delete route validates authentication but not ownership before mutation.",
  "primary_file": "src/routes/items.py",
  "impact": "Cross-tenant deletion risk.",
  "file_paths": ["src/routes/items.py"],
  "evidence": "Route calls delete() without verifying resource ownership.",
  "recommended_fix": "Add ownership check before delete; return 403 on violation.",
  "owner_agent": "review-security-sentinel",
  "confidence": "high"
}
```

### Severity Mapping

- `R1` **(Critical)**: blocks the primary use case or yields an incorrect primary outcome.
- `R2` **(High)**: breaks meaningful in-scope subflows while the primary path still works.
- `R3` **(Medium)**: not breaking now, but likely to cause near-term rework, drag, or defect risk.
- `R4` **(Low)**: minor quality improvement or consistency cleanup; low risk to defer.
- `R5` **(Wishlist)**: optional improvement or informational note; no action required.

### Deduplication

Dedupe key: `root_cause + primary_file + impact`

- Keep the highest severity if duplicates conflict.
- Keep the strongest evidence and shortest actionable fix.

### Default Remediation Policy

- Automated remediation flows should resolve `R1` and `R2` by default.
- `R3` and `R4` findings should be deferred for separate filing/handling.
- `R5` findings are informational — note for awareness, no action required.

## Standards by Domain

### 1. Naming and Code Style
- Follow existing service-local naming conventions; prefer consistency over novelty.
- Use descriptive names that match business intent and existing patterns.
- Avoid introducing new patterns when an equivalent project pattern already exists.
- Keep logic straightforward; avoid premature abstractions and deeply nested branching.

### 2. Architecture Boundaries
- Respect service boundaries and prevent hidden cross-service coupling.
- Ensure cross-service contracts are explicit and synchronized.
- Keep responsibility boundaries clear — no layer-skipping or misplaced logic.

### 3. Test Coverage
- New or changed behavior should have matching test coverage.
- Verify test intent aligns with real behavior (not just line coverage).
- Highlight coverage gaps in changed areas as findings, not optional notes.
- If external dependencies are involved, ensure stable mocks and deterministic assertions.

### 4. Security and Privacy
- No secrets in source, client bundles, logs, prompts, or fixtures.
- Validate auth and authorization for sensitive operations.
- Treat input as untrusted; require validation/sanitization where appropriate.
- Avoid PII exposure in responses, logs, and telemetry.

### 5. Frontend Async Patterns
- Avoid stale async updates that can overwrite fresher state.
- Ensure cancellation/ignore-stale-result patterns for concurrent requests.
- Keep loading/error/success states coherent under rapid user interactions.
- Guard against hydration mismatch and client/server divergence.

### 6. Copy and Persona
- Keep user-facing copy concise, clear, and action-oriented.
- Maintain consistent terminology and voice across UI, prompts, and docs.
- Standardize agent persona framing (role, tone, boundaries) across surfaces.
- Flag conflicting product terms or mixed persona voice as quality findings.

### 7. Agent-Native Expectations
- Ensure workflows are machine-actionable, not human-only.
- Prefer structured outputs and explicit fields where automation consumes results.
- Require observable execution signals (clear status, logs, error context).
- Flag steps that rely on hidden/manual-only context without deterministic artifacts.

## Reporting Expectations

Every review response should:
- Use the shared finding schema.
- Group findings by severity (`R1`, `R2`, `R3`, `R4`, `R5`).
- Keep recommendations specific and executable.
- Distinguish confirmed findings from low-confidence suggestions.
- Avoid domain overreach unless escalation is required for `R1` risk.

For merged command outputs (`/review`), emit one prioritized list only.

## Specialist Domains (Reference)

| Agent | Domain |
|---|---|
| `review-security-sentinel` | auth/authz, injection, secrets, privacy |
| `review-frontend-reviewer` | race conditions, stale async, hydration/state mismatch |
| `review-architecture-strategist` | dependency direction, service boundaries, layering |
| `review-pattern-recognition-specialist` | anti-patterns, over-abstraction, code smells |
| `review-data-migration-expert` | mapping safety, data integrity, rollback safety |
| `review-copyediting-reviewer` | terminology drift, inconsistent tone/persona |
| `review-agent-native-reviewer` | machine-readable outputs, observable state, automation readiness |

## Startup Line for Specialist Agents

Include this line in each specialist agent file:

> Read `.agents/skills/code-review/SKILL.md` first; it is the mandatory shared baseline for all review findings.

## Embedded Reference (Canonical)

This section replaces the old separate reference file. Treat this `SKILL.md` as the single source for review schema and standards.

### Severity Quick Guide

- `R1` (Critical): issue blocks the primary use case or yields incorrect primary outcome.
- `R2` (High): issue breaks meaningful in-scope subflows/features while the main path still works.
- `R3` (Medium): issue is not breaking now, but likely to create near-term rework, implementation drag, or defect risk for follow-up tasks in this story.
- `R4` (Low): minor quality improvement or consistency cleanup that does not meet `R1`/`R2`/`R3`.
- `R5` (Wishlist): optional improvement or informational note; no action required.

### Merge and Dedupe Reminders

- Dedupe key: `root_cause + primary_file + impact`.
- Keep the highest severity when duplicates conflict.
- Keep the strongest evidence and shortest actionable fix.
- Default automated remediation target is `R1` and `R2`; defer `R3`/`R4` for separate filing/handling; `R5` is informational only.
- Routing caps/tiering reduce specialist fan-out only; they do not lower review quality expectations or schema requirements.

### Specialist Boundary Examples

- `review-security-sentinel`: auth/authz, injection, secrets, privacy boundary checks.
- `review-frontend-reviewer`: race conditions, stale async updates, hydration/client-server state mismatch.
- `review-architecture-strategist`: dependency direction, service boundaries, layering violations.
- `review-pattern-recognition-specialist`: anti-patterns, over-abstraction, readability/code smell clusters.
- `review-data-migration-expert`: mapping safety, data integrity assumptions, rollback safety.
- `review-copyediting-reviewer`: terminology drift, inconsistent tone/persona, ambiguous UI or prompt language.
- `review-agent-native-reviewer`: machine-readable outputs, observable state transitions, automation readiness.

## Related Skills

- $license-audit
