---
name: manual-testing-best-practices
description: "Guide manual testing efforts with structured test plans, clear bug reporting, multi-environment coverage, exploratory testing, usability evaluation, and balanced functional and non-functional testing. Use when planning, executing, or reviewing manual or exploratory testing efforts. Do not use for automated test suite design."
---

# Manual Testing Best Practices

## When to Use This Skill

Use when planning, executing, or reviewing manual testing efforts — exploratory testing, acceptance testing, usability testing, or any scenario where automated tests are not feasible or sufficient. Applicable to web, mobile, desktop, and API testing.

## Core Principles

Manual testing validates software from a real user's perspective. It catches issues that automation misses: usability friction, visual inconsistencies, confusing workflows, and edge cases that emerge from spontaneous interaction.

## Process

### 1. Define a Clear Testing Objective

Every manual testing session must have a goal. Before starting, confirm:
- What feature or functionality is being tested
- What the expected outcome should be
- Which risks or failure modes are the primary concern

### 2. Test from the User's Perspective

Step away from the developer/QA mindset and think like a real user.

### 3. Cover All Test Dimensions

| Dimension | What to Test |
|---|---|
| **Happy path** | Normal, expected conditions |
| **Negative testing** | Invalid inputs, unexpected user behavior, missing data |
| **Edge cases** | Very large inputs, unusual action sequences, rapid interactions |
| **Boundary testing** | Limits of acceptable input values (min, max, empty, overflow) |

### 4. Test Across Multiple Environments

| Environment | Purpose |
|---|---|
| **Development** | Early-stage verification after coding |
| **Staging / Pre-production** | Final validation in a production replica |
| **Production** | Post-deployment verification of critical paths |

### 5. Include Non-Functional Testing

| Area | What to Check |
|---|---|
| **Performance** | Does the application feel responsive? |
| **Security baseline** | Are sensitive fields masked? Does the app enforce auth? |
| **Usability** | Can a new user complete core tasks without confusion? |
| **Accessibility** | Keyboard navigation, color contrast, screen reader compatibility |

### 6. Document Everything

- Test cases and scripts
- Execution results with timestamps
- Test logs
- Environment details

## Bug Reporting

Every bug report must include:

| Field | Content |
|---|---|
| **Title** | Clear, descriptive summary |
| **Steps to reproduce** | Detailed, numbered steps |
| **Expected vs. actual result** | What should have happened vs. what actually happened |
| **Environment** | OS, browser/version, device, network conditions |
| **Severity / priority** | Impact assessment and urgency |
| **Attachments** | Screenshots, screen recordings, console logs |

## Quality Checklist

- [ ] Testing objective was defined before the session started
- [ ] Tests covered happy paths, negative cases, edge cases, and boundary conditions
- [ ] Tests ran in at least the staging environment
- [ ] Non-functional aspects (performance, usability, accessibility, security) were evaluated
- [ ] All bugs are documented with reproducible steps, environment details, and severity
- [ ] Test execution results and logs are recorded
- [ ] Findings were shared with the development team
