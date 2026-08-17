# Privacy policy

**App:** Fitness App (`com.noahfares.fitnessapp`)
**Effective:** 2026-08-17 · **Version:** 1 · Canonical copy: this file, in the
app's own repository.

## The short version

This app collects nothing, sends nothing, and has no account. Everything you log
stays on your device until you choose to export it.

## What is collected

**Nothing is collected.** There is no server to collect it with. The app has no
account system, no login, no email capture, no analytics, no crash reporting, no
advertising identifier, and no telemetry of any kind.

## What is stored, and where

Everything you enter — workouts, sets, routines, exercises, bodyweight and body
measurements, personal records, and your settings — is stored in a database file
in the app's own private storage on your device. It is never transmitted.

If you set an app-lock PIN, it is stored as a salted hash, on the device only.
It gates the app's UI; it is not encryption, and it is not sent anywhere.

## Network access

**The app makes no network calls at all.** This is enforced, not just promised:
a check runs in continuous integration that fails the build if any networking
library, dependency, or API appears in the app's source
(`tools/check-network.sh`). The Android app declares **no permissions
whatsoever** — including no internet permission.

Two things involve other apps, at your explicit request, and neither sends
anything on its own:

- **Export and share.** When you export your data, the file is handed to
  Android's share sheet and you choose what receives it. What that app then does
  with the file is governed by its own privacy policy, not this one.
- **The source-code link** on the About screen opens your browser at this app's
  public repository. Your browser makes that request; the app does not.

## Sharing with third parties

None. No data is shared, sold, or disclosed to anyone, because none of it ever
leaves your device unless you export it yourself.

## Your control over your data

- **Export** everything, at any time, as JSON or as a backup file
  (Settings › Data).
- **Delete** everything, at any time, from the same screen — "Wipe all data"
  clears the database on the device.
- **Uninstalling** the app removes its private storage, and with it every record
  described above.

There is no request to make and no one to ask: the export and the delete are
both buttons in the app.

## Children

The app is not directed at children and collects no data from anyone, of any
age.

## Health data

The app stores the training and body measurements *you* enter, on your device.
It does not read from or write to Apple Health, Google Health Connect, or any
other health platform. If that ever changes, it will be opt-in, off by default,
disclosed here, and reflected in the store declarations before it ships.

## Changes to this policy

The policy lives in the repository alongside the code, so every change to it is
a commit with a date and a diff. Material changes will be noted in the app's
release notes.

## Contact

Questions or corrections: open an issue at
<https://github.com/noahfares/FitnessApp/issues>.
