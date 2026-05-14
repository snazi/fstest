---
name: azure-tco
description: "Guide monthly Total Cost of Ownership (TCO) estimation for Azure infrastructure from Terraform code, optional application workload context, and official Azure pricing. Covers AKS, Azure OpenAI, managed databases, storage, and compute SKU costing. Use when estimating Azure cloud spend or producing cost breakdowns. Do not use for AWS cost estimation."
---

# TCO Skill — Monthly Estimate from Infrastructure Code

Use this skill when the user runs `/tco` or asks for a **monthly Total Cost of Ownership** estimate grounded in Terraform infrastructure code and, when available, the related application codebase.

## Phase 0 — Locate Infrastructure and Application Code

Before any inventory or pricing work, establish two inputs:

### 0.1 Infrastructure code

1. **Auto-discovery:** scan the current workspace for Terraform roots — directories that contain a `*.tf` file but are not themselves module directories (i.e. not under a `modules/` subtree). Treat each discovered root as a candidate environment.
2. If **no Terraform roots are found**, ask the user:
   > "No Terraform roots were found in this workspace. Please provide the path to your infrastructure code — either a local directory path or a Git repository URL."
3. If roots are found, present them as a checklist and ask which are **in scope for this estimate**.

### 0.2 Application codebase (optional — never blocks TCO)

1. **Auto-discovery:** check for application code in the current workspace — look for `Dockerfile`, `helm/`, `k8s/`, `charts/`, `src/`, or `pyproject.toml` / `package.json` at the repo root or one level deep.
2. If **not found in the workspace**, ask the user or enter **Terraform-only mode**.

### 0.3 User count gate

For each **non-Databricks** environment root in scope, the user must supply:
- **Expected user count** (or equivalent seat / active-user assumption).

**Do not proceed** to Phase 1 if any in-scope non-Databricks root is missing a user count.

## Phase 1 — Understand What Exists

### 1.1 Infrastructure code pass

For each selected root, build a factual **bill of materials** before any pricing:
- Read provider configuration to determine the **Azure region** per environment.
- Summarize deployed **functional groups**: network, Kubernetes / AKS, SQL / managed databases, storage, AI services, Databricks, identity, monitoring, etc.
- Note SKUs, counts, tiers, and any environment-specific conditionals.

### 1.2 Application codebase (optional)

**If available**, scan for services deployed to AKS, features implying Azure service usage, and agentic/LLM workflows.

### 1.3 Azure OpenAI configuration

If an Azure OpenAI resource is present, collect chat model, audio/realtime model, transcription model details and monthly volumes.

### 1.4 Clarifying questions

Ask only what materially changes the estimate.

## Phase 2 — Assumptions and Pricing

- **Month:** **730 hours** (30-day month).
- **Currency:** **USD**.
- **Region:** taken from Terraform provider configuration **per environment**.
- Use **official Azure pricing documentation**. Cite stable URLs.

## Phase 3 — Artifacts

### Output directory

```
tco/YYYY-MM-DD-v<N>/
```

### Per-environment files

For each selected environment root write `<env-name>.md` with Overview, Assumptions, TCO table, and Caveats.

### total.md

List per-environment totals, present a grand total, and consolidate cross-cutting caveats.

## Quality Bar

- Every cost claim must be **grounded in Terraform** (and application repo when present).
- Never imply billing accuracy; these are **planning estimates**.

## Handoff

After writing all files:
1. Tell the user the output folder path.
2. List each file created.
3. State whether the **application codebase** was used or whether this was a **Terraform-only** run.
4. Offer a **same-version rerun**.
