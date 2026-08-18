# F-HLT-002 — Health Connect read

Status: done | Priority: P3 | Phase: 6
Depends on: F-BOD-001
Reads: 20-ARCHITECTURE#cross-platform-discipline

## Spec

Read bodyweight from Health Connect so a smart scale populates `F-BOD-001`
automatically. Read-only, opt-in, and with a clear conflict rule when both
sources have an entry for the same day.

## Implementation

Shares `HealthService` and the settings screen with `F-HLT-001`; what is
specific to reading is the conflict rule, and it is the strict one:
**a bodyweight entry you logged in this app always wins for the same day.** A
scale's reading never silently overwrites something you typed. The import is
also explicit — a button, over the last year — rather than a background sync,
because a silent writer into your own log is exactly the behaviour this app
exists not to have.

Same caveat as `F-HLT-001`: unit-tested against a fake, unverified on a device.
