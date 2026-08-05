# Glossary

Domain vocabulary, so the documents and the code use the same words for the same
things. Where a term has a precise definition in this project, that definition
wins over general usage.

## Training terms

**1RM** — One-rep max. The heaviest weight liftable for a single repetition.

**e1RM** — *Estimated* one-rep max, computed from a submaximal set. The app's
primary strength metric, because it normalises across rep ranges. Formulas:
[`40-ANALYTICS-SPEC.md`](40-ANALYTICS-SPEC.md) §1.

**Working set** — A set performed at meaningful effort, as opposed to a warm-up.
In this project: any set whose `set_type` is `working`, `drop`, `failure`, or
`amrap`. **Only working sets count toward analytics.**

**Warm-up set** — A preparatory set at a lighter load. `set_type == warmup`.
Excluded from every metric in the app, always.

**Hard set** — Used interchangeably with working set in the training literature.
The unit for volume prescription: "10–20 hard sets per muscle per week".

**Drop set** — Immediately reducing the weight after failure and continuing.
Counts toward volume.

**AMRAP** — As Many Reps As Possible. A set taken to a rep maximum rather than a
prescribed count.

**RPE** — Rate of Perceived Exertion, 6–10 on the lifting scale. RPE 8 means
roughly two reps left in reserve.

**RIR** — Reps In Reserve. The inverse of RPE: `RIR = 10 − RPE`. Stored
canonically as RPE; RIR is a display preference (`F-LOG-014`).

**Volume load** — Σ(weight × reps) over working sets. The standard measure of
training work.

**Training max** — A working figure, typically ~90% of true 1RM, used as the
basis for percentage-based programming (`F-PRG-010`).

**Progressive overload** — Systematically increasing demand over time. The
principle the entire app exists to support.

**Double progression** — Increase reps within a range at a fixed weight; when the
top of the range is reached across all sets, add weight and return to the bottom
(`F-PRG-003`).

**Linear progression** — Add a fixed increment each successful session
(`F-PRG-002`).

**Autoregulation** — Adjusting load session to session based on how the lifter is
actually performing, usually via RPE (`F-PRG-005`).

**Deload** — A planned period of reduced load or volume to allow recovery
(`F-PRG-009`, `F-PRG-011`).

**Superset** — Two or more exercises performed back to back with little or no
rest between them (`F-ROU-005`).

**PPL** — Push / Pull / Legs, a common three-day training split.

**5/3/1, GZCLP, nSuns** — Named percentage-based programs, candidates for
built-in templates (`F-ROU-015`).

**ACWR** — Acute-to-chronic workload ratio. Last 7 days' volume divided by the
28-day weekly average, used as a ramp-rate signal (`F-ANA-010`).

**Micro-plates** — Fractional plates (0.25–1.25 kg) enabling smaller jumps than
standard plates allow. The reason `F-PLT-002` tracks plate inventory precisely.

## Project terms

**Feature ID** — `F-<DOMAIN>-<NNN>`, e.g. `F-LOG-004`. Permanent, never reused.
The addressing scheme the entire documentation set is built on.

**Routine** — A named container of routine days. Not itself startable.

**Routine day** — One session's worth of planned exercises within a routine —
"Push", "Pull". **This is what you start a workout from.**

**Workout / session** — A performed training session. Snapshots its routine day
at start ([ADR-0004](70-decisions/ADR-0004-template-snapshot.md)).

**Snapshot** — Copying template data into a workout at start time so later edits
to the template never alter history. A core invariant.

**Canonical units** — Grams, metres, seconds, millimetres. The only
representation used in storage and computation
([ADR-0003](70-decisions/ADR-0003-canonical-units.md)).

**Tombstone** — A row marked deleted via `deleted_at` rather than removed.
Nothing in this schema is ever hard-deleted
([ADR-0008](70-decisions/ADR-0008-sync-ready-foundations.md)).

**Soft delete** — Setting `deleted_at`. Every read filters `deleted_at IS NULL`.

**Audit columns** — `created_at`, `updated_at`, `deleted_at`, `user_id`. Present
on every table from schema v1.

**External ID** — The seed dataset's own identifier for an exercise, stored
alongside the row's UUID so the catalogue can be re-synced upstream without
duplicating rows (`F-CAT-001`).

**Unrecoverable data** — An observation that cannot be reconstructed after the
fact: bodyweight on a given day, whether a set was a warm-up, the local time an
session happened, what the lifter noticed mid-set. The reason several Phase 4
features were pulled forward into Phase 1.

**Display unit** — What the user sees: kg or lb, cm or in. A presentation
concern only; changing it never touches stored data.

**Ghost values** — Last session's numbers shown greyed inline in each set row as
a prefill target (`F-LOG-004`). The highest-value UX detail in the app.

**Sticky note** — A persistent per-exercise note carrying setup details such as
seat height or pin position (`F-CAT-007`). Distinct from per-session notes.

**Tracking type** — What a given exercise measures: `weightReps`, `reps`, `time`,
`distanceTime`, `weightTime`. Determines which inputs the logger renders
(`F-CAT-002`).

**Entry mode** — Whether a weight is entered as total load or per side
(`F-LOG-017`). Storage is always total.

**Progression rule** — A pure function mapping history to next-session targets
(`F-PRG-001`).

**Insight card** — A generated plain-English observation on the dashboard
(`F-ANA-013`).

## Technical terms

**Drift** — The typed SQLite layer ([ADR-0005](70-decisions/ADR-0005-drift.md)).

**Riverpod** — State management and dependency injection
([ADR-0006](70-decisions/ADR-0006-riverpod.md)).

**Domain layer** — `lib/domain/`. Pure Dart, no Flutter, no database. Holds every
computation that could be silently wrong.

**Write-through** — Persisting every change immediately rather than buffering in
memory. Why an app kill mid-session loses nothing (`F-LOG-007`).

**Upload key / app signing key** — Play App Signing terminology. The distinction
that determines whether sideloaded installs can upgrade to store installs
([ADR-0007](70-decisions/ADR-0007-signing.md)).

**Health Connect** — Android's health data platform (`F-HLT-001`). HealthKit is
the iOS equivalent.
