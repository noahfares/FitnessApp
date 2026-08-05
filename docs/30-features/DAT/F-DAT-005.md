# F-DAT-005 — Strong CSV import

Status: planned | Priority: P1 | Phase: 5
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
- [ ] A real export imports with correct dates, weights and set types.
- [ ] Ambiguous units halt and ask rather than assuming.
- [ ] Warm-up set information is preserved where the source records it.

## Open questions

Strong's export format has varied across versions. Support
detection of multiple layouts, and fail loudly on an unrecognised one.

---

## Why

Removes the switching cost. Anyone with years of Strong history can
move without abandoning it, which is the difference between "interesting project"
and "app I can actually use".
