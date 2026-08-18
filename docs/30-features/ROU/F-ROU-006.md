# F-ROU-006 — Rest defaults

Status: done | Priority: P1 | Phase: 2
Depends on: F-TIM-005
Reads: 21-DATA-MODEL#routine_days, 70-decisions/ADR-0004-template-snapshot

## Spec

Rest duration resolves in order: routine exercise → exercise default → global
default. Each level is explicitly overridable and shows which level it inherited
from.

## Implementation

The resolution order itself has been correct since `F-TIM-005`
(`resolveRestSeconds`: routine → exercise → global → built-in), and the routine
level has been writable since batch 2.1. What was missing is the second half of
the spec — "shows which level it inherited from" — which is now
`resolveRestSource`, paired with the resolver and tested against it so the
number and the explanation can never disagree.

The day editor's rest field states it in words: "1:30 min, inherited from this
exercise's own default", rather than the word "Default" over a value with no
provenance. A field showing 90 s with no indication of where 90 came from is
indistinguishable from one somebody set deliberately, and the difference
decides whether editing the exercise will change anything.
