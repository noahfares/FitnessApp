# F-TIM-004 — Notification and lock-screen controls

Status: planned | Priority: P2 | Phase: 2
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
