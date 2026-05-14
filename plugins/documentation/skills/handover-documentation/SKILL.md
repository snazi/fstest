---
name: handover-documentation
description: "Create knowledge-transfer and handover documentation for ownership transitions, team changes, and system onboarding. Use for transition documentation, operational context capture, and maintainer onboarding guides. Scope: handover and knowledge transfer docs only -- not feature docs or architecture overviews."
---

# Handover Documentation

Write handover docs that transfer practical system knowledge from one team or person to another.

## Scope

Use this skill when asked to:
- Prepare handover or transition documentation
- Capture ownership and operational context
- Document what a new maintainer needs to run and support a system

## Workflow

1. Define handover target
   - Component/system being handed over
   - Intended audience
2. Trace source material
   - Architecture and dependencies
   - Runtime and deployment setup
   - Monitoring, alerting, and support routines
3. Draft document — begin with the YAML frontmatter from `## Output Frontmatter`, then use the required sections
4. Validate
   - Confirm claims against repository evidence
   - Call out unknowns or missing ownership details
5. Save output
   - Write to `docs/handover/<topic>.md`

## Output Frontmatter

Every generated handover document must begin with this YAML frontmatter block:

```yaml
---
name: <topic-in-kebab-case>
description: <one-sentence description of what system or component this handover covers>
---
```

- `name`: Use the kebab-case topic name matching the filename (e.g., `brief-system`, `authentication-service`).
- `description`: One sentence summarizing the system or component being handed over.

## Required Sections

- System Overview
- Ownership and Responsibilities
- Architecture and Design
- Operational Context
- Development Workflow
- Known Issues and Gotchas
- References

## Diagram Guidance

When diagrams help understanding, generate Mermaid diagrams with:
- Clear labels
- Minimal visual noise
- No syntax-breaking characters in labels

Use placeholder names if concrete names are unavailable.

## Writing Requirements

- Prioritize actionable information over narrative
- Include "what", "why", and "how to operate"
- Separate confirmed facts from assumptions
- Provide direct references to code or docs paths where possible

## Quality Requirements

- Accurate and implementation-grounded
- Sufficient for a new maintainer to operate independently
- Covers both technical design and operations
