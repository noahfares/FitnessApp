# F-ROU-008 — Duplicate and version

Status: planned | Priority: P1 | Phase: 2
Depends on: F-ROU-001
Reads: 21-DATA-MODEL#routine_days, 70-decisions/ADR-0004-template-snapshot

## Spec
1. Duplicate produces an independent copy with a distinguishing name.
2. Because workouts snapshot their day, editing a routine in place is already
   safe for history — versioning is for the user's own clarity, not data safety.
3. Archived routines stay startable but are hidden from the main list.

---

## Why

Programs evolve. You want "PPL v2" with a swapped accessory without
losing what v1 was, and without rewriting history.
