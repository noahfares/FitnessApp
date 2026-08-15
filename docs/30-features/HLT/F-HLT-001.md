# F-HLT-001 — Health Connect write

Status: done | Priority: P2 | Phase: 6
Reads: 20-ARCHITECTURE#cross-platform-discipline

## Spec
1. Write completed workouts to Health Connect as strength-training sessions with
   start time, duration, and optionally energy expenditure.
2. Explicitly opt-in, off by default, revocable, with a clear statement of what
   is written.
3. Write failures never block finishing a workout — the local record is
   authoritative.

## Acceptance
- [x] Nothing is written before explicit consent.
- [x] Revoking permission degrades gracefully with no data loss.
- [x] Deleting a workout locally offers to remove the corresponding record.

## Status note

Built and verified end-to-end on a real device (Samsung Galaxy S24+,
Android, Health Connect app installed). `data/platform/health_connect_service.dart`
(`AndroidHealthConnectService`, wrapping the `health` package) writes a
`HealthWorkoutActivityType.STRENGTH_TRAINING` session with title, start and
end time only — no energy expenditure, per the Open Questions note below.
`WorkoutRepository.finish()` takes a `healthConnectEnabled` flag (a
call-site parameter, not injected into the repository, to keep
`data/` from importing the `features/`-layer settings provider — see
`docs/20-ARCHITECTURE.md#cross-platform-discipline`) and writes
best-effort inside a try/catch, setting `workouts.health_connect_synced`
only on success; a write failure is silently swallowed and never blocks
finishing. `HealthConnectSettingsScreen` gates the whole feature behind one
off-by-default toggle (`healthConnectEnabledProvider`,
`SharedPreferences`); enabling it drives `isAvailable()` →
`requestPermissions()` → `setEnabled(true)`, requesting only
`WRITE_EXERCISE` and `READ_WEIGHT` (`F-HLT-002`) — confirmed on-device via
Health Connect's own "App access" screen, which shows exactly "Activity —
1 of 1 selected" and "Body measurements — 1 of 1 selected", never the
broader read/write groups. `WorkoutDetailScreen._delete()` checks
`workout.healthConnectSynced` before offering removal, and calls
`HealthConnectService.deleteWorkout()` (re-targeting by the same
start/end timestamp window the write used, rather than storing a returned
record UUID — the `health` package's `writeWorkoutData` returns only a
bool).

On-device verification (this session, 2026-08-14): logged a real
"Back Squat" set, finished the workout, and confirmed via a direct sqlite
query on the pulled app database that `health_connect_synced = 1`;
confirmed independently through Health Connect's own UI that the session
appeared verbatim ("Strength training • Evening Workout", correct
start/end times); deleted the workout through the app and confirmed via
Health Connect's "See app data" screen that the record was gone
("No data"); and confirmed "Revoke permissions" flips the toggle off with
a confirmation snackbar and clears Health Connect's grant, with the local
workout history entirely unaffected throughout. Not verified: the
`writeWorkoutData` failure path itself (no way to force Health Connect
into a write-rejecting state in this session) — code review confirms the
try/catch shape, but it has no on-device negative-path proof.

## Open questions

Energy expenditure for resistance training is a guess at
best. Writing a fabricated calorie figure into a user's health record is worse
than writing nothing. Default to omitting it.

---

## Why

Workouts logged here should appear alongside everything else the
user's phone knows about their activity, without them re-entering anything.
