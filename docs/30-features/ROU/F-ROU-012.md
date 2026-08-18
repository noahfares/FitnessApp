# F-ROU-012 — Scheduling

Status: done | Priority: P2 | Phase: 3
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

## Status — closed (v0.56.0)

The open question is answered as **both**, and the rotation needed no second
scheduling model: `domain/routines/rotation.dart` derives which day is next
from `workouts.source_routine_day_id` — the last day actually trained from that
routine — rather than storing a cursor. A stored position would be a second
source of truth, wrong the moment a session is deleted, edited or logged
retroactively.

A routine with any scheduled weekday keeps the calendar answer and is excluded
from the rotation query, because two "next" cards for one routine would be two
different answers to the same question. The dashboard shows either as one card:
"Today: Push" from the calendar, "Next up: Day B" from the rotation.

A day deleted since it was trained restarts the rotation at the first day
rather than guessing which neighbour it sat between — a rotation whose next
step is unknowable should restart visibly.
