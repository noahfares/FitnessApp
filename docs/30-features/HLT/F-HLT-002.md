# F-HLT-002 — Health Connect read

Status: done | Priority: P3 | Phase: 6
Depends on: F-BOD-001
Reads: 20-ARCHITECTURE#cross-platform-discipline

## Spec

Read bodyweight from Health Connect so a smart scale populates `F-BOD-001`
automatically. Read-only, opt-in, and with a clear conflict rule when both
sources have an entry for the same day.

## Status note

Shares its opt-in toggle and permission request with `F-HLT-001` — one
`READ_WEIGHT` grant, requested and revoked together with `WRITE_EXERCISE`.
`BodyMeasurementRepository.syncBodyweightFromHealthConnect` (called from
`healthConnectBodyweightSyncProvider`, watched at the top of
`BodyWeightScreen.build()`) reads the last 30 days (Health Connect's own
default access window; reading further back would need the extra history
permission this feature deliberately never requests), skips any record
already imported (`health_connect_record_id`) and any local calendar date
that already has a manually-entered bodyweight row — "a day you have
already logged yourself is never overwritten," per the settings screen's
own copy — implemented as `shouldImportHealthConnectReading`
(`lib/domain/health/health_connect_import.dart`), fixture-tested
(`test/domain/health/health_connect_import_test.dart`).

On-device verification (2026-08-14): confirmed via Health Connect's own
"App access" screen that the read grant is exactly "Body measurements — 1
of 1 selected" (Weight only, not the broader group), and that revoking
permissions through the app's settings screen clears it. The full
write-then-import round trip — logging a weight reading in a real
Health-Connect-connected app (e.g. a smart scale's own app) and confirming
it appears on the Body screen — was not exercised in this session: doing
so would have meant writing test data into this device's real, already
account-connected health apps (RENPHO Health, Samsung Health), which was
judged out of scope for a feature verification pass. The import logic
itself is covered by fixture tests and code review, not an on-device
positive-path proof.
