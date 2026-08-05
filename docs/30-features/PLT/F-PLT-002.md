# F-PLT-002 — Bar and plate inventory

Status: planned | Priority: P1 | Phase: 4
Blocks: F-PLT-001
Reads: 22-UNITS, 21-DATA-MODEL#bars-and-plates
Screens: Plate Settings | Data: `bars`, `plates`

## Spec
1. Define bars: name, weight, default flag. Ships with sensible defaults —
   20 kg / 45 lb standard, 15 kg / 35 lb women's, plus common specialty bars.
2. Define plates: weight and number of *pairs* available; enable/disable per
   plate.
3. Ships with standard kilogram and pound plate sets, chosen by the user's load
   unit at first run.
4. Per-exercise default bar (`exercises.default_bar_id`).
5. Micro-plates (0.25 / 0.5 / 1.25 kg, 1.25 lb) supported, since they're the
   whole point of the feature for upper-body progression.
