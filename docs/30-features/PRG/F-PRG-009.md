# F-PRG-009 — Failure and deload handling

Status: done | Priority: P1 | Phase: 4
Depends on: F-PRG-002
Reads: 40-ANALYTICS-SPEC, 22-UNITS

## Spec

Detect repeated failure and apply the rule's deload. Explicitly surfaced rather
than silent — the user must know a deload happened and why, or the app looks
broken.

## Status note

The failure streak is derived, not stored: `computeTargets` walks the
exercise's real history backward counting a trailing run of failures at the
current weight, rather than persisting an incrementally-updated counter —
same recompute-from-raw-data reasoning `PersonalRecordRepository.rebuildAll`
already uses. `ProgressionOutcome.deload` is a distinct outcome from
`.failure` precisely so it is never silent: `progressionRationaleText`
(`F-PRG-008`) renders it as "Missed target 3 sessions in a row — deloading
to 90 kg," not the same "repeating the same weight" text a plain failure
gets.
