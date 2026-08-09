# F-PRG-012 — Plate-aware rounding

Status: done | Priority: P1 | Phase: 4
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

---

## Status note (batch 4.3)

`domain/progression/plate_aware_rounding.dart`'s `applyPlateRounding`,
applied by `WorkoutRepository.startFromRoutineDay` after `computeTargets`
— never folded into it (§12 rule 5, §13). §3's "hold weight, add a rep"
case is `ProgressionOutcome.plateRoundingHeld`, detected structurally
(rounding round-trips back to the previous session's weight) rather than
by comparing the jump size to the rule's own increment, so it holds for
every rule including RPE-autoregulation's `2×increment` branch. Skipped
entirely with no bar or empty plate inventory configured — a fresh
install with no plate setup behaves exactly as it did before this batch.
