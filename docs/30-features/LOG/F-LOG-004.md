# F-LOG-004 — "Last time" ghost values

Status: planned | Priority: P0 | Phase: 1
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
- [ ] First-ever session of an exercise shows an empty ghost, not a zero or an error.
- [ ] Ghost respects display-unit settings and updates when they change.
- [ ] Query completes in under 50 ms with several years of history — this runs
      on every exercise open and is the app's hottest path.
- [ ] Deleting the previous session updates ghosts to the one before it.

## Edge cases

The previous session was aborted mid-exercise (only count
completed sets). Set order changed between sessions. Exercise last done a year
ago (still show it; optionally note the date). Unit changed since — no issue,
storage is canonical.

## Open questions

Match by set index, or by "best set"? Index is simpler and
matches user expectation; revisit if it proves confusing with varying set counts.

---

## Why

The single highest-value UX detail in the app. Progressive overload
means every session is "what I did last time, plus a bit". Showing last time's
numbers inline in each set row removes the need to remember, look up, or guess —
and turns the common case into a single tap. Its absence is what makes paper
logs and spreadsheets tedious.
