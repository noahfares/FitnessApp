# F-PRG-012 — Plate-aware rounding

Status: planned | Priority: P1 | Phase: 4
Depends on: F-PLT-001
Reads: 22-UNITS, 40-ANALYTICS-SPEC

## Spec
1. Every proposed load is rounded to the nearest weight assemblable from the
   user's actual bar and plate inventory (`F-PLT-002`).
2. Rounding direction is configurable — the default rounds down, since
   overshooting a target causes missed reps.
3. When the smallest achievable jump exceeds the rule's increment, the engine
   says so and offers to hold weight and add reps instead.

## Acceptance
- [ ] No proposed target is ever unassemblable from the configured inventory.
- [ ] Micro-plate owners get micro-plate-sized jumps.

---

## Why

A target of 102.3 kg is worse than useless — it's noise the user has
to mentally correct every session, and it destroys trust in the engine.
