# Privacy policy

_Last updated: see this file's git history — it is versioned with the app, not
hosted separately (`F-REL-007`)._

FitnessApp is a local-first strength-training tracker. This policy is short
because the honest answer to almost every privacy question is "none" and "no".

## Summary

- **No account.** The app never asks you to sign up, sign in, or provide an
  email address, name, or any other identifying information.
- **No telemetry, no analytics, no crash reporting.** Nothing about how you use
  the app is measured, logged, or transmitted anywhere.
- **No network calls.** The app does not talk to the internet at all — not to
  us, not to a cloud backend (there isn't one), not to any third party. This
  isn't just a policy promise: the release build's Android manifest requests no
  `INTERNET` permission, so the operating system itself would block any attempt
  regardless of what the code does.
- **No data collection, no data sharing.** We don't have your data, because it
  never leaves your device unless you personally choose to move it — see
  Exporting and sharing your data below.
- **No third-party SDKs that phone home.** The app has no advertising, analytics,
  or crash-reporting libraries. The only user-triggered exceptions are the
  device's own share sheet, for sending an export file somewhere of your
  choosing, and opening a link (this project's GitHub repository, or an
  open-source licence) in your browser when you explicitly tap one.

## What data the app stores, and where

Everything the app knows about your training lives in a single local database
on your device, plus a private folder for any progress photos you add:

- Workouts, sets, weights, reps, exercises, and routines you log or create.
- Body measurements you choose to log, including bodyweight and, optionally,
  progress photos.
- App preferences: units, theme, rest-timer defaults, plate inventory, and so
  on.

None of it is encrypted at rest — an optional PIN app lock (`F-SET-010`) can
gate casual access to the app itself while it's unlocked on your device, but
it is not disk encryption and doesn't protect the data if your device's own
storage is otherwise accessible. Progress photos are the most sensitive data
category the app holds; they are stored only in the app's private storage,
never uploaded anywhere, and excluded by default from exports and backups
(see below) precisely because bundling them without asking would be a privacy
failure in its own right.

## Exporting and sharing your data

You can export your data as JSON or CSV, or make a full backup, at any time
from Settings. These are ordinary files written to storage you control, or
handed to the operating system's share sheet so *you* can decide where they
go — by email, cloud storage, a messaging app, or anywhere else. The app has
no part in that decision beyond handing the file to the system; it does not
upload anything itself.

## Deleting your data

You can wipe all app data at any time from Settings, which requires typed
confirmation and offers a backup first. This is a genuine, permanent deletion,
not a soft "hide it" — see `docs/21-DATA-MODEL.md`'s deletion policy for the
one documented exception to how the app otherwise treats deletes everywhere
else. Uninstalling the app removes everything it stored, same as any other
Android app with no cloud copy to also delete, because there isn't one.

## Children's privacy

The app collects no personal information from anyone, of any age, since it
collects no personal information at all. It is not directed at children and
has no age-gating because none is needed.

## Health data (if you use Health Connect integration)

If Health Connect read/write support (`F-HLT-001`, `F-HLT-002`) is enabled on
your device, any data shared with or read from Health Connect is governed by
the Android Health Connect permission model, which you grant and can revoke at
any time in system settings. It is exchanged directly between the app and
Health Connect on-device — it does not pass through us, because nothing does.

## Changes to this policy

This file is checked into the app's source repository and versioned alongside
the app itself (`F-REL-007` §4) — changes are visible in the project's commit
history rather than announced separately.

## Contact

This is an open-source, no-account project with no company behind it. For
questions or concerns, open an issue on the project's GitHub repository.
