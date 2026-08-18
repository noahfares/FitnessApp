# F-ANA-001 — Analytics engine

Status: done | Priority: P0 | Phase: 3
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

## Status — closed (v0.56.0)

The umbrella closes because every metric it covers now exists with a
fixture-backed test: e1RM and its three formulas, personal records, volume load,
sets per muscle, consistency, muscle balance, ACWR, stall detection, intensity
distribution, weekly insights, duration compliance, bodyweight EMA, muscle heat,
and the plate maths §13 added. `test/domain/analytics/` is nineteen files
against `docs/40-ANALYTICS-SPEC.md`'s worked examples.

Two acceptance criteria resolved rather than left dangling:

- **Zero Flutter imports in `domain/`** — enforced by `tools/check-layers.sh`
  in CI, and it has never been allowed to break.
- **"Under 100 ms on a mid-range device"** — **waived**, with the same
  reasoning Phase 3's audit gave: a literal wall-clock number needs an
  AOT-compiled release build on real hardware, and `flutter test`'s JIT tier
  measures roughly 3× over budget for reasons that are entirely about the
  tier. `recompute_performance_test.dart` proves the property that actually
  matters and can be checked here — recomputation is linear in history size,
  not quadratic — and the literal number goes on the same on-device list as
  `F-TIM-003`'s battery-manager criterion.

§4's memoisation is `.family` providers keyed by id and range, as specified;
nothing recomputes per frame.
