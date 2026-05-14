---
name: architecture-documentation
description: "Generate architecture documentation with per-environment Mermaid diagrams and infrastructure component overviews. Use for creating or updating architecture docs, visualizing infrastructure topology (AKS, Databricks, networking, compute, storage), generating C4 model diagrams, writing ADRs, and documenting system design. Scope: architecture-level documentation only -- not feature docs, API docs, or MOPs."
---

# Architecture Documentation

Produce `docs/architecture.md` containing per-environment Mermaid architecture diagrams and a high-level explanation of every infrastructure component organized by functional purpose.

## Read Rules First

Before generating architecture documentation, read any repository-specific environment mappings, taxonomy, and output constraints from the project's rules or configuration files.

## Workflow

1. Crawl Terraform codebase per environment (Phase 1)
2. Classify resources by functional purpose (Phase 2)
3. Generate a separate Mermaid diagram for each environment (Phase 3)
4. Write explanation organized by purpose (Phase 4)
5. Save to `docs/architecture.md` (Phase 5)
6. Verify quality (Phase 6)

## Phase 1: Resource Discovery

Crawl each environment root separately, then shared modules.

**Per-environment (repeat for each in-scope environment):**

```
1. infra/<env>/main.tf         -> Module instantiations, locals, resource group
2. infra/<env>/variables.tf    -> Environment-level variables and defaults
3. infra/<env>/providers.tf    -> Provider versions, backend config
```

**Shared modules:**

```
4. infra/modules/network/      -> VNet, subnets, NSGs, private DNS zones, private endpoints
5. infra/modules/*/main.tf     -> All other module resource definitions
6. infra/modules/*/variables.tf -> Configuration inputs per module
7. infra/modules/*/outputs.tf  -> Exported references (subnet IDs, endpoints, connection strings)
```

For each module in each environment, extract:
- Azure resource types created (e.g. `azurerm_kubernetes_cluster`, `azurerm_virtual_network`)
- Cross-module references via inputs (e.g. `subnet_id = module.network.aks_subnet_id`)
- `depends_on` chains connecting modules
- Network connectivity: subnet assignments, private endpoints, VNet integrations
- Traffic flow direction: which resources talk to which
- **Environment-specific conditionals** (`var.env == "dev" ? ... : ...`) that change what gets created

Start with the network module — it defines the VNet topology that all other resources plug into.

**Track which modules exist in which environments.** Not all environments share the same modules (e.g. Databricks environments don't have AKS, main environments don't have Unity Catalog).

## Phase 2: Resource Classification

Classify modules using the taxonomy defined in the project's infrastructure taxonomy rules.

A module may touch multiple groups — classify by primary purpose.

## Phase 3: Per-Environment Mermaid Diagrams

Generate a **separate diagram for each environment**. Each must reflect only resources in that specific environment — do not combine environments.

### Diagram Rules

- Use `graph TB` or `flowchart TB` for top-to-bottom layout
- Use `subgraph` blocks for the VNet and each subnet
- **Never use parentheses `()` inside node labels or edge labels**
  - Bad: `A[AKS Cluster (Kubernetes)]`
  - Good: `A[AKS Cluster<br/>Kubernetes]`
- Use descriptive node IDs and labels
- Show traffic direction with arrows: `-->` for data flow, `-.->` for private endpoint links
- Group external services (Log Analytics, Key Vault if not VNet-integrated) outside the VNet subgraph
- **Include environment-specific details in node labels** where they differ: SKU names, capacity, node counts, replication mode
- Conditional resources appear only in the environment where the condition is true

### Main Environment Diagram Structure

```
graph TB
    subgraph VNet["<project>-<env>-vnet"]
        subgraph AKS_Subnet["AKS Subnet"]
            ...
        end
        subgraph Workloads_Subnet["Workloads Subnet"]
            ...
        end
        subgraph AGW_Subnet["App Gateway Subnet"]
            ...
        end
    end

    External resources outside VNet...
    Traffic flow arrows...
```

### Databricks Environment Diagram Structure

```
graph TB
    subgraph VNet["<project>-<env>-vnet"]
        subgraph DBW_Private["Databricks Private Subnet"]
            ...
        end
        subgraph DBW_Public["Databricks Public Subnet"]
            ...
        end
        subgraph DBW_PE["Databricks PE Subnet"]
            ...
        end
    end

    External Databricks services...
    Traffic flow arrows...
```

### Expected Diagrams

Generate one diagram per in-scope environment root from the repository rules.

## Phase 4: High-Level Explanation

For each purpose group (from Phase 2) that has actual resources:

- **What it does**: 1-2 sentence summary
- **Key resources**: Azure resources and their Terraform modules
- **How it connects**: subnet, private endpoints, what it talks to
- **Environment differences**: dev vs prod (SKU, scaling, redundancy)

Use H2 headings per group. Omit empty groups. Keep it engineer-friendly — no filler text.

## Phase 5: Output Format

Save to `docs/architecture.md`:

```markdown
# Infrastructure Architecture

> Auto-generated architecture overview of the Azure infrastructure deployed via Terraform.

## Environments

| Environment | Region | Project | Terraform Root |
|-------------|--------|---------|----------------|
| <env-1> | <region> | <project> | `infra/<env-1>` |
| <env-2> | <region> | <project> | `infra/<env-2>` |
| ... | ... | ... | ... |

---

## <Environment 1>

### Architecture Diagram — <Environment 1>

<Mermaid diagram for dev>

### <Environment 1> Notes
<Key characteristics: SKUs, scaling limits, conditional resources absent in dev>

---

## <Environment 2>

### Architecture Diagram — <Environment 2>

<Mermaid diagram for prod>

### <Environment 2> Notes
<Key characteristics: SKUs, scaling, backup policies, additional private endpoints>

---

## Components by Purpose

### Networking
<explanation>

### Compute
<explanation>

... (all applicable groups) ...

## Traffic Flow Summary

<Brief description of how traffic enters the system and flows between components>
```

**Environment Notes** must call out:
- Resources unique to that environment (e.g. Recovery Services Vault only in prod)
- SKU/tier differences (e.g. `Standard_B2s` in dev vs `Standard_D4as_v5` in prod)
- Conditional resources absent (e.g. "AI Search private endpoints not created in dev")
- Scaling parameters (node pool min/max, capacity, TPM allocations)

## Phase 6: Quality Checklist

Before saving:
- [ ] All generated Mermaid diagrams render without syntax errors
- [ ] Each diagram only contains resources that exist in that specific environment
- [ ] Conditional resources appear only in the correct environment diagram
- [ ] Every Terraform module is represented in at least one diagram and in the explanation
- [ ] Subnet assignments match the network module definitions
- [ ] Cross-module connectivity is accurate (traced from actual `subnet_id`, `depends_on`, and input references)
- [ ] No speculative content — everything is grounded in Terraform code
- [ ] Dev and prod diagrams use the same layout structure for easy comparison
- [ ] Environment names, roots, and regions align with repository configuration

## Completion Summary

Report:
- Total modules documented
- Total resources identified
- Per-environment breakdown: modules and resource count per environment
- Number of Mermaid diagrams generated
- Files created or updated
- Any modules or resources that were unclear or need manual review
