# F-PRG-002 — Linear progression

Status: planned | Priority: P1 | Phase: 4
Depends on: F-PRG-001
Reads: 40-ANALYTICS-SPEC, 22-UNITS

## Spec
1. All target reps achieved at target weight → add a configured increment.
2. N consecutive failures → deload by a configured percentage.
3. Increment and failure threshold are per-exercise, with sensible defaults
   (smaller jumps for upper-body lifts than lower-body).
4. Partial success — some sets made, some missed — repeats the same weight.

## Acceptance
- [ ] Success, partial, and failure paths each produce the right next target.
- [ ] Deload triggers only after the configured consecutive-failure count.
