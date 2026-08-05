# F-LOG-017 — Per-side versus total weight

Status: planned | Priority: P1 | Phase: 2
Reads: 22-UNITS, 21-DATA-MODEL#sets
Data: `exercises.weight_entry_mode`, `sets.weight_grams`

## Spec
1. `sets.weight_grams` **always stores total load.**
2. Each exercise has an entry mode, `total` or `perSide`, defaulting sensibly
   per equipment type (dumbbells → per side).
3. Per-side entry is converted on input and displayed back in the entry mode.
4. The mode is visible in the set row header so it's never ambiguous.

## Acceptance
- [ ] Volume for a per-side exercise counts total load.
- [ ] Switching an exercise's mode converts existing history correctly, or
      explicitly refuses and explains why.

## Open questions

What happens to existing history when the mode changes? A
migration is risky; refusing is safer but annoying. Decide before Phase 2.

---

## Why

A persistent source of silently corrupt data. "Dumbbell press 30 kg"
means 30 per hand to most people and 60 total to a volume calculation. Getting
this wrong doubles or halves every derived figure.
