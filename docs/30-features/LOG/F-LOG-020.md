# F-LOG-020 — Warm-up set generator

Status: done | Priority: P2 | Phase: 4
Depends on: F-PLT-001, F-LOG-005
Reads: 21-DATA-MODEL#sets, 24-DESIGN-SYSTEM#component-inventory

## Spec

Generate a warm-up ramp from the working weight (e.g. bar × 8, 40% × 5, 60% × 3,
80% × 1), rounded to available plates, inserted as `warmup` sets in one tap. The
ruleset is user-editable and per-exercise.

## Status note (batch 4.6)

`domain/logging/warmup_generator.dart`'s `generateWarmupSets` is the pure
ramp math — each step's raw target rounds through the caller's own
weight-source-aware function, then clamps to `[minWeightGrams,
workingWeightGrams]`, so a step never proposes lighter than what's actually
loadable or heavier than the set it's building up to. Schema v5 adds
`exercises.warmup_ruleset` (nullable JSON, null = the default ramp);
`SetRepository.insertWarmupSets` shifts whatever is already logged for the
exercise to make room and inserts the generated `warmup`-type sets ahead of
it, in one transaction. `WarmupGeneratorSheet`, reached from a
"Generate warm-ups" item on the active workout screen's per-exercise menu,
resolves plate/fixed-increment/stack rounding the same dispatch
`PlateCalculatorSheet` already does (`F-PLT-005`), and saves the edited
ruleset back to the exercise on generate — the "per-exercise" half of the
spec, without a separate settings screen. Found and fixed along the way:
`PlateRepository.getBars`/`getPlates` (`F-PLT-002`) read through
`watchBars().first`/`watchPlates().first` — a stream-based one-shot read
that needs more real asynchronous hops than a widget test's
`pumpAndSettle` reliably drives forward, which this feature's own widget
test caught as the sheet never closing. Both now do a plain one-shot query
instead, faster and more correct for what was always meant to be a single
read.
