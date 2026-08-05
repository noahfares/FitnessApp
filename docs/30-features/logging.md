# Workout logging — `LOG`

The core loop. Principle 1 in [`../10-VISION.md`](../10-VISION.md) applies with
full force here: this is used mid-set, one-handed, with a clock running. If a
change makes the set row slower, it loses regardless of what else it offers.

---

### F-LOG-001 — Start, finish, and discard a workout
Status: planned | Priority: P0 | Phase: 1
Blocks: F-LOG-002, F-LOG-003, F-LOG-007
Screens: Start sheet, Active Workout
Data: `workouts`

**Intent** — The session container. Everything else hangs off it.

**Behaviour**
1. Start an empty workout, or start from a routine day (`F-ROU-010`, Phase 2).
2. Starting inserts a `workouts` row with `started_at` set and `ended_at` null.
3. **At most one workout may be in progress**, enforced in the database and in
   navigation (`F-NAV-002`). Starting another prompts to finish or discard first.
4. Finishing sets `ended_at`, triggers PR evaluation (`F-LOG-013`), and routes
   to the summary (`F-LOG-018`).
5. Discarding requires explicit confirmation naming what will be lost, and hard
   deletes the workout and its sets.
6. A workout with zero completed sets prompts "discard instead?" on finish.

**Acceptance criteria**
- [ ] Only one in-progress workout can exist, verified at the database level.
- [ ] Discard requires confirmation and removes all associated rows.
- [ ] Finishing an empty workout doesn't create a junk history entry.

**Edge cases** — Starting a workout just before midnight and finishing after
(the session belongs to its `started_at` date for grouping). An in-progress
workout left open for days — prompt to finish or discard on next launch if
`started_at` is more than ~12 hours old.

---

### F-LOG-002 — Add exercises to a session
Status: planned | Priority: P0 | Phase: 1
Depends on: F-LOG-001, F-CAT-001
Screens: Active Workout, Exercise Picker
Data: `workout_exercises`

**Behaviour**
1. Exercise picker opens as a bottom sheet (thumb reach, preserves context).
2. Multi-select: add several exercises in one pass.
3. Added exercises append in selection order, each with one empty set row ready.
4. Search, filter, and recency ordering as per `F-CAT-004`–`F-CAT-006`.

**Acceptance criteria**
- [ ] Adding an exercise takes at most three taps from the active workout.
- [ ] The same exercise can appear twice in one session (legitimate — e.g. a
      movement done again at the end).

---

### F-LOG-003 — Set row entry
Status: planned | Priority: P0 | Phase: 1
Depends on: F-LOG-002, F-CAT-002
Blocks: F-LOG-004, F-LOG-005, F-LOG-006
Screens: Active Workout
Data: `sets`

**Intent** — The most-used widget in the app by an enormous margin. Everything
about it is a performance and ergonomics decision.

**Behaviour**
1. Columns: set number / type indicator · previous (ghost, `F-LOG-004`) ·
   weight · reps · completion toggle. Columns rendered depend on tracking type
   (`F-CAT-002`).
2. Tapping a value opens the numeric keypad sheet (`F-LOG-006`), not the system
   keyboard.
3. The completion toggle writes `is_completed` and `completed_at`, and starts
   the rest timer (`F-TIM-002`).
4. Completing a set with empty fields adopts the ghost values — the common case
   is "same as last time", and it should cost one tap.
5. Add-set appends a row pre-filled from the previous set in the same exercise.
6. Swipe left deletes with undo; long-press opens set-type selection
   (`F-LOG-005`).
7. Every change writes through to the database immediately (`F-LOG-007`).

**Acceptance criteria**
- [ ] Completing a set is one tap when values are unchanged from last time.
- [ ] Row remains legible and operable at 200% text scale (`F-A11Y-002`).
- [ ] All five tracking types render correct inputs.
- [ ] No frame drops scrolling a 12-exercise session on a low-end device.
- [ ] Screen reader announces the row meaningfully (`F-A11Y-001`).

**Edge cases** — Zero-weight sets (bodyweight — valid, not an error). Very large
numbers (a 1000 kg leg press is real). Deleting a set that's mid-edit. Reps
without weight on a `weightReps` exercise — allowed, flagged only in analytics.

---

### F-LOG-004 — "Last time" ghost values
Status: planned | Priority: P0 | Phase: 1
Depends on: F-LOG-003
Blocks: F-PRG-001
Screens: Active Workout
Data: `sets`

**Intent** — The single highest-value UX detail in the app. Progressive overload
means every session is "what I did last time, plus a bit". Showing last time's
numbers inline in each set row removes the need to remember, look up, or guess —
and turns the common case into a single tap. Its absence is what makes paper
logs and spreadsheets tedious.

**Behaviour**
1. For each set row, display the corresponding set from the **most recent
   completed session containing this exercise**, matched by set index.
2. Rendered in the `ghost` semantic colour (`../24-DESIGN-SYSTEM.md`) —
   unmistakably not entered data, but legible in gym lighting.
3. Format: `100 kg × 8`, in the user's display unit.
4. Completing an empty row adopts the ghost values as actual values.
5. If the previous session had fewer sets, later rows show no ghost.
6. Warm-up sets match warm-up sets; working sets match working sets. Never mix
   the two.
7. Once the progression engine exists (`F-PRG-001`), the *target* takes visual
   precedence and the ghost becomes secondary context.

**Acceptance criteria**
- [ ] First-ever session of an exercise shows an empty ghost, not a zero or an error.
- [ ] Ghost respects display-unit settings and updates when they change.
- [ ] Query completes in under 50 ms with several years of history — this runs
      on every exercise open and is the app's hottest path.
- [ ] Deleting the previous session updates ghosts to the one before it.

**Edge cases** — The previous session was aborted mid-exercise (only count
completed sets). Set order changed between sessions. Exercise last done a year
ago (still show it; optionally note the date). Unit changed since — no issue,
storage is canonical.

**Open questions** — Match by set index, or by "best set"? Index is simpler and
matches user expectation; revisit if it proves confusing with varying set counts.

---

### F-LOG-005 — Set types
Status: planned | Priority: P0 | Phase: 1
Depends on: F-LOG-003
Data: `sets.set_type`

**Intent** — Warm-ups must be excluded from analytics or every metric is wrong
(see [`../21-DATA-MODEL.md`](../21-DATA-MODEL.md)). Drop sets and AMRAPs need to
be distinguishable for the same reason. This has to exist in v1 because the
information can't be recovered later.

**Behaviour**
1. Types: `warmup`, `working`, `drop`, `failure`, `amrap`, `backoff`. Default
   `working`. The full enum exists in schema v1 even though Phase 1 only
   surfaces `warmup` and `working` in the UI — adding an enum value later is a
   migration, and mislabelled historical sets cannot be recovered.
2. Set by long-press on the set-number cell; indicated by letter and colour.
3. Warm-up sets are numbered separately (W1, W2) from working sets (1, 2, 3).
4. **Warm-ups are excluded from all analytics** — volume, PRs, e1RM, set counts.
5. Drop, failure, AMRAP, and back-off sets all count toward volume and PRs.

**Acceptance criteria**
- [ ] Changing a set's type updates all derived figures immediately.
- [ ] Warm-ups never appear in any volume or PR calculation.

---

### F-LOG-006 — Numeric keypad and steppers
Status: planned | Priority: P0 | Phase: 1
Depends on: F-LOG-003
Blocks: F-PLT-001

**Intent** — The system keyboard is the wrong tool: small targets, a layout that
shifts, and it covers the set list. A purpose-built keypad is faster and works
with imprecise thumbs.

**Behaviour**
1. Bottom-sheet keypad with large digits, decimal point, and clear.
2. Plus/minus steppers increment by the exercise's configured step
   (`F-SET-007`), defaulting to 2.5 kg / 5 lb for barbells and 2 kg / 5 lb for
   dumbbells. Long-press repeats.
3. Increments are defined in the *display* unit (`../22-UNITS.md`).
4. Next/previous field navigation without closing the sheet.
5. Plate calculator accessible from the keypad once `F-PLT-001` exists.
6. The set list stays visible above the sheet.

**Acceptance criteria**
- [ ] Entering weight and reps for a set requires no system keyboard.
- [ ] Steppers produce exact values with no floating-point drift over hundreds
      of increments.

---

### F-LOG-007 — Crash and kill recovery
Status: planned | Priority: P0 | Phase: 1
Depends on: F-LOG-001

**Intent** — Losing a session in progress is the worst possible failure. Phones
get killed by aggressive battery managers constantly, and gym phones are usually
low on battery.

**Behaviour**
1. Write-through persistence: every set change hits the database immediately.
   In-progress state is never only in memory.
2. On launch, any workout with a null `ended_at` is restored automatically.
3. Recovery restores exercises, sets, and elapsed time. The rest timer does not
   resume (it would be meaningless).
4. No "restore session?" prompt — it just resumes. Prompting invites the wrong
   answer under stress.

**Acceptance criteria**
- [ ] Force-killing the app mid-session loses nothing.
- [ ] Reopening lands directly in the active workout.
- [ ] Verified by an integration test that kills and restarts the app.

---

### F-LOG-008 — Session and exercise notes
Status: planned | Priority: P1 | Phase: 1
Data: `workouts.notes`, `workout_exercises.notes`

**Behaviour**
1. A free-text note on the workout, and one per exercise within the workout.
2. Distinct from the exercise's persistent sticky note (`F-CAT-007`) and from
   per-set notes (`F-LOG-023`).
3. Visible in workout detail and in per-exercise history.

---

### F-LOG-009 — Edit and delete past workouts
Status: planned | Priority: P0 | Phase: 1
Screens: Workout Detail, Edit Past Workout

**Intent** — People forget to log a set, log the wrong weight, or need to enter
a session from memory afterwards. Without this the history can't be trusted, and
untrusted history poisons every analytic built on it.

**Behaviour**
1. Any past workout is fully editable: sets, values, types, exercises, date.
2. Deleting requires confirmation and cascades to its sets.
3. Any edit invalidates and recomputes the PR cache for affected exercises.
4. Workouts can be created retroactively with a chosen date and time.

**Acceptance criteria**
- [ ] Editing a past workout correctly recomputes PRs and analytics.
- [ ] Deleting the workout that held a PR demotes it to the next best.

---

### F-LOG-010 — Modify a session in progress
Status: planned | Priority: P1 | Phase: 2
Depends on: F-LOG-002

**Intent** — Reality rarely matches the plan; the squat rack is taken.

**Behaviour**
1. Add, remove, and reorder exercises mid-session by drag.
2. Swap an exercise, preserving already-logged sets on the original.
3. Removing an exercise with logged sets requires confirmation.

---

### F-LOG-011 — Workout history list
Status: planned | Priority: P0 | Phase: 1
Screens: History

**Behaviour**
1. Reverse-chronological list: date, name, duration, exercise count, total
   volume, PR badges.
2. Grouped by month with sticky headers.
3. Paginated or lazily loaded — must stay smooth at thousands of sessions.
4. Search by exercise name or workout name.

---

### F-LOG-012 — Workout detail
Status: planned | Priority: P0 | Phase: 1
Screens: Workout Detail

**Behaviour**
1. Full session: every exercise, every set, notes, duration, total volume.
2. PRs achieved are marked inline.
3. Actions: edit (`F-LOG-009`), delete, repeat as a new workout (`F-LOG-016`),
   save as a routine (`F-ROU-001`).

---

### F-LOG-013 — PR detection and celebration
Status: planned | Priority: P1 | Phase: 2
Depends on: F-LOG-003
Data: `personal_records`

**Intent** — The main intrinsic reward loop in strength training. Detecting it
at the moment it happens, rather than in a chart three weeks later, is most of
the emotional value of the app.

**Behaviour**
1. On set completion, evaluate against `maxWeight`, `maxRepsAtWeight`,
   `bestE1rm`, `maxSessionVolume` (formulas: [`../40-ANALYTICS-SPEC.md`](../40-ANALYTICS-SPEC.md)).
2. A PR shows an inline badge on the set row plus a brief, non-blocking
   animation. It must never interrupt logging.
3. PRs are listed in the session summary (`F-LOG-018`) and the PR timeline
   (`F-ANA-007`).
4. Warm-up sets can never set a PR.
5. The PR cache is rebuildable from raw sets; a maintenance action exists to do so.

**Acceptance criteria**
- [ ] Detection is correct for each PR kind against fixtures.
- [ ] Celebration never blocks input or steals focus.
- [ ] Deleting a PR set correctly demotes to the next best.

**Edge cases** — First-ever set of an exercise (technically a PR — suppress the
celebration, record it silently). Multiple PR kinds in one set (show the most
significant). Equal-value ties are not PRs.

---

### F-LOG-014 — RPE and RIR
Status: planned | Priority: P1 | Phase: 2
Blocks: F-PRG-005
Data: `sets.rpe`

**Behaviour**
1. Optional RPE per set, 6.0–10.0 in 0.5 steps.
2. A setting toggles between RPE and RIR display; stored canonically as RPE
   (`RIR = 10 − RPE`).
3. Hidden entirely when disabled — most users don't want it, and the set row has
   no room to spare.
4. Feeds autoregulated progression (`F-PRG-005`) and intensity analytics
   (`F-ANA-011`).

---

### F-LOG-015 — Supersets in the logger
Status: planned | Priority: P1 | Phase: 2
Depends on: F-ROU-005

**Behaviour**
1. Superset-grouped exercises render with a shared visual grouping.
2. Completing a set advances to the next exercise in the group.
3. The rest timer runs after the last exercise in the group, not between them,
   unless a within-superset rest is configured.
4. Groups can be created and broken mid-session.

---

### F-LOG-016 — Repeat a previous session
Status: planned | Priority: P1 | Phase: 2

Start a new workout pre-populated from any past one, exercises and targets
carried across but sets empty. Covers people who train without formal routines,
and is the fastest path to a second session of the same thing.

---

### F-LOG-017 — Per-side versus total weight
Status: planned | Priority: P1 | Phase: 2
Data: `exercises.weight_entry_mode`, `sets.weight_grams`

**Intent** — A persistent source of silently corrupt data. "Dumbbell press 30 kg"
means 30 per hand to most people and 60 total to a volume calculation. Getting
this wrong doubles or halves every derived figure.

**Behaviour**
1. `sets.weight_grams` **always stores total load.**
2. Each exercise has an entry mode, `total` or `perSide`, defaulting sensibly
   per equipment type (dumbbells → per side).
3. Per-side entry is converted on input and displayed back in the entry mode.
4. The mode is visible in the set row header so it's never ambiguous.

**Acceptance criteria**
- [ ] Volume for a per-side exercise counts total load.
- [ ] Switching an exercise's mode converts existing history correctly, or
      explicitly refuses and explains why.

**Open questions** — What happens to existing history when the mode changes? A
migration is risky; refusing is safer but annoying. Decide before Phase 2.

---

### F-LOG-018 — Session summary
Status: planned | Priority: P1 | Phase: 1
Depends on: F-LOG-001

Shown on finishing: duration, total volume, sets, PRs achieved, muscle groups
worked, and comparison against the last time this workout was done. One of only
two celebratory moments in the app (`../24-DESIGN-SYSTEM.md`).

---

### F-LOG-019 — Bodyweight-loaded exercises
Status: planned | Priority: P2 | Phase: 4
Depends on: F-BOD-001
Data: `workouts.bodyweight_grams`

**Intent** — Pull-ups and dips are load-bearing exercises whose load is mostly
you. Counting a weighted pull-up as "20 kg" understates it by a factor of five
and makes volume comparisons across a bodyweight change meaningless.

**Behaviour**
1. Exercises flagged as bodyweight-loaded compute effective load as
   bodyweight + added weight.
2. Bodyweight comes from the nearest measurement to the session date
   (`F-BOD-001`), falling back to the most recent.
3. A per-exercise bodyweight coefficient handles partial loading (a push-up is
   roughly 0.64 of bodyweight).
4. Analytics use effective load; the set row displays added weight.

**Open questions** — Coefficients per exercise are approximations. Ship a default
table and let users override, or omit the concept and treat everything as full
bodyweight? Decide with real data.

---

### F-LOG-020 — Warm-up set generator
Status: planned | Priority: P2 | Phase: 4
Depends on: F-PLT-001, F-LOG-005

Generate a warm-up ramp from the working weight (e.g. bar × 8, 40% × 5, 60% × 3,
80% × 1), rounded to available plates, inserted as `warmup` sets in one tap. The
ruleset is user-editable and per-exercise.

---

### F-LOG-021 — Live session metrics
Status: idea | Priority: P2 | Phase: —

Running elapsed time, total volume, and set count in the active-workout header.
Cheap, and useful for pacing. Must not cost a frame.

---

### F-LOG-022 — Undo and mis-tap protection
Status: planned | Priority: P1 | Phase: 2

**Intent** — Fat-fingering a completion toggle or deleting the wrong set
mid-session is common with imprecise, sweaty taps.

**Behaviour**
1. Set deletion offers undo via a snackbar for several seconds.
2. Discarding a workout requires typed or held confirmation, not a single tap.
3. Undo covers the last destructive action within the session.
4. Undo is a `deleted_at` field update, not a re-insert — nothing is ever hard
   deleted ([ADR-0008](../70-decisions/ADR-0008-sync-ready-foundations.md)), so
   restoring is trivially correct and preserves the original ID and timestamps.

---

### F-LOG-023 — Per-set notes
Status: planned | Priority: P1 | Phase: 1
Depends on: F-LOG-003
Data: `sets.notes`

**Intent** — The catch-all for everything the schema didn't anticipate. "Left
shoulder twinged", "belt too loose", "spotter took some of it", "bar slipped".
This is unrecoverable data: the observation exists for about ten seconds after
the set and then it's gone. A nullable text column costs nothing and captures
what no structured field ever will.

**Behaviour**
1. Optional free-text note per set, distinct from workout and per-exercise notes
   (`F-LOG-008`) and from the exercise's persistent sticky note (`F-CAT-007`).
2. Entry must be genuinely incidental — an icon on the set row that opens a
   small sheet, never a field competing for space in the row itself. The set row
   is the most contested space in the app (`F-LOG-003`).
3. A set carrying a note shows a subtle marker so it's findable later.
4. Notes are visible in workout detail (`F-LOG-012`) and in per-exercise history
   (`F-ANA-002`), and are searchable there.
5. Included in export (`F-DAT-001`, `F-DAT-002`).

**Acceptance criteria**
- [ ] Adding a note never displaces or shrinks the weight, reps, or completion
      controls.
- [ ] Notes survive an export/import round-trip.
- [ ] A set with a note is visually distinguishable without opening it.

**Edge cases** — A very long note (truncate in list views, never in storage).
Notes on a set that is later deleted — tombstoned with the set, restored by undo.
