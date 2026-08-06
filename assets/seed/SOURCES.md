# Seed data provenance

Required by `F-CAT-001` and by the licensing risk in
[`../../docs/10-VISION.md`](../../docs/10-VISION.md#risks). Every record shipped
with the app must be accounted for here.

## `exercises.json` — 100 exercises

**Origin: hand-authored for this project. No third-party dataset was used.**

**Licence: none needed.** The content is original to this repository and carries
the repository's own licence.

### Why not an existing dataset

The plan named Free Exercise DB as a candidate
([`../../docs/11-EXTERNAL-INPUTS.md`](../../docs/11-EXTERNAL-INPUTS.md)), with
the standing condition that its licence be verified against the actual licence
file rather than a README summary.

That verification could not be completed — the licence file was not retrievable
at the expected path. `F-CAT-001` states the risk plainly: importing content
whose terms cannot be confirmed is "fatal to a store release", and public store
release is a confirmed goal. An unverifiable licence is not a licence.

Hand-authoring also turned out to be better on the merits, not merely safer:

- **Muscle assignments are correct.** Sets-per-muscle-per-week (`F-ANA-005`) and
  muscle balance (`F-ANA-008`) aggregate over `primaryMuscle` and
  `secondaryMuscles`. A dataset with sloppy or inconsistent assignments would
  produce confidently wrong analytics — worse than no analytics.
- **100 well-chosen movements beat 800 noisy ones.** Search over a padded
  catalogue is slower to use, and the padding is mostly near-duplicates and
  novelty exercises nobody logs.
- **Every field is populated.** No nulls to defend against.

### Coverage

100 exercises across all 21 muscles in the taxonomy, spanning barbell, dumbbell,
machine, cable, bodyweight, kettlebell and cardio work. Tracking types
`weightReps`, `bodyweightReps`, `time`, `weightTime` and `distanceTime` all
appear, so the logger's rendering paths have real data to exercise.

This is deliberately a *starter* catalogue, not an exhaustive one. Anything
missing is one tap away as a custom exercise (`F-CAT-003`), which is the feature
competitors charge for.

### How it is maintained

`tools/gen_seed_exercises.py` is the source of truth; the JSON is generated.
Editing the JSON by hand is a mistake — the generator validates every muscle and
equipment value against the enums, rejects duplicate names and IDs, and catches
a muscle listed as both primary and secondary.

UUIDs are derived deterministically (`uuid5`) from `externalId`, so regenerating
never changes an existing row's identity and therefore never orphans logged
sets. **The namespace UUID in that script must never change.**

## Adding records later

A verified permissive dataset could still be merged in alongside this one —
`externalId` namespacing keeps the two distinguishable. Any such import must
record here: the source, the exact licence text and where it was read, the date,
and whether the licence covers data and images separately. Images frequently
carry different terms from the data they accompany.
