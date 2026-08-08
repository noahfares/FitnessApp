# F-ROU-012 — Scheduling

Status: in-progress | Priority: P2 | Phase: 3
Reads: 21-DATA-MODEL#routine_days, 70-decisions/ADR-0004-template-snapshot
Data: `routine_days.scheduled_weekdays`

Assign days to weekdays so the dashboard can show "today: Push" and consistency
analytics can measure adherence against a plan rather than just counting
sessions. Optional — plenty of people train on a rolling rotation.

## Open questions

Fixed weekdays or a rolling rotation ("day 3 of 6")? Both
are common. Probably needs to support both, which makes the model non-trivial.

## Status

Fixed weekdays only, batch 3.5: a "Schedule" sheet on the day editor and each
day tile writes `routine_days.scheduled_weekdays` (ISO weekday ints,
`RoutineRepository.setScheduledWeekdays`), and the dashboard's "today: Push"
card reads it back (`RoutineRepository.watchDaysForWeekday`, hidden while a
workout is already in progress — `_ResumeOrStartCard` already covers that
case). A rolling rotation is not modelled — this open question's other half
is deferred, not answered, so the feature stays `in-progress` rather than
`done`. Consistency's schedule-adherence figure (`F-ANA-006`) can now read
this column but wasn't wired to it this batch — out of scope for a feature
this batch didn't touch.
