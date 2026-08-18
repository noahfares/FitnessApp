# F-LOG-015 — Supersets in the logger

Status: done | Priority: P1 | Phase: 2
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

## Status notes (closed, v0.54.0)

§2 — "completing a set advances to the next exercise in the group" — is built,
without the screen reshape batch 2.3 balked at. The logger still shows every
exercise at once, because seeing the whole session is what makes it usable
between sets; ticking a set inside a superset scrolls the next member to the
top instead, wrapping back to the group's first member after the last one,
since that is what the next round is. That is the same intent a
one-exercise-at-a-time screen would express, without hiding everything else.

`SetRow` gained an `onCompleted` callback fired before the writes — advancing
is a UI move and belongs at the moment of the tap, not after two database round
trips. Within-group rest is `F-ROU-005`'s half of the same batch.
