# F-LOG-013 — PR detection and celebration

Status: planned | Priority: P1 | Phase: 2
Depends on: F-LOG-003
Reads: 40-ANALYTICS-SPEC#4-personal-records, 21-DATA-MODEL#personal_records
Data: `personal_records`

## Spec
1. On set completion, evaluate against `maxWeight`, `maxRepsAtWeight`,
   `bestE1rm`, `maxSessionVolume` (formulas: [`../40-ANALYTICS-SPEC.md`](../../40-ANALYTICS-SPEC.md)).
2. A PR shows an inline badge on the set row plus a brief, non-blocking
   animation. It must never interrupt logging.
3. PRs are listed in the session summary (`F-LOG-018`) and the PR timeline
   (`F-ANA-007`).
4. Warm-up sets can never set a PR.
5. The PR cache is rebuildable from raw sets; a maintenance action exists to do so.

## Acceptance
- [ ] Detection is correct for each PR kind against fixtures.
- [ ] Celebration never blocks input or steals focus.
- [ ] Deleting a PR set correctly demotes to the next best.

## Edge cases

First-ever set of an exercise (technically a PR — suppress the
celebration, record it silently). Multiple PR kinds in one set (show the most
significant). Equal-value ties are not PRs.

---

## Why

The main intrinsic reward loop in strength training. Detecting it
at the moment it happens, rather than in a chart three weeks later, is most of
the emotional value of the app.
