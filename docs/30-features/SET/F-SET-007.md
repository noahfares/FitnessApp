# F-SET-007 — Increment steps

Status: done | Priority: P1 | Phase: 2
Depends on: F-SET-001
Reads: 22-UNITS

## Spec

Default weight increments per equipment type, overridable per exercise. Defined
in the display unit — 2.5 kg or 5 lb — converted once to canonical. Drives the
steppers (`F-LOG-006`) and linear progression (`F-PRG-002`).

## Status notes

The per-equipment default (`domain/logging/weight_steps.dart`'s
`defaultStep`) and the full read path for a per-exercise override
(`exercises.increment_grams` threaded through `SetRow`, `NumericKeypadSheet`
and `IncrementStepper`) predate this batch, built ahead of time in
`F-LOG-006`. The one missing piece was a way to actually set that override:
the exercise editor now has a "Stepper increment" field, in the display load
unit, showing the computed default as its helper text ("Blank uses the
default, 2.5 kg") so leaving it blank is visibly a choice rather than an
oversight. Parsed via the same `QuantityParser` every other numeric field
uses; blank or unparseable falls through to `Value(null)` — the equipment
default — never to zero.
