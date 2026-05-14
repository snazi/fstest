---
name: engineering-consulting
description: "Concrete day-to-day engineering and consulting habits covering code quality, robustness, security, async patterns, testing, maintainability, client delivery standards, and stakeholder empathy. Use when evaluating engineering standards, reviewing consulting deliverables, or establishing team-wide best practices. Do not use for specific framework guidance (use framework-specific skills instead)."
---

# Engineering Best Practices

Concrete "how" habits applied at the code, testing, and process level. These complement principles and patterns with day-to-day discipline.


## Code Quality

- **Explicit Typing** — annotate types on all function signatures, return values, and data structures; never rely on implicit inference for public APIs.
- **Pure Functions and Immutability** — prefer functions without side effects and data that is not mutated in place.
- **Small, Focused Functions** — each function should do one thing; keep them short and easy to reason about independently.
- **Early Return / Guard Clauses** — handle error and edge cases at the top of a function to avoid deep nesting.
- **Meaningful Naming** — names should reveal intent; avoid abbreviations, generic names (`data`, `manager`), and misleading labels.
- **Avoid Magic Numbers and Strings** — replace literals with named constants that communicate their purpose.
- **Code for the Reader** — optimize for clarity and maintainability over cleverness; the next engineer is your audience.
- **Consistent Formatting** — apply a consistent, automated style (linter/formatter) across the codebase; eliminate style debates.

## Robustness and Safety

- **Fail Fast** — validate inputs and assert invariants early; surface errors at the boundary, not deep inside logic.
- **Defensive Programming** — anticipate invalid inputs, unexpected states, and external failures; handle them explicitly rather than assuming the happy path.
- **Explicit Error Handling** — never silently swallow exceptions; log, surface, or propagate errors deliberately with enough context to diagnose. Before adding a handler: check whether the exception can actually occur and whether it is already handled upstream.
- **Retry Transient Failures** — distinguish retryable errors (network timeouts, rate limits, transient service failures) from non-retryable ones (validation errors, auth failures). Retry with exponential backoff; fail fast on non-retryable errors.
- **Never Leak Internal Details** — stack traces, internal paths, and system state must never be exposed to external clients in production; sanitize error responses at the boundary.
- **Idempotency** — design operations so that applying them multiple times produces the same result as applying them once.
- **Graceful Degradation** — when a non-critical component fails, the system should continue to function in a reduced capacity.
- **Least Privilege** — grant only the permissions actually needed; minimize the blast radius of a failure or breach.

## Testing

- **Test at the Right Level** — unit-test pure logic, integration-test boundaries, and e2e-test critical user flows.
- **Arrange-Act-Assert** — structure each test clearly: set up state, perform the action, then assert the outcome.
- **One Behavior per Test** — each test case should verify a single behavior or code path; split multiple assertions into separate tests.
- **No Test Interdependence** — tests must be runnable in any order and must not share mutable state.
- **Test the Behavior, Not the Implementation** — assert on observable outcomes, not on internal calls or private details.
- **High Coverage on Critical Paths** — prioritize coverage where failure cost is highest: auth, payments, data mutations.

## Security

- **Never Hardcode Secrets** — load all secrets and credentials from environment variables or a secrets manager; never commit them to source control.
- **Authentication by Default** — all API endpoints must require authentication unless explicitly public.
- **Authorization After Authentication** — verify permissions and roles after confirming identity; never assume an authenticated user is authorized.
- **Validate and Sanitize All Inputs** — validate on the server; never trust client-supplied data. Use parameterized queries; never concatenate user input into SQL or shell commands.
- **Never Log Sensitive Data** — passwords, tokens, API keys, and PII must never appear in logs; sanitize before writing.

## Async and Concurrency

- **Async for I/O** — use async/await for all I/O-bound operations (network, disk, database); never block the event loop with synchronous calls.
- **Parallel Where Independent** — run independent async operations concurrently rather than sequentially; await them together.
- **Caching** — cache the results of expensive or repeated operations (computation, I/O, external calls) at an appropriate layer; invalidate explicitly.

## Maintainability

- **Continuous Refactoring** — improve internal structure incrementally without changing external behavior; pay down tech debt as you go.
- **Boy Scout Rule** — leave the code cleaner than you found it; fix small issues as you encounter them.
- **Document Intent, Not Mechanics** — comments should explain why, not what; let well-named code speak for itself.
- **Explicit Versioning and Deprecation** — mark breaking changes, deprecated APIs, and migration paths clearly; never silently remove or alter contracts.
- **Observability by Default** — emit structured logs with appropriate level and context at key decision points; expose metrics and traces so behavior is diagnosable in production.


# Consulting Best Practices

## Context Awareness

- **Repository Awareness** - always check the documentation, and the code for context that is relevant to what is being built. Start with the documents, then validate with the relevant code.

- **External Documentation** - whenever available, check online and external documentation that is relevant to development.

## Business & Client Empathy

- **Stakeholder Profile** - having a profile of the stakeholder allows for more targeted decisions on implementation.

- **Project Context** - always refer to what the goals of the project are when making technical decisions and implementation.
