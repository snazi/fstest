---
name: terraform-skill
description: "Comprehensive Terraform and OpenTofu guidance covering HCL infrastructure as code, modules, testing (native test framework and Terratest), CI/CD pipelines, security scanning (trivy, checkov), state management, and production patterns. Use when creating, reviewing, or refactoring Terraform/OpenTofu configurations, modules, or tests. Do not use for cloud platform questions unrelated to Terraform/OpenTofu."
---

# Terraform Skill for Claude

Comprehensive Terraform and OpenTofu guidance covering testing, modules, CI/CD, and production patterns. Based on terraform-best-practices.com and enterprise experience.

## When to Use This Skill

**Activate this skill when:**
- Creating new Terraform or OpenTofu configurations or modules
- Setting up testing infrastructure for IaC code
- Deciding between testing approaches (validate, plan, frameworks)
- Structuring multi-environment deployments
- Implementing CI/CD for infrastructure-as-code
- Reviewing or refactoring existing Terraform/OpenTofu projects
- Choosing between module patterns or state management approaches

**Don't use this skill for:**
- Basic Terraform/OpenTofu syntax questions (Claude knows this)
- Provider-specific API reference (link to docs instead)
- Cloud platform questions unrelated to Terraform/OpenTofu

## Core Principles

### 1. Code Structure Philosophy

**Module Hierarchy:**

| Type | When to Use | Scope |
|------|-------------|-------|
| **Resource Module** | Single logical group of connected resources | VPC + subnets, Security group + rules |
| **Infrastructure Module** | Collection of resource modules for a purpose | Multiple resource modules in one region/account |
| **Composition** | Complete infrastructure | Spans multiple regions/accounts |

**Hierarchy:** Resource -> Resource Module -> Infrastructure Module -> Composition

**Directory Structure:**
```
environments/        # Environment-specific configurations
+-- prod/
+-- staging/
+-- dev/

modules/            # Reusable modules
+-- networking/
+-- compute/
+-- data/

examples/           # Module usage examples (also serve as tests)
+-- complete/
+-- minimal/
```

**Key principle from terraform-best-practices.com:**
- Separate **environments** (prod, staging) from **modules** (reusable components)
- Use **examples/** as both documentation and integration test fixtures
- Keep modules small and focused (single responsibility)

**For detailed module architecture, see:** [Code Patterns: Module Types & Hierarchy](references/code-patterns.md)

### 2. Naming Conventions

**Resources:**
```hcl
# Good: Descriptive, contextual
resource "aws_instance" "web_server" { }
resource "aws_s3_bucket" "application_logs" { }

# Good: "this" for singleton resources (only one of that type)
resource "aws_vpc" "this" { }
resource "aws_security_group" "this" { }

# Avoid: Generic names for non-singletons
resource "aws_instance" "main" { }
resource "aws_s3_bucket" "bucket" { }
```

**Singleton Resources:**

Use `"this"` when your module creates only one resource of that type.

**Variables:**
```hcl
# Prefix with context when needed
var.vpc_cidr_block          # Not just "cidr"
var.database_instance_class # Not just "instance_class"
```

**Files:**
- `main.tf` - Primary resources
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `versions.tf` - Provider versions
- `data.tf` - Data sources (optional)

## Testing Strategy Framework

### Decision Matrix: Which Testing Approach?

| Your Situation | Recommended Approach | Tools | Cost |
|----------------|---------------------|-------|------|
| **Quick syntax check** | Static analysis | `terraform validate`, `fmt` | Free |
| **Pre-commit validation** | Static + lint | `validate`, `tflint`, `trivy`, `checkov` | Free |
| **Terraform 1.6+, simple logic** | Native test framework | Built-in `terraform test` | Free-Low |
| **Pre-1.6, or Go expertise** | Integration testing | Terratest | Low-Med |
| **Security/compliance focus** | Policy as code | OPA, Sentinel | Free |
| **Cost-sensitive workflow** | Mock providers (1.7+) | Native tests + mocking | Free |
| **Multi-cloud, complex** | Full integration | Terratest + real infra | Med-High |

**For detailed testing guides, see:**
- **[Testing Frameworks Guide](references/testing-frameworks.md)**
- **[Quick Reference](references/quick-reference.md#testing-approach-selection)**

## Code Structure Standards

### Resource Block Ordering

**Strict ordering for consistency:**
1. `count` or `for_each` FIRST (blank line after)
2. Other arguments
3. `tags` as last real argument
4. `depends_on` after tags (if needed)
5. `lifecycle` at the very end (if needed)

### Variable Block Ordering

1. `description` (ALWAYS required)
2. `type`
3. `default`
4. `validation`
5. `nullable` (when setting to false)

**For complete structure guidelines, see:** [Code Patterns: Block Ordering & Structure](references/code-patterns.md#block-ordering--structure)

## Count vs For_Each: When to Use Each

| Scenario | Use | Why |
|----------|-----|-----|
| Boolean condition (create or don't) | `count = condition ? 1 : 0` | Simple on/off toggle |
| Simple numeric replication | `count = 3` | Fixed number of identical resources |
| Items may be reordered/removed | `for_each = toset(list)` | Stable resource addresses |
| Reference by key | `for_each = map` | Named access to resources |
| Multiple named resources | `for_each` | Better maintainability |

**For migration guides and detailed examples, see:** [Code Patterns: Count vs For_Each](references/code-patterns.md#count-vs-for_each-deep-dive)

## Module Development

### Standard Module Structure

```
my-module/
+-- README.md           # Usage documentation
+-- main.tf             # Primary resources
+-- variables.tf        # Input variables with descriptions
+-- outputs.tf          # Output values
+-- versions.tf         # Provider version constraints
+-- examples/
|   +-- minimal/        # Minimal working example
|   +-- complete/       # Full-featured example
+-- tests/              # Test files
    +-- module_test.tftest.hcl
```

### Best Practices Summary

**Variables:**
- Always include `description`
- Use explicit `type` constraints
- Provide sensible `default` values where appropriate
- Add `validation` blocks for complex constraints
- Use `sensitive = true` for secrets

**Outputs:**
- Always include `description`
- Mark sensitive outputs with `sensitive = true`
- Consider returning objects for related values

**For detailed module patterns, see:**
- **[Module Patterns Guide](references/module-patterns.md)**
- **[Quick Reference](references/quick-reference.md#common-patterns)**

## CI/CD Integration

### Recommended Workflow Stages

1. **Validate** - Format check + syntax validation + linting
2. **Test** - Run automated tests (native or Terratest)
3. **Plan** - Generate and review execution plan
4. **Apply** - Execute changes (with approvals for production)

**For complete CI/CD templates, see:**
- **[CI/CD Workflows Guide](references/ci-cd-workflows.md)**
- **[Quick Reference](references/quick-reference.md#troubleshooting-guide)**

## Security & Compliance

### Essential Security Checks

```bash
# Static security scanning
trivy config .
checkov -d .
```

**For detailed security guidance, see:**
- **[Security & Compliance Guide](references/security-compliance.md)**

## Version Management

### Strategy by Component

| Component | Strategy | Example |
|-----------|----------|---------|
| **Terraform** | Pin minor version | `required_version = "~> 1.9"` |
| **Providers** | Pin major version | `version = "~> 5.0"` |
| **Modules (prod)** | Pin exact version | `version = "5.1.2"` |
| **Modules (dev)** | Allow patch updates | `version = "~> 5.1"` |

**For detailed version management, see:** [Code Patterns: Version Management](references/code-patterns.md#version-management)

## Detailed Guides

This skill uses **progressive disclosure** - essential information is in this main file, detailed guides are available when needed:

**Reference Files (in references/):**
- **[Testing Frameworks](references/testing-frameworks.md)** - In-depth guide to static analysis, native tests, and Terratest
- **[Module Patterns](references/module-patterns.md)** - Module structure, variable/output best practices
- **[CI/CD Workflows](references/ci-cd-workflows.md)** - GitHub Actions, GitLab CI templates, cost optimization
- **[Security & Compliance](references/security-compliance.md)** - Trivy/Checkov integration, secrets management
- **[Quick Reference](references/quick-reference.md)** - Command cheat sheets, decision flowcharts

**Test Files (in tests/):**
- **[Baseline Scenarios](tests/baseline-scenarios.md)** - RED phase test scenarios
- **[Compliance Verification](tests/compliance-verification.md)** - GREEN phase verification
- **[Rationalization Table](tests/rationalization-table.md)** - REFACTOR phase tracking

## License

This skill is licensed under the **Apache License 2.0**. See the LICENSE file for full terms.

**Copyright (c) 2026 Anton Babenko**
