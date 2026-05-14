---
name: software-design-principles
description: "Timeless structural design principles including SOLID, DRY, KISS, YAGNI, Separation of Concerns, encapsulation, cohesion, coupling, Law of Demeter, and layered architecture. Use when evaluating module boundaries, assessing coupling and cohesion, deciding where logic belongs, or articulating why a design feels structurally wrong. Do not use for named design patterns (use software-design-patterns instead)."
---

# Core Design Principles

Timeless "why" rules that guide every design decision, regardless of language, pattern, or technology.

## Simplicity

- **KISS** (Keep It Simple, Stupid) — prefer the simplest solution that works; avoid unnecessary complexity.
- **YAGNI** (You Aren't Gonna Need It) — don't add functionality until it is actually needed.
- **Avoid Premature Optimization** — write clear, correct code first; optimize only after profiling reveals a real bottleneck.
- **Principle of Least Astonishment** — code should behave in a way that least surprises its readers and users.

## Correctness and Knowledge

- **DRY** (Don't Repeat Yourself) — every piece of knowledge should have a single, authoritative representation; avoid duplicating logic or data.
- **Single Source of Truth** — each piece of state should live in exactly one place; derive everything else from it.
- **Explicit over Implicit** — make intent, dependencies, and behavior visible in the code itself rather than relying on convention, magic, or hidden side effects.

## Structure and Boundaries

- **Separation of Concerns** — keep distinct responsibilities in distinct modules; avoid mixing unrelated logic.
- **SOLID** — Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion.
- **Encapsulation** — hide internal state and implementation details; expose only what is necessary through a stable interface.
- **Cohesion over Coupling** — maximize relatedness within a module; minimize dependencies across module boundaries.
- **Law of Demeter** — a unit should only talk to its immediate collaborators; avoid deep chain access (`a.b.c.d()`).
- **Modularity** — decompose systems into self-contained, independently replaceable units with clear boundaries and minimal shared state.
- **Layered Architecture** — organize code into layers (presentation, application, domain, infrastructure) with dependencies pointing in one direction only.
