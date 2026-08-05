# ADR-0008 — Sync-ready foundations

**Status:** Accepted · 2026-08 · supersedes the deletion policy in
[ADR-0004](ADR-0004-template-snapshot.md)'s original schema and the integer
primary keys originally specified in [`../21-DATA-MODEL.md`](../21-DATA-MODEL.md)

## Context

An external schema handoff ([`../11-EXTERNAL-INPUTS.md`](../11-EXTERNAL-INPUTS.md))
argued a specific case: certain schema properties are nearly free to add before
any data exists and are expensive or impossible to retrofit afterwards. Most are
nullable columns that v1 will never populate.

The project is local-only and single-user, with no server planned
([ADR-0002](ADR-0002-local-first.md)). The instinct is therefore to omit
sync-oriented machinery entirely. That instinct is wrong for a specific reason:
these columns cost nothing now, and the option they preserve — file-based sync
(`F-DAT-009`), multi-device, or simply a reliable undo — cannot be recovered
later without migrating live training history against a ground truth that no
longer exists.

## Options

**Omit all of it.** Integer primary keys, hard deletes, timestamps only where
needed. Simplest schema, smallest rows. Cost: adding a `NOT NULL` `user_id` to
populated tables later is painful; retrofitting soft deletes means the deleted
rows are already gone; and offline ID generation is impossible with
autoincrement.

**Add everything, populate it properly.** Full audit columns, UUIDs, tombstones.
Cost: slightly larger rows, marginally more code at the write boundary.

**Add the columns but leave them unpopulated until needed.** The worst of both —
carries the cost with none of the benefit, and a half-populated column is worse
than an absent one because queries start trusting it.

## Decision

**Adopt the full set, populated correctly from schema v1.**

### 1. UUID primary keys

`TEXT` UUID PKs on every table, not autoincrement integers.

Enables generating an ID client-side before an insert completes, so the UI can
render optimistically — which matters directly for set logging, where write-
through persistence (`F-LOG-007`) happens on every tap. It also makes
export/import genuinely idempotent (`F-DAT-001`) and removes the ID-collision
problem from any future sync.

This replaces the `id INTEGER PRIMARY KEY` + `uuid TEXT UNIQUE` pairing
originally specified, which carried the cost of both schemes and the benefit of
neither.

### 2. Audit columns on every table

`created_at` and `updated_at`, UTC epoch milliseconds, on every row.
`updated_at` is rewritten on every modification — the basis for last-write-wins
resolution if sync ever ships.

### 3. Timezone offset alongside every UTC timestamp

`*_tz_offset_minutes` beside each user-meaningful timestamp.

**This was missing entirely and is genuinely unrecoverable.** A workout at
06:00 local in Tokyo and one at 06:00 local in London are the same training
behaviour and different UTC instants. Without the offset it is impossible to
reconstruct afterwards whether someone trains in the morning or the evening, to
group sessions into the correct local calendar day across travel, or to compute
week boundaries (`F-SET-005`) correctly for a user who has moved.

### 4. Soft deletes everywhere

`deleted_at` on every table. **Nothing is ever hard-deleted.** All queries filter
`deleted_at IS NULL`.

This **overrides** the mixed deletion policy previously written, which hard-
deleted workouts and sets. Tombstones are required for sync correctness, and
they make undo (`F-LOG-022`) a trivial field update rather than a resurrection
problem. The previous policy's motivation — not accumulating junk — is better
served by an explicit purge action than by destroying data at the moment a user
taps something by accident, sweaty-handed, mid-set.

### 5. `user_id` on every table

Populated with the constant `'local-user'`. Adding a `NOT NULL` foreign key to
populated tables later is painful; adding a column that is already there and
already correct is free.

### 6. `external_id` on exercises

The source dataset's identifier for seeded exercises, distinct from the row's
own UUID. Lets the seed catalogue be re-synced or corrected upstream without
duplicating rows or breaking references from existing sets (`F-CAT-001`).

## Consequences

- Rows are larger and PK indexes are wider. Irrelevant at this scale — a
  multi-year history is tens of thousands of rows.
- Every write path must set `updated_at`. Centralised in the repository layer so
  no feature can forget.
- Every read path must filter `deleted_at IS NULL`. Centralised in the DAOs,
  with a lint-visible convention, because a query that forgets this silently
  resurrects deleted data — the one genuine hazard this decision introduces.
- Analytics gain a fourth universal precondition alongside the existing three
  ([`../40-ANALYTICS-SPEC.md`](../40-ANALYTICS-SPEC.md)).
- A purge action is needed eventually to reclaim space from tombstones. Not
  urgent; noted in `F-DAT-010`.
- `F-DAT-011` (minimal JSON dump, Phase 1) becomes the escape hatch for schema
  mistakes made while the schema is still moving.

## Reversal cost

**Very high once real training history exists**, which is the entire argument
for deciding it now. Changing primary key types or reconstructing tombstones
after the fact means migrating live data with no ground truth to verify against.

Free today, because no data exists.
