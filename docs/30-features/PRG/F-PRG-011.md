# F-PRG-011 — Deload suggestion

Status: done | Priority: P2 | Phase: 4
Depends on: F-ANA-009, F-ANA-010
Reads: 40-ANALYTICS-SPEC, 22-UNITS

## Spec

Suggest a deload week when stall detection and workload ratio both indicate it.
A suggestion with reasoning, never an automatic change to the program.

## Status note (batch 4.5)

`domain/progression/deload_suggestion.dart`'s `suggestDeload` is a pure
composition of `F-ANA-009`'s `StallVerdict` and `F-ANA-010`'s `AcwrResult`
— `suggested` is true only when *both* signals fire, each with its own
plain-English reason. Surfaced inside `ExerciseDetailScreen`'s stall
banner, never as a standalone automatic change — the routine's
progression rule is untouched either way.
