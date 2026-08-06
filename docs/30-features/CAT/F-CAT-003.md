# F-CAT-003 — Custom exercises

Status: done | Priority: P0 | Phase: 1
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
- [x] Deleting one with history is prevented, with archive offered. The editor
      checks `hasHistory` before it offers Delete at all; when history exists
      the dialog offers Archive instead.
- [ ] Survives export/import round-trip with its UUID intact. *Phase 5.*

## Implementation

Data layer (batch 1.1) and editor screen (batch 1.2) both complete.

- `lib/data/repositories/exercise_repository.dart` — create, rename, notes,
  favourite, archive, soft delete, restore. Every read filters
  `deleted_at IS NULL` and every write stamps `updated_at`, so no feature can
  forget either invariant.
- `lib/features/catalog/presentation/exercise_editor_screen.dart` — one screen
  for create and edit, reached from the catalogue (`F-CAT-004`) at
  `/exercises/new` and `/exercises/:exerciseId/edit`.
- `lib/core/ids/uuid.dart` — ids are generated before the insert, so a new row
  can be referenced while the write is still in flight (ADR-0008).
- Duplicate names warn rather than block: the check runs per keystroke against
  `nameExists`, guarded by a token so a slow earlier check cannot overwrite a
  later answer.
- Editing a **seeded** row goes through the same screen and the same repository,
  which is what makes `updated_at != seed_updated_at` and stops the next
  re-seed clobbering the edit (`F-CAT-001`).

---

## Why

The single most commonly paywalled feature in competitors, and the
one that makes the app viable for anyone with an unusual machine or a coach's
bespoke movement. Unlimited, free.
