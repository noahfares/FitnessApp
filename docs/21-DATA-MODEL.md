# Data model

SQLite via Drift. See [ADR-0005](70-decisions/ADR-0005-drift.md). All quantities
follow [`22-UNITS.md`](22-UNITS.md) without exception.

## Three decisions that are expensive to reverse

Get these wrong and the fix is a data migration over real training history.

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
one. Deleting a routine must likewise never cascade into workouts.

### 3. Warm-up sets are flagged, and excluded from all analytics

`sets.set_type` distinguishes warm-up from working sets from the first schema
version. Volume load, PR detection, e1RM, and sets-per-muscle all filter to
working sets only.

Retrofitting this is not possible — the information is simply gone. If it isn't
in v1, every analytic in the app is quietly wrong from day one.

## Schema — v1

Types are Drift/SQLite. `id` columns are `INTEGER PRIMARY KEY AUTOINCREMENT`
unless noted. All timestamps are `INTEGER` Unix epoch **milliseconds UTC**;
local-date grouping happens in the domain layer using the user's week-start
preference (`F-SET-005`).

### `exercises`

The catalogue. Seeded rows and user-created rows live in the same table.

| Column | Type | Notes |
|---|---|---|
| `id` | int PK | |
| `uuid` | text unique | Stable across export/import and re-seeding. Seeded rows carry a fixed UUID from the seed file. |
| `name` | text | |
| `aliases` | text | JSON array. Powers synonym search (`F-CAT-008`), e.g. `["RDL"]`. |
| `primary_muscle` | text enum | See muscle taxonomy below. |
| `secondary_muscles` | text | JSON array of muscle enum values. |
| `equipment` | text enum | `barbell`, `dumbbell`, `machine`, `cable`, `bodyweight`, `band`, `kettlebell`, `other`. |
| `tracking_type` | text enum | `weightReps`, `reps`, `time`, `distanceTime`, `weightTime`. Determines which input fields the logger renders (`F-CAT-002`). |
| `is_custom` | bool | |
| `is_favorite` | bool | `F-CAT-006` |
| `archived_at` | int? | Soft delete. Never hard-delete an exercise with history. |
| `notes` | text? | Sticky notes: seat height, pin position, grip width (`F-CAT-007`). |
| `default_rest_seconds` | int? | Overrides the global default (`F-TIM-005`). |
| `default_bar_id` | int? → `bars.id` | For plate maths (`F-PLT-001`). |
| `weight_entry_mode` | text enum | `total` or `perSide` (`F-LOG-017`). |
| `increment_grams` | int? | Smallest sensible jump for this exercise (`F-SET-007`). |
| `created_at`, `updated_at` | int | |

**Muscle taxonomy** (`F-CAT-013`) is a fixed enum, not free text, because
sets-per-muscle-group (`F-ANA-005`) and muscle balance (`F-ANA-008`) depend on
it: `chest`, `frontDelts`, `sideDelts`, `rearDelts`, `lats`, `traps`,
`upperBack`, `lowerBack`, `biceps`, `triceps`, `forearms`, `quads`, `hamstrings`,
`glutes`, `calves`, `adductors`, `abductors`, `abs`, `obliques`, `neck`,
`fullBody`. Adding a value is a migration.

### `routines`

| Column | Type | Notes |
|---|---|---|
| `id` | int PK | |
| `uuid` | text unique | |
| `name` | text | |
| `folder_id` | int? → `routine_folders.id` | `F-ROU-007` |
| `notes` | text? | |
| `order_index` | int | |
| `archived_at` | int? | |
| `created_at`, `updated_at` | int | |

### `routine_folders`

`id`, `uuid`, `name`, `order_index`. (`F-ROU-007`)

### `routine_days`

A routine contains ordered days — "Push", "Pull", "Legs". A *day* is what you
start a workout from, not the routine itself.

| Column | Type | Notes |
|---|---|---|
| `id` | int PK | |
| `uuid` | text unique | |
| `routine_id` | int → `routines.id` cascade | |
| `name` | text | |
| `order_index` | int | |
| `scheduled_weekdays` | text? | JSON array of ISO weekday ints (`F-ROU-012`). |
| `notes` | text? | |

### `routine_exercises`

| Column | Type | Notes |
|---|---|---|
| `id` | int PK | |
| `routine_day_id` | int → `routine_days.id` cascade | |
| `exercise_id` | int → `exercises.id` restrict | |
| `order_index` | int | |
| `superset_group` | int? | Same value = same superset (`F-ROU-005`). Null = standalone. |
| `target_sets` | int? | |
| `target_reps_min` | int? | Rep *ranges*, not single numbers — real programming says 8–12. |
| `target_reps_max` | int? | |
| `target_weight_grams` | int? | |
| `target_rpe` | real? | |
| `rest_seconds` | int? | Overrides exercise and global defaults. |
| `progression_rule` | text? | JSON-serialised rule union (`F-PRG-001`). |
| `notes` | text? | |

### `workouts`

| Column | Type | Notes |
|---|---|---|
| `id` | int PK | |
| `uuid` | text unique | |
| `name` | text | Snapshotted from the routine day, or user-entered. |
| `source_routine_day_id` | int? | Provenance only. Nullable, `ON DELETE SET NULL`, never used to render the session. |
| `started_at` | int | |
| `ended_at` | int? | Null = in progress. At most one row may have `ended_at IS NULL` (`F-LOG-007`). |
| `notes` | text? | |
| `bodyweight_grams` | int? | Captured at session time; needed for bodyweight-loaded exercises (`F-LOG-019`). |
| `perceived_fatigue` | int? | 1–5, optional. |

### `workout_exercises`

| Column | Type | Notes |
|---|---|---|
| `id` | int PK | |
| `workout_id` | int → `workouts.id` cascade | |
| `exercise_id` | int → `exercises.id` restrict | |
| `order_index` | int | |
| `superset_group` | int? | Snapshotted. |
| `notes` | text? | Session-specific, distinct from the exercise's sticky note. |
| `target_snapshot` | text? | JSON of the routine targets as they were at start — what progression proposed, kept for auditing `F-PRG-008`. |

### `sets`

The hot table. Everything else exists to give these rows meaning.

| Column | Type | Notes |
|---|---|---|
| `id` | int PK | |
| `workout_exercise_id` | int → `workout_exercises.id` cascade | |
| `set_index` | int | Display order within the exercise. |
| `set_type` | text enum | `warmup`, `working`, `drop`, `failure`, `amrap`. **Only `working`, `drop`, `failure`, and `amrap` count toward analytics; `warmup` never does.** |
| `weight_grams` | int? | Total load, always. Per-side entry is converted on input (`F-LOG-017`). |
| `reps` | int? | |
| `rpe` | real? | 6.0–10.0 in 0.5 steps (`F-LOG-014`). |
| `distance_metres` | int? | |
| `duration_seconds` | int? | |
| `is_completed` | bool | A row can exist as a planned-but-unfinished target. Incomplete sets are excluded from analytics. |
| `completed_at` | int? | |
| `rest_taken_seconds` | int? | Actual rest before this set (`F-TIM-007`). |

Index: `(workout_exercise_id, set_index)`, plus a covering index supporting
"most recent completed sets for exercise X" — the query behind `F-LOG-004`, run
on every exercise open and therefore the app's hottest path.

### `body_measurements`

| Column | Type | Notes |
|---|---|---|
| `id` | int PK | |
| `measured_at` | int | |
| `type` | text enum | `bodyweight`, `waist`, `chest`, `hips`, `neck`, `leftArm`, `rightArm`, `leftThigh`, `rightThigh`, `leftCalf`, `rightCalf`, `shoulders`, `bodyFatPercent`. |
| `value_canonical` | int | Grams for mass, millimetres for lengths, basis points for percentages. Interpretation is fixed per `type`. |
| `notes` | text? | |

### `personal_records`

A **cache**, never a source of truth. Rebuildable from `sets` at any time; a
"rebuild PR cache" maintenance action must exist because any bug here is
otherwise permanent.

| Column | Type | Notes |
|---|---|---|
| `id` | int PK | |
| `exercise_id` | int → `exercises.id` cascade | |
| `kind` | text enum | `maxWeight`, `maxRepsAtWeight`, `bestE1rm`, `maxSessionVolume`. |
| `qualifier` | int? | For `maxRepsAtWeight`, the weight in grams. |
| `value` | int | |
| `set_id` | int? → `sets.id` | |
| `workout_id` | int? → `workouts.id` | |
| `achieved_at` | int | |

### `bars` and `plates`

Plate maths (`F-PLT-002`), configured in settings (`F-SET-004`).

- `bars`: `id`, `name`, `weight_grams`, `is_default`.
- `plates`: `id`, `weight_grams`, `count_available`, `is_enabled`. Counts are
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

| Target | Behaviour |
|---|---|
| Exercise with history | Soft-delete only (`archived_at`). Hidden from pickers, retained in history. Hard delete offered only when zero sets reference it. |
| Routine / routine day | Hard delete allowed. Workouts are unaffected; `source_routine_day_id` is nulled. |
| Workout | Hard delete, cascading to its exercises and sets. Requires confirmation, and invalidates the PR cache. |
| Set | Hard delete. Invalidates the PR cache for that exercise. |

## Migration policy

1. Migrations are numbered and sequential. Schema version is bumped in the same
   commit as the change.
2. **A shipped migration is never edited.** Fix forward with a new one.
3. Every migration has a test that opens a database at version *n*, migrates,
   and asserts on the data — not just that it didn't throw.
4. Drift schema snapshots are committed so migration tests can build historical
   schemas.
5. Destructive migrations require a backup prompt first, once `F-DAT-003` exists.
6. Post-v1, the exported JSON schema version (`F-DAT-001`) is bumped alongside
   and an import path from the previous version is kept.

## Persistence behaviour

**Write-through, always.** Completing a set writes to the database immediately;
in-progress session state is never held only in memory. The database *is* the
session. Consequences: the app can be killed mid-workout with zero loss
(`F-LOG-007`), and recovery is just "find the workout with a null `ended_at`",
not a serialised-state restore.

## Seed data

The exercise catalogue ships as versioned JSON in `assets/seed/exercises.json`,
each record carrying a stable UUID. Re-seeding on upgrade adds new records and
updates unmodified seeded ones; it never touches user-edited or custom rows
(tracked by a `user_modified` flag or updated-timestamp comparison — decision
open in `F-CAT-001`).

Provenance for every record is recorded in `assets/seed/SOURCES.md`. This is a
licensing requirement, not bookkeeping — see Risks in
[`10-VISION.md`](10-VISION.md).
