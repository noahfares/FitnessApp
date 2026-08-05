# F-LOG-020 — Warm-up set generator

Status: planned | Priority: P2 | Phase: 4
Depends on: F-PLT-001, F-LOG-005
Reads: 21-DATA-MODEL#sets, 24-DESIGN-SYSTEM#component-inventory

## Spec

Generate a warm-up ramp from the working weight (e.g. bar × 8, 40% × 5, 60% × 3,
80% × 1), rounded to available plates, inserted as `warmup` sets in one tap. The
ruleset is user-editable and per-exercise.
