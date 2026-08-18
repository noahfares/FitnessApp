# F-SET-004 — Bar and plate inventory

Status: done | Priority: P1 | Phase: 4
Depends on: F-PLT-002
Reads: 22-UNITS

## Spec

Configure available bars and plates. Reached from settings and directly from the
plate calculator, since that's where you notice it's wrong.

## Implementation

Satisfied by `F-PLT-002` rather than by separate work, which is why it closed
without a commit of its own: `PlateSettingsScreen` is the inventory editor
(bars and plates, with per-plate pair counts), reached from Settings ›
Bars & plates *and* from the plate calculator's own empty state — "since that's
where you notice it's wrong", exactly as this spec asks.

Left `planned` through Phase 4 because nobody re-read it after the batch that
implemented it. Recorded here rather than silently flipped: a feature file that
disagrees with the code is the failure mode the whole planning-first setup
exists to avoid.
