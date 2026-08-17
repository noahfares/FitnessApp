# F-REL-007 — Privacy policy and data safety

Status: done | Priority: P0 | Phase: 6
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

## Implementation

- `PRIVACY.md` at the repository root is the canonical policy (§4): a file with
  a commit history is harder to quietly rewrite than a hosted page. Linked from
  Settings › About, which already carried the one-paragraph version.
- `docs/64-PRIVACY.md` holds the operational half — Play's questionnaire
  answered line by line, the App Store label recorded ahead of an iOS that is
  not scheduled, and the list of changes that would invalidate all of it.
- The acceptance criterion says *verified*, so it is a required CI check rather
  than a reviewer's memory: `tools/check-network.sh` fails the build on a
  networking import, API, direct dependency, or an `INTERNET` permission in the
  manifest. The permission check is the load-bearing one — Android refuses a
  socket without it whatever the code says.
- Transitive dependencies are deliberately out of scope; the reasoning is in
  `tools/check_no_network.py`'s own docstring rather than repeated here.
- `url_launcher` is the single named exception: the browser it opens makes the
  request, not the app.

---

## Why

Mandatory for both stores, and unusually easy here: the honest
answer to almost every question is "none" and "no".
