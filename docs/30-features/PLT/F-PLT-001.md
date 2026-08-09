# F-PLT-001 — Plate calculator

Status: in-progress | Priority: P1 | Phase: 4
Depends on: F-PLT-002 | Blocks: F-PRG-012, F-LOG-020
Reads: 22-UNITS, 21-DATA-MODEL#bars-and-plates
Screens: Active Workout (sheet), Numeric Keypad

## Spec
1. Given a target load, a bar, and a plate inventory, produce the per-side
   plate loading.
2. Greedy heaviest-first solve, constrained by the number of pairs actually
   available.
3. When the target is unassemblable, show the closest achievable load above and
   below, and by how much each misses.
4. Accessible in one tap from any weight field.
5. Handles non-barbell cases: fixed dumbbells, machine stacks (`F-PLT-005`).

## Acceptance
- [ ] Correct for kilogram and pound inventories, and for mixed ones.
- [ ] Never proposes plates the user doesn't have.
- [ ] Target below bar weight is reported clearly, not as an empty result.
- [ ] Odd loads that cannot be split evenly per side are rejected with an
      explanation.

## Edge cases

Target equals bar weight (valid, no plates). Target below bar
weight. Inventory with no small plates, so the minimum jump is large. Bar not
loaded symmetrically — out of scope, symmetric loading is assumed.

---

## Status note (batch 4.3)

§1–§4 done: `domain/plates/plate_calculator.dart`'s `solvePlateLoad`
(greedy heaviest-first, closest-below/above on a miss, fixture-tested
against `docs/40-ANALYTICS-SPEC.md` §13), and `PlateCalculatorSheet`,
reached with one tap from the weight field on the numeric keypad for any
barbell exercise. §5 (fixed dumbbells, machine stacks) stays unbuilt —
it depends on `F-PLT-005`, not attempted this batch — so this feature
stays `in-progress` rather than `done`.

## Why

Nobody wants to do `(102.5 − 20) ÷ 2` mentally between sets. Every
serious lifter has done this arithmetic wrong at least once.
