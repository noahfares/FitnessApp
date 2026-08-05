# ADR-0005 — Drift for persistence

**Status:** Accepted · 2026-08

## Context

The app is entirely local ([ADR-0002](ADR-0002-local-first.md)) and relational:
routines contain days contain exercises; workouts contain exercises contain sets.
Analytics aggregate across years of sets. The database is the app's whole state,
including in-progress sessions.

## Options

**Drift (SQLite).** Typed queries checked at compile time, generated migrations,
streaming queries that push updates into the UI, and an in-memory mode for tests.
Cost: code generation in the build loop.

**sqflite (raw SQLite).** Minimal, no generation. Cost: stringly-typed SQL,
hand-written mapping, hand-written migrations, no compile-time checking of
anything.

**Isar / Hive (NoSQL).** Fast, no SQL. Cost: relational aggregation over years of
sets is the app's main query pattern, and a document store is the wrong shape for
it. Migration stories are also weaker.

**Realm.** Capable, with a sync story — which is deliberately unwanted here.

## Decision

**Drift.**

1. **Streaming queries are the architecture.** `watch` on a query drives the
   reactive flow in [`../20-ARCHITECTURE.md`](../20-ARCHITECTURE.md). Completing
   a set writes once, and the session screen, running totals, and history all
   update with no manual invalidation.
2. **Migrations are first-class.** Schema snapshots are committed, historical
   schemas can be constructed in tests, and every upgrade path is testable —
   required by the policy in [`../21-DATA-MODEL.md`](../21-DATA-MODEL.md).
3. **Relational is the right shape.** Sets-per-muscle-per-week is a join and a
   group-by. Fighting a document store for that would be perverse.
4. **In-memory testing.** Repository and migration tests run without a device.
5. **Compile-time query checking** catches the class of bug that silently
   produces wrong analytics.

## Consequences

- `build_runner` is part of the workflow. Generated output is not cached in CI —
  stale generated code produces confusing failures.
- Schema changes are a documented ritual: update the doc, add a numbered
  migration, commit the snapshot, write the test
  ([`../60-ENGINEERING.md`](../60-ENGINEERING.md)).
- Features never touch Drift types directly; repositories map rows to domain
  entities at the seam.
- Performance is a non-issue at this scale, given the indexes specified for the
  ghost-value query (`F-LOG-004`) — the app's hottest path.

## Reversal cost

Medium. Swapping the persistence layer means rewriting `data/db/` and the
repository mapping, but `domain/` and `features/` are insulated by design. The
data itself is plain SQLite and portable regardless.
