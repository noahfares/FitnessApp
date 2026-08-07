# F-ROU-004 — Reordering

Status: done | Priority: P1 | Phase: 2
Reads: 21-DATA-MODEL#routine_days, 70-decisions/ADR-0004-template-snapshot

## Spec

Drag to reorder exercises within a day and days within a routine. Order is
explicit (`position`), never implied by insertion or ID.

## Acceptance
- [x] Dragging a day in a multi-day routine persists the new order.
- [x] Dragging an exercise within a day persists the new order.
- [x] `RoutineRepository.reorderDays`/`reorderExercises` write positions as a
      contiguous `0..n-1` sequence, never inferred from row count.
