# Architecture

Stack decision and rationale: [ADR-0001](70-decisions/ADR-0001-flutter.md).
Related: [`21-DATA-MODEL.md`](21-DATA-MODEL.md), [`22-UNITS.md`](22-UNITS.md),
[`23-NAVIGATION.md`](23-NAVIGATION.md).

## The one hard rule

**`lib/domain/` imports nothing from Flutter and nothing from `lib/data/`.**

Everything that can be *silently wrong* — estimated 1RM, volume load, sets per
muscle group, progression targets, unit conversion, plate solving — lives there
as plain Dart functions over plain Dart data. No widgets, no database types, no
`BuildContext`, no I/O.

This is the difference between a tracker you trust and one you don't. A wrong
number in a chart is worse than a missing chart, because you'd act on it. Pure
functions are exhaustively testable against the worked fixtures in
[`40-ANALYTICS-SPEC.md`](40-ANALYTICS-SPEC.md), and they port to any future UI
without modification.

Enforced by lint (`import_lint` or an equivalent layer rule) in CI, not by
good intentions — see [`61-CI-CD.md`](61-CI-CD.md).

## Layers

```
lib/
  main.dart
  app.dart                    root widget, theme wiring, router mount

  core/                       cross-cutting, no feature knowledge
    units/                    Mass, Distance, Duration value objects  → 22-UNITS
    formatting/               display formatters, locale-aware
    result/                   Result / failure types
    di/                       provider container setup
    extensions/

  domain/                     PURE DART. No Flutter, no data-layer imports.
    entities/                 Exercise, Workout, SetEntry, Routine, …
    analytics/                e1rm.dart, volume.dart, muscle_sets.dart,
                              consistency.dart, prs.dart, trends.dart
    progression/              rules.dart, engine.dart
    plates/                   plate_solver.dart
    validation/

  data/                       persistence & external boundaries
    db/                       Drift database, tables, DAOs, migrations
    repositories/             the only thing features talk to
    seed/                     exercise catalogue loader
    io/                       export, import, backup
    platform/                 notification, health, file-picker adapters

  features/                   one folder per feature area
    shell/                    app scaffold, navigation, dashboard
    exercises/                catalogue browse, detail, custom exercise editor
    routines/                 routine list, editor, day editor
    logger/                   active workout, set rows, session summary
    history/                  workout history, workout detail
    analytics/                charts and insight screens
    body/                     bodyweight, measurements
    settings/                 all preference screens
```

Each `features/<area>/` folder contains:

```
  <area>/
    presentation/    screens, widgets
    application/     Riverpod providers, controllers, view models
```

Features may depend on `core/`, `domain/`, and `data/repositories/`. Features
must **not** import `data/db/` directly — repositories are the seam. Features
must not import each other; shared widgets go to `core/` or
`features/shell/widgets/`.

## Dependency direction

```
features ──► data/repositories ──► data/db
    │                │
    └──────► domain ◄┘          (domain depends on nothing internal)
    └──────► core
```

## Chosen dependencies

| Package | Role | Why this one |
|---|---|---|
| `flutter_riverpod` + `riverpod_generator` | State & DI | Compile-time safe, testable without a widget tree, no `BuildContext` dependency for business logic. Overriding providers makes integration tests cheap. |
| `go_router` | Routing | Declarative, deep-link ready (needed for `F-NAV-002`, widgets and app shortcuts), and the closest thing to a standard. |
| `drift` | Database | Typed SQL, real generated migrations, streaming queries that drive reactive UI, and a genuine test harness (in-memory DB). See [ADR-0005](70-decisions/ADR-0005-drift.md). |
| `freezed` + `json_serializable` | Models | Immutable entities, exhaustive union types for things like set type and progression rule, free `copyWith` and equality. |
| `fl_chart` | Charts | The strongest charting option in the ecosystem; renders in-widget so it themes correctly in light and dark without bespoke work (`F-THM-004`). |
| `flutter_local_notifications` | Rest timer alerts | Behind a `RestTimerService` interface so the iOS port touches one adapter, not every call site. |
| `shared_preferences` | Simple settings | Small key/value settings only. Anything with structure goes in the database. |
| `path_provider`, `file_picker`, `share_plus` | Export/import I/O | Standard, cross-platform. |
| `intl` | Formatting & i18n | Locale-aware numbers and dates from the start (`F-I18N-002`). |

Rules for adding a dependency: it must be cross-platform (Android **and** iOS),
actively maintained, and either widely adopted or trivially replaceable. Any
platform-specific package must sit behind an interface in `data/platform/`.
Adding one is an ADR-worthy decision if it touches the domain or the database.

## Cross-platform discipline

iOS has no timeline but is a real goal ([`10-VISION.md`](10-VISION.md)). The
standing constraints:

1. No Android-only package is called directly from `features/` or `domain/` —
   always via a `data/platform/` interface with an Android implementation and a
   documented iOS gap.
2. Nothing depends on Android-specific filesystem semantics; all paths go
   through `path_provider`.
3. Background execution assumptions are documented per platform in `F-TIM-003` —
   this is the single biggest behavioural divergence between the two.
4. UI uses Material components throughout, including on iOS. Matching Cupertino
   idioms is not a goal; consistency and maintainability are.

## Reactive data flow

Drift's streaming queries are the backbone:

```
Drift stream (watchX) ──► Repository (maps rows → domain entities)
                              │
                              ▼
                     Riverpod StreamProvider
                              │
                              ▼
                    Widget rebuilds on change
```

Consequence: writes never need manual UI invalidation. Completing a set writes
to the database, and the session screen, running-volume header, and history all
update from the same stream. This also makes crash recovery (`F-LOG-007`) fall
out naturally — the database *is* the session state, not a mirror of it.

Derived analytics are computed by pure `domain/analytics/` functions over the
entity lists the repositories emit, memoised in providers keyed by their inputs.

## Testing shape

| Layer | Test type | Bar |
|---|---|---|
| `domain/` | Pure unit tests | Near-total coverage, mandatory. Every analytics function needs the worked fixture from `40-ANALYTICS-SPEC.md`. |
| `data/` | Integration against in-memory Drift | Every migration path tested; repository mapping tested. |
| `features/application/` | Provider tests with overridden repositories | Core flows. |
| `features/presentation/` | Widget tests | The set row and active-workout screen at minimum — that's the critical path. |
| End to end | `integration_test` | One smoke test: start workout → log sets → finish → appears in history. |

Details and the definition of done: [`60-ENGINEERING.md`](60-ENGINEERING.md).

## Deliberate omissions

- **No repository interface abstractions with a single implementation.** Concrete
  repositories, overridden in tests via Riverpod. Interfaces get added when a
  second implementation actually exists.
- **No BLoC/redux-style event plumbing.** Riverpod providers plus immutable
  state is sufficient at this scale.
- **No code generation beyond `freezed`, `drift`, `riverpod_generator` and
  `json_serializable`.** Build times matter more than saved keystrokes.
- **No dependency injection framework beyond Riverpod.**
