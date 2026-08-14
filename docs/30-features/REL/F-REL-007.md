# F-REL-007 — Privacy policy and data safety

Status: in-progress | Priority: P0 | Phase: 6
Reads: 62-RELEASE, 10-VISION#non-goals

## Spec
1. A published privacy policy stating: no account, no telemetry, no network
   calls, no data collection, no third-party sharing. All data local; export and
   deletion available at any time (`F-DAT-001`, `F-DAT-010`).
2. Play Data Safety and App Store Privacy Nutrition Label completed to match.
3. If health integration (`F-HLT-001`) ships, the additional health-data
   declarations are completed accurately.
4. The policy is checked into the repository, not just hosted somewhere.

## Acceptance
- [x] Declarations match actual app behaviour exactly — verified by confirming
      the app makes no network calls at all.
- [ ] Play Data Safety form and App Store Privacy Nutrition Label actually
      submitted — needs a live store console, not just the written policy.

## Status note

`PRIVACY.md` (repo root, §4) covers the app's actual behaviour: no account, no
telemetry, no network calls, what data is stored and where, export/sharing
(always user-initiated, never automatic), deletion (`F-DAT-010`'s wipe),
children's privacy, and the Health Connect case for if `F-HLT-001`/`F-HLT-002`
ship. §1's acceptance criterion — "no network calls" verified, not asserted —
is checked at the strongest level available without a live network capture: the
release build's `android/app/src/main/AndroidManifest.xml` declares no
`INTERNET` permission at all (only the `debug`/`profile` manifests do, which is
the standard Flutter template default for the DevTools connection and is never
present in a release artefact), a dependency audit of `pubspec.yaml` finds no
HTTP/socket/analytics/crash-reporting package, and a codebase grep finds no
`dart:io` `HttpClient`/`Socket`/`InternetAddress` usage anywhere. Left
`in-progress`, not `done`: §2's actual Play Data Safety form and App Store
Privacy Nutrition Label submission need a live developer console this session
has no access to and can't responsibly fill in without one — the same class of
external dependency as `F-REL-006`'s store listing or the Play internal
testing track in the phase's own exit criteria. §3 is not yet applicable —
`F-HLT-001` hasn't shipped.

---

## Why

Mandatory for both stores, and unusually easy here: the honest
answer to almost every question is "none" and "no".
