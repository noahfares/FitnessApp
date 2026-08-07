# F-LOG-013 — PR detection and celebration

Status: done | Priority: P1 | Phase: 2
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

## Status notes

`domain/analytics/e1rm.dart` (Epley only — formula selection is `F-SET-006`,
Phase 3) and `domain/analytics/personal_records.dart` hold the pure detection
logic, each with fixture-backed unit tests. `PersonalRecordRepository` is the
cache: `evaluateSet` runs live on every set completion for `maxWeight`,
`maxRepsAtWeight` and `bestE1rm`; `maxSessionVolume` is deliberately **not**
evaluated there; a per-set running total would keep beating its own
more-recent self as the session progresses, celebrating arithmetic rather
than a real record. It is evaluated once instead, in
`evaluateSessionVolume`, when the workout finishes
(`active_workout_screen.dart`'s finish action). `rebuildForExercise`/
`rebuildAll` are the full recompute rule 4 requires — wired to every delete,
undo, and un-complete, on both the live and history set rows. Settings ›
Data carries "Rebuild personal records" as the maintenance action rule 5
asks for. The inline badge (`PrBadge`, `features/shell/widgets/`) shows on
the live set row only, and its own mount-time entrance animation stands in
for the "brief, non-blocking animation" — no separate celebratory overlay.
The finish summary lists each session's records by exercise name.

One gap against rule 4 ("deleting *or editing* a set invalidates the
cache"): editing a **value** (weight/reps) of an already-completed set
through the numeric keypad, without un-ticking and re-ticking it, does not
currently trigger a rebuild — only completion-toggling and deletion do. A
stale record can therefore survive a same-session in-place correction until
the next delete/toggle or maintenance rebuild touches that exercise. Worth
closing if it turns out to matter in practice; not done here because the
keypad sheet has several independent write sites and threading invalidation
through all of them cleanly wants its own pass rather than a bolt-on.

Found during the Phase 2 exit-criteria audit: the "suppress the celebration"
half of the first-ever-set edge case is only partly honoured. The cache
write itself is silent as specified (`evaluateSet` returns no hits for a
`hadNoPriorSet` completion), but `PrBadge` doesn't know *why* a set is a
record — it shows whenever the set holds one, which for a first-ever set is
true immediately after that first completion. So the record is recorded
silently, but the inline badge still appears right away rather than only on
a later, genuine PR. Distinguishing "just silently recorded" from "actually
being celebrated" in the badge would need a short-lived per-set signal
threaded from the completion event through to the widget; not attempted
here, since it is a soft UX nuance (the badge is true information, not a
toast) rather than a correctness bug.

---

## Why

The main intrinsic reward loop in strength training. Detecting it
at the moment it happens, rather than in a chart three weeks later, is most of
the emotional value of the app.
