# Session contract for Claude Code

This repo is **planning-first**. `docs/` is the source of truth; code is
downstream of it.

New to the terminology? [`docs/01-PLAIN-ENGLISH.md`](docs/01-PLAIN-ENGLISH.md).

## Project in one line

An offline-first Flutter strength-training tracker that gives away free what
Strong / Hevy / JEFIT paywall: unlimited routines and custom exercises, real
analytics, progression automation, and full data export.

---

## Session recipes — follow these exactly

These exist to keep sessions cheap. **Read only what the recipe names.** Do not
explore the docs to build context; the context you need is declared for you.

### Implement a feature

1. Read `docs/30-features/<DOM>/<F-ID>.md`. The filename is the ID — no search
   needed.
2. Read **only** the documents listed in its `Reads:` line.
3. **Skip the `## Why` section** — it's rationale for the human, not the build.
4. Build it. Update `Status:` in the same commit.

### Implement a batch

`docs/50-ROADMAP.md` groups features into batches that share a `Reads:` set.
Read the shared documents **once**, then all the batch's feature files. This is
the cheapest way to work — prefer it over one feature at a time.

### Read one section of a document

`tools/read.sh <DOC>#<anchor>` prints just that section — `Reads:` lines name
sections, not files, and `21-DATA-MODEL` is 324 lines of which `#sets` is 30.
`tools/read.sh F-LOG-003` prints a feature file without its `## Why`, which the
recipe above says to skip anyway.

### Verify before committing

`tools/verify.sh` — format, analyze, test, layers, docs, in **CI's order**. CI's
first gate is `dart format --set-exit-if-changed`, which fails the job before a
single test runs, so a green local suite is not evidence of a green build.
`tools/verify.sh --fix` formats in place first.

### Run the tests

`tools/test.sh` — failures only, one line when the suite is green (254 lines of
"passed" is 254 lines of nothing). `tools/test.sh -v` when debugging, and it
takes paths: `tools/test.sh test/domain`.

Widget tests build on `test/support/harness.dart`; read it before writing a new
one rather than re-deriving the provider overrides.

### Check project state

Read `docs/features.tsv`. 163 rows, everything: phase, status, priority,
dependencies. Do **not** open spec files to answer "what's left" or "what's next".

### Add a feature

`tools/new-feature.sh <DOMAIN> "<title>"` — allocates the next ID, writes the
template, regenerates the index. Then fill it in.

### Verify the docs

`tools/check-docs.sh` — orphan IDs, `Reads:` targets, index freshness, roadmap
consistency, version agreement. One command; don't hand-roll grep pipelines.

### Regenerate the index

`tools/gen-index.sh` after adding or editing any feature header.
`docs/features.tsv` and `docs/30-features/INDEX.md` are **generated** — never
hand-edit them.

---

## Rules

1. **Every feature has an ID.** `F-<DOMAIN>-<NNN>`, one file each under
   `docs/30-features/`. Never build something with no entry — write the entry
   first. IDs are permanent and never reused.
2. **Update `Status:` in the same commit as the code.** The feature files are
   the only progress tracker. `idea → planned → in-progress → done →
   deferred | dropped`.
3. **Don't silently expand scope.** If a task reveals a missing feature, add it
   with `tools/new-feature.sh`, park it in `docs/51-BACKLOG.md`, and mention it.
   Don't build it.
4. **Ask before deviating from an ADR.** `docs/70-decisions/` is load-bearing.
   If one seems wrong, say so; don't route around it.

## Invariants — violating any of these is a bug, not a style choice

Canonical statement. Other documents link here rather than restating.

- **Canonical units only.** Weight in integer grams, distance in metres,
  duration in seconds. Imperial/metric is a *display* concern. Never a per-row
  unit flag. → `docs/22-UNITS.md`
- **`lib/domain/` imports nothing from Flutter and nothing from `lib/data/`.**
  All maths that can be silently wrong is pure Dart under test.
  → `docs/20-ARCHITECTURE.md`
- **Warm-up sets are excluded** from volume, PR, and e1RM maths, always.
  → `docs/40-ANALYTICS-SPEC.md`
- **Nothing is ever hard-deleted.** Every delete sets `deleted_at`; every read
  filters `deleted_at IS NULL`; every write sets `updated_at`. → `ADR-0008`
- **Every user-meaningful timestamp stores its local UTC offset.** Local dates
  derive from the pair, never from UTC alone. → `ADR-0008`
- **Workouts snapshot their template.** Editing a routine must never alter
  historical sessions. → `ADR-0004`
- **Write-through persistence.** Every set completion hits the DB immediately.
  An app kill mid-session must lose nothing.
- **No network calls in the core app.** Local-first, no account, no telemetry.
  → `ADR-0002`

---

## Versioning — MANDATORY, NEVER SKIP, NEVER ASK

**Every commit bumps the version.** Do it automatically as part of committing.
Do not ask permission, do not batch several commits under one version.

```bash
echo "0.4.0" > VERSION          # 1. bump
git add -A && git commit -m "<type>(<domain>): <F-ID> <summary>"
git push origin main            # 2. push — CI tags it (F-REL-012)
```

**Tagging is automatic.** `.github/workflows/tag.yml` reads `VERSION` on every
push and creates `v$VERSION`. Don't create tags locally — this session's
credentials can't push them anyway, and CI is authoritative.

**Bump rules while pre-1.0** (`MAJOR` stays `0` until the schema is stable):

| Change | Bump |
|---|---|
| New feature, phase work, schema change, new planning doc | **MINOR** — `0.3.0 → 0.4.0` |
| Fix, clarification, refactor, doc edit, test-only change | **PATCH** — `0.3.0 → 0.3.1` |

`VERSION` at the repo root is the single source of truth. Full scheme:
`docs/63-VERSIONING.md`.

## The roadmap is binding

`docs/50-ROADMAP.md` is followed **strictly and in order**. Don't skip ahead,
don't reorder, don't start Phase N+1 while Phase N has unmet exit criteria.

- **Allowed without asking:** adding a sub-feature inside the current phase's
  scope, and improving any spec.
- **Ask first:** moving a feature between phases, reordering phases, starting a
  phase early, declaring a phase complete with unmet exit criteria, dropping a
  feature.

If the roadmap looks wrong, say so and stop. Don't route around it.

## Conventions

- **Work directly on `main`. Commit and push there.** No feature branches, no
  pull requests — solo project, and a self-approved PR is ceremony. Revisit once
  CI has a real test suite to gate on (`F-REL-001`); until then a PR gates
  nothing.
- Commit: `<type>(<domain>): <F-ID> <summary>` — e.g.
  `feat(log): F-LOG-004 last-time ghost values in set rows`.
- Commits are the unit of review. Keep them coherent and their messages honest —
  with no PR descriptions, the commit message *is* the record.
- Every pure-domain function needs a unit test using its worked fixture from
  `docs/40-ANALYTICS-SPEC.md` (machine-readable copies in `docs/fixtures/`).
- Definition of done: `docs/60-ENGINEERING.md`.

## Current state

Version **0.25.0**. **Phase 0 complete** — scaffold, CI, auto-tagging, units,
theming, five-tab shell, and the Drift schema (now at **v3**).

**Phase 1 complete.** Batches 1.1–1.9 done:

- **1.1–1.2** — 100-exercise seeded catalogue, `ExerciseRepository`, custom
  exercises, catalogue screen with search and filtering (`F-CAT-001`–`F-CAT-005`).
- **1.3** — session lifecycle: start/finish/discard, the exercise picker, and
  kill recovery (`F-LOG-001`, `F-LOG-002`, `F-LOG-007`). Schema v3 adds the
  partial unique index enforcing one in-progress workout.
- **1.4** — the set row: `SetRepository`, ghost values, set types, the numeric
  keypad and per-set notes (`F-LOG-003`–`F-LOG-006`, `F-LOG-023`). No schema
  change — the `sets` table has held all of this since v1.
- **1.5** — the rest timer: `RestTimer` as a target timestamp, auto-start on set
  completion, per-exercise-type defaults, the bar on the active workout and the
  preferences screen (`F-TIM-001`, `F-TIM-002`, `F-TIM-005`, `F-TIM-006`,
  `F-SET-003`). No schema change — `exercises.default_rest_seconds` already
  existed.

`F-TIM-003` (background execution and notification) is the one batch-1.5 item
still `in-progress`: the `RestTimerService` seam and an in-app implementation
have landed, but `flutter_local_notifications`, the manifest work and the deep
link have not. Its acceptance criteria are on-device.

- **1.6** — history: `WorkoutRepository.watchHistory`/`summaryStats`, the
  History screen (search, month grouping with sticky headers, lazy loading),
  workout detail, full past-workout editing (sets, values, types, exercises,
  date, both kinds of note), retroactive logging, and the finish summary
  (`F-LOG-008`, `F-LOG-009`, `F-LOG-011`, `F-LOG-012`, `F-LOG-018`). No schema
  change — `workouts.notes`, `workout_exercises.notes` and `personal_records`
  have held this since v1–v3. PR badges, repeat-as-workout, and save-as-routine
  are left for their owning Phase 2 features (`F-LOG-013`, `F-LOG-016`,
  `F-ROU-001`) rather than built early.
- **1.7** — shell and empty states: the real Dashboard (resume/start a
  workout, recent workouts), the active-workout banner above the bottom nav
  on every shell screen, shared `EmptyState`, `ErrorView`/`LoadingView` and
  `ConfirmSheet` components retrofitted across the catalogue, history, active
  workout and exercise editor screens, and 48 dp touch targets on all of them
  (`F-NAV-003`–`F-NAV-006`, `F-A11Y-004`). No schema change. Dashboard cards
  for today's scheduled day, streaks, recent PRs and insight cards wait on
  their own Phase 2/3 features, same reasoning as batch 1.6's deferrals.
- **1.8** — unrecoverable capture: `BodyMeasurementRepository` (bodyweight
  log, dashboard quick-entry card, the `/body` screen), a workout's
  `bodyweight_grams` derived from it at start and recomputed on every
  backfill or edit, and `JsonDumpService` — every table to one JSON file via
  the system share sheet, one table at a time so memory stays bounded
  (`F-BOD-001`, `F-DAT-011`). No schema change — `body_measurements` and
  `workouts.bodyweight_grams` have existed since v1. Adds `share_plus` (the
  one `F-DAT-*` dependency Phase 1 actually needs) and a `core/app_version.dart`
  constant, now the single source both the About screen and the dump read.

- **1.9** — ship it: `.github/workflows/release.yml` on tag `v*` — decodes
  the upload keystore from GitHub Secrets, fails the job outright if any
  signing secret is missing rather than falling back to a debug-signed APK
  (`android/app/build.gradle.kts` throws when `REQUIRE_RELEASE_SIGNING=true`
  and the keystore isn't configured), builds a `--split-per-abi` release APK
  with `--build-name`/`--build-number` derived from `VERSION` and commit
  count, computes SHA-256 checksums, and creates a GitHub Release with
  generated notes (`F-REL-002`, `F-REL-003`, `F-REL-005`). `AboutScreen` now
  reads version and build number from the installed package via
  `package_info_plus` (`AppInfoService`, faked in tests) instead of a
  constant, and adds the open-source licences page and a repository link via
  `url_launcher` (`F-SET-009`, now done).

**Phase 1's on-device exit criteria are verified**, from a real signed APK
built by `release.yml` and installed via GitHub Release: a full session
logged start to finish, ghost values on a second session, force-kill
recovery, the rest timer surviving a pocketed screen-off phone, bodyweight
logging, and the JSON dump against a real database all passed. One criterion
was explicitly **waived** by the project owner rather than met: "two weeks of
real training logged before Phase 2 begins" — the app isn't yet a daily-driver
replacement for the tracker currently in use, so there's no real-use data to
accumulate yet, and waiting on it would only delay Phase 2 without changing
what it finds. See `docs/50-ROADMAP.md` Phase 1 exit criteria for the full
record, including the one open caveat: `F-TIM-003`'s background
notification/foreground-service layer still isn't built (only the in-app
timer), so the rest-timer result is a real but possibly lucky pass — worth
re-checking if a longer rest or a different device ever fires late.

**Phase 2 started — batch 2.1 done.** Routine CRUD, days, per-exercise
targets, and starting a workout from a routine day
(`F-ROU-001`–`F-ROU-003`, `F-ROU-010`): `RoutineRepository`, the Routines tab
(list, editor, day editor with a target-editing sheet), and
`WorkoutRepository.startFromRoutineDay` — the `ADR-0004` snapshot copy of a
day's exercises, order and targets into fresh `workout_exercises`/`sets` rows.
Set rows are created empty and uncompleted; the target is shown alongside the
ghost value rather than written into the row, so a target is never
indistinguishable from something actually logged. "Save as routine"
(`F-LOG-012` §3) is included as part of `F-ROU-001` §3's third creation path.
No schema change — `routine_folders`, `routines`, `routine_days` and
`routine_exercises` have existed since schema v3. Superset grouping
(`F-ROU-005`), day/exercise reordering UI (`F-ROU-004`), and rest-default
inheritance display (`F-ROU-006`) were not part of this batch. Batch 2.1 was
drafted and built together, ahead of the rest of Phase 2's batch table
(`docs/50-ROADMAP.md` §Phase 2, batches 2.1–2.8).

**Batch 2.2 done.** Reordering, folders, and archive/restore
(`F-ROU-004`, `F-ROU-007`, `F-ROU-008`, `F-ROU-009`): drag-to-reorder on both
the day list and the exercise list via `ReorderableListView`, writing back
through `RoutineRepository.reorderDays`/`reorderExercises`; `routine_folders`
CRUD and a "move to folder" sheet, with the list grouped by folder (flat when
none are in use, and skipping empty folder sections); a "show archived"
toggle on the Routines tab with a restore action, closing the gap where an
archived routine had no way back once hidden. `F-ROU-008`'s "duplicate and
version" turned out to already be satisfied by `F-ROU-001`'s `duplicate()`
(distinguishing "X copy" name) plus the new archived view (archived routines
stay reachable and startable) — no extra versioning concept was needed, per
its own spec's reasoning that snapshot-on-start already makes history safe.
`F-ROU-005` (supersets), `F-ROU-006` (rest-default inheritance display) and
the rest of Phase 2 remain `planned`.

**Batch 2.3 — supersets.** `F-ROU-005` and `F-LOG-015` both in-progress
(their own files' §Status notes have the detail — the gap in each is
within-group configurable rest and set-completion focus-advance,
respectively). No schema
change — `routine_exercises.group_id`/`workout_exercises.group_id` have
existed since schema v3; this batch is the first to write and read them.
Same value = same group, with no distinct circuit/round concept. The day
editor gets a multi-select "Group" action (adjacent rows only) and a
bordered, labelled block per group with a per-group "Ungroup" button; the
active workout screen gets the same visual treatment plus a per-tile
"Group with next"/"Ungroup" control for creating and breaking groups
mid-session (`WorkoutRepository.toggleGroupWithNext`). The rest timer skips
non-last group members (there is no dedicated within-group-rest column, so
it is fixed at zero) and fires normally after the last member, using that
exercise's existing resolved rest. `startFromRoutineDay` was already
snapshotting `group_id` from batch 2.1 — this batch is what actually
populates it. Fixed a latent bug found along the way: `duplicate()` and
`createFromWorkout` previously copied `group_id` verbatim, which would have
tied a duplicated day's or a "save as routine" day's exercises to the
*source*'s group; both now mint a fresh id per copied group. Not built:
§2 of `F-LOG-015` ("completing a set advances to the next exercise in the
group") — the logger shows every exercise's full set list at once rather
than one exercise at a time, so there is no single focus to advance without
first reshaping the screen into something this batch didn't intend to build.

**Batch 2.4 — session editing & safety.** `F-LOG-010`, `F-LOG-016` and
`F-LOG-022` all done. No schema change. Mid-session editing
(`F-LOG-010`): `WorkoutRepository.reorderExercises` (a direct port of
`RoutineRepository.reorderExercises`'s drag-to-reorder-plus-contiguity-dissolve,
`F-ROU-004`) and `.swapExercise`, wired into `ActiveWorkoutScreen` via a
`ReorderableListView` and a per-exercise "Swap"/"Remove" menu. `swapExercise`
never mutates `exercise_id` in place — every set attached to a
`workout_exercises` row is joined back through it, so rewriting it would
silently reattribute logged history (`ADR-0004`) — instead the row is
retired-and-replaced if nothing on it is completed, or left standing (with a
fresh row inserted after it) if it has completed sets, so those sets keep the
exercise actually done. Repeating a session (`F-LOG-016`):
`WorkoutRepository.startFromWorkout`, deriving targets from what was actually
logged the same way `RoutineRepository.createFromWorkout` does for "save as
routine", reached from a "Repeat this workout" action on the workout detail
screen. Undo and mis-tap protection (`F-LOG-022`): removing an exercise now
offers undo via the same snackbar pattern set deletion already used
(`WorkoutRepository.restoreExercise`, discriminated by the exact tombstone
timestamp so it cannot resurrect a set deleted before the exercise was), and
discarding an in-progress workout now requires a held press
(`HoldToConfirmButton`) rather than a single tap — gating only that one
confirm, not the empty-session discard prompt or history's already-shipped
past-workout delete. Also extracted `WorkoutRepository._backfillBodyweight`,
which `start()` and `startFromRoutineDay()` had each been duplicating
verbatim and `startFromWorkout()` needed a third copy of.

**Batch 2.5 — set richness.** `F-LOG-014` (RPE/RIR) and `F-LOG-017`
(per-side weight) both done. No schema change — `sets.rpe` and
`exercises.weight_entry_mode` have existed since schema v1/v3 respectively;
this batch is the first to read or write either. RPE: `domain/logging/rpe.dart`
holds the pure RPE↔RIR conversion and the nine fixed 6.0–10.0 steps;
`RpeSettingsNotifier` persists on/off and display mode (off by default,
`F-LOG-014` §3), inline on the settings root rather than its own screen —
two settings didn't earn a route. The set row's RPE cell sits beside the note
button, shown only when enabled, opening `RpeSheet` (a `SetTypeSheet`-style
grid). Per-side weight: `defaultWeightEntryModeFor` (dumbbell → per side,
else total) is applied by `ExerciseSeeder` on **insert only** and by
`ExerciseRepository.createCustom` — re-seeding never touches an existing
row's mode, so an existing catalogue's dumbbells keep `total` until edited by
hand, the same "user edits always win" rule as every other user-owned field.
`sets.weight_grams` stays total always (`F-LOG-017` §1); every read/write
site — `SetRow`, `_ColumnHeaders`, `NumericKeypadSheet`, the ghost, the
routine-target summary, and both read-only history screens — now takes a
`perSide` bool and converts for display only, via `Mass * 0.5`/`* 2` (round,
not truncate, per docs/22-UNITS.md §rounding). One real behaviour change
flagged in `F-LOG-017`'s own status note: a dumbbell's stepper default
(unchanged at `Mass.kg(2)`) now applies in the per-side domain once an
exercise is `perSide`, so its total steps by 4 kg per tap rather than 2 kg —
the more sensible reading, but a change in effect for every existing dumbbell
exercise the moment its mode flips. `F-LOG-017`'s "Open questions" section
(switching mode risking a history migration) is resolved rather than
deferred: because storage is always total, switching mode is display-only,
so neither migrating nor refusing was ever needed. Not built: RPE does not
appear on the history or edit-past-workout screens, and neither feature yet
feeds `F-PRG-005` or `F-ANA-011`, both still `planned`.

**Batch 2.6 — PR detection.** `F-LOG-013` done. No schema change —
`personal_records` and its `PrKind` enum have existed since schema v3; this
batch is the first to read or write either. `domain/analytics/e1rm.dart`
(Epley only — formula selection is `F-SET-006`, Phase 3) and
`domain/analytics/personal_records.dart` hold the pure detection logic
(`detectPrs`), each with fixture-backed tests against
`docs/40-ANALYTICS-SPEC.md` §1/§4. `PersonalRecordRepository.evaluateSet`
runs live on every set completion for `maxWeight`, `maxRepsAtWeight` and
`bestE1rm`; `maxSessionVolume` is deliberately evaluated separately, once,
in `evaluateSessionVolume` when the workout finishes — a per-set running
total would keep beating its own more-recent self as a session progresses,
celebrating arithmetic rather than a real record. `rebuildForExercise`/
`rebuildAll` are the full recompute rule 4 requires (a cache can be demoted
but never knows the next-best value without rescanning raw sets); wired to
every delete, undo, and un-complete on both the live and history set rows,
and exposed as "Rebuild personal records" on Settings › Data as the rule-5
maintenance action. `PrBadge` (`features/shell/widgets/`) is the inline
badge on the live set row; its own mount-time entrance animation stands in
for the "brief, non-blocking animation" the spec asks for, so no separate
celebratory overlay exists. The finish summary lists each session's records
by exercise name. Not built: editing a completed set's **value** (weight or
reps) through the numeric keypad, without un-ticking and re-ticking it, does
not yet trigger a cache rebuild — only completion-toggling and deletion do,
so a stale record can survive an in-place correction until the next
delete/toggle or maintenance rebuild touches that exercise (`F-LOG-013`'s
own status note has the detail). `F-ANA-007` (the PR timeline this batch's
cache is meant to eventually feed) remains `planned`, Phase 3.

**Batch 2.7 — catalogue polish.** `F-CAT-006`, `F-CAT-007`, `F-CAT-008` and
`F-CAT-009` all done. No schema change — `is_favorite`, `notes`, `aliases`
and `archived_at` have existed on `exercises` since schema v1/v3; a fair
amount of the repository- and domain-layer plumbing for this batch was
already in place ahead of time (favourite/archive toggles on
`ExerciseRepository`, and `domain/catalog/exercise_search.dart`'s
favourite→recency→alphabetical ordering, built in `F-CAT-004` with
`lastUsedAt` deliberately left always-null "for a one-line change later").
This batch is what closes the remaining gaps: `SetRepository
.watchLastUsedAtByExercise()` wires real recency into `CatalogIndex`, and
the catalogue screen gets a favourite star per row (`F-CAT-006`); the
exercise editor gains Notes and Aliases fields, `WorkoutRepository
.watchExercises` now carries the exercise's own persistent note as
`SessionExercise.exerciseNotes` (kept distinct from the session-specific
`.notes`), and the active workout screen shows it collapsed-to-one-line via
`_StickyNoteText` with an "Edit note" action on the overflow menu, opening
`ExerciseNoteSheet` — which writes only through `ExerciseRepository`, so it
can never disturb a logged set or the rest timer (`F-CAT-007`); the alias
seed data (`rdl`, `ohp`, `bss`, 29 of 100 exercises) and alias-aware search
already existed, so `F-CAT-008` only needed the editor's add/remove alias UI
closing §3. `F-CAT-009` mirrors `F-ROU-009`'s routine-archive pattern
exactly: a "show archived" toggle on the catalogue screen's app bar, a flat
`_ArchivedExerciseList` with a "Restore" action per row, and
`ExerciseRepository.bulkArchiveByEquipment` (only ever widens the archived
set, never touches an already-archived row) reached from an app-bar action
that confirms via the shared `ConfirmSheet`.

Local toolchain: Flutter at `/opt/flutter` on the Linux sandbox, or
`C:\flutter` on the Windows machine (`git clone https://github.com/flutter/flutter.git -b stable --depth 1 C:\flutter`,
then add `C:\flutter\bin` to `PATH` — done once, persisted to the user `PATH`
via `setx`/`[Environment]::SetEnvironmentVariable`). No Android SDK on
either, so `flutter build apk` is CI-only. Flutter web is not a target
platform. `tools/verify.sh` passes clean on both as of this note — if a
future session finds neither toolchain present, set one up the same way
before trusting an unverified diff.
