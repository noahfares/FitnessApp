# F-ANA-005 — Sets per muscle group per week

Status: planned | Priority: P1 | Phase: 3
Depends on: F-CAT-013 | Blocks: F-ROU-011
Reads: 40-ANALYTICS-SPEC, 21-DATA-MODEL#sets

## Spec
1. Count working sets per muscle per week. Primary muscle counts 1.0, each
   secondary counts 0.5.
2. Bar chart per muscle with optional reference bands for common volume targets.
3. Drill into a muscle to see which exercises contributed.

## Open questions

Should reference bands ship at all? They imply a
prescriptive stance the app otherwise avoids, and the research ranges are wide.
Probably yes, clearly labelled as a rough guide, off by default.

---

## Why

The metric that actually drives hypertrophy programming, and the one
most consumer apps omit entirely. Training literature talks in hard sets per
muscle per week; nothing else in the app answers "am I doing enough for rear
delts?"
