# F-LOG-022 — Undo and mis-tap protection

Status: planned | Priority: P1 | Phase: 2
Reads: 21-DATA-MODEL#sets, 24-DESIGN-SYSTEM#component-inventory

## Spec
1. Set deletion offers undo via a snackbar for several seconds.
2. Discarding a workout requires typed or held confirmation, not a single tap.
3. Undo covers the last destructive action within the session.
4. Undo is a `deleted_at` field update, not a re-insert — nothing is ever hard
   deleted ([ADR-0008](../../70-decisions/ADR-0008-sync-ready-foundations.md)), so
   restoring is trivially correct and preserves the original ID and timestamps.

---

## Why

Fat-fingering a completion toggle or deleting the wrong set
mid-session is common with imprecise, sweaty taps.
