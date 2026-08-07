# F-SET-008 — Notification preferences

Status: planned | Priority: P2 | Phase: 2
Depends on: F-TIM-003
Reads: 22-UNITS

## Spec

Rest-timer alerts, optional workout reminders, and measurement reminders. All
default off except the rest timer; permission requested in context, never at
first launch.

## Status notes

Blocked, not attempted, in batch 2.8, for the same reason as `F-TIM-004`:
every preference this feature exposes ("rest-timer alerts", "workout
reminders", "measurement reminders") is a toggle over a notification channel
that `F-TIM-003` hasn't built yet. Building the settings screen first would
mean shipping switches that request a permission for something that cannot
yet fire. Revisit alongside `F-TIM-003`.
