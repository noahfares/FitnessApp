# F-LOG-004 — "Last time" ghost values

Status: done | Priority: P0 | Phase: 1
Depends on: F-LOG-003 | Blocks: F-PRG-001
Reads: 21-DATA-MODEL#sets, 24-DESIGN-SYSTEM#colour, 22-UNITS, 60-ENGINEERING#performance-budgets
Screens: Active Workout | Data: `sets`

## Spec
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

## Acceptance
- [x] First-ever session of an exercise shows an empty ghost, not a zero or an error.
- [x] Ghost respects display-unit settings and updates when they change — 100 kg
      reads `220.5 lb × 8` in pound mode, and nothing is written back.
- [x] Query completes in under 50 ms with several years of history. Asserted
      against 600 sessions and 12,000 sets, which is three years of training
      four times a week.
- [x] Deleting the previous session updates ghosts to the one before it — the
      query is a stream over `sets`, `workout_exercises` and `workouts`, so
      nothing has to remember to invalidate it.

## Edge cases

The previous session was aborted mid-exercise (only count
completed sets). Set order changed between sessions. Exercise last done a year
ago (still show it; optionally note the date). Unit changed since — no issue,
storage is canonical.

## Open questions

Match by set index, or by "best set"? **Resolved for now as index**
(`matchGhostIndices`): "best set" makes the ghost move between sessions, and
the number people chase is what they did in that slot last time. Revisit if it
proves confusing with varying set counts — the pairing is one pure function, so
changing it is a local edit.

## Implementation

- `SetRepository.watchGhostSetsFor` — one query, riding
  `idx_workout_exercises_exercise` and `idx_sets_workout_exercise`. In-progress
  sessions are excluded by `ended_at IS NOT NULL`, which excludes *today's*
  session without needing to know its id.
- Only completed sets come back, so a session abandoned mid-exercise
  contributes what was actually done and nothing else.
- The result is de-duplicated (`distinct`): the query re-runs on every write to
  `sets`, which during a session means every completion, and the answer is
  almost always identical. Without it, ticking one set rebuilds the ghost of
  every exercise on screen.
- The pairing rule is pure and separately tested (`matchGhostIndices`) — it is
  the part that is easy to get quietly wrong.
- §7 (the progression target taking precedence) waits for `F-PRG-001`.

---

## Why

The single highest-value UX detail in the app. Progressive overload
means every session is "what I did last time, plus a bit". Showing last time's
numbers inline in each set row removes the need to remember, look up, or guess —
and turns the common case into a single tap. Its absence is what makes paper
logs and spreadsheets tedious.
