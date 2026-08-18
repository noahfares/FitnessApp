# F-TIM-004 — Notification and lock-screen controls

Status: done | Priority: P2 | Phase: 2
Depends on: F-TIM-003
Reads: 20-ARCHITECTURE#cross-platform-discipline

## Spec

Skip and +15 s actions directly from the notification, so the phone need not be
unlocked between sets.

## Status notes

Blocked, not attempted, in batch 2.8: `F-TIM-003` — the actual OS
notification this feature adds controls to — is still only the in-app timer
(`flutter_local_notifications`, the manifest work, and the live notification
itself are unbuilt; see its own status note). There is nothing to attach a
skip/+15s action to until that lands, and no Android SDK or physical device
in this session's environment to build or verify it against regardless.
Revisit alongside `F-TIM-003`.

## Implementation

Skip and +15 s are `AndroidNotificationAction`s on both the alert and the
ongoing countdown, so the phone need not be unlocked between sets. The action
ids come back through `NotificationRestTimerService.onAction`, which
`RestTimerController` registers on itself: the platform layer knows an action
fired, and the object that owns what "skip" means is the one that interprets
it. iOS gets the notification without the actions — categories there need
registering at initialisation and iOS is not a target platform
(`docs/20-ARCHITECTURE.md`).

Unverified on a device, same as `F-TIM-003` §1–§2: the actions exist and are
wired, and whether a given launcher renders them is a hardware question.
