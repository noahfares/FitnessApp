# F-SET-008 — Notification preferences

Status: done | Priority: P2 | Phase: 2
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

## Implementation

Three switches on Settings › Rest timer rather than a screen of their own —
two of them are about the timer, and a fourth settings route for three
booleans would be worse than the grouping. Defaults are the spec's:
**rest alerts on, both reminders off**.

Turning any of them on requests the notification permission *then*, in context,
and a refusal leaves the switch off rather than pretending it is on — which is
the honest behaviour and also what makes "never at first launch" hold: nothing
in the launch path touches a permission.

The rest-alert switch gates the platform alert only. The in-app countdown, the
bar and the timer state are unaffected by it, because those need no permission
and losing them to a refused dialog would be a worse app.

Not built: the reminders themselves are preferences with no scheduler behind
them yet — the switch persists and gates a future `F-TIM-008`-shaped feature.
Recorded here rather than shipped as a switch that silently does nothing:
`docs/51-BACKLOG.md` carries the follow-up.
