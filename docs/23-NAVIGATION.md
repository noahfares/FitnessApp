# Navigation & screens

Routing with `go_router`. Features: `F-NAV-001`–`F-NAV-008` in
[`30-features/shell.md`](30-features/shell.md).

## Shell

A five-tab bottom navigation bar with a persistent, stateful nested navigator
per tab, so switching tabs never loses scroll position or a half-filled form.

| Tab | Icon | Root screen | Purpose |
|---|---|---|---|
| Home | house | Dashboard | Today's plan, resume/start, streak, recent PRs |
| Routines | list | Routine list | Programs and templates |
| **Start** | + (centre, emphasised) | Start-workout sheet | The primary action, deliberately unmissable |
| History | calendar | Workout history | Past sessions, calendar heatmap |
| Insights | chart | Analytics home | Trends, charts, insight cards |

Settings and body metrics are reached from Home rather than owning a tab; they
are low-frequency and would dilute the five slots.

**Reachability matters more than convention here.** The app is used one-handed,
standing, mid-set. Primary actions live in the bottom half of the screen. Set
completion, weight/rep entry, and the rest timer must all be operable with a
thumb without shifting grip. Anything that puts a primary action in a top app
bar is wrong.

### Active-workout banner (`F-NAV-003`)

While a workout is in progress, a persistent banner sits directly above the
bottom navigation on every screen: exercise count, elapsed time, tap to return.
Non-dismissible. It exists because it is trivially easy to navigate away
mid-session to check history, and unacceptable to then have to hunt for the
session you're in.

## Route map (`F-NAV-002`)

```
/                                     Dashboard
/routines                             Routine list
  /routines/new                       Routine editor (create)
  /routines/:routineId                Routine detail
  /routines/:routineId/edit           Routine editor
  /routines/:routineId/days/:dayId    Day editor
/start                                Start-workout sheet (modal)
/workout/active                       Active workout          ← singleton
  /workout/active/exercise/:weId      Exercise detail within session
  /workout/active/summary             Finish summary
/history                              Workout history list
  /history/:workoutId                 Workout detail
  /history/:workoutId/edit            Edit past workout
/exercises                            Exercise catalogue
  /exercises/new                      Custom exercise editor
  /exercises/:exerciseId              Exercise detail: history, charts, notes, PRs
  /exercises/:exerciseId/edit         Exercise editor
/insights                             Analytics home
  /insights/exercise/:exerciseId      Per-exercise analytics
  /insights/volume                    Volume & sets-per-muscle
  /insights/consistency               Streaks & calendar
  /insights/records                   PR timeline
/body                                 Body metrics
  /body/measurements/:type            Measurement history & chart
/settings                             Settings root
  /settings/units                     Units
  /settings/appearance                Theme
  /settings/timers                    Rest-timer defaults
  /settings/plates                    Bar & plate inventory
  /settings/data                      Export, import, backup
  /settings/about                     Version, licences, source link
```

Deep links matter beyond convenience: home-screen widgets (`F-NAV-007`), app
shortcuts (`F-NAV-008`), and rest-timer notification taps (`F-TIM-004`) all
route by URI.

### Active workout is a singleton

At most one workout may be in progress — enforced in the database (at most one
`workouts` row with a null `ended_at`) and in navigation. `/workout/active`
resolves the in-progress session or redirects to `/start`. Starting a workout
while one is live prompts to finish or discard the existing one first.

## Screen inventory

The 24 screens above, grouped by build phase:

| Phase | Screens |
|---|---|
| 0 | App shell, a placeholder Home, Settings root, Appearance, Units |
| 1 | Dashboard, Start sheet, Active workout, Exercise-picker sheet, Exercise catalogue, Exercise detail, Custom exercise editor, History list, Workout detail, Finish summary, About |
| 2 | Routine list, Routine detail, Routine editor, Day editor, Edit-past-workout |
| 3 | Insights home, Per-exercise analytics, Volume, Consistency, PR timeline |
| 4 | Plate settings, Body metrics, Measurement detail |
| 5 | Data settings (export/import/backup) |

## State management patterns

Riverpod throughout. Four kinds of provider, and each has a right use:

| Kind | Use for | Example |
|---|---|---|
| `StreamProvider` | Anything backed by the database | `activeWorkoutProvider`, `workoutHistoryProvider` |
| `FutureProvider` | One-shot async reads | `exerciseSeedStatusProvider` |
| `NotifierProvider` | Ephemeral UI state | set-row draft input, filter selections |
| `Provider` | Pure derived values | analytics computed from a stream's output |

Rules:

1. **Screens never hold data state.** Persistent state lives in the database and
   flows through a `StreamProvider`. Widget state is limited to genuinely
   ephemeral things — text controllers, expansion, animation.
2. **Providers depend on repositories, never on Drift types.** Keeps
   `features/` testable by overriding one provider.
3. **Analytics providers are keyed and memoised**, `.family` on
   `(exerciseId, dateRange)`. Recomputing an e1RM trend on every rebuild is the
   obvious performance mistake here.
4. **The active workout is one provider**, watched by every part of the logger.
   No duplicated session state, no synchronisation problem.

## Navigation invariants

- Back from the active workout **never** discards it — it navigates away and
  leaves it running, with the banner visible. Discarding is explicit only.
- Finishing a workout replaces the route stack with the summary; back from the
  summary goes Home, not back into the finished session.
- Modal sheets are used for pickers and quick entry (exercise picker, plate
  calculator, weight/rep keypad) rather than full pages; they preserve the
  context behind them and land the interaction in the thumb zone.
- Every destructive action (discard workout, delete exercise with history, wipe
  data) requires explicit confirmation naming what is being lost.
