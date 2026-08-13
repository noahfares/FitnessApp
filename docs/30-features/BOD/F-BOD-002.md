# F-BOD-002 — Circumference measurements

Status: done | Priority: P2 | Phase: 4
Reads: 21-DATA-MODEL#body_measurements, 22-UNITS
Data: `body_measurements`

## Spec

Waist, chest, hips, neck, arms, thighs, calves, shoulders, plus body-fat
percentage. Left and right tracked separately for limbs, since asymmetry is
worth seeing. Stored in millimetres, displayed in centimetres or inches
(`F-SET-001`). Users choose which measurements to track — showing all thirteen
by default is clutter.

## Status note (batch 4.4)

No schema change — every `MeasurementType` value and `body_measurements`
itself have existed since schema v1/v3; this batch is the first to read or
write any type but `bodyweight`. `BodyMeasurementRepository` gained generic
`watchHistory`/`watchLatest`/`logMeasurement`/`updateMeasurement`/
`deleteMeasurement`, deliberately separate from the bodyweight-specific
methods `F-BOD-001` already shipped — only bodyweight triggers the
workout-bodyweight recompute, and folding every type through that path would
run it needlessly for a waist measurement. `trackedMeasurementTypesProvider`
(`SharedPreferences`, same shape as `weekStartProvider`) persists which of
the twelve non-bodyweight types someone has opted into, empty by default per
this feature's own spec. The body screen (formerly bodyweight-only) gained a
"Measurements to track" sheet from its app bar and a section per tracked
type, each with its own latest-first history and a `LogMeasurementSheet`
that dispatches on shape: `Length` (millimetres, cm/in display) for the
eleven circumferences, or a bare percentage (basis points) for
`bodyFatPercent` — the same "one screen, dispatch on shape" reasoning
`F-PLT-005`'s weight-source fields used a batch earlier.
