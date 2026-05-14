---
name: smoke-testing-best-practices
description: "Design and maintain lightweight smoke test suites that verify critical user journeys, API health, infrastructure availability, and deployment readiness after every build or deployment. Use when designing a smoke test suite, reviewing existing smoke gates, or deciding which tests belong in a smoke gate vs deeper regression. Do not use for detailed regression or exploratory testing."
---

# Smoke Testing Best Practices

## When to Use This Skill

Use when designing a new smoke test suite, reviewing an existing one, or deciding which tests belong in a smoke gate vs. deeper regression. Applicable to any stack — web, API, mobile, or infrastructure.

## Core Principles

Smoke tests answer one question: **does this build float?** They are not regression tests, sanity tests, or exploratory tests. They verify that the most critical paths work at a fundamental level before investing time in deeper testing.

### What Smoke Tests Are

- A small, fast subset of tests targeting the application's most critical functionality.
- A build gate — if smoke fails, the build is rejected and not promoted to further testing.
- Broad but shallow: cover many areas, verify none exhaustively.

### What Smoke Tests Are Not

- Regression tests (thorough, detailed, covering edge cases).
- Sanity tests (post-fix verification of a specific change).
- A guarantee of a bug-free product.

## Process

### 1. Identify Critical Functionality

Analyze the application to determine its core purpose, key functions, and highest-impact user journeys. Prioritize:

- Functions where failure makes the application unusable (login, signup, core transaction).
- Functions with high complexity or frequent user interaction.
- Infrastructure dependencies (database connectivity, external API reachability, message queue health).

### 2. Design the Smoke Test Checklist

Every smoke suite should cover these categories:

| Category | Example Checks |
|---|---|
| **Launch** | Application starts without critical errors; health endpoint returns 200 |
| **Authentication** | Login with valid credentials succeeds; redirect to authenticated page works |
| **Core UI** | Main page renders; navigation between primary sections works |
| **Core API** | Key endpoints return expected status codes and response shapes |
| **Data** | Read path works (list/detail); write path works (create/update) |
| **Input validation** | Invalid data is rejected at the boundary |
| **Cross-browser / device** | Renders on Chrome, Firefox, Safari, Edge; responsive on mobile viewport |
| **Recovery** | Application recovers from transient failures |
| **Security baseline** | Auth-gated routes reject unauthenticated requests |

### 3. Write Smoke Test Cases

- **Focus on positive paths.** Save edge-case exploration for regression.
- **One assertion per concern.** Each test case targets a single critical behavior.
- **Keep tests independent.** No test should depend on the outcome of another smoke test.
- **Use descriptive names.** `test_login_redirects_to_dashboard` not `test_1`.

### 4. Integrate into CI/CD

- Run smoke tests automatically on every build before promoting to staging or production.
- Set smoke tests as a hard gate — a failing smoke test blocks the pipeline.
- Keep execution time under 5 minutes.

### 5. Monitor and Improve

Track pass/fail rate, execution time, test coverage of critical paths, and flakiness rate. Review and update the suite regularly.

## Quality Checklist

- [ ] Suite covers all critical user journeys identified with stakeholders
- [ ] No test depends on another test's state or outcome
- [ ] Suite completes in under 5 minutes
- [ ] Suite runs in CI and blocks promotion on failure
- [ ] Every test has a clear, descriptive name
- [ ] Flaky tests are tracked and resolved, not skipped
- [ ] Suite is reviewed and updated with each major feature release
