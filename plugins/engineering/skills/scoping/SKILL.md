---
name: scoping
description: "Turn a set of requirements, feature briefs, or PRDs into categorized user stories with complexity ratings and dev time estimates (with and without AI SDLC), split into Functional and Non-Functional groups. Use when the user wants project scoping, user story breakdown, effort estimation, or says 'scope this' or 'estimate this'. Do not use for timeline scheduling (use timelining instead)."
---

# Scoping

## When to Use This Skill

Use when the user provides requirements, a feature brief, a PRD, or any description of what needs to be built — and wants it broken down into categorized, estimated user stories. Also use when the user says "scope this", "break this down", "estimate this", or "what are the user stories".

## Process

### 1. Parse the Requirements

Read the input and extract every distinct requirement. Accepted input types:

| Input type | How to parse |
|------------|-------------|
| Free-text description | Extract each capability, constraint, or behavior mentioned |
| Bullet list | Treat each bullet as a candidate requirement |
| PRD / spec document | Extract from goals, features, acceptance criteria, and non-functional sections |
| Existing user stories | Re-categorize and re-estimate per the structure below |
| Conversation context | Gather requirements from the discussion so far |

If the requirements are ambiguous or incomplete, ask one focused clarifying question before proceeding. Do not guess at scope — it shapes all estimates.

### 2. Split Into Functional vs Non-Functional

| Category | Definition | Focus |
|----------|-----------|-------|
| **Functional** | What the app/system does from the end user's perspective | User-facing behavior, features, workflows, UI interactions |
| **Non-Functional** | How the app/system runs | Infrastructure, data, governance, performance, security |

### 3. Write User Stories

Write each user story in standard format:

```
As a [role], I want to [action] so that [outcome].
```

Assign each user story a unique code:

| Category | Code prefix | Example |
|----------|------------|---------|
| Functional | `F-` | `F-001`, `F-002` |
| Non-Functional: Infrastructure | `NFI-` | `NFI-001` |
| Non-Functional: Data | `NFD-` | `NFD-001` |
| Non-Functional: Governance | `NFG-` | `NFG-001` |
| Non-Functional: Application | `NFA-` | `NFA-001` |

### 4. Categorize by Complexity

| Complexity | Dev + Test Time | Characteristics |
|-----------|----------------|-----------------|
| **High** | 1 week or more | Multiple components, complex logic, external integrations |
| **Medium** | 2-3 days | Moderate logic, touches 2-3 modules |
| **Low** | 1 day or less | Simple CRUD, config changes, minor UI updates |

### 5. Estimate Dev Time

For every user story, provide two time estimates:

| Estimate | Description |
|----------|------------|
| **Dev Time (no AI SDLC)** | Traditional development |
| **Dev Time (w/ AI SDLC)** | AI-assisted development (typically 30-60% faster) |

### 6. Output as Tables

Present the categorized user stories as tables — one table per group.

### 7. Output Summary

```
SCOPE SUMMARY
-------------
Functional stories:     X (H: _, M: _, L: _)
Non-Functional stories: X (Infra: _, Data: _, Gov: _, App: _)
Total stories:          X

Estimated total (no AI SDLC):   X-Y days
Estimated total (w/ AI SDLC):   X-Y days
Estimated time savings w/ AI:   ~X%
```

### 8. Present for Review

After generating the scope plan:
1. Show all tables and the summary to the user
2. Flag any requirements that were ambiguous or could not be cleanly categorized
3. Note any assumptions made during estimation
4. Ask the user if they want to adjust complexity ratings, add missing stories, or split/merge any items

## Constraints

- Every user story must have a unique code, a properly formatted story statement, and both time estimates.
- Do not skip Non-Functional categories — if none apply, state "No requirements identified" for that sub-category.
- Do not inflate story count by splitting overly granular tasks. Each story should be independently testable.
- Time estimates must include both development and testing time — never estimate dev-only.
- If the requirements are insufficient to estimate (e.g., "build an app"), ask for clarification before producing tables.
