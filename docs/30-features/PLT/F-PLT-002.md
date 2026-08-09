# F-PLT-002 — Bar and plate inventory

Status: done | Priority: P1 | Phase: 4
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

---

## Status note (batch 4.3)

`PlateRepository` (`lib/data/repositories/plate_repository.dart`) — `bars`
and `plates` CRUD, `resolveBar` (exercise's own bar → inventory default →
heaviest available, never throwing on a tombstoned `default_bar_id`), and
`seedDefaultsIfNeeded` (§1, §3): a first-run-only kg or lb set, gated by an
`app_settings` marker rather than the load unit itself, so a later unit
switch never rewrites a curated inventory. Settings › Bars & plates
(`PlateSettingsScreen`) covers §1–§3. §4 (per-exercise default bar) is a
dropdown on the exercise editor, shown only for barbell exercises.
Micro-plates (§5) are ordinary rows — no special casing needed, the seeded
kg set includes 1.25/0.5/0.25 kg.
