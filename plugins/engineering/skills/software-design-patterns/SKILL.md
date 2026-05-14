---
name: software-design-patterns
description: "Named, reusable solutions to recurring structural and behavioral problems including factory, strategy, observer, repository, decorator, adapter, builder, command, CQRS, and event sourcing patterns. Use when introducing a new abstraction, evaluating how dependencies are wired, identifying misapplied patterns, or recognizing a recurring problem with a well-understood named solution. Do not use for design principles (use software-design-principles instead)."
---

# Software Design Patterns

Named, reusable solutions to recurring structural and behavioral problems. Apply them when the problem fits; don't force them.

## Design Techniques

Foundational techniques for structuring dependencies and composing behavior.

- **Composition over Inheritance** — prefer assembling behavior from small, focused units over deep class hierarchies; keeps components independently reusable.
- **Dependency Injection** — pass dependencies in rather than constructing them internally; decouples components and makes them testable in isolation.
- **Inversion of Control** — let a framework or container manage object lifecycles and wiring rather than doing it manually; separates configuration from logic.
- **Interface-Based Programming** — depend on abstractions, not concrete implementations; enables substitution, mocking, and future extension without changing callers.

## Creational

Patterns that control how objects are created.

- **Factory / Factory Method** — delegate object creation to a dedicated factory rather than calling constructors directly.
- **Abstract Factory** — create families of related objects without specifying their concrete classes.
- **Builder** — construct complex objects step by step, separating construction logic from representation.
- **Singleton** — ensure a class has exactly one instance and provide a global access point (use sparingly).

## Structural

Patterns that define how objects and classes are composed.

- **Adapter** — convert an interface into one a client expects; bridge incompatible interfaces.
- **Decorator** — extend behavior by wrapping objects rather than subclassing.
- **Facade** — provide a simplified interface over a complex subsystem.
- **Proxy** — control access to an object, transparently adding caching, logging, or access control.
- **Composite** — treat individual objects and compositions uniformly through a shared interface.

## Behavioral

Patterns that define how objects communicate and distribute responsibility.

- **Strategy** — define a family of algorithms, encapsulate each, and make them interchangeable.
- **Observer** — decouple event producers from consumers using subscriptions.
- **Command** — encapsulate a request as an object to support queuing, undo, and logging.
- **Chain of Responsibility** — pass a request along a chain of handlers until one processes it.
- **Template Method** — define the skeleton of an algorithm in a base, deferring specific steps to subclasses.
- **State** — allow an object to alter its behavior when its internal state changes.
- **Iterator** — provide a standard way to traverse a collection without exposing its internal structure.
- **Mediator** — centralize communication between components to reduce direct dependencies.

## Architectural

Patterns that define the high-level structure of a system or service.

- **Repository** — abstract data access behind an interface; decouple business logic from persistence.
- **Service Layer** — define an application boundary with a layer of services that coordinate domain logic.
- **CQRS** (Command Query Responsibility Segregation) — separate read and write models to reduce complexity at scale.
- **Event Sourcing** — store state as a sequence of immutable events rather than mutable current-state snapshots.
- **MVC / MVP / MVVM** — separate presentation, logic, and data concerns across well-defined layers.
