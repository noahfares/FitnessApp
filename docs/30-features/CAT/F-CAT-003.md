# F-CAT-003 — Custom exercises

Status: in-progress | Priority: P0 | Phase: 1
Depends on: F-CAT-002
Reads: 21-DATA-MODEL#exercises
Screens: Custom Exercise Editor | Data: `exercises`

## Spec
1. Create with name, primary muscle, optional secondary muscles, equipment,
   tracking type.
2. Edit and archive freely. Delete only when no sets reference it; otherwise
   archive.
3. Custom exercises are indistinguishable from seeded ones in use, marked only
   in the editor.
4. Duplicate-name warning, not a block — "Bench Press (Smith)" is legitimate.

## Acceptance
- [x] Created exercise is immediately usable — `ExerciseRepository.createCustom`
      returns the row and `watchAll` re-emits, so no manual refresh exists to
      forget.
- [x] Seeding never touches a custom exercise: `external_id` and
      `seed_updated_at` are both null, so it is not matched and not refreshed.
- [ ] Deleting one with history is prevented, with archive offered.
      *`hasHistory` exists and is tested; the confirmation UI needs the
      catalogue screen (batch 1.2).*
- [ ] Survives export/import round-trip with its UUID intact. *Phase 5.*

## Implementation

Data layer complete (batch 1.1), **editor screen outstanding**:

- `lib/data/repositories/exercise_repository.dart` — create, rename, notes,
  favourite, archive, soft delete, restore. Every read filters
  `deleted_at IS NULL` and every write stamps `updated_at`, so no feature can
  forget either invariant.
- Duplicate names warn rather than block: "Bench Press (Smith)" is legitimate.
- Remaining: the Custom Exercise Editor screen, which needs somewhere to be
  reached from (`F-CAT-004`, batch 1.2).

---

## Why

The single most commonly paywalled feature in competitors, and the
one that makes the app viable for anyone with an unusual machine or a coach's
bespoke movement. Unlimited, free.
