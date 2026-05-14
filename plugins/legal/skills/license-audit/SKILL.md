---
name: license-audit
description: "Audit package licenses in a repository for copyleft (GPL, AGPL, LGPL) and non-permissive risks. Covers npm, pip, Go, Rust, Ruby, Java, and .NET dependency license scanning, SPDX classification, transitive dependency analysis, and alternative recommendations. Use when adding dependencies, updating packages, or preparing a deliverable for a client. Do not use for security vulnerability scanning."
---

# License Audit

## When to Use This Skill

Use when checking whether new or updated packages in a repository have licenses compatible with proprietary client delivery. Thinking Machines builds custom solutions and customizes templates for clients — all dependencies must be permissive enough for closed-source, commercial distribution.

## License Classification

### Permissive (allowed)

These licenses allow use in proprietary/commercial projects without source disclosure obligations:

| License | SPDX ID |
|---------|---------|
| MIT | MIT |
| Apache 2.0 | Apache-2.0 |
| BSD 2-Clause | BSD-2-Clause |
| BSD 3-Clause | BSD-3-Clause |
| ISC | ISC |
| Unlicense | Unlicense |
| CC0 1.0 | CC0-1.0 |
| 0BSD | 0BSD |
| Python-2.0 | PSF-2.0 |
| Zlib | Zlib |
| WTFPL | WTFPL |

### Copyleft / Restricted (flag for review)

These licenses require derivative works to be distributed under the same terms — **incompatible with proprietary client deliverables** unless an exception applies:

| License | SPDX ID | Risk |
|---------|---------|------|
| GNU GPL v2/v3 | GPL-2.0, GPL-3.0 | **High** — must open-source the entire work |
| GNU AGPL v3 | AGPL-3.0 | **Critical** — triggers on network use, not just distribution |
| GNU LGPL v2.1/v3 | LGPL-2.1, LGPL-3.0 | **Medium** — OK if dynamically linked, not statically bundled |
| Mozilla Public License 2.0 | MPL-2.0 | **Low** — file-level copyleft only; OK if unmodified files are kept separate |
| Creative Commons ShareAlike | CC-BY-SA-4.0 | **High** — typically for content, not code, but check |
| EUPL | EUPL-1.2 | **High** — strong copyleft similar to GPL |

### Unknown / Custom (flag for manual review)

Any license not in the above tables, or packages with no declared license, must be reviewed manually. Treat unlicensed packages as **high risk** — no license means no permission to use.

## Process

### 1. Detect Package Ecosystems

Scan the repository root and common subdirectories for manifest files:

| Ecosystem | Manifest Files |
|-----------|---------------|
| Node.js / npm | `package.json`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml` |
| Python | `requirements.txt`, `requirements*.txt`, `pyproject.toml`, `setup.py`, `Pipfile`, `poetry.lock` |
| Go | `go.mod`, `go.sum` |
| Rust | `Cargo.toml`, `Cargo.lock` |
| Ruby | `Gemfile`, `Gemfile.lock` |
| Java/Kotlin | `pom.xml`, `build.gradle`, `build.gradle.kts` |
| .NET | `*.csproj`, `packages.config` |

### 2. Extract Dependency Licenses

Use the appropriate tool for each detected ecosystem.

### 3. Classify Each Dependency

For every dependency found:
1. Match the license string against the classification tables above
2. Normalize license identifiers to SPDX format when possible
3. Flag `OR` expressions — the **most permissive** option applies if the user can choose
4. Flag `AND` expressions — **all** terms must be satisfied

### 4. Check for Changes (Diff Mode)

When auditing new or updated packages specifically, compare against the previous state.

### 5. Generate Report

Output a structured report with three sections: **Approved**, **Flagged**, and **Unknown**.

### 6. Recommend Alternatives for Flagged Packages

For each flagged package, search for a permissively-licensed alternative.

### 7. Document Exceptions

If a copyleft-licensed package must be kept, document the package, license, rationale, exception, and approval.

## Special Considerations for Thinking Machines Projects

- **Client deliverables are proprietary** — assume all projects will be delivered as closed-source unless explicitly stated otherwise.
- **Templates and boilerplates** — when TM customizes a template, all added dependencies must still be audited.
- **Dev-only dependencies** — packages used only in development/testing have lower risk since they are not distributed to clients. Still flag GPL/AGPL dev dependencies but note the reduced risk.
- **Transitive dependencies** — a permissive top-level package that bundles or statically links a copyleft dependency inherits the copyleft obligation. Always check the full dependency tree.
- **SaaS/hosted deployments** — if the project is deployed as a service (not distributed as software), AGPL is the only copyleft license that triggers. Confirm the deployment model before making this exception.
