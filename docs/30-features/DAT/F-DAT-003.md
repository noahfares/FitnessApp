# F-DAT-003 — Backup file

Status: done | Priority: P0 | Phase: 5
Depends on: F-DAT-001
Reads: 21-DATA-MODEL, 22-UNITS#import-and-export

## Spec

Single-file backup of the entire database, with optional passphrase encryption.
Includes progress photos only with explicit consent (`F-BOD-004`). Timestamped
filename. This is the artefact a user keeps.

---

## Status note (batch 5.1)

`lib/data/io/backup_service.dart` wraps `JsonExportService` into a
timestamped file kept in the app's own documents directory rather than
handed straight to the share sheet — `F-DAT-004`'s automatic pre-restore
safety copy needs a file it can create without user interaction. Not built:
passphrase encryption (the spec's own "optional") and photo bundling
(`F-BOD-004` doesn't exist yet, batch 5.4) — both explicit deferrals.
