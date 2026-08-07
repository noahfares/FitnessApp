# F-LOG-017 — Per-side versus total weight

Status: done | Priority: P1 | Phase: 2
Reads: 22-UNITS, 21-DATA-MODEL#sets
Data: `exercises.weight_entry_mode`, `sets.weight_grams`

## Spec
1. `sets.weight_grams` **always stores total load.**
2. Each exercise has an entry mode, `total` or `perSide`, defaulting sensibly
   per equipment type (dumbbells → per side).
3. Per-side entry is converted on input and displayed back in the entry mode.
4. The mode is visible in the set row header so it's never ambiguous.

## Acceptance
- [x] Volume for a per-side exercise counts total load.
- [x] Switching an exercise's mode converts existing history correctly, or
      explicitly refuses and explains why.

---

## Why

A persistent source of silently corrupt data. "Dumbbell press 30 kg"
means 30 per hand to most people and 60 total to a volume calculation. Getting
this wrong doubles or halves every derived figure.

## Status

**Open questions, resolved:** §1 already answers it — because storage is
always total regardless of entry mode, switching an exercise's mode is purely
a *display* decision. Nothing is migrated, and nothing needs to be refused;
every set logged under the old mode still has the one number it always had,
and simply gets shown in the new mode from then on. The dilemma the open
question posed does not apply to either of its branches.

`WeightEntryMode` (`exercises.weight_entry_mode`) has existed since schema v3;
this batch is the first to read or write it anywhere but the column default.
`defaultWeightEntryModeFor` (dumbbell → `perSide`, everything else → `total`)
is applied by `ExerciseSeeder` on **insert only** and by
`ExerciseRepository.createCustom` — re-seeding never touches an existing row's
mode, the same "user edits always win" rule that already governs every other
user-owned field (`F-CAT-001`). This means an **existing** catalogue's
dumbbell exercises keep `total` (the column default) until edited by hand in
`ExerciseEditorScreen`; only a fresh install or a newly added exercise gets
the per-equipment default automatically.

Display conversion (§3) halves stored total grams with `Mass * 0.5`, which
rounds rather than truncates (docs/22-UNITS.md §rounding) — truncation would
bias every per-side display down and, worse, compound across repeated edits
of an odd-gram total. Editing writes what was typed doubled back to a total,
via `NumericKeypadSheet`'s existing "buffer is the display domain, `_write`
converts to storage" shape — the same shape already used for kg/lb, extended
rather than duplicated.

One real behaviour change, not a bug: the dumbbell stepper default (`Mass.kg(2)`
in `weight_steps.dart`, unchanged) now applies **in the per-side domain**
wherever `perSide` is true, since the keypad's buffer is per-side there. A
dumbbell exercise switched to `perSide` therefore steps its *total* by 4 kg
per tap, not 2 kg — arguably the more sensible reading of "the next size of
dumbbell", but a change in effect versus every dumbbell exercise's behaviour
before this batch (`F-LOG-006` §2).

Threaded through everywhere a set's weight is read or written: the active
workout's set rows, ghosts and column header (`SetRow`, `_ColumnHeaders`),
the numeric keypad, and the read-only history screens
(`HistorySetRow`/`edit_past_workout_screen.dart`,
`workout_detail_screen.dart`) — all of it reads the same total-grams column,
so all of it must show it in the same domain or two screens showing the same
set would disagree about what it was. The one place left showing total
regardless of entry mode is `_targetSummary`'s target weight, which now also
halves via the same `Mass * 0.5` when the exercise is per-side, for the same
reason — a routine's target and the set rows below it must read as the same
kind of number.

Not built: RPE display (`F-LOG-014`) is not shown on the read-only history
screens, only in the active logger — a set's RPE not being visible after the
session ends is a real gap, left for whichever analytics or history feature
next needs to read `sets.rpe`.
