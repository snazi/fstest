---
name: mop-documentation
description: "Create MOP (Method of Procedure) documents, runbooks, how-to guides, and operational documentation with step-by-step instructions. Use for onboarding procedures, troubleshooting guides, developer workflows, and operational runbook creation. Scope: operational documentation only -- not feature docs, architecture docs, or API docs."
---

# MOP Documentation

Write MOPs (Mode of Procedure docs) that help engineers execute recurring tasks safely and consistently.

## Scope

Use this skill when asked to:
- Write a how-to guide
- Document an operational or developer procedure
- Create onboarding, runbook, or troubleshooting steps

## Workflow

1. Define procedure scope
   - Task name, target audience, and prerequisites
   - Context: local, staging, or production-like environment
2. Verify real commands and paths
   - Confirm command syntax from repository scripts/config
   - Confirm required environment variables and permissions
3. Draft step-by-step procedure
   - One discrete action per step
   - Include expected outputs and verification checks
4. Add troubleshooting section
   - Common failures
   - How to detect and resolve each issue
5. Save output
   - Write to `docs/mops/<category>/<mop-name>.md` or the relevant doc storage

## Required Template

Each MOP must begin with YAML frontmatter:

```yaml
---
name: <mop-name-in-kebab-case>
description: <one-sentence description of what this procedure covers>
---
```

- `name`: Use the kebab-case MOP filename matching the file stem (e.g., `run-end-to-end-tests`, `configure-github-actions`).
- `description`: One sentence summarizing the procedure's objective.

Then include:
- Title
- Objective
- Prerequisites
- Procedure steps
- Verification
- Troubleshooting
- References

## Path Conventions

- MOP file: `docs/mops/<category>/<mop-name>.md`
- Optional assets: `docs/mops/<category>/assets/<mop-name>/`

Suggested categories:
- `setup`
- `operations`
- `testing`
- `troubleshooting`
- `features`

## Writing Requirements

- Use imperative voice: "Run", "Open", "Verify"
- Include exact commands and path placeholders where needed
- State success criteria after key steps
- Avoid project-specific assumptions unless explicitly provided

## Quality Requirements

- Commands are runnable and complete
- Prerequisites are explicit
- Failure handling is practical
- Procedure can be executed without extra context
