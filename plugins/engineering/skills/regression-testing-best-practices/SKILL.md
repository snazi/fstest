---
name: regression-testing-best-practices
description: "Design, maintain, and scale regression test suites that prevent previously working functionality from breaking after code changes, bug fixes, or feature additions. Covers impact analysis, selective regression, test prioritization, stability monitoring, and code change validation. Use when building or reviewing regression suites. Do not use for smoke testing (use smoke-testing-best-practices instead)."
---

# Regression Testing Best Practices

## When to Use This Skill

Use when building a new regression test suite, reviewing an existing one, choosing a regression testing strategy, or deciding which tests to automate vs. keep manual. Applicable to any stack — web, API, data pipelines, or ML model services.

## Core Principles

Regression testing answers one question: **does everything that worked before still work now?** It is not unit testing (isolated components), integration testing (module interactions), or smoke testing (critical-path gating). It is the long-term stability guarantee across releases.

## Process

### 1. Perform Impact Analysis

Before selecting which tests to run, determine which parts of the system are affected by the change:
- Use code coverage analyzers or dependency graphs to map affected modules.
- Prioritize modules that interact with modified code.
- Document the scope of impact to justify test selection decisions.

### 2. Choose a Regression Strategy

| Strategy | When to Use | Trade-off |
|---|---|---|
| **Retest all** | Major refactors, early-stage projects | Full coverage but slow |
| **Selective regression** | Modular systems with frequent, scoped changes | Fast feedback but requires accurate dependency mapping |
| **Prioritized regression** | Time-limited cycles or large systems | Covers critical paths first |
| **Automated regression** | Any project with a CI/CD pipeline | Fast, scalable, repeatable |

### 3. Build the Regression Suite

- Cover critical business workflows and previously fixed bugs.
- Keep each test atomic and independent.
- Use descriptive names: `test_updated_transform_preserves_output_schema`.
- Use controlled fixtures, mocks, or synthetic datasets.

### 4. Decide What to Automate

Automate stable, high-frequency, high-value scenarios. Keep manual tests for scenarios requiring human interpretation or volatile functionality.

### 5. Integrate into CI/CD

Trigger regression tests automatically on every pull request or merge to main. Configure the pipeline to fail if regression tests detect new issues.

### 6. Tag and Prioritize Tests

| Priority | Coverage | Run Frequency |
|---|---|---|
| **P0 — Critical** | Authentication, payments, core data paths | Every commit |
| **P1 — High** | Dashboard rendering, API contracts | Every PR merge |
| **P2 — Medium** | Secondary workflows | Nightly or pre-release |
| **P3 — Low** | Cosmetic, layout adjustments | Pre-release only |

### 7. Monitor, Review, and Prune

Track pass/fail rate, execution time, coverage, and flakiness rate. Fix flaky tests immediately. Audit and prune the suite at least once per release cycle.

## Quality Checklist

- [ ] Suite covers all critical business workflows and previously fixed bugs
- [ ] Each test is atomic — validates one behavior, no shared state between tests
- [ ] Automation covers stable, high-frequency, high-value scenarios
- [ ] Suite is integrated into CI/CD and blocks merges on failure
- [ ] Tests are tagged by priority and run at appropriate frequencies
- [ ] Flaky tests are tracked, quarantined, and resolved — not ignored
- [ ] Test data uses controlled fixtures, not live sources
- [ ] Suite is audited and pruned at least once per release cycle
