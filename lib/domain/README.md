# `lib/domain/` — pure Dart only

**This directory imports nothing from Flutter and nothing from `lib/data/`.**

Everything that can be *silently wrong* lives here: estimated 1RM, volume load,
sets per muscle group, progression targets, unit conversion, plate solving. Plain
functions over plain data — no widgets, no database types, no `BuildContext`, no
I/O, no clock. The current date arrives as a parameter, or the tests fail at
midnight.

A wrong number in a chart is worse than a missing chart, because you would act on
it. Keeping this layer pure is what makes every calculation exhaustively testable
against the worked fixtures in [`../../docs/40-ANALYTICS-SPEC.md`](../../docs/40-ANALYTICS-SPEC.md)
(machine-readable in [`../../docs/fixtures/analytics.json`](../../docs/fixtures/analytics.json)).

The rule is enforced by `tools/check-layers.sh`, which runs in CI (`F-REL-001`)
and fails the build. It is not a matter of good intentions.

See [`../../docs/20-ARCHITECTURE.md`](../../docs/20-ARCHITECTURE.md).

## Contents

Empty so far. Arriving in Phase 0: the `Mass`/`Length`/`Distance` value objects
(batch 0.2, `F-SET-001` — though those live in `lib/core/units/`, the analytics
that consume them land here). First real occupants are the analytics functions
in Phase 3 (`F-ANA-001`) and the progression engine in Phase 4 (`F-PRG-001`).
