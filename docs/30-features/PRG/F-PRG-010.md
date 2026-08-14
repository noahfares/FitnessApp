# F-PRG-010 — Training max management

Status: done | Priority: P2 | Phase: 4
Blocks: F-PRG-004
Reads: 40-ANALYTICS-SPEC, 22-UNITS

## Spec

Per-exercise training max, set manually or derived from e1RM (typically ~90%),
with prompts to increase it at cycle boundaries. The anchor for all
percentage-based programming.

## Status note (batch 4.2, second pass)

`exercises.training_max_grams` (schema v6, nullable, null on every existing
row) plus `domain/progression/training_max.dart`'s `deriveTrainingMaxGrams`
(floor, not round, of `bestE1rm × 0.9` — a training max is meant to err
light). `PersonalRecordRepository.bestE1rmGrams` reads the cached
`bestE1rm` record (`F-LOG-013`) a "Derive from e1RM" button on the exercise
editor uses to fill the field; the user still confirms with Save, the same
as every other field there. Not built: automated prompts to increase the
training max at cycle boundaries — there is no cycle concept yet
(`F-ROU-013`, not scheduled), so the max only ever moves by hand or by a
fresh derive pull. `F-PRG-004` is the first and, for now, only consumer.
