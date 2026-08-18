# Store listing (`F-REL-006`)

Copy and metadata for the Play listing, checked in so it is reviewable and
versioned rather than typed straight into a web form. Graphics in this
directory are generated — `tools/gen-icons.sh` (`F-THM-006`).

Privacy answers live in [`docs/64-PRIVACY.md`](../docs/64-PRIVACY.md); this
file is everything else.

---

## Title (30 characters max)

```
FitnessApp — Gym Log
```

## Short description (80 characters max)

```
Offline strength tracker. Unlimited routines, real analytics, no subscription.
```

(77 characters.)

## Full description (4000 characters max)

```
A strength-training tracker that gives away, free and offline, what the popular
apps charge a subscription for: unlimited routines and custom exercises, real
analytics, progression automation, and full data export.

No account. No server. No telemetry. The app makes no network calls at all —
it does not even request internet permission — and your training data never
leaves your device unless you export it yourself.

LOGGING
• A set row built to be used mid-set, one-handed, with a rest clock running
• Last-session values shown in place, so repeating a workout is three taps
• Warm-up, drop, failure, AMRAP and back-off set types
• RPE or RIR, per-side dumbbell weights, and per-set notes
• A rest timer that survives a pocketed phone, with per-exercise defaults
• Nothing is lost if the app is killed mid-session — every set is saved as
  you complete it

ROUTINES AND PROGRAMS
• Unlimited routines, days and custom exercises — no paywalled counts
• Six built-in starter programs: PPL, Upper/Lower, Starting Strength, GZCLP,
  5/3/1 and nSuns
• Supersets, folders, scheduling, and a preview of a day's planned volume
• Editing a routine never rewrites the sessions you already logged

PROGRESSION
• Linear, double-progression, RPE-autoregulated and percentage-of-training-max
  rules that propose the next session's targets
• Every proposal explains itself in one sentence
• Plate-aware rounding: it will not suggest a weight your plates cannot make
• A plate calculator, plus dumbbell racks and machine stacks

ANALYTICS
• Estimated 1RM trends with your choice of formula
• Volume and hard sets per muscle per week
• Personal records detected automatically, with a timeline
• Stall detection, training-load (ACWR), intensity distribution, muscle balance
• Consistency streaks and a training calendar
• Bodyweight and body measurements with smoothed trends

YOUR DATA
• Export everything as JSON or CSV, at any time
• Local backups and restore
• Import your history from Strong or Hevy
• Delete everything from inside the app, in one action

ACCESSIBILITY
• Works with a screen reader, including spoken summaries of every chart
• Full functionality at 200% text scale
• Honours the system reduce-motion setting
• No information conveyed by colour alone

Open source. The code, the plans and the privacy policy are all public.
```

## Category and tags

- **Category:** Health & Fitness
- **Tags:** workout, gym, strength training, weightlifting, log, tracker
- **Content rating:** the lowest rating in every region — no user-generated
  content, no communication features, no ads, no purchases.
- **Ads:** none. **In-app purchases:** none.

## Graphics

| Asset | File | Requirement |
|---|---|---|
| App icon | `play-icon-512.png` | 512×512 PNG, 32-bit |
| Feature graphic | `play-feature-graphic.png` | 1024×500 PNG |
| Phone screenshots | **not generated — see below** | 2–8, 16:9 or 9:16, min 320 px |

**Screenshots need a real device or emulator**, and deliberately so: a golden
render from `flutter test` uses the test font, so every label would come out as
placeholder boxes. The procedure, once hardware is available:

1. Install the release APK and open Settings › Data › **Load sample data**
   (`kDebugMode` only — use a debug build for this step, then re-shoot on the
   release build if the listing needs release-signed provenance, which Play
   does not require).
2. Capture, in this order — the listing is read in order, so the first two
   carry the pitch:
   1. Active workout mid-session, with ghost values and the rest timer visible
   2. Insights: e1RM trend with the regression overlay
   3. Insights: volume and hard sets per muscle
   4. A routine day editor showing targets and a progression rule
   5. History with the month grouping
   6. Settings › Data, showing export and wipe (the privacy pitch, visibly)
3. No device frames, no marketing overlays — Play shows them small, and the
   screenshots are there to show the actual app.

## Release notes template

Kept short and factual; the tag's generated notes carry the detail.

```
What's new in {version}

• {one line per user-visible change}

Full notes: https://github.com/noahfares/FitnessApp/releases
```
