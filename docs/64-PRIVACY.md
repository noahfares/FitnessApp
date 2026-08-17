# Privacy & store declarations

The published policy is [`PRIVACY.md`](../PRIVACY.md) at the repository root —
that file is the canonical, user-facing text (`F-REL-007` §4). This document is
the operational side: what to enter in each store's questionnaire, and how the
claims are verified rather than asserted.

Feature: [`F-REL-007`](30-features/REL/F-REL-007.md). Decision:
[ADR-0002](70-decisions/ADR-0002-local-first.md).

---

## Verification (`F-REL-007` acceptance)

The acceptance criterion is that the declarations match actual behaviour,
"verified by confirming the app makes no network calls at all". Three
independent things establish that, all of them checkable by someone who does not
trust the claim:

| Evidence | Where | Fails the build? |
|---|---|---|
| No networking import, API, or direct dependency in `lib/` | `tools/check-network.sh` | Yes — CI required check |
| No Android permissions at all, `INTERNET` included | `android/app/src/main/AndroidManifest.xml` | Yes — `tools/check-network.sh` reads it |
| No backend exists to talk to | [ADR-0002](70-decisions/ADR-0002-local-first.md) | n/a — architectural |

An app with no `INTERNET` permission cannot open a socket even if code tried to:
Android refuses it at the OS level. That is what makes this claim unusually
cheap to keep honest — it is enforced a layer below our own code.

**On-device confirmation**, for the record, is still worth doing once before the
first public listing: install the release APK, put the device in airplane mode,
and use every screen. Nothing should degrade, because nothing needs the network.
Any future feature that would change this (crash reporting `F-REL-011`, update
checks `F-REL-008`) must be opt-in, disclosed in `PRIVACY.md`, and re-declared
in both stores *before* it ships — ADR-0002 §consequences is explicit.

---

## Google Play — Data safety

Play's questionnaire, answer by answer.

| Question | Answer |
|---|---|
| Does your app collect or share any of the required user data types? | **No** |
| Is all of the user data collected by your app encrypted in transit? | n/a — no data is transmitted |
| Do you provide a way for users to request that their data is deleted? | **Yes** — in-app, Settings › Data › Wipe all data (`F-DAT-010`); no request mechanism needed |
| Data types collected | **None** |
| Data types shared | **None** |
| Privacy policy URL | The raw `PRIVACY.md` URL in this repository, until a hosted page exists |

**Health data:** Play treats "Health and fitness" as a data *type*, and the
distinction that matters is collection versus local storage. The app stores your
training data on your device and never transmits it, so it is not "collected" in
Play's sense. Declare no data collection, not "health data collected, not
shared".

**App access / permissions declaration:** no permissions are requested, so no
sensitive-permission form applies. No foreground service is declared today —
`F-TIM-003`'s rest-timer notification will need one, and the declaration must be
updated in the same change that adds it, not afterwards.

**Content rating:** the app has no user-generated content, no communication
features, no ads, and no purchases. The IARC questionnaire should come out at
the lowest rating for every region.

**Ads:** none. Declare "No ads".

---

## Apple App Store — Privacy Nutrition Label

Not scheduled (iOS is not a target platform yet — `docs/20-ARCHITECTURE.md`),
recorded here so the answer is not re-derived under submission pressure.

- **Data Used to Track You:** none.
- **Data Linked to You:** none.
- **Data Not Linked to You:** none.
- Result: "Data Not Collected", the label's simplest state.
- **HealthKit:** if `F-HLT-003` ever ships, health-data usage strings and the
  additional declarations are required, and `PRIVACY.md` §health-data must
  change first.

---

## What would invalidate all of this

One list, so the trigger is recognisable when it comes up:

1. Any dependency that phones home — analytics, crash reporting, ads,
   remote config, an update checker.
2. Any backend, sync service, or account system (`F-DAT-009` file sync is
   deliberately *not* one: it writes a file to storage the user already owns).
3. Any health-platform integration (`F-HLT-001`, `F-HLT-002`) — that is
   permissioned, sensitive data leaving the app's own store, and needs its own
   declarations even when it never touches a network.

Each of these is a policy change first and a code change second.
