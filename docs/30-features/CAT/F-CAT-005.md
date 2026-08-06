# F-CAT-005 — Filter by muscle and equipment

Status: done | Priority: P1 | Phase: 1
Depends on: F-CAT-001
Reads: 21-DATA-MODEL#exercises
Screens: Exercise Catalogue, Exercise Picker

## Spec
1. Filter chips for primary muscle group and equipment type.
2. Filters combine with search and with each other (AND across categories, OR
   within one).
3. Active filters are visible and clearable in one tap.
4. Filter state persists within a session, resets on app restart.

## Acceptance
- [x] Filters compose correctly with search text — asserted in the domain tests
      and again through the screen.
- [x] Result count is shown when filters are active, and only then.

## Implementation

- `ExerciseFilter` in `lib/domain/catalog/exercise_search.dart` holds the query
  and both facet sets, and owns the AND/OR rule.
- Facets match the **primary** muscle only. A filter on "biceps" that also
  matched secondary muscles would return most of the catalogue, which is not a
  filter.
- The sheet offers only facets the catalogue actually contains, so no chip can
  return an empty list.
- Held in a `NotifierProvider`, never persisted: §4 asks for exactly what not
  persisting gives. Because it outlives the screen, the search field is seeded
  from it on re-entry rather than showing an empty box over a filtered list.
- Clearing facets deliberately keeps the typed query — losing the search text
  when clearing a chip is the annoying version of one-tap clearing.
