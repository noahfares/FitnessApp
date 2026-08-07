# F-LOG-015 — Supersets in the logger

Status: in-progress | Priority: P1 | Phase: 2
Depends on: F-ROU-005
Reads: 21-DATA-MODEL#sets, 24-DESIGN-SYSTEM#component-inventory

## Spec
1. Superset-grouped exercises render with a shared visual grouping.
2. Completing a set advances to the next exercise in the group.
3. The rest timer runs after the last exercise in the group, not between them,
   unless a within-superset rest is configured.
4. Groups can be created and broken mid-session.

## Status notes

§1, §3 and §4 are done: `ActiveWorkoutScreen` renders grouped exercises with
a shared border and "Superset" label, the rest timer only starts after the
last member of a group completes a set (non-last members resolve to zero
rest — no dedicated within-group rest column exists), and a per-tile
"Group with next" / "Ungroup" control plus `WorkoutRepository.toggleGroupWithNext`
create and break groups mid-session.

§2 ("completing a set advances to the next exercise in the group") is **not**
built. The active workout screen renders every exercise's full set list at
once rather than one exercise at a time, so there is no single "focus" to
advance — the whole premise of §2 assumes a carousel-style logger this app
doesn't have. Revisit once/if the logger gains a focused single-exercise
view; forcing an auto-scroll-only interpretation onto the current layout
was judged more confusing than leaving it undone.
