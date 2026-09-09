# F-LOG-024 — Live rolling volume in the set row

Status: done | Priority: P2 | Phase: 6
Depends on: F-LOG-003 | Reads: 21-DATA-MODEL#sets, 24-DESIGN-SYSTEM#motion, 40-ANALYTICS-SPEC#2-volume-load

## Spec

1. A sixth, always-visible column on the set row: live volume load
   (weight × reps) in the user's display unit, updating on every edit to
   weight or reps — no need to complete the set first.
2. Excluded exactly where `totalVolumeGrams` excludes: warm-up sets, and
   tracking types other than `weightReps`/`weightTime` (`bodyweightReps` has
   both fields but is not volume-eligible). Shown as `—`, never as `0`, same
   reasoning as the ghost cell.
3. Read-only — it has nothing to write, since it is derived from the other
   two fields rather than logged directly.
4. On a value change, the cell rolls from its old number to its new one
   digit by digit, odometer-style: each place value animates independently
   but all land at the same instant. A digit the two numbers don't share
   (`99 → 100`) fades in or out instead of rolling through digits that were
   never really "between" the two values.
5. Reduce motion drops the roll entirely — the new number simply appears
   (`core/a11y/motion.dart`).

## Acceptance

- [x] Editing weight or reps on a volume-eligible set updates the cell
      immediately, without completing the set.
- [x] Warm-ups and non-eligible tracking types show `—`.
- [x] All digits of a multi-digit roll finish at the same time.
- [x] A digit-count change (`99 → 100`) doesn't show a nonsense mid-roll
      digit in the new place.
- [x] No roll under reduce motion; the value still updates.
- [x] Screen reader announces the volume alongside the other fields.

## Edge cases

Both fields empty (`—`, not `0 kg`). A value that shrinks a place
(`100 → 99`, the highest column fades out rather than rolling backward
through nine). Negative volume is impossible by construction (weight and
reps are both non-negative), so `RollingNumber`'s own minus-sign handling is
exercised only by its unit tests, not by anything this cell can produce.

## Implementation

- `lib/core/widgets/rolling_number.dart` — the reusable odometer widget.
  Generic over any `int`, not set-row-specific, in case a later screen wants
  the same effect (none does yet — no early abstraction beyond what this
  widget itself needs).
- `lib/domain/history/workout_volume.dart#setVolumeGrams` — the single-set
  counterpart to `totalVolumeGrams`, sharing its exclusion rules
  (`isVolumeEligible`) so this cell can never disagree with the aggregate
  totals it feeds into.
- `lib/features/logging/presentation/set_row.dart` — `_VolumeCell`, wired in
  as a new fixed-width column (`AppSpacing.setVolumeColumn`) in both the
  normal and large-text-scale row layouts.
- `QuantityFormatter.volumeWholeUnits` — the numeric twin of `volume()`'s
  `maxDecimals: 0`, returning an `int` so the roller can animate digit by
  digit instead of diffing formatted strings.

---

## Why

Requested directly: seeing volume update live, with a rolling-digit
animation, as weight and reps are typed. It's a deliberate, narrow exception
to `24-DESIGN-SYSTEM.md`'s "mid-set, animation is latency" rule, which
otherwise reserves motion for exactly two celebratory moments — kept inside
that doc's own 150–250 ms sparing budget and dropped entirely under reduce
motion, rather than treated as license for animation elsewhere in the row.
