# F-ANA-001 — Analytics engine

Status: in-progress | Priority: P0 | Phase: 3
Blocks: F-ANA-002 … F-ANA-014
Reads: 40-ANALYTICS-SPEC, 20-ARCHITECTURE#the-one-hard-rule

## Spec
1. Functions live in `lib/domain/analytics/`, take plain entity lists, return
   plain results.
2. Every function has a unit test using the fixture from
   [`../40-ANALYTICS-SPEC.md`](../../40-ANALYTICS-SPEC.md).
3. Warm-up and incomplete sets are filtered at the boundary, once, so no
   individual metric can forget to.
4. Results are memoised in `.family` providers keyed by inputs and date range.

## Acceptance
- [x] `domain/` has zero Flutter imports, enforced by a lint rule in CI
      (`tools/verify.sh`'s `layers` check, pre-existing since Phase 0).
- [ ] Every metric in the spec has a passing fixture test. e1RM (§1) and
      personal records (§4) landed in batch 2.6; per-exercise history (§1/§2
      composition) in batch 3.1; the e1RM trend (§1, all three formulas) and
      its regression overlay (shares §7's slope maths) in batch 3.2. Volume
      load (§2 standalone), sets-per-muscle (§3), consistency (§5), and
      muscle balance (§9) remain, scheduled across batches 3.3–3.4.
- [ ] Computing a year of history stays under 100 ms on a mid-range device —
      not yet measured; revisit once more of the spec's metrics exist to
      benchmark together.

## Status notes (batch 3.1)

The shared boundary filter (§3) is `domain/analytics/analytics_boundary.dart`'s
`isCountedSet()` — one function, reused by `domain/history/workout_volume.dart`
(refactored in place, behaviour unchanged) and by the new
`domain/analytics/exercise_history.dart`. Deliberately **not** retrofitted
into `domain/analytics/personal_records.dart`, whose own filtering
responsibility is documented on its caller (`PersonalRecordRepository`) rather
than inline — rewriting an already-shipped, fixture-tested Phase 2 feature's
filtering seam was out of scope for landing the first Phase 3 batch. §4
("memoised in `.family` providers keyed by inputs and date range") is
partially met: `exerciseHistoryProvider` is a `StreamProvider.family` keyed by
exercise id, but there is no date range yet to key on — that arrives with
`F-ANA-015` (batch 3.2).

## Status notes (batch 3.2)

§4's date range now exists (`F-ANA-015`'s `resolveRange`/`DateRange`), and
`ExerciseDetailScreen`'s trend section resolves it against a newly-added
`analyticsClockProvider` rather than a direct `DateTime.now()` call — the
same testable-clock seam `restClockProvider` already used, needed the moment
a chart's default range depends on "now" and a test wants to pin it. Still
`in-progress`: acceptance items 2 and 3 above remain open until the
sets-per-muscle, consistency and muscle-balance fixtures land.

---

## Why

All metrics computed by pure Dart functions over entity lists, with
no Flutter or database dependency. This is the load-bearing decision that makes
the numbers trustworthy: every function is testable against a hand-worked
fixture, and a wrong figure is a failing test rather than a chart nobody
double-checks.
