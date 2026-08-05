# ADR-0006 — Riverpod for state and dependency injection

**Status:** Accepted · 2026-08

## Context

Flutter has no consensus state-management answer. The app's needs are specific:
most state comes from database streams ([ADR-0005](ADR-0005-drift.md)), the
active workout is a singleton watched from many places, and analytics are
expensive derived values that must be memoised rather than recomputed on every
rebuild.

The business logic must also be testable without a widget tree — the correctness
bar in this project is high enough that testing through the UI is not acceptable.

## Options

**Riverpod.** Compile-safe, no `BuildContext` needed for business logic,
first-class async and stream providers, `.family` for keyed memoisation, and
provider overriding that makes testing trivial. Cost: its own vocabulary to
learn, and code generation for the modern API.

**BLoC.** Widely used, very explicit, good tooling. Cost: substantial event and
state boilerplate per feature — heavy for an app whose state is mostly "what the
database says".

**Provider.** Simpler and older. Cost: `BuildContext` dependence, weaker typing,
no built-in memoisation story.

**setState + InheritedWidget.** No dependency. Cost: doesn't scale past a few
screens, and offers nothing for cross-screen singletons like the active workout.

## Decision

**Riverpod**, with the four provider kinds and usage rules in
[`../23-NAVIGATION.md`](../23-NAVIGATION.md).

1. **Stream providers map directly onto Drift's streaming queries**, which is the
   backbone of the reactive flow. BLoC would add an event layer on top of
   something already reactive.
2. **`.family` memoisation is exactly what analytics need** — keyed on
   `(exerciseId, dateRange)`, computed once.
3. **Provider overriding is the testing story.** Override one repository
   provider and a whole feature is testable with no database and no widgets.
4. **No `BuildContext` in business logic**, which keeps `application/` layers
   plain Dart and fast to test.
5. **Less boilerplate** than BLoC, which matters for a solo project with ~160
   planned features.

Riverpod is also the DI mechanism; no separate container is introduced.

## Consequences

- Persistent state lives in the database and flows through providers. Widgets
  hold only genuinely ephemeral state — controllers, expansion, animation.
- Providers depend on repositories, never on Drift types, preserving the seam.
- Analytics providers must be keyed and memoised. Forgetting this is the obvious
  performance mistake in this app.
- `riverpod_generator` adds to the build-runner step already required by Drift
  and `freezed`.
- The active workout is a single provider watched everywhere — no duplicated
  session state, and therefore no synchronisation problem.

## Reversal cost

Low to medium. State management is concentrated in `features/*/application/`;
`domain/` and `data/` are untouched by it. A migration would be tedious and
mechanical rather than risky.
