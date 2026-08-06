# F-CAT-004 — Search

Status: done | Priority: P0 | Phase: 1
Depends on: F-CAT-001
Reads: 21-DATA-MODEL#exercises
Screens: Exercise Catalogue, Exercise Picker

## Spec
1. Case- and diacritic-insensitive substring match on name and aliases.
2. Results update per keystroke; no explicit search action.
3. Ordering: exact prefix match, then favourites, then recency, then alphabetical.
4. Tolerates a leading/trailing space and matches across word boundaries
   ("inc bench" → "Incline Bench Press").

## Acceptance
- [x] Sub-100 ms on a 400-row catalogue. Asserted in
      `test/domain/catalog/exercise_search_test.dart` on the **cold** path —
      folding every name and alias included — which is the first keystroke
      after a catalogue change. Not yet re-measured on a low-end device; that
      belongs with the first real APK (`F-REL-002`).
- [x] "rdl" finds Romanian Deadlift via alias. Aliases already ship in the seed
      data, so this works ahead of `F-CAT-008`, which adds *editing* them.

## Implementation

- `lib/domain/catalog/exercise_search.dart` — matching, folding and ordering, as
  pure Dart. Quietly returning nothing looks like a missing exercise rather than
  a bug, so the rules are pinned by unit tests rather than left in a widget.
- Query tokens are matched **unordered**: "bench inc" works as well as
  "inc bench", because that is what typing fast and correcting yourself
  produces.
- Diacritics fold through a table rather than Unicode normalisation — Dart's
  core library has no NFD decomposition, and a package for 90 entries would put
  a dependency underneath the domain layer.
- Folded forms are computed once per database change in `CatalogIndex`, not per
  keystroke. That is what the 100 ms budget actually rests on.
- Recency is a real tiebreak in the comparator but is always null until there is
  history to read it from; wiring it up is one line in the provider
  (`F-CAT-006`).

The same domain function backs the exercise-picker sheet when `F-LOG-002` lands
— the picker differs in chrome, not in matching.

## Open questions

Fuzzy matching for typos? Adds complexity; defer until it
proves annoying in real use.

---

## Why

With 400 exercises, search *is* the picker. It's used mid-session
with a rest clock running, so it must be instant and forgiving.
