# Plate mathematics — `PLT`

Small, self-contained, and disproportionately loved. Also load-bearing for the
progression engine: `F-PRG-012` cannot propose sane targets without knowing what
loads are physically assemblable.

All solving happens in canonical grams ([`../22-UNITS.md`](../22-UNITS.md)), so a
pound-denominated target on a kilogram-plate gym resolves correctly rather than
producing an impossible number.

---

### F-PLT-001 — Plate calculator
Status: planned | Priority: P1 | Phase: 4
Depends on: F-PLT-002
Blocks: F-PRG-012, F-LOG-020
Screens: Active Workout (sheet), Numeric Keypad

**Intent** — Nobody wants to do `(102.5 − 20) ÷ 2` mentally between sets. Every
serious lifter has done this arithmetic wrong at least once.

**Behaviour**
1. Given a target load, a bar, and a plate inventory, produce the per-side
   plate loading.
2. Greedy heaviest-first solve, constrained by the number of pairs actually
   available.
3. When the target is unassemblable, show the closest achievable load above and
   below, and by how much each misses.
4. Accessible in one tap from any weight field.
5. Handles non-barbell cases: fixed dumbbells, machine stacks (`F-PLT-005`).

**Acceptance criteria**
- [ ] Correct for kilogram and pound inventories, and for mixed ones.
- [ ] Never proposes plates the user doesn't have.
- [ ] Target below bar weight is reported clearly, not as an empty result.
- [ ] Odd loads that cannot be split evenly per side are rejected with an
      explanation.

**Edge cases** — Target equals bar weight (valid, no plates). Target below bar
weight. Inventory with no small plates, so the minimum jump is large. Bar not
loaded symmetrically — out of scope, symmetric loading is assumed.

---

### F-PLT-002 — Bar and plate inventory
Status: planned | Priority: P1 | Phase: 4
Blocks: F-PLT-001
Screens: Plate Settings
Data: `bars`, `plates`

**Behaviour**
1. Define bars: name, weight, default flag. Ships with sensible defaults —
   20 kg / 45 lb standard, 15 kg / 35 lb women's, plus common specialty bars.
2. Define plates: weight and number of *pairs* available; enable/disable per
   plate.
3. Ships with standard kilogram and pound plate sets, chosen by the user's load
   unit at first run.
4. Per-exercise default bar (`exercises.default_bar_id`).
5. Micro-plates (0.25 / 0.5 / 1.25 kg, 1.25 lb) supported, since they're the
   whole point of the feature for upper-body progression.

---

### F-PLT-003 — Loading visualisation
Status: planned | Priority: P2 | Phase: 4
Depends on: F-PLT-001

Draw the loaded bar to scale with colour-coded plates matching real IPF plate
colours. Far faster to read mid-set than a list of numbers, and it's how lifters
already think about a loaded bar.

---

### F-PLT-004 — Closest achievable weight
Status: planned | Priority: P1 | Phase: 4
Depends on: F-PLT-001, F-PLT-002
Blocks: F-PRG-012

Given an arbitrary target, return the nearest assemblable load, with a
configurable rounding direction (default down). Exposed as a pure domain
function so the progression engine can call it directly without touching UI.

---

### F-PLT-005 — Machine and stack increments
Status: planned | Priority: P2 | Phase: 4

Some exercises aren't plate-loaded at all. Per-exercise weight sources: plate
loaded, fixed dumbbells (with an available-increment list), or a weight stack
(base increment plus optional half-steps for add-on magnets). Determines both
what the calculator shows and what increments the steppers and progression
engine use.
