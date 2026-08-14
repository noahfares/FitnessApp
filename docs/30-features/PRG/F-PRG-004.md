# F-PRG-004 — Percentage / training-max based

Status: done | Priority: P2 | Phase: 4
Depends on: F-PRG-010
Reads: 40-ANALYTICS-SPEC, 22-UNITS

## Spec

Targets computed as percentages of a training max, as used by 5/3/1 and GZCLP.
Requires training-max management (`F-PRG-010`) and, for full fidelity, week/cycle
structure (`F-ROU-013`).

## Status note (batch 4.2, second pass)

Built as a flat percentage, deliberately not full fidelity — `F-ROU-013`
(week/cycle structure) still isn't scheduled, so there is no multi-week
wave the way 5/3/1's own percentage schedule needs. `PercentageProgressionRule`
(`domain/progression/progression_rule.dart`) stores one `percent`;
`computeTargets` (`domain/progression/progression_engine.dart`) resolves it
against the exercise's own `trainingMaxGrams` (`F-PRG-010`) every time a
routine day using it is started — `nextWeight = round(trainingMax ×
percent)` — and, unlike every other rule in the engine, ignores logged
history entirely: the training max is what's supposed to move, and only by
hand or by re-deriving from e1RM, never by session performance. No
training max configured → falls back to the routine's static target
unchanged, the same shape every other rule's first-run case already uses.
Reached from a fifth "% of TM" segment on the day editor's target sheet.
Not built: the week/cycle wave itself — this is the "flat percentage"
half of the spec's own two-part requirement, ready for `F-ROU-013` to build
on rather than requiring it up front.
