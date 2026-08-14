# F-DAT-005 — Strong CSV import

Status: in-progress | Priority: P1 | Phase: 5
Blocks: F-CAT-010
Reads: 22-UNITS#import-and-export, 21-DATA-MODEL

## Spec
1. Parse Strong's CSV export into workouts, exercises and sets.
2. Map source exercise names onto catalogue entries; unmatched names create
   custom exercises or prompt for mapping (`F-DAT-007`).
3. **Determine the source unit explicitly.** If it cannot be established with
   certainty from the file, ask. Never guess — a silently mis-imported history
   is worse than a failed import.
4. Preview before committing: counts of workouts, sets, and unmatched exercises.
5. Idempotent — re-importing the same file doesn't duplicate.

## Acceptance
- [ ] A real export imports with correct dates, weights and set types. **Not
      verified this session** — no real Strong export file was available to
      test against, the same waiver shape Phases 1 and 3 used for their own
      on-device-only criteria. Worth re-checking against a real file.
- [x] Ambiguous units halt and ask rather than assuming.
- [x] Warm-up set information is preserved where the source records it.

## Open questions

Strong's export format has varied across versions. Support
detection of multiple layouts, and fail loudly on an unrecognised one.

---

## Why

Removes the switching cost. Anyone with years of Strong history can
move without abandoning it, which is the difference between "interesting project"
and "app I can actually use".

---

## Status note (batch 5.3)

`domain/import/csv_import_adapter.dart`'s `CsvImportAdapter` matches columns
by **header name**, not position, against a per-format list of candidate
spellings (`ColumnMapping`) — this is what closes the "Open questions" ask
directly: a version whose headers don't include any recognised spelling for
a required field throws `UnrecognisedCsvFormatException` naming exactly
what's missing, rather than guessing at a layout. The unit (§3) is read
from the weight column's own header (`"Weight (kg)"`, `"weight_kg"`) or a
separate unit column; if neither is present, `AmbiguousUnitException` halts
before any row is parsed and `ImportScreen` asks. `domain/import/
import_exercise_matcher.dart` reuses `exercise_search.dart`'s `foldForSearch`
for exact/alias matching (§2) — deliberately not that module's own
"contains" search, which would resolve "Bench" to every exercise with
"bench" in its name. `data/io/import_service.dart`'s `ImportService.commit`
is idempotent (§5) at the workout level: a workout is skipped wholesale if
one already exists with the exact same `started_at`, the source date being
deterministic across re-imports of the same file. A CSV carries no UTC
offset — the parsed local wall-clock is stamped with the device's current
offset at import time, the same best-effort choice `app_database.dart`'s own
`from < 3` migration already made once. `PersonalRecordRepository.rebuildAll`
runs after a non-empty commit, since the PR cache only ever advances
incrementally and can't find a bulk-imported history's best values without a
full rescan. Not built: distance import — exactly as unit-ambiguous as
weight, but no acceptance criterion here requires cardio-distance
correctness, so distance is left unset rather than guessed at; see
`import_service.dart`'s own class doc for the full reasoning.

## Status note (Phase 5 close)

No real Strong export file was available in any session, so the one open
acceptance item was checked on paper instead: `strongColumnMapping`
(`csv_import_adapter.dart`) was compared against Strong's publicly
documented export columns (`Date`, `Workout Name`, `Duration`,
`Exercise Name`, `Set Order`, `Weight`, `Weight Unit`, `Reps`, `Distance`,
`Distance Unit`, `Seconds`, `Notes`, `Workout Notes`, `RPE`) and the
warm-up-in-`Set Order` convention (`W1`, `W2`) reported for Strong's
export. Every candidate spelling and the warm-up detection regex line up
with the documented format. This is not the same as running a real file
through the importer — the project owner accepted it as sufficient to
close Phase 5 regardless, waiving the criterion rather than leaving it
open indefinitely. Worth re-running against a real Strong export if one
ever turns up.
