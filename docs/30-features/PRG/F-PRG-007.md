# F-PRG-007 — Rule assignment

Status: done | Priority: P1 | Phase: 4
Reads: 40-ANALYTICS-SPEC, 22-UNITS
Screens: Routine Editor

## Spec

Assign a rule and its parameters per routine exercise, with a routine-level
default. Presented in plain language ("Add 2.5 kg when I hit 3×5") rather than
as a configuration form, because the concepts are simple but the vocabulary
isn't.

## Status note

The target-editing sheet (`_TargetEditorSheet`,
`lib/features/routines/presentation/routine_day_editor_screen.dart`) gained a
two-option `SegmentedButton` — "I'll decide" (manual) vs. "Add weight on
success" (linear) — with the increment field only shown for the linear
choice, prefilled from `defaultIncrementGrams`. Not built: a **routine-level**
default (only per-exercise), and exposing failure threshold or deload
fraction in this UI — both use the fixed defaults `F-PRG-002`'s status note
records. Double progression, percentage/training-max, and RPE-autoregulated
rules (`F-PRG-003`–`F-PRG-005`) have no picker option yet since none of them
exist until batch 4.2.
