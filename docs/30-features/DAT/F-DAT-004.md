# F-DAT-004 — Restore

Status: planned | Priority: P0 | Phase: 5
Depends on: F-DAT-003
Reads: 21-DATA-MODEL, 22-UNITS#import-and-export

## Spec
1. Restore from a backup file, replacing all current data after explicit
   confirmation naming what will be lost.
2. Version-checked; a newer backup on an older app version is refused clearly
   rather than partially applied.
3. Restore is transactional — it either fully succeeds or leaves the existing
   database untouched.
4. An automatic pre-restore backup is taken first.

## Acceptance
- [ ] A failed or interrupted restore never leaves a half-populated database.
- [ ] Restoring onto a device with existing data is unambiguous about the outcome.
