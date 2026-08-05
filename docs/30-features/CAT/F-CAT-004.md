# F-CAT-004 — Search

Status: planned | Priority: P0 | Phase: 1
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
- [ ] Sub-100 ms on a 400-row catalogue on a low-end device.
- [ ] "rdl" finds Romanian Deadlift via alias (`F-CAT-008`).

## Open questions

Fuzzy matching for typos? Adds complexity; defer until it
proves annoying in real use.

---

## Why

With 400 exercises, search *is* the picker. It's used mid-session
with a rest clock running, so it must be instant and forgiving.
