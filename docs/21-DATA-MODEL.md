# Data model

SQLite via Drift. See [ADR-0005](70-decisions/ADR-0005-drift.md). All quantities
follow [`22-UNITS.md`](22-UNITS.md) without exception. Sync-ready foundations
per [ADR-0008](70-decisions/ADR-0008-sync-ready-foundations.md).

## Five decisions that are expensive to reverse

Get these wrong and the fix is a data migration over real training history —
with no ground truth left to verify against.

### 1. Canonical units only

Weight is stored as **integer grams**. Distance as **integer metres**. Duration
as **integer seconds**. There is no per-row unit column anywhere in the schema.
Imperial versus metric is a *display* concern resolved at the presentation edge
from a single user preference (`F-SET-001`).

Integers, not doubles, because the app adds 2.5 kg to a number hundreds of times
across a training block; floating-point drift would eventually surface as
`102.49999999` in a chart. Grams give exact representation of every plate
increment in use anywhere, including 0.25 kg micro-plates and 1.25 lb fractional
plates. Full rationale: [ADR-0003](70-decisions/ADR-0003-canonical-units.md).

### 2. Workouts snapshot their template

A workout copies the exercise list, targets, and ordering from the routine day
at the moment it starts. It holds `source_routine_day_id` only as a weak
provenance reference, never as a live foreign key for display.

Without this, editing a routine silently rewrites months of history: swap an
exercise in your PPL template and last March's session claims you did the new
one. Full rationale: [ADR-0004](70-decisions/ADR-0004-template-snapshot.md).

### 3. Warm-up sets are flagged, and excluded from all analytics

`sets.set_type` distinguishes warm-up from working sets from the first schema
version. Volume load, PR detection, e1RM, and sets-per-muscle all filter to
counted sets only.

Retrofitting this is not possible — the information is simply gone. If it isn't
in v1, every analytic in the app is quietly wrong from day one.

### 4. Sync-ready foundations on every table

UUID primary keys, `created_at` / `updated_at` / `deleted_at`, and `user_id`.
Nothing is ever hard-deleted. Free now; impossible to reconstruct later.
See [ADR-0008](70-decisions/ADR-0008-sync-ready-foundations.md).

### 5. Timezone offset beside every timestamp

A workout at 06:00 local in Tokyo and one at 06:00 local in London are the same
behaviour and different UTC instants. Without the offset stored at write time it
is impossible to reconstruct afterwards whether someone trains mornings or
evenings, to group sessions into the correct local day across travel, or to
compute week boundaries correctly for a user who has relocated.

## Universal columns

**Every table** carries these. They are not repeated in the per-table
definitions below.

| Column | Type | Notes |
|---|---|---|
| `id` | text PK | UUID v4, generated client-side before insert |
| `user_id` | text NOT NULL | Constant `'local-user'` for now |
| `created_at` | int NOT NULL | UTC epoch milliseconds |
| `updated_at` | int NOT NULL | UTC epoch ms, rewritten on **every** modification |
| `deleted_at` | int? | Soft-delete tombstone. **Nothing is ever hard-deleted** |

Two rules follow, both [invariants](../CLAUDE.md#invariants) and both
centralised so no feature can forget them: every write sets `updated_at`
(repository layer), and every read filters `deleted_at IS NULL` (DAOs). A query
that forgets the second silently resurrects deleted rows — the single most
likely bug this schema introduces.

## Schema — v1

Types are Drift/SQLite. Timestamps are `INTEGER` Unix epoch **milliseconds UTC**;
user-meaningful ones carry a companion `*_tz_offset_minutes` integer holding the
local UTC offset at the moment of recording.

### `exercises`

The catalogue. Seeded rows and user-created rows live in the same table.

| Column | Type | Notes |
|---|---|---|
| `external_id` | text? | The seed dataset's own identifier. Lets the catalogue be re-synced or corrected upstream without duplicating rows or breaking references (`F-CAT-001`). Null for custom exercises |
| `name` | text | |
| `aliases` | text | JSON array. Powers synonym search (`F-CAT-008`), e.g. `["RDL"]` |
| `primary_muscle` | text enum | See muscle taxonomy below |
| `secondary_muscles` | text | JSON array of muscle enum values |
| `equipment` | text enum | `barbell`, `dumbbell`, `machine`, `cable`, `bodyweight`, `band`, `kettlebell`, `other` |
| `tracking_type` | text enum | `weightReps`, `bodyweightReps`, `reps`, `time`, `distanceTime`, `weightTime`. Determines which input fields the logger renders (`F-CAT-002`) |
| `is_custom` | bool | |
| `is_favorite` | bool | `F-CAT-006` |
| `archived_at` | int? | Hidden from pickers. Distinct from `deleted_at` — archiving is a user-facing organisational act, deletion is a tombstone |
| `notes` | text? | Sticky notes: seat height, pin position, grip width (`F-CAT-007`) |
| `default_rest_seconds` | int? | Overrides the global default (`F-TIM-005`) |
| `default_bar_id` | text? → `bars.id` | For plate maths (`F-PLT-001`) |
| `weight_entry_mode` | text enum | `total` or `perSide` (`F-LOG-017`) |
| `increment_grams` | int? | Smallest sensible jump for this exercise (`F-SET-007`) |
| `bodyweight_coefficient` | real? | Fraction of bodyweight loaded, for `bodyweightReps` (`F-LOG-019`) |
| `weight_source` | text enum | `plateLoaded`, `fixedIncrement`, or `stack` (`F-PLT-005`). Decides what the plate calculator shows and what plate-aware rounding (`F-PRG-012`) snaps a proposal to |
| `fixed_increments_grams` | text | JSON array of canonical grams — the discrete weights a `fixedIncrement` exercise's rack actually stocks |
| `stack_base_grams` | int? | A `stack` exercise's minimum pin weight |
| `stack_step_grams` | int? | A `stack` exercise's jump between pin positions |
| `stack_half_step_grams` | int? | A `stack` exercise's optional add-on magnet |

**Muscle taxonomy** (`F-CAT-013`) is a fixed enum, not free text, because
sets-per-muscle-group (`F-ANA-005`) and muscle balance (`F-ANA-008`) depend on
it: `chest`, `frontDelts`, `sideDelts`, `rearDelts`, `lats`, `traps`,
`upperBack`, `lowerBack`, `biceps`, `triceps`, `forearms`, `quads`, `hamstrings`,
`glutes`, `calves`, `adductors`, `abductors`, `abs`, `obliques`, `neck`,
`fullBody`. Adding a value is a migration.

### `routines`

| Column | Type | Notes |
|---|---|---|
| `name` | text | |
| `folder_id` | text? → `routine_folders.id` | `F-ROU-007` |
| `notes` | text? | |
| `position` | int | Explicit ordering. Never inferred from `created_at` — that breaks on reorder |
| `archived_at` | int? | |

### `routine_folders`

`name`, `position`. (`F-ROU-007`)

### `routine_days`

A routine contains ordered days — "Push", "Pull", "Legs". A *day* is what you
start a workout from, not the routine itself.

| Column | Type | Notes |
|---|---|---|
| `routine_id` | text → `routines.id` | |
| `name` | text | |
| `position` | int | |
| `scheduled_weekdays` | text? | JSON array of ISO weekday ints (`F-ROU-012`) |
| `notes` | text? | |

### `routine_exercises`

| Column | Type | Notes |
|---|---|---|
| `routine_day_id` | text → `routine_days.id` | |
| `exercise_id` | text → `exercises.id` | |
| `position` | int | |
| `group_id` | text? | Same value = same superset (`F-ROU-005`). Null = standalone |
| `target_sets` | int? | |
| `target_reps_min` | int? | Rep *ranges*, not single numbers — real programming says 8–12 |
| `target_reps_max` | int? | |
| `target_weight_grams` | int? | |
| `target_rpe` | real? | |
| `rest_seconds` | int? | Overrides exercise and global defaults |
| `progression_rule` | text? | JSON-serialised rule union (`F-PRG-001`) |
| `notes` | text? | |

### `workouts`

| Column | Type | Notes |
|---|---|---|
| `name` | text | Snapshotted from the routine day, or user-entered |
| `source_routine_day_id` | text? | Provenance only. Nullable, never used to render the session |
| `started_at` | int | UTC ms |
| `started_at_tz_offset_minutes` | int | Local offset at start. Determines the session's local calendar date for all grouping |
| `ended_at` | int? | Null = in progress. At most one row may have `ended_at IS NULL` (`F-LOG-007`) |
| `notes` | text? | |
| `bodyweight_grams` | int? | Captured at session time; needed for bodyweight-loaded exercises (`F-LOG-019`) |
| `perceived_fatigue` | int? | 1–5, optional |

### `workout_exercises`

| Column | Type | Notes |
|---|---|---|
| `workout_id` | text → `workouts.id` | |
| `exercise_id` | text → `exercises.id` | |
| `position` | int | |
| `group_id` | text? | Snapshotted superset grouping |
| `notes` | text? | Session-specific, distinct from the exercise's sticky note |
| `target_snapshot` | text? | JSON of the routine targets as they were at start — what progression proposed, kept for auditing `F-PRG-008` |

### `sets`

The hot table. Everything else exists to give these rows meaning.

**Row per set, never a JSON blob.** Any query like "best 5-rep squat" is
otherwise impossible.

| Column | Type | Notes |
|---|---|---|
| `workout_exercise_id` | text → `workout_exercises.id` | |
| `position` | int | Display order within the exercise |
| `set_type` | text enum | `warmup`, `working`, `drop`, `failure`, `amrap`, `backoff`. Default `working`. **Only `warmup` is excluded from analytics; all others count** |
| `weight_grams` | int? | Total load, always. Per-side entry is converted on input (`F-LOG-017`) |
| `reps` | int? | |
| `rpe` | real? | 6.0–10.0 in 0.5 steps (`F-LOG-014`). Nullable — v1 does not populate it, but the column exists from day one |
| `distance_metres` | int? | |
| `duration_seconds` | int? | |
| `is_completed` | bool | A row can exist as a planned-but-unfinished target. Incomplete sets are excluded from analytics |
| `completed_at` | int? | UTC ms. **The only way to derive actual rest intervals after the fact** (`F-TIM-007`) |
| `completed_at_tz_offset_minutes` | int? | |
| `rest_taken_seconds` | int? | Denormalised from consecutive `completed_at` values |
| `notes` | text? | Free-text per set (`F-LOG-023`). Captures everything not anticipated |

All four measurement columns are nullable, because not every exercise is
weight × reps. Which ones the UI renders is driven by the exercise's
`tracking_type` (`F-CAT-002`).

Index: `(workout_exercise_id, position)`, plus a covering index supporting
"most recent completed sets for exercise X" — the query behind `F-LOG-004`, run
on every exercise open and therefore the app's hottest path. Both must include
`deleted_at`.

### `body_measurements`

| Column | Type | Notes |
|---|---|---|
| `measured_at` | int | UTC ms |
| `measured_at_tz_offset_minutes` | int | |
| `type` | text enum | `bodyweight`, `waist`, `chest`, `hips`, `neck`, `leftArm`, `rightArm`, `leftThigh`, `rightThigh`, `leftCalf`, `rightCalf`, `shoulders`, `bodyFatPercent` |
| `value_canonical` | int | Grams for mass, millimetres for lengths, basis points for percentages. Interpretation is fixed per `type` |
| `notes` | text? | |

Bodyweight is the highest-priority row in this table and is captured from
**Phase 1** (`F-BOD-001`), not Phase 4. A missing column can be added later; a
year of missing bodyweight observations cannot, and without it no strength trend
can be interpreted as relative strength.

### `personal_records`

A **cache**, never a source of truth. Rebuildable from `sets` at any time; a
"rebuild PR cache" maintenance action must exist because any bug here is
otherwise permanent.

| Column | Type | Notes |
|---|---|---|
| `exercise_id` | text → `exercises.id` | |
| `kind` | text enum | `maxWeight`, `maxRepsAtWeight`, `bestE1rm`, `maxSessionVolume` |
| `qualifier` | int? | For `maxRepsAtWeight`, the weight in grams |
| `value` | int | |
| `set_id` | text? → `sets.id` | |
| `workout_id` | text? → `workouts.id` | |
| `achieved_at` | int | |

### `bars` and `plates`

Plate maths (`F-PLT-002`), configured in settings (`F-SET-004`).

- `bars`: `name`, `weight_grams`, `is_default`.
- `plates`: `weight_grams`, `count_available`, `is_enabled`. Counts are
  *pairs* available.

### `app_settings`

Single-row table for structured settings. Simple scalars may live in
`shared_preferences`; anything relational lives here.

## Relationships

```
routine_folders ─┬─< routines ──< routine_days ──< routine_exercises >── exercises
                 │                    ╎                                      │
                 │           (snapshot, not a live link)                     │
                 │                    ╎                                      │
                 └───────────► workouts ──< workout_exercises >──────────────┤
                                              │                              │
                                              └──< sets                      │
                                                                             │
                              personal_records >─────────────────────────────┘
```

## Deletion policy

**Nothing is ever hard-deleted.** Every delete sets `deleted_at`
([ADR-0008](70-decisions/ADR-0008-sync-ready-foundations.md)).

| Target | Behaviour |
|---|---|
| Exercise | Tombstoned. Hidden from pickers; history referencing it still renders. Archiving (`archived_at`) is the *organisational* action and is separate |
| Routine / routine day | Tombstoned. Workouts are unaffected; `source_routine_day_id` simply points at a tombstoned row, which is never read for display anyway |
| Workout | Tombstoned, cascading the tombstone to its exercises and sets. Requires confirmation, and invalidates the PR cache |
| Set | Tombstoned. Invalidates the PR cache for that exercise. Makes undo (`F-LOG-022`) a field update rather than a resurrection |

A purge action to reclaim space from old tombstones is noted in `F-DAT-010`. Not
urgent — a multi-year history is tens of thousands of rows.

## Migration policy

1. Migrations are numbered and sequential. Schema version is bumped in the same
   commit as the change, along with `VERSION` ([`63-VERSIONING.md`](63-VERSIONING.md)).
2. **A shipped migration is never edited.** Fix forward with a new one.
3. Every migration has a test that opens a database at version *n*, migrates,
   and asserts on the data — not just that it didn't throw.
4. Drift schema snapshots are committed so migration tests can build historical
   schemas.
5. Migrations are configured and tested **from the first commit that creates the
   database**, before any real workout is logged. The schema will change weekly
   early on, and a broken migration discovered after real data exists is the
   worst failure mode available.
6. Destructive migrations require a backup prompt first, once `F-DAT-003` exists.
   Until then, `F-DAT-011` (minimal JSON dump, Phase 1) is the escape hatch.
7. Post-v1, the exported JSON schema version (`F-DAT-001`) is bumped alongside
   and an import path from the previous version is kept.

## Persistence behaviour

**Write-through, always.** Completing a set writes to the database immediately;
in-progress session state is never held only in memory. The database *is* the
session. Consequences: the app can be killed mid-workout with zero loss
(`F-LOG-007`), and recovery is just "find the workout with a null `ended_at`",
not a serialised-state restore.

UUID primary keys make this cheap — the ID is generated client-side, so the row
can be rendered optimistically before the insert completes.

## Seed data

The exercise catalogue ships as versioned JSON in `assets/seed/exercises.json`,
each record carrying a stable UUID **and** the source dataset's `external_id`.
Re-seeding on upgrade adds new records and updates unmodified seeded ones; it
never touches user-edited or custom rows.

Provenance for every record is recorded in `assets/seed/SOURCES.md`. This is a
licensing requirement, not bookkeeping — see Risks in
[`10-VISION.md`](10-VISION.md) and the open question in `F-CAT-001`.
