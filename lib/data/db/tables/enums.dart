/// Enumerations stored in the database, by name.
///
/// Stored as text rather than an ordinal so the values stay readable in a raw
/// database dump (`F-DAT-011`) and cannot be silently reassigned by reordering
/// the Dart declaration. Adding a value is a migration.
library;

/// What an exercise measures — decides which inputs the logger renders
/// (`F-CAT-002`).
///
/// All four measurement columns on `sets` are nullable from v1 so that adding
/// support for a type later needs no migration. Phase 1 implements
/// [weightReps] only.
enum TrackingType {
  weightReps,
  bodyweightReps,
  reps,
  time,
  distanceTime,
  weightTime,
}

enum Equipment {
  barbell,
  dumbbell,
  machine,
  cable,
  bodyweight,
  band,
  kettlebell,
  other,
}

/// Fixed taxonomy, not free text, because sets-per-muscle-per-week
/// (`F-ANA-005`) and muscle balance (`F-ANA-008`) aggregate over it.
enum Muscle {
  chest,
  frontDelts,
  sideDelts,
  rearDelts,
  lats,
  traps,
  upperBack,
  lowerBack,
  biceps,
  triceps,
  forearms,
  quads,
  hamstrings,
  glutes,
  calves,
  adductors,
  abductors,
  abs,
  obliques,
  neck,
  fullBody,
}

/// **Only [warmup] is excluded from analytics.** Everything else counts.
///
/// This distinction must exist in v1: the information cannot be recovered
/// afterwards, and without it every volume, PR and e1RM figure in the app is
/// quietly wrong from the first session
/// (docs/40-ANALYTICS-SPEC.md §universal preconditions).
enum SetType { warmup, working, drop, failure, amrap, backoff }

/// Whether a weight is entered as total load or per side (`F-LOG-017`).
///
/// Storage is **always** total. "Dumbbell press 30 kg" means 30 per hand to a
/// person and 60 to a volume calculation; getting this wrong doubles or halves
/// every derived figure.
enum WeightEntryMode { total, perSide }

/// The sensible default entry mode for a newly created exercise of
/// [equipment] (`F-LOG-017` §2). Dumbbells are held one per hand, so
/// "30 kg" means per hand to whoever racks them; everything else defaults to
/// the number already on the plate or the stack, which is total.
WeightEntryMode defaultWeightEntryModeFor(Equipment equipment) =>
    equipment == Equipment.dumbbell
    ? WeightEntryMode.perSide
    : WeightEntryMode.total;

/// Body measurement kinds. `valueCanonical` means grams for masses,
/// millimetres for lengths, basis points for percentages — fixed per kind.
enum MeasurementType {
  bodyweight,
  waist,
  chest,
  hips,
  neck,
  leftArm,
  rightArm,
  leftThigh,
  rightThigh,
  leftCalf,
  rightCalf,
  shoulders,
  bodyFatPercent,
}

/// Personal-record kinds (docs/40-ANALYTICS-SPEC.md §4).
enum PrKind { maxWeight, maxRepsAtWeight, bestE1rm, maxSessionVolume }

/// Where an exercise's load actually comes from (`F-PLT-005`).
///
/// Decides what the plate calculator shows and what `F-PRG-012`'s
/// plate-aware rounding snaps a proposed weight to — a barbell assembles
/// arbitrary plate combinations, a dumbbell rack only offers whatever
/// discrete weights it stocks, and a stack machine only offers whatever the
/// pin (plus an optional add-on magnet) can reach.
enum WeightSource { plateLoaded, fixedIncrement, stack }

/// The sensible default weight source for a newly created exercise of
/// [equipment] — the same "reasonable guess, always overridable" shape as
/// [defaultWeightEntryModeFor].
WeightSource defaultWeightSourceFor(Equipment equipment) => switch (equipment) {
  Equipment.dumbbell || Equipment.kettlebell => WeightSource.fixedIncrement,
  Equipment.machine || Equipment.cable => WeightSource.stack,
  _ => WeightSource.plateLoaded,
};
