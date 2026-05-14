# Modifications to terraform-skill

This file documents changes made to the original [terraform-skill](https://github.com/antonbabenko/terraform-skill) by Anton Babenko, as required by the Apache License 2.0 Section 4(b).

## Original Work

- **Author:** Anton Babenko
- **License:** Apache-2.0
- **Source:** https://github.com/antonbabenko/terraform-skill

## Changes Made

### 2026-01-28: Restructure for azure-infrastructure repo

**Files moved:**
- `references/*.md` → `.agents/skills/terraform-skill/references/` (6 files: ci-cd-workflows.md, code-patterns.md, module-patterns.md, quick-reference.md, security-compliance.md, testing-frameworks.md)

**Files removed:**
- `../` directory
- `.github/` directory
- `.gitignore`
- `CHANGELOG.md`
- `CLAUDE.md`
- `CONTRIBUTING.md`

**Files retained:**
- `LICENSE` (required by Apache 2.0)
- `SKILL.md` (updated with new paths to reference files)
- `tests/` directory (baseline-scenarios.md, compliance-verification.md, rationalization-table.md)

### 2026-03-12: Decouple skill references from repository rules

**Files moved:**
- Legacy terraform reference docs directory → `.agents/skills/terraform-skill/references/*.md`

**Links updated:**
- Internal references in `.agents/skills/terraform-skill/SKILL.md` now point to `references/*.md`
- Back-links in `.agents/skills/terraform-skill/references/*.md` now point to `../SKILL.md`

**Files removed:**
- Legacy terraform reference docs directory (all generic reference docs migrated)
