# F-ANA-001 — Analytics engine

Status: planned | Priority: P0 | Phase: 3
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
- [ ] `domain/` has zero Flutter imports, enforced by a lint rule in CI.
- [ ] Every metric in the spec has a passing fixture test.
- [ ] Computing a year of history stays under 100 ms on a mid-range device.

---

## Why

All metrics computed by pure Dart functions over entity lists, with
no Flutter or database dependency. This is the load-bearing decision that makes
the numbers trustworthy: every function is testable against a hand-worked
fixture, and a wrong figure is a failing test rather than a chart nobody
double-checks.
