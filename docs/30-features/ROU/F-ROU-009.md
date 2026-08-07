# F-ROU-009 — Archive routines

Status: done | Priority: P2 | Phase: 2
Reads: 21-DATA-MODEL#routine_days, 70-decisions/ADR-0004-template-snapshot

## Spec

Soft-hide completed training blocks without deleting them. Archived routines
remain in history references and can be restored.

## Acceptance
- [x] Archiving a routine removes it from the main list immediately.
- [x] The "Archived routines" toggle lists it, with a restore action.
- [x] Restoring returns it to the main list; nothing about the routine or its
      days changed while archived.
