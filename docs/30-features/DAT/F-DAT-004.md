# F-DAT-004 — Restore

Status: done | Priority: P0 | Phase: 5
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
- [x] A failed or interrupted restore never leaves a half-populated database.
- [x] Restoring onto a device with existing data is unambiguous about the outcome.

---

## Status note (batch 5.1)

`lib/data/io/restore_service.dart` + `lib/data/db/table_snapshot_io.dart`.
Version-checked by exact `schemaVersion` match — this app migrates the
database it opens, never a restore's raw rows, so any other version is
refused with a clear message rather than guessed at (§2). Transactional via
a single Drift transaction with `PRAGMA defer_foreign_keys = TRUE` (§3): any
failure rolls back completely before a single row changes, which also means
the version check itself can never leave a half-applied restore — it runs
before the transaction opens. Pre-restore backup (§4) via `BackupService`.
Settings › Data: file picker, then a `ConfirmSheet` naming exactly what will
be replaced. Tested in `test/data/io/restore_service_test.dart` and the
end-to-end round trip in `test/data/db/table_snapshot_io_test.dart`.
