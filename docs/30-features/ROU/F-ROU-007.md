# F-ROU-007 — Folders

Status: done | Priority: P2 | Phase: 2
Reads: 21-DATA-MODEL#routine_days, 70-decisions/ADR-0004-template-snapshot
Data: `routine_folders`

## Spec

Group routines into folders — "Current block", "Archive", "Deload". Flat, one
level deep; nested folders are complexity without payoff at this scale.

## Acceptance
- [x] A routine can be created inside a folder and moved between folders.
- [x] The routine list groups by folder, folders in position order, with an
      unfoldered section last; a list with no folders in use stays flat.
- [x] Deleting a folder moves its routines to "no folder" — never orphaned,
      never deleted with it.
