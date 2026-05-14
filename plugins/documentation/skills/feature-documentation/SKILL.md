---
name: feature-documentation
description: "Create implementation-grounded feature documentation and feature specs by tracing behavior across UI, API, and backend layers. Use for end-to-end feature docs, technical feature walkthroughs, and user guide generation. Scope: feature-level documentation only -- not MOPs, architecture docs, or API specs."
---

# Feature Documentation

Write feature documentation that explains how a feature works from user action to system output.

## Scope

Use this skill when asked to:
- Document a feature end-to-end
- Trace a feature flow through the codebase
- Produce technical feature specs for engineers

## Workflow

1. Define scope
   - Identify the feature entry point (for example: UI screen, endpoint, job, or command)
   - Confirm boundaries: what is in scope and out of scope
2. Trace implementation
   - Follow control flow through all relevant layers:
     - `<ui-root>/...`
     - `<api-root>/...`
     - `<service-root>/...`
     - `<data-root>/...`
   - Capture key inputs, outputs, and transformations
3. Decompose behavior
   - Main Flow: primary user or system journey
   - Subfeatures: user-visible enhancements
   - Supporting Features: background logic that improves quality, safety, or performance
4. Write docs
   - Begin each file with the YAML frontmatter block from `## Output Frontmatter`
   - Use the required structure below
   - Include exact file paths and endpoint names where relevant
5. Save output
   - Write to `docs/features/<feature-name>/`

## Output Frontmatter

Every generated document must begin with this YAML frontmatter block:

```yaml
---
name: <feature-name-in-kebab-case>
description: <one-sentence description of what this document covers>
---
```

- `name`: Use the kebab-case directory or file name (e.g., `brief-generation`, `invoice-processing-subfeature`).
- `description`: One sentence summarizing the feature or subfeature documented in this file.

## Required Sections

Every feature document must include:

### 1) Step-by-Step Flow
- Sequence from trigger to final output
- Use `->` to show direction
- Include concrete code references

### 2) Successful Output
- What users/operators see
- What the system produces
- Any state changes or side effects

### 3) Handled Failures
- Known failure modes currently handled
- Handling behavior and source location

### 4) Unhandled Issues
- Known gaps not yet handled
- Impact level: high, medium, low

## Output Structure

Use this directory layout:

```text
<docs-root>/features/<feature-name>/
├── README.md
├── subfeatures/
│   └── <subfeature-name>/README.md
└── supporting-features/
    └── <supporting-feature-name>/README.md
```

Main flow belongs in `README.md`. Subfeatures and supporting features get their own `README.md` files.

## Quality Requirements

- Ground all statements in observed implementation
- Do not invent behavior, schemas, or guarantees
- Prefer concise, engineer-readable explanations
- Document both behavior and rationale when discoverable
