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

**Run the full `tools/verify.sh` exactly once per session, right before the
commit.** It re-runs the entire suite and full analyzer every time — cheap
once, wasteful as a mid-development sanity check. While iterating, use the
targeted commands below instead and save the full run for the actual gate.

### Run the tests, and analyze, cheaply while iterating

`tools/test.sh` — failures only, one line when the suite is green (254 lines of
"passed" is 254 lines of nothing). `tools/test.sh -v` when debugging, and it
takes paths: `tools/test.sh test/domain`. **Scope it to the file or directory
you're touching** (`tools/test.sh test/domain/routines`), not the whole suite —
that's what the one-shot `verify.sh` at the end is for.

Same for the analyzer: `flutter analyze <path>` on the files just changed, not
`flutter analyze lib/`. After the first `flutter` call in a session, pass
`--no-pub` on subsequent ones — pub re-resolves and reprints its "Resolving
dependencies" preamble on every invocation otherwise, which is pure noise once
packages are already fetched.

Widget tests build on `test/support/harness.dart`; read it before writing a new
one rather than re-deriving the provider overrides. **Widget tests are for new
interaction or layout logic** — a screen that reveals a real bug if built
wrong (state toggles, reorder/drag, a layout that can starve a sibling of
space, as `_RoutinePreviewCard`'s `ExpansionTile` once did). **They are not
required for a widget that only renders data it's given** — a card, a tile, a
label — where a domain-level test on the data it renders plus a quick read of
the code is the cheaper and sufficient check. When in doubt, prefer a
pure-domain unit test (fast, no widget pump, no provider harness) over a
widget test that exercises the same logic through a screen.

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

Version **0.26.1**. **Phase 0 complete** — scaffold, CI, auto-tagging, units,
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

**Batch 2.8 — timer & settings polish.** `F-TIM-007`, `F-SET-007` and
`F-THM-003` done; `F-TIM-004` and `F-SET-008` blocked, not attempted — both
depend on `F-TIM-003` (the real OS notification), which is still only the
in-app timer, and this session had no Android SDK or physical device to
build or verify notification work against regardless. No schema change —
`sets.rest_taken_seconds` and `exercises.increment_grams` have existed since
schema v3. `SetRepository.complete()` now records actual elapsed rest,
looked up as the gap since the most recent *other* completed set anywhere
in the session (not scoped to one exercise — the rest timer itself already
works that way, so a superset partner's set correctly counts), null for a
session's first completion rather than zero (`F-TIM-007`); nothing displays
it yet; it feeds `F-ANA-012`, Phase 4. The increment stepper's per-equipment
default and full per-exercise-override read path
(`domain/logging/weight_steps.dart`, threaded through `SetRow` since
`F-LOG-006`) already existed — the exercise editor just gained the one
missing piece, a "Stepper increment" field showing the computed default as
its own helper text (`F-SET-007`). Dynamic colour (`F-THM-003`) is the first
new dependency since `F-DAT-011`'s `share_plus`: `dynamic_color` supplies a
wallpaper-derived `ColorScheme` via `DynamicColorBuilder`, harmonized
against it with the package's own `ColorScheme.harmonized()`;
`AppColors` — `pr`/`danger`/`success`/`warning` — was already a fixed
`ThemeExtension` never derived from `ColorScheme` (its doc comment
anticipated this feature by name), so the "semantic roles survive any
wallpaper" requirement holds by construction, pinned by a test rather than
trusted from the comment. Off by default on Settings › Appearance, and a
no-op (null schemes, falls through to the fixed seed) on any platform the
package doesn't support.

**Phase 2 exit-criteria audit (v0.26.1).** All four of Phase 2's exit
criteria (`docs/50-ROADMAP.md` §Phase 2) are now backed by an automated test
that proves the criterion's own wording, not just its component features'
specs — added: a multi-day "full training week" repository test (three
routine days started, logged and finished in sequence, targets pre-filled
each time); a stronger routine-edit test that finishes the workout and then
deletes the exercise/day/routine entirely, not just re-targets it, before
re-reading the historical record; a widget test that completes a
record-setting set through the real `ActiveWorkoutScreen` and asserts
`PrBadge` actually appears, not just that the cache updates; and
`restSecondsForGroupMember`, a one-line rule (non-last group member rests
zero) that was previously inline in `active_workout_screen.dart` and
untested, now extracted to `domain/timing/rest_defaults.dart` and
unit-tested, with a widget test confirming the full rest doesn't start for
a non-last member. Two pre-existing gaps surfaced along the way, both
already noted in their own features' status notes rather than fixed here:
`F-ROU-005`/`F-LOG-015`'s within-group-rest and focus-advance items remain
`in-progress`, and `F-LOG-013`'s `PrBadge` doesn't suppress itself for a
first-ever set the way the spec's "record it silently" edge case asks —
the cache write is silent, but the badge isn't.

**Phase 2 declared complete by the project owner (v0.26.1)**, accepting
those two caveats explicitly rather than silently carrying them forward:
`F-ROU-005`/`F-LOG-015` stay `in-progress` (within-group rest fixed at
zero, no focus-advance on completion), and `F-TIM-004`/`F-SET-008` stay
`planned`, blocked on `F-TIM-003`'s real OS notification. The precedent is
the same one Phase 1 set — a phase closes on its exit criteria being met,
not on every one of its features reaching `done`.

**Phase 3 started (v0.28.0) — batched into 3.1–3.6** in
`docs/50-ROADMAP.md`, the same way Phases 0–1 were, since later phases only
get batched once actually scheduled. Ordering: the shared analytics engine
first, paired with its first real consumer rather than shipped alone; the
`fl_chart` dependency (pre-declared in `pubspec.yaml`) introduced with the
first batch that actually renders a chart (3.2); `F-CAT-013`'s muscle
taxonomy before its two readers; polish batches last. Full rationale is in
the roadmap doc itself, not restated here.

**Batch 3.1 — engine & per-exercise history.** `F-ANA-002` done; `F-ANA-001`
`in-progress` (by design — it's the umbrella for every `F-ANA-*` fixture
test through batch 3.4, not a single deliverable). No schema change.
`domain/analytics/analytics_boundary.dart`'s `isCountedSet()` is the shared
warm-up/incomplete filter the spec's §universal-preconditions rules 2–3 ask
for; `domain/history/workout_volume.dart` was refactored in place to use it
(behaviour unchanged, existing tests untouched) rather than leaving a second
inline copy of the same two-line check. `domain/analytics/personal_records.dart`
was deliberately **not** touched — retrofitting an already-shipped,
fixture-tested Phase 2 feature's filtering seam was out of scope for landing
the first Phase 3 batch. `domain/analytics/exercise_history.dart`
(`ExerciseHistorySession`) composes the existing `epley1Rm` with the shared
filter for best-set-by-e1RM and volume, fixture-tested against the same
`sessionE1rm`/`volumeLoad` worked examples the spec already defines.
`SetRepository.watchExerciseHistory` is a newest-first join across
`sets`/`workout_exercises`/`workouts` scoped to one exercise, shaped like the
existing ghost-values query. `ExerciseDetailScreen` lives at the new
`/exercises/:exerciseId` route (nested under it: `/edit`, unchanged) and is
reached from a new history icon on each catalogue row — the row's own tap
still opens the editor directly, exactly as before, so every existing
catalogue test kept passing untouched. Not built: date-range scoping
(`F-ANA-015`, batch 3.2) — every session shows unconditionally, which only
becomes a real problem once there's enough logged history for it to matter.

**Batch 3.2 — e1RM trend & date range.** `F-ANA-003`, `F-SET-006` done;
`F-ANA-015` `in-progress` (by design — "shared across every chart" can't be
verified with only one chart to share it with yet); `F-THM-004` done. No
schema change. `fl_chart` is now a real dependency (previously reserved in
`pubspec.yaml`'s deferred-deps comment) — `TrendChart`
(`features/shell/widgets/`) is the shared line-chart component the design
system names, reading colours from `context.appColors.chartSeries` rather
than literals, respecting the never-zero-based Y axis rule for weight
charts, and rendering unreliable points (§1 rule 2, reps > 12) as hollow
dots instead of hiding them — exclusion is a screen-level toggle, not the
chart's decision. `domain/analytics/e1rm.dart` gained `estimate1Rm`/
`E1rmFormula` (Epley/Brzycki/Lombardi, including Brzycki's undefined-range
fallback at r≥37) alongside the pre-existing Epley-only `epley1Rm`, which
stays untouched and is still what PR detection and per-exercise history use
— record-keeping isn't a user preference the way a trend chart's formula is.
`domain/analytics/linear_regression.dart` is the optional overlay's
least-squares slope, deliberately written as a shared utility rather than
inlined, since `F-ANA-009` (Phase 4 stall detection) needs the identical
computation on different data. `domain/analytics/date_range.dart`
(`RangePreset`, `resolveRange`) and an in-memory
`dateRangeSelectionProvider` back `DateRangeSelector`, a horizontally
scrolling row of choice chips (six labels don't fit a `SegmentedButton` on a
phone width) wired into `ExerciseDetailScreen`'s new trend section above its
batch-3.1 session list. Added `analyticsClockProvider`
(`Provider<DateTime Function()>`, the same shape `restClockProvider` already
used) so a chart's default range resolves against an overridable "now"
instead of a bare `DateTime.now()` call — without it, a widget test logging
a fixed date and expecting it inside "the last 3 months" would silently
start failing once the real calendar moved far enough past that date; the
test harness overrides it alongside `restClockProvider` whenever `now` is
passed to `pumpScreen`. Found and fixed along the way: the analytics spec's
own `e1rm` fixture had an arithmetic error in one cell (Lombardi at 60kg×12
reps read 76.049; `60 × 12^0.10` is actually 76.925, confirmed numerically
against the other four rows in the same table, which all match their
formula exactly) — corrected in both `docs/40-ANALYTICS-SPEC.md` and
`docs/fixtures/analytics.json` rather than worked around. Not built: the
regression overlay and unreliable-set toggles are screen-local `State`, not
persisted preferences — reasonable for a first chart, worth revisiting if a
second chart wants the same toggles to agree with each other.

**Batch 3.3 — volume & muscle analytics.** `F-ANA-004` done; `F-CAT-013`,
`F-SET-005`, `F-ANA-005` all `in-progress` (each for its own documented
reason — see their status notes). No schema change. `core/units/week_start.dart`
(`WeekStart`) mirrors `UnitPreferences`'s shape: a country-code first-run
default (Sunday for the US/Canada, Saturday for a handful of Gulf states,
Monday elsewhere), persisted afterwards via `WeekStartNotifier`, exposed as
a three-way radio row on Settings root. `domain/catalog/muscle_taxonomy.dart`
maps all 21 muscles to push/pull/legs/core except `neck` and `fullBody`,
which resolve to `null` deliberately rather than being forced into a
category — verified against the analytics spec's own push/pull ratio
fixture. Two new domain modules split "per exercise" from "per
muscle/overall" because they start from different data:
`weekly_volume.dart`'s `weeklyVolumeFromSessions` sums the existing
`ExerciseHistorySession.volumeGrams` for a new "Weekly volume" section on
`ExerciseDetailScreen`; `weeklyVolume` and `sets_per_muscle.dart`'s
`setsPerMuscleByWeek`/`contributingExercises` work from a new cross-catalogue
stream, `SetRepository.watchAllAnalyticsSets` (`AnalyticsSetRecord`, joining
`sets`/`workout_exercises`/`workouts`/`exercises`), that nothing before this
batch needed. `WeeklyBarChart` (`features/shell/widgets/`) is the shared
zero-based bar component the design system names, built on `fl_chart`'s
`BarChart` the same way `TrendChart` used `LineChart`. The Insights tab's
Phase-3 placeholder is gone: `InsightsScreen` now shows the shared date
range selector, overall weekly volume, and muscle-scoped volume/sets-per-week
charts behind a single muscle dropdown, with a non-interactive "contributing
exercises" list beneath (`F-ANA-005` §3's drill-down — scoped to the whole
selected range rather than one tapped bar, since per-bar tap-through is
`F-ANA-016`, batch 3.6, not built yet). Not built: reference bands on the
sets-per-muscle chart (`F-ANA-005` §2) and applying `WeekStart` to streaks
or the calendar (`F-ANA-006`, neither exists yet) — both explicitly deferred
in each feature's own status notes, not silently dropped.

**Batch 3.4 — consistency, PR timeline & balance.** `F-ANA-007` done;
`F-ANA-006`, `F-ANA-008` both `in-progress` (each for its own documented
reason). No schema change — `personal_records.achieved_at` has existed
since schema v3; this batch is the first to read it outside the repository
that writes it. `domain/analytics/consistency.dart` matches the spec's
`streak` fixture exactly, including its trickiest rule: the in-progress
current week never breaks a streak but still counts in the trailing-4-week
average. `CalendarHeatmap` (`features/shell/widgets/`) uses exactly two
cell states — trained or not — no colour ramp by volume and no red for a
miss, since "no shame" (§5 rule 4) is a colour rule as much as a motion
one. `PersonalRecordRepository.watchTimeline` is a plain join with no
domain layer needed — a display list, not a computed metric — reusing
`SessionSummaryScreen`'s own per-kind description wording so a record
reads identically whether celebrated in the moment or found later on the
new `PrTimelineScreen`. `domain/analytics/muscle_balance.dart`'s two
ratios match §9's fixture exactly (27:22, ≈1.23:1), computed over their own
independent trailing-4-week window rather than the shared date range
selector — §9 fixes its own window regardless of what someone has picked
for the volume charts above it — and each ratio's muscle list is the
specific, narrower set §9's own table names, not
`domain/catalog/muscle_taxonomy.dart`'s broader push/pull category from
batch 3.3 (the two serve different purposes; neither is wrong). Both new
screens reached from a new button row at the top of `InsightsScreen`. Not
built: `F-ANA-006`'s weekly target is a fixed `3`, not yet the
user-configurable setting the spec calls for, and its schedule-adherence
figure waits on `F-ROU-012` (scheduling), which doesn't exist; `F-ANA-008`'s
radar chart of relative volume by muscle group ships as two plain-text
ratio tiles instead, clearly labelled a rough guide rather than a
prescription.

**Batch 3.5 — routine programming view.** `F-ROU-011` done; `F-ROU-012`
`in-progress` (its own status note has the detail — fixed weekdays only, no
rolling rotation). No schema change — `routine_days.scheduled_weekdays` has
existed since schema v1 and `duplicate()` already carried it over; this batch
is the first to read or write it anywhere else. `domain/routines/routine_preview.dart`
(`estimateSessionDurationSeconds`, `plannedSetsPerMuscle`, `plannedVolumeGrams`)
reuses `domain/timing/rest_defaults.dart`'s `resolveRestSeconds`/
`restSecondsForGroupMember` for duration (spec §11) and the same
1.0-primary/0.5-secondary rule `F-ANA-005` uses for sets-per-muscle (spec §3),
applied to a day's *targets* rather than logged sets — fixture-tested against
the same `setsPerMuscle` worked example. `RoutineExerciseDetail` and its
backing query gained the exercise's tracking type, equipment, both muscle
fields and its default rest seconds, so the preview can resolve rest and
attribute muscles without a second query. The day editor's new "Preview"
card shows duration and volume in its collapsed subtitle always — only the
`WeeklyBarChart` (fixed 200 px) sits behind an `ExpansionTile`, collapsed by
default. The first version kept the whole card, chart included, always
expanded, which starved the `Expanded` exercise list of layout height badly
enough to break an existing widget test (`routine_flow_test.dart`) on a short
day; collapsing just the chart fixed both the test and the real on-device
layout, since the bug wasn't test-specific, and a widget test now covers both
the collapsed and expanded state so the same starvation can't regress
silently. Muscle-name lookups for the chart use `Muscle.values.asNameMap()`
rather than `.byName`, since `secondary_muscles` is a plain
`StringListConverter` column with no DB-level guarantee every stored name is
still a recognised `Muscle` — same reasoning as `categoryOf()`'s
deliberate null-for-unknown. Scheduling (`F-ROU-012`): `RoutineRepository
.setScheduledWeekdays`/`watchDaysForWeekday` (ISO weekday ints, matching
`DateTime.weekday`), a "Schedule" action (calendar icon or day-tile menu) on
every day-editing surface, and the dashboard's new "Today: Push" card
(`_TodaysScheduleCard`, hidden while a workout is already in progress —
`_ResumeOrStartCard` already owns that state). Not built: the rolling-rotation
half of `F-ROU-012`'s own open question, and wiring `F-ANA-006`'s
schedule-adherence figure to the column this batch finally populates — the
column exists now, but that feature wasn't touched.

**Batch 3.6 — chart interaction & starter programs.** `F-ANA-016` and
`F-ROU-015` both done — the last batch of Phase 3. No schema change.
Chart interaction (`F-ANA-016`): `TrendChart` gains tap-through to a point's
source workout (`onPointTap`, `TrendChartPoint.workoutId` carried from
`E1rmTrendPoint`/`ExerciseHistorySession.workoutId`, reached from the e1RM
trend on `ExerciseDetailScreen`) and pinch-to-zoom on the time axis via
fl_chart 1.2's `FlTransformationConfig` (already satisfied by batch 3.2's
`^1.1.1` constraint — the resolved lockfile had already moved to 1.2.0,
the first minor with transformation support, with no `pubspec.yaml`
change needed); `WeeklyBarChart` gains per-bar tap-through instead of
zoom — a
week aggregates many workouts, so there's no single session to navigate to,
and pinch/pan risked fighting the routine day editor Preview card's parent
scroll the same way batch 3.5's own chart there once broke a widget test.
Tapping a bar on Insights' "hard sets per muscle" chart now scopes the
existing "contributing exercises" drill-down (`F-ANA-005` §3) to that one
week, closing the exact deferral `sets_per_muscle.dart`'s doc comment named
since batch 3.3 ("tap-through to a single bar is `F-ANA-016`, batch 3.6").
Starter programs (`F-ROU-015`): `domain/routines/starter_programs.dart`
(pure Dart, `StarterProgram`/`StarterProgramDay`/`StarterProgramExercise`)
ships all six named programs — PPL, Upper/Lower, Starting Strength, GZCLP,
5/3/1, nSuns — as structure only, exercises referenced by the catalogue's
stable `external_id` rather than a database row id; percentage/wave loading
the schema's absolute targets can't express (5/3/1, nSuns) lands in each
day's `loadingNotes`, written in this codebase's own words, never
transcribed from the source, alongside an `attribution` string and a
source `attributionUrl` for every program.
`RoutineRepository.importStarterProgram` resolves references against the
live catalogue at import time, skips and reports whatever it can't find
rather than failing the whole import, and keeps no back-reference to the
template — same "snapshot, never link" reasoning as `duplicate()`/
`createFromWorkout()` (`ADR-0004` generalised one level up). Reached from
`StarterProgramGalleryScreen` (`/routines/starter-programs`), a browsable
list rather than an `ExerciseSeeder`-style auto-seed, linked from the
routine list's empty state and a permanent app-bar icon. A pure-domain test
asserts every program's exercise references resolve against the seeded
catalogue — the guard against a program silently rotting as the seed list
changes. Not built: reduce-motion gating (`F-A11Y-005`) for either chart
widget — no chart anywhere in the codebase reads
`MediaQuery.disableAnimations` yet, and adding it here alone, for these two
widgets only, without an app-wide convention was judged out of scope.

**Phase 3 audited and declared complete (v0.34.0)**, mirroring Phase 2's own
audit batch: a test per exit criterion proving the criterion's own wording.
Every Phase-3-scheduled metric already had its spec's fixture as a test;
dark-theme rendering was the one real gap in "charts render in both themes"
and is now covered for all three chart widgets (`TrendChart`,
`WeeklyBarChart`, `CalendarHeatmap`), alongside a `dark` param added to
`pumpScreen` for future screen-level theme tests. Two criteria could not be
verified in this session and are recorded as such rather than silently
marked met: the real-training-block figure check is **waived**, same
reasoning as Phase 1's own waived "two weeks of real training" criterion —
there is still no real block to check against; and the literal "under
100 ms on a mid-range device" number needs an AOT-compiled release build on
real hardware to mean anything — `flutter test`'s JIT tier measured ~3x over
budget for reasons entirely explained by that gap, not by the code being
slow, so `recompute_performance_test.dart` instead proves recomputation is
linear in history size, not quadratic, and defers the literal wall-clock
number to the same on-device verification Phase 1's criteria used.

**Phase 4 started (v0.34.0) — batched into 4.1–4.6** in
`docs/50-ROADMAP.md`, the same way Phases 2–3 were.

**Batch 4.1 — progression engine & first rule.** `F-PRG-002`, `F-PRG-006`,
`F-PRG-007`, `F-PRG-008` and `F-PRG-009` done; `F-PRG-001` `in-progress` —
its own acceptance note has the one unmet criterion (plate-aware rounding,
waiting on `F-PRG-012` in batch 4.3). No schema change —
`routine_exercises.progression_rule` and `workout_exercises.target_snapshot`
have existed since schema v3 and v1 respectively; this batch is the first to
write a real value into the former or read anything beyond the static
routine target out of the latter. `40-ANALYTICS-SPEC.md` had no progression
section before this batch — §12 is new, with a `linearProgression` fixture
covering success, partial, failure, deload, and first-run, the same set
Phase 4's own exit criterion demands per rule.
`lib/domain/progression/` holds the pure engine: `computeTargets` (the
literal `F-PRG-001` §1 signature) derives a linear rule's failure streak by
walking real logged history backward rather than storing an incrementally
updated counter — the same recompute-from-raw-data reasoning
`PersonalRecordRepository.rebuildAll` already used — and models one
**top set** per exercise, not independent per-set progression (`F-PRG-001`'s
own doc comment names this as the scope `F-PRG-002`'s spec describes).
`ProgressionRationale` is structured data, not a sentence — canonical units
only, so `lib/features/logging/presentation/progression_rationale_text.dart`
is what turns it into "You hit every set at 100 kg last time, so this is
+2.5 kg." using the same `QuantityFormatter` every other screen already
reads weight through, shown collapsed-to-one-line and expandable on the
active workout screen, the same interaction `_StickyNoteText` already used
there for the exercise note. `RoutineRepository.setProgressionRule` and a
`SegmentedButton` on the day editor's target sheet ("I'll decide" vs. "Add
weight on success") are `F-PRG-007`; `duplicate()` was updated to carry a
routine exercise's assigned rule to its copy, closing the same
copy-every-field gap `F-ROU-005`'s superset `group_id` fix closed for
batch 2.1. `startFromRoutineDay` now calls `computeTargets` for every
exercise — a real behaviour change, deliberate and spec'd
(`F-PRG-006` names manual carry-forward "the default"): a *second* start of
a routine day with no rule assigned now proposes the last actually-logged
weight rather than repeating the routine's static target verbatim, which a
new repository test asserts directly. `SetRepository.getExerciseHistory` is
the one-shot equivalent of the existing `watchExerciseHistory` stream this
needed. Not built: double progression, percentage/training-max, and
RPE-autoregulated rules (`F-PRG-003`–`F-PRG-005`, batch 4.2); plate-aware
rounding and a routine-level (rather than per-exercise) rule default.

**Batch 4.2 — remaining progression rules (partial, v0.36.0).** `F-PRG-003`
(double progression) and `F-PRG-005` (RPE-autoregulated) done; `F-PRG-010`,
`F-PRG-004` untouched, still `planned` — this batch is not closed. No schema
change — `routine_exercises.progression_rule` already stored an arbitrary
JSON union; this batch writes the second and third variants into it, and
`sets.rpe` (`F-LOG-014`, schema v1) is the first thing outside the logger to
read it. `domain/progression/double_progression.dart` mirrors
`linear_progression.dart`'s shape but judges a session against two
thresholds instead of one (`repsMax` for "add weight", `repsMin` for "heading
toward deload" — a mid-range session is neither and just repeats), with the
same derived-not-stored trailing-streak approach `computeTargets` already
used for the linear rule's failure count. `ProgressionContext` gained
`staticRepsMax` (`staticReps` already existed, doubling as the rep floor for
this rule) since `TargetSet.reps` still isn't read anywhere downstream of
`startFromRoutineDay` — only `weightGrams`, `sets` and `rationale` are.
`domain/progression/rpe_autoregulation.dart` compares the target RPE
(`routine_exercises.target_rpe`, already existed) against the RPE logged on
last session's top set and buckets the gap into four bands (≥1 under: double
step, 0–1 under: normal step, 0–1 over: repeat, ≥1 over: 10% back-off),
reusing `ProgressionOutcome.success`/`.partial`/`.deload` rather than adding
new enum values — the same three directions linear progression already
names, reached by a different signal. No RPE logged, or no target RPE
configured, degrades to plain linear progression exactly (`F-PRG-005`'s own
spec) — `computeTargets`'s linear-rule body was extracted to a private
`_computeLinearTarget` helper so both the `LinearProgressionRule` case and
this degrade path share one implementation rather than two copies.
`ExerciseHistorySet` gained an `rpe` field and `SetRepository`'s exercise-
history query now selects `s.rpe` — nothing before this batch needed a set's
RPE outside the logger itself. The day editor's target sheet gained a fourth
segment ("Match effort (RPE)"), a target-RPE dropdown (the existing
`rpeSteps` from `F-LOG-014`), and — since a fourth segment plus its fields
now overflow the sheet's fixed test-harness height — the whole sheet is
wrapped in a `SingleChildScrollView`; `routine_flow_test.dart`'s existing
"Save targets" tap needed `scrollUntilVisible` with an explicit `scrollable:`
finder as a result, since two `Scrollable`s are now on screen at once (the
background list plus the sheet) and the unscoped default binds to whichever
one flutter_test picks arbitrarily first. `docs/40-ANALYTICS-SPEC.md` §12
gained both rules plus `doubleProgression` and `rpeAutoregulation` fixtures
(success/partial/failure/deload/first-run, and RPE's own degrade case),
mirrored into `docs/fixtures/analytics.json`. Not started: `F-PRG-010`
(training max) needs a persistence decision this session didn't make — a new
per-exercise column (schema v4) vs. cramming it into the rule JSON, which
would contradict "per exercise, independent of any one rule"; `F-PRG-004`
(percentage-based) depends on it, and also on `F-ROU-013` (week/cycle
structure), which doesn't exist yet, so it can't reach full fidelity
regardless of what `F-PRG-010` decides — the two remaining items in this
batch, in dependency order.

**Batch 4.3 — plate maths.** `F-PLT-002`, `F-PLT-004` and
`F-PRG-012` done. Schema unchanged — `bars` and
`plates` have existed since schema v3, unpopulated until now; this batch is
the first to read or write either. `docs/40-ANALYTICS-SPEC.md` gained §13
(plate solve, closest achievable, plate-aware rounding) with a single
worked fixture reused across all three, deliberately built with no
micro-plates in its inventory so a 2.5 kg progression increment is *not*
assemblable — the case §3 exists for — mirrored into
`docs/fixtures/analytics.json#plateMaths`. `domain/plates/plate_calculator.dart`
holds `solvePlateLoad` (greedy heaviest-first per §2, closest-below/above
via the smallest unused pair on a miss) and `closestAchievableGrams`
(`F-PLT-004`, direction-configurable, default down).
`domain/progression/plate_aware_rounding.dart`'s `applyPlateRounding` is
applied by `WorkoutRepository.startFromRoutineDay` *after* `computeTargets`,
never inside it (§12 rule 5) — every 4.1/4.2 progression fixture test stays
untouched, and rounding is skipped entirely with no bar or empty inventory
configured, so a fresh install behaves exactly as it did before this batch.
Its §3 case — a raw increase that rounds back to the previous session's
weight — is `ProgressionOutcome.plateRoundingHeld`, detected structurally
(the round-trip) rather than by comparing the jump to the rule's own
increment number, so it holds correctly under RPE-autoregulation's
`2×increment` branch too. That case also needed
`WorkoutRepository.startFromRoutineDay`'s own snapshot write fixed: it was
building `targetRepsMin` from the routine's static config unconditionally
(a deliberate `F-PRG-001`-era choice, "never collapse a configured range"),
which silently discarded the held case's `reps + 1` — now overridden
specifically for `plateRoundingHeld`, every other outcome unchanged.
`PlateRepository` (`F-PLT-002`) — CRUD for both tables plus `resolveBar`
(exercise's own bar → inventory default → heaviest available, never
throwing on a tombstoned `default_bar_id`) and `seedDefaultsIfNeeded`, a
first-run-only kg/lb set gated by an `app_settings` marker rather than the
load unit itself, so a later unit switch never rewrites a curated
inventory — `main()` resolves the seed unit the same way
`UnitPreferencesNotifier`'s own first-run inference does, since that
provider isn't constructed yet this early in startup. New surfaces: Settings
› Bars & plates (`PlateSettingsScreen`, add/edit bars, enable and set pair
counts on plates); a "Bar" dropdown on the exercise editor for barbell
exercises only (§4); and `PlateCalculatorSheet`, one tap from the weight
field on the numeric keypad for any barbell exercise (§4 of `F-PLT-001`).
`F-PLT-001` was left `in-progress` at the end of that first pass — §5's
non-barbell cases waited on `F-PLT-005`, not yet built.

**Batch 4.3 closed (v0.38.0).** `F-PLT-003` and `F-PLT-005` done, both P2,
closing out the batch. Schema v4 adds `exercises.weight_source`
(`WeightSource`: `plateLoaded`, `fixedIncrement`, `stack`) plus its
per-source config columns (`fixed_increments_grams`, `stack_base_grams`,
`stack_step_grams`, `stack_half_step_grams`) — existing rows default to
`plateLoaded`, exactly how every exercise behaved before this column
existed, so no backfill beyond the default column value was needed.
`defaultWeightSourceFor` mirrors `defaultWeightEntryModeFor`'s per-equipment
guess (`F-LOG-017`): dumbbell/kettlebell → fixed increment, machine/cable →
stack, everything else → plate-loaded, always overridable on the exercise
editor's new "Weight source" field, which swaps in the bar picker, an
available-weights list, or base/step/half-step fields depending on the
choice. `domain/plates/weight_source_calculator.dart` mirrors
`closestAchievableGrams`'s direction semantics for the other two sources:
`closestAchievableFixedIncrement` looks up the nearest value actually in
the configured list — a real dumbbell rack is not evenly spaced, which is
why this is an explicit list rather than a step size — and
`closestAchievableStack` enumerates `base + n·step` and, when a half step
is configured, `base + n·step + halfStep`.
`domain/progression/plate_aware_rounding.dart` gained
`applyFixedIncrementRounding`/`applyStackRounding` alongside the existing
`applyPlateRounding`, refactored to share one hold-or-round decision
(`_applyRounding`) so `F-PRG-012` §3's "the rounding erased the whole
proposed increase" case works identically across all three sources.
`WorkoutRepository.startFromRoutineDay` now dispatches on the exercise's
own `weight_source` rather than assuming plate-loaded, closing the gap
`F-PLT-001`'s status note left open; `PlateCalculatorSheet` does the same
dispatch to decide what it shows — the plate solve and its to-scale
drawing, the closest stocked dumbbell weight, or the closest reachable
stack pin. `features/shell/widgets/plate_stack_visualization.dart`'s
`PlateStackVisualization` (`F-PLT-003`) draws one side, heaviest plate
nearest the bar sleeve (how a bar is actually loaded), height scaling with
plate size within a fixed band so a 1.25 kg change plate never draws
taller than a 25 kg one; colours are bucketed by canonical kilograms
regardless of the display unit, since the IPF convention itself is defined
in kg and a pound-configured inventory still uses these same physical
plate sizes.

**Phase 4 batch 4.4 — body tracking (v0.39.0, partial).** `F-BOD-002` done;
`F-BOD-003` `in-progress` (§4's optional goal line waits on `F-BOD-005`, not
attempted). No schema change — every `MeasurementType` value and
`body_measurements` itself have existed since schema v1/v3; this batch is
the first to read or write any type but `bodyweight`.
`BodyMeasurementRepository` gained generic `watchHistory`/`watchLatest`/
`logMeasurement`/`updateMeasurement`/`deleteMeasurement`, deliberately
separate from `F-BOD-001`'s bodyweight-specific methods — only bodyweight
triggers the workout-bodyweight recompute, and routing every type through
that path would run it needlessly for a waist measurement.
`trackedMeasurementTypesProvider` (`SharedPreferences`, same shape as
`weekStartProvider`) persists which of the twelve non-bodyweight types
someone has opted into, empty by default per `F-BOD-002`'s own "showing all
thirteen is clutter." `domain/analytics/bodyweight_trend.dart`'s
`bodyweightTrendEma` matches §6's `ema` fixture exactly, and
`weeklyRateOfChangeGrams` reuses `linear_regression.dart` for the
slope-of-a-series-against-elapsed-time computation that module's own doc
comment had already earmarked for a second consumer. `TrendChart` gained an
optional `secondaryPoints` — a muted, line-less scatter drawn behind the
dominant series — so the raw bodyweight points render behind the EMA
without a second chart widget existing. The body screen (renamed from
bodyweight-only) gained a "Measurements to track" sheet from its app bar,
a trend section (EMA chart plus weekly rate of change) above the bodyweight
history, and one section per tracked type below it, each backed by
`LogMeasurementSheet` — a single sheet dispatching on shape: `Length`
(millimetres, cm/in display) for the eleven circumferences, or a bare
percentage (basis points, new `QuantityFormatter.percent`/
`QuantityParser.parsePercentBasisPoints`) for `bodyFatPercent` — the same
"one screen, dispatch on shape" reasoning `F-PLT-005`'s weight-source
fields used a batch earlier.

**Phase 4 batch 4.5 — advanced analytics & deload (v0.40.0, partial).**
`F-ANA-009`, `F-ANA-010`, `F-ANA-011` and `F-PRG-011` done; `F-ANA-012`
(duration/rest compliance, P3) and `F-ANA-014` (body map heat overlay, P3 —
needs a licence-clean SVG asset this session couldn't responsibly source)
not attempted; `F-ANA-013` (weekly insight cards) not attempted either —
it depends on all four `F-ANA-*` metrics done here plus `F-ANA-004`/
`F-ANA-005`, and composing a significance-ranked, never-fabricated card
generator on top of them is its own batch-sized piece of work, so this
batch closes with the underlying signals built rather than half-building
their dashboard consumer. No schema change. `domain/analytics/
stall_detection.dart`'s `detectStall` matches §7's `slope` fixture exactly
— silence under 5 sessions, the trailing-8-session window, and the
slope-and-3-week-span condition together (the open question in
`F-ANA-009`'s own doc — real-history-tuned thresholds — stays open, same
waiver shape as Phase 1/3's own no-real-history criteria).
`domain/analytics/acwr.dart`'s `computeAcwr` matches §8's `acwr` fixture,
built on a new `dailyVolume` helper alongside the existing `weeklyVolume`
in `weekly_volume.dart`. `domain/analytics/intensity_distribution.dart`
buckets sets by rep range and by percentage of e1RM — using each
exercise's own best e1RM *as of the session before it*, so a set from an
exercise's first-ever session has no baseline and is excluded rather than
bucketed as zero (§10 rules 1–2) — plus an RPE-based reading shown
alongside wherever RPE was logged (§10 rule 3). `AnalyticsSetRecord`
(the shared whole-catalogue stream `F-ANA-004`/`F-ANA-005` already used)
gained `exerciseId` and `rpe` columns for this — grouping by exercise
*name* alone was never safe (`F-CAT-003` §4 allows duplicate names).
`domain/progression/deload_suggestion.dart`'s `suggestDeload` is a pure
composition of the two: suggested only when *both* signals fire (`F-PRG-011`'s
own spec), each with its own plain-English reason, never an automatic
program change. New surfaces: `InsightsScreen` gained a "Training load"
ACWR info tile (explicitly labelled information, never a warning — §8
rule 4, the same "rough guide, not a prescription" framing already used
for muscle balance) and rep-range/intensity/RPE histograms, reusing
`WeeklyBarChart` for a non-weekly categorical axis since the widget only
ever needed `(value, label)` pairs; `ExerciseDetailScreen` gained a stall
banner — plain English, not a chart annotation (§7 rule 5), rendering
nothing at all when there's no verdict or it isn't stalled — that also
shows the deload suggestion when `F-ANA-010`'s workload signal agrees.

**Phase 4 batch 4.6 — logging extras (v0.41.0).** `F-LOG-019`, `F-LOG-020`
and `F-TIM-009` all done — the last scheduled batch of Phase 4, though the
phase itself is not yet audited complete (`F-PRG-004`/`F-PRG-010` from
batch 4.2 and `F-ANA-013` from batch 4.5 remain `planned`/not attempted,
so the roadmap's own exit criteria aren't all met). Schema v5 adds
`exercises.warmup_ruleset` (nullable JSON, null = the app-wide default
ramp) — every other column this batch touches (`bodyweight_coefficient`,
`sets.rpe` used only for stopwatch's own duration field) already existed.
Bodyweight-loaded exercises (`F-LOG-019`): `domain/logging/
bodyweight_load.dart`'s `effectiveLoadGrams` is the pure §1 formula
(bodyweight × coefficient + added weight); `set_fields.dart`'s
`bodyweightReps` case gained `SetField.weight` so the set row can log
*added* weight (a push-up leaves it blank, a weighted pull-up doesn't) —
storage was always meant to be added-only, this is what actually renders
the field. The per-exercise coefficient (`exercises.bodyweight_coefficient`,
existed since schema v3) is a plain percentage field on the exercise editor
shown only for that tracking type, defaulting to unset (full bodyweight).
§2's "nearest measurement, falling back to most recent" needed no new code
— `WorkoutRepository._backfillBodyweight` (`F-BOD-001`) already resolves
`workouts.bodyweight_grams` that way at session start. §4 (analytics use
effective load) reaches only `weekly_volume.dart`'s `weeklyVolume`/
`dailyVolume` this batch, via a new `_setVolumeGrams` helper and two new
fields on `AnalyticsSetRecord` (`workoutBodyweightGrams`,
`bodyweightCoefficient`); `personal_records.dart` and
`exercise_history.dart` still key off raw weight, left alone for the same
reason batch 3.1 left PR detection's own filter alone. Warm-up generator
(`F-LOG-020`): `domain/logging/warmup_generator.dart`'s
`generateWarmupSets` rounds each step through the caller's own
weight-source-aware function (`F-PLT-005`) then clamps to
`[minWeightGrams, workingWeightGrams]`; `SetRepository.insertWarmupSets`
shifts whatever's already logged to make room and inserts the generated
`warmup` sets ahead of it in one transaction; `WarmupGeneratorSheet`
(reached from the active workout screen's per-exercise menu) resolves
rounding with the same plate/fixed-increment/stack dispatch
`PlateCalculatorSheet` uses, and saves the edited ruleset back to the
exercise on generate. Stopwatch (`F-TIM-009`): `domain/timing/
stopwatch.dart`'s `LogStopwatch` is `RestTimer`'s own "value, not a ticking
object" shape — elapsed time derived from a stored start timestamp against
"now", immune to background drift — wired into `NumericKeypadSheet` as a
start/stop toggle shown only for the duration field, redrawn once a second
by a `Timer.periodic` that is the sheet's own state, not a new provider.
Found and fixed along the way, via this batch's own new widget test:
`PlateRepository.getBars`/`getPlates` (`F-PLT-002`) read through
`watchBars().first`/`watchPlates().first`, a stream-based one-shot read
that needs more real asynchronous hops than `pumpAndSettle` reliably
drives forward in a widget test — `WarmupGeneratorSheet` was the first
caller to hit this off the stream path, surfacing as the sheet silently
never closing after "Generate" with no exception thrown. Both getters now
run a plain one-shot query instead, which is both the fix and the more
correct shape for what was always meant to be a single read; no other
caller of either method needed to change.

**Phase 4 batch 4.2, second pass — training max & percentage-based
progression (v0.42.0).** `F-PRG-010` and `F-PRG-004` both done, closing out
batch 4.2 (`F-PRG-003`/`F-PRG-005` landed in the first pass). Schema v6
adds `exercises.training_max_grams` (nullable, null on every existing row —
a percentage-based rule can't be assigned without one anyway, so nothing
behaves differently until it's set). `domain/progression/training_max.dart`'s
`deriveTrainingMaxGrams` is `floor(bestE1rm × 0.9)` — floored rather than
rounded, since a training max is a conservative anchor meant to err light;
`PersonalRecordRepository.bestE1rmGrams` reads the cached `bestE1rm` record
(`F-LOG-013`) a new "Derive from e1RM" button on the exercise editor uses to
fill the field, same as every other field there, without saving until the
user hits the screen's own Save. `PercentageProgressionRule`
(`domain/progression/progression_rule.dart`) is the one rule in
`computeTargets` that ignores logged history entirely — `nextWeight =
round(trainingMax × percent)`, decided before the engine's own first-run
check even runs (extracted to `_computePercentageTarget`, called both from
the early branch and from the switch's now-required exhaustive case) —
because the training max is what's supposed to move, never the weight
itself reacting to a session's success or failure the way every other rule
here does. No training max configured falls back to the routine's static
target unchanged, the same "nothing to compute from yet" shape `firstRun`
already used for missing history, reused rather than given a second outcome
value. Deliberately not full 5/3/1-style fidelity: this is a flat
percentage, not a multi-week wave — `F-ROU-013` (week/cycle structure)
still isn't scheduled, so there is nothing yet for the percentage to vary
against week to week, exactly the caveat batch 4.2's own first-pass status
note left open. Reached from a fifth "% of TM" segment on the day editor's
target sheet's `SegmentedButton`, which stayed within one row across all
five phone-width segments in the existing widget tests without needing the
chip-row treatment `F-ANA-015`'s date range selector used for six longer
labels. `docs/40-ANALYTICS-SPEC.md` §12 gained both the training-max
derivation formula and the percentage rule, plus a `trainingMaxProgression`
fixture (`docs/fixtures/analytics.json`) covering the percentage case and
the no-training-max fallback.

**Phase 4 closing pass — duration/rest compliance, weekly insight cards,
body map (v0.43.0).** `F-ANA-012`, `F-ANA-013`, `F-ANA-014` all done — the
last three features scheduled for Phase 4, closing out batch 4.5 and the
phase itself. No schema change. Duration and rest compliance (`F-ANA-012`):
`domain/analytics/duration_compliance.dart`'s `sessionDurationTrend` is
`endedAt − startedAt` per finished session; `averageRestComplianceRatio`
averages actual-vs-prescribed rest across every completed, non-warm-up set
with a recorded `rest_taken_seconds` (`F-TIM-007`), "prescribed" resolved
through the exercise's *current* configuration (`resolveRestSeconds`) since
no per-set historical snapshot exists — a documented approximation, not a
gap. Weekly insight cards (`F-ANA-013`): `domain/analytics/
weekly_insights.dart`'s `generateWeeklyInsights` composes three existing
signals (per-muscle volume, per-exercise e1RM via `epley1Rm`, hard sets per
muscle) into a ranked, capped list, gated by a hard "at least 3 distinct
weeks of history" rule that closes the acceptance criterion directly — two
sessions land inside one or two calendar weeks, so nothing is generated for
them at all. Each signal has its own significance-threshold, and a plain
"sets last week" fact is deliberately scaled below any real comparison's
significance so a busy muscle's raw count can never crowd out a genuine
change — a bug the first draft of the ranking had, caught by its own
fixture test. Reached on the **dashboard**, per the feature's own spec
(not Insights) — `WeeklyInsightsSection` renders nothing at all while
loading, on error, or with insufficient history, never a placeholder; each
card links to the chart behind it, precisely for the e1RM kind (the specific
exercise's detail screen) and generally for the two muscle-scoped kinds
(the Insights tab, since its muscle picker is local widget state, not a
route parameter — a documented simplification). Body map heat overlay
(`F-ANA-014`): resolves batch 4.5's own "needs a licence-clean SVG this
session couldn't responsibly source" blocker by not needing an SVG at all —
`BodyMapHeatOverlay` draws an original, non-anatomical silhouette with
`CustomPaint`, simple rounded rectangles per muscle region, nothing traced
or sourced from anywhere. `domain/analytics/muscle_heat.dart`'s
`muscleHeatIntensity` is relative to the hottest-trained muscle in the
window, not absolute. Closes `F-CAT-013` §2 as a side effect:
`domain/catalog/muscle_taxonomy.dart`'s new `bodyMapViewOf` maps every
categorised muscle to a front/back region, `neck`/`fullBody` to neither,
the same "decide explicitly" precedent `categoryOf` already set. Both new
`InsightsScreen` sections ship collapsed behind an `ExpansionTile` by
default — `F-ROU-011`'s own starvation fix, needed again here: an
uncollapsed first draft of `BodyMapHeatOverlay` (an unbounded-width 100:220
portrait shape) pushed "Overall weekly volume" and its chart out of the
initial render/cache extent, caught by this batch's own widget test rather
than shipped.

**Phase 4 audited and declared complete (v0.43.0)**, mirroring Phases 2 and
3's own audit batches. All four roadmap exit criteria are met:
starting a routine day pre-fills targets that are correct, explained, and
always assemblable — proven end-to-end by an existing batch 4.3 repository
test that actually calls `startFromRoutineDay` through a real plate
inventory and asserts the `plateRoundingHeld` rationale, not just the
domain-level rounding function in isolation; the plate calculator never
proposes plates the user doesn't own, same test plus `F-PLT-004`'s own
fixture; every progression rule has fixture tests for success, partial,
failure and first-run — true for linear, double-progression and
RPE-autoregulation, with one deliberate, documented exception:
percentage-of-training-max has no success/partial/failure verdict *by
design* (`F-PRG-004`'s own spec — the training max moves by hand, not by
session performance), so its fixture instead covers the percentage
computation and the no-training-max fallback, the shape that actually
applies to it; and insight cards say nothing at all when data is
insufficient, proven both at the domain level (`weekly_insights_test.dart`)
and through the real `DashboardScreen` (`weekly_insights_section_test.dart`
asserts no "This week" section renders with too little history) — the
widget-level proof Phases 2 and 3's own audits established as the standard,
not just a domain fixture. Every feature `F-PRG-*`, `F-PLT-*`, `F-BOD-*`,
`F-ANA-*` and `F-LOG-019`/`F-LOG-020`/`F-TIM-009` scheduled for Phase 4 is
`done`.

**Dev tooling — demo data seeder (v0.44.0).** Not a roadmap feature (no
`F-ID`), same as the `tools/*.sh` scripts. `lib/data/seed/demo_data_seeder.dart`'s
`DemoDataSeeder` writes 8 weeks of a Push/Pull/Legs split plus weekly
bodyweight through the real repositories (`WorkoutRepository.start`/
`finish`, `SetRepository.addSet`/`complete`), so every derived table (PRs,
`workouts.bodyweight_grams`, rest-taken seconds) comes out the way real use
would produce it rather than being poked in directly. Reached from a
`kDebugMode`-gated "Load sample data" button on Settings › Data, never
present in a release build. Exists so the analytics screens (weekly
insights, stall detection, ACWR, muscle balance, the body map) have
something to look at without hand-logging weeks of sessions first.

**Phase 5 — Data (v0.44.0–v0.48.3).** This "Current state" narrative fell out
of sync with `docs/50-ROADMAP.md` during Phase 5 — none of its five commits
touched this file. Recorded here after the fact, from the roadmap's own
Phase 5 section (the authoritative record) rather than re-derived: batch
5.1 (`F-DAT-001`, `F-DAT-003`, `F-DAT-004`, `F-DAT-010`) built the real
JSON export/backup/restore/wipe round trip on top of `F-DAT-011`'s
Phase-1 rescue-dump escape hatch; 5.2 (`F-DAT-002`, `F-DAT-008`) added CSV
export and automatic backups; 5.3 (`F-DAT-005`, `F-DAT-006`, `F-DAT-007`)
added Strong/Hevy CSV import, `F-DAT-005`'s own real-file verification
later waived by the project owner; 5.4 (`F-BOD-004`, `F-SET-010`) added
progress photos (excluded from JSON backup by construction — file paths
only, no bytes in the export) and a PIN-only app lock, no biometrics. Phase
5 declared complete at v0.48.3 with the round-trip exit criterion proven
table-by-table in `test/data/db/table_snapshot_io_test.dart`. Full detail:
`docs/50-ROADMAP.md` §Phase 5.

**Phase 6 started (v0.49.0) — batched into 6.1–6.5** in
`docs/50-ROADMAP.md`, the same way Phases 3–5 were.

**Batch 6.1 — accessibility, partial.** `F-A11Y-001` and `F-A11Y-003` done;
`F-A11Y-002` and `F-A11Y-005` `in-progress`. No schema change.
`docs/24-DESIGN-SYSTEM.md` §130 claims accessibility "is not a Phase 6
retrofit," and that was largely true — `SetRow` (`F-LOG-003`) already
carried a semantic label, a text-scale stacking threshold, and
colour-plus-letter set-type encoding, and `app_theme_test.dart` already
held `AppColors` to 4.5:1. Auditing the rest of the app found the real gap:
only 3 files used `Semantics`, 1 read `MediaQuery.textScal*`, and none
checked `disableAnimations`. `TrendChart` and `WeeklyBarChart` are
`fl_chart` canvas painting, not semantic, so a screen reader got nothing
from either (`F-A11Y-001`'s own spec names charts explicitly) — both now
wrap the chart in `Semantics(label: ...)` over an `ExcludeSemantics`-wrapped
chart, the label built from the same points/value-formatter the chart
already renders. Both also gate their `fl_chart` swap-animation `duration`
on `MediaQuery.disableAnimations`, as does `PrBadge`'s 350 ms entrance
`TweenAnimationBuilder` (`F-A11Y-005`); `CalendarHeatmap` has no animation
of its own and needed no change. `F-A11Y-003`'s untested half — 3:1 for
interactive boundaries — is now one line in `app_theme_test.dart` asserting
`ColorScheme.outline` against `surface` in both themes, passing by
construction from Material 3's own seeded scheme; "no colour alone" was
already true and needed no code. Left `in-progress`: `F-A11Y-005`'s
"instant transitions" also covers page-route transitions
(`PageTransitionsTheme`), not touched this batch — an app-wide change out
of scope for a chart-focused fix. `F-A11Y-002` stays `in-progress` because
`SetRow`'s stacking behaviour is now proven at the screen level (new
200%-scale `ActiveWorkoutScreen` and `ExerciseDetailScreen` render tests,
`pumpApp` gaining `textScale` support alongside `pumpScreen`'s existing
one — `pumpApp` needed `tester.platformDispatcher.textScaleFactorTestValue`
rather than `pumpScreen`'s `MediaQuery`-wrapping trick, since
`MaterialApp.router` builds its own root `MediaQuery` from the platform
view rather than inheriting an ancestor one) but every other screen —
catalogue, history, routines, insights, settings — remains unverified at
200%, left for a future accessibility pass rather than claimed done.
Batches 6.3–6.5 (onboarding, release, Health Connect) not started;
`F-HLT-001`/`F-HLT-002` are blocked on this session's toolchain having no
Android SDK or device regardless.

**Batch 6.2 — localisation & branding, partial.** `F-I18N-001`
`in-progress`; `F-THM-006` deliberately not attempted, stays `planned` —
`flutter_launcher_icons`/`flutter_native_splash` write platform assets this
session's toolchain (no Android SDK, no device) can't render or verify,
same deferral class as `F-TIM-003`/`F-ANA-014`; `F-REL-006` depends on it
and stays untouched too. `F-I18N-001`'s ARB pipeline is real: `flutter:
generate: true`, `l10n.yaml`, `lib/l10n/app_en.arb`, `AppLocalizations`
wired into `app.dart` and both `pumpScreen`/`pumpApp` in the test harness.
`SettingsScreen` is the one fully migrated screen (18 keys) — chosen for
being self-contained, not small; unit symbols and anything
`QuantityFormatter`/`intl` already formats deliberately stay outside ARB.
Every other screen is still English literals. Full detail:
`docs/50-ROADMAP.md` §Phase 6 batch 6.2.

Local toolchain: Flutter at `/opt/flutter` on the Linux sandbox, or
`C:\flutter` on the Windows machine (`git clone https://github.com/flutter/flutter.git -b stable --depth 1 C:\flutter`,
then add `C:\flutter\bin` to `PATH` — done once, persisted to the user `PATH`
via `setx`/`[Environment]::SetEnvironmentVariable`). Flutter web is not a
target platform. `tools/verify.sh` passes clean on both as of this note —
if a future session finds neither toolchain present, set one up the same
way before trusting an unverified diff.

**Android SDK is now installed on the Windows machine (2026-08-14)** —
`flutter build apk`/`appbundle` work locally, not just in CI. Eclipse
Temurin JDK 17 (`C:\Program Files\Eclipse Adoptium\jdk-17.0.20.8-hotspot`,
`JAVA_HOME`), Android SDK command-line tools at `C:\Android\sdk`
(`ANDROID_HOME`/`ANDROID_SDK_ROOT`), with `platform-tools`,
`platforms;android-36`, and `build-tools;36.0.0` installed and licences
accepted (`flutter config --android-sdk C:\Android\sdk` points Flutter at
it). All four env vars are persisted at the Windows user level, plus
`platform-tools` and `cmdline-tools\latest\bin` on `PATH`.

**Required fix, not optional**: `TEMP`/`TMP` were redirected to
`C:\Android\tmp` (plain local folder, persisted at the user level) because
Gradle — and any JVM's `java.nio.channels.Selector.open()`/`Pipe.open()`
on this specific machine — fails with `java.io.IOException: Unable to
establish loopback connection` / `SocketException: Invalid argument:
connect` when its internal Unix-domain-socket auto-bind lands under
`C:\Users\<user>\AppData\Local\Temp` (this profile's OneDrive-affected
tree — see the hub's own `C:\claude\CLAUDE.md` note on that). Isolated with
a minimal Java reproduction (`ServerSocketChannel.open(StandardProtocolFamily.UNIX)`
+ `bind(null)`, connect fails under `AppData\Local\Temp`, succeeds under a
plain `C:\Android\...` path) before touching anything — `-D` system
property overrides (`java.io.tmpdir`, `preferIPv4Stack`, forcing
`WindowsSelectorProvider`) were tried first and **do nothing**; only
redirecting the actual `TEMP`/`TMP` environment variables works, because
the JDK's Unix-domain-socket path resolution reads the OS temp path
directly, not the `java.io.tmpdir` system property. No Android SDK license
prompt in `sdkmanager.bat --licenses` accepts through a PowerShell pipe —
route the "y" lines through a file and use `cmd /c "... < file.txt"`
redirection instead, and set `JAVA_HOME` inline in the same command (each
tool-call PowerShell process is fresh; a `[Environment]::SetEnvironmentVariable`
from an earlier command isn't visible to a later one, only to processes
started after the *next* full session/shell restart). A debug APK
(`flutter build apk --debug`) built clean with this setup, confirming the
whole chain end to end — first real local verification since Phase 1.
No emulator/AVD attempted: `systeminfo` reports this machine is itself
already running under a hypervisor, so nested virtualization for the
Android emulator is unlikely to be available — real on-device testing
(`F-HLT-001`/`F-HLT-002`, and physically confirming `F-THM-006`'s icon
once it has source art) still needs a real phone or a host-level nested-
virtualization check this session can't perform. Visual Studio (Windows
desktop target) remains not installed — irrelevant to this app, which
doesn't target Windows as a release platform.
