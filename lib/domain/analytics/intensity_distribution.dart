/// Rep-range and intensity distribution (`F-ANA-011`),
/// `docs/40-ANALYTICS-SPEC.md` §10.
///
/// Pure Dart.
library;

import 'e1rm.dart';

enum RepRangeBucket {
  strength,
  strengthHypertrophy,
  hypertrophy,
  hypertrophyEndurance,
  endurance,
}

/// `1–3` strength · `4–6` strength/hypertrophy · `7–12` hypertrophy ·
/// `13–20` hypertrophy/endurance · `21+` endurance (§10 rep-range buckets).
RepRangeBucket repRangeBucketFor(int reps) {
  if (reps <= 3) return RepRangeBucket.strength;
  if (reps <= 6) return RepRangeBucket.strengthHypertrophy;
  if (reps <= 12) return RepRangeBucket.hypertrophy;
  if (reps <= 20) return RepRangeBucket.hypertrophyEndurance;
  return RepRangeBucket.endurance;
}

/// Counts of [reps] by [repRangeBucketFor].
Map<RepRangeBucket, int> repRangeDistribution(List<int> reps) {
  final result = {for (final b in RepRangeBucket.values) b: 0};
  for (final r in reps) {
    final bucket = repRangeBucketFor(r);
    result[bucket] = result[bucket]! + 1;
  }
  return result;
}

enum IntensityZone { under60, from60to70, from70to80, from80to90, over90 }

/// `<60%` · `60–70%` · `70–80%` · `80–90%` · `90%+` of [e1rmGrams] (§10
/// intensity zones). Null when [e1rmGrams] is not a usable baseline (§10
/// rule 2) — the set is excluded, never bucketed as zero.
IntensityZone? intensityZoneFor({
  required int weightGrams,
  required int? e1rmGrams,
}) {
  if (e1rmGrams == null || e1rmGrams <= 0) return null;
  final pct = weightGrams / e1rmGrams;
  if (pct < 0.6) return IntensityZone.under60;
  if (pct < 0.7) return IntensityZone.from60to70;
  if (pct < 0.8) return IntensityZone.from70to80;
  if (pct < 0.9) return IntensityZone.from80to90;
  return IntensityZone.over90;
}

/// One weight×reps set, dated, for one exercise — the shape
/// [intensityZoneDistribution] groups and orders by.
class IntensitySample {
  const IntensitySample({
    required this.exerciseId,
    required this.date,
    required this.weightGrams,
    required this.reps,
    this.rpe,
  });

  final String exerciseId;
  final DateTime date;
  final int weightGrams;
  final int reps;

  /// Set when logged with RPE (`F-LOG-014`) — feeds [rpeDistribution], the
  /// more honest intensity measure §10 rule 3 prefers alongside the
  /// e1RM-based zones.
  final double? rpe;
}

/// Counts of sets by their logged RPE, wherever [IntensitySample.rpe] is set
/// (§10 rule 3). Sets with no RPE are excluded, not bucketed as zero.
Map<double, int> rpeDistribution(List<IntensitySample> samples) {
  final result = <double, int>{};
  for (final s in samples) {
    final rpe = s.rpe;
    if (rpe == null) continue;
    result[rpe] = (result[rpe] ?? 0) + 1;
  }
  return result;
}

/// Buckets [samples] by [IntensityZone], using each set's own exercise's
/// best e1RM as of *before* that set's session (§10 rule 1) — a set from an
/// exercise's first-ever session has no prior baseline and is excluded
/// (§10 rule 2), never classified against a same-day or future e1RM.
Map<IntensityZone, int> intensityZoneDistribution(
  List<IntensitySample> samples,
) {
  final byExercise = <String, List<IntensitySample>>{};
  for (final s in samples) {
    byExercise.putIfAbsent(s.exerciseId, () => []).add(s);
  }

  final result = {for (final z in IntensityZone.values) z: 0};
  for (final list in byExercise.values) {
    final sorted = [...list]..sort((a, b) => a.date.compareTo(b.date));
    DateTime? lastDate;
    int? bestE1rmBeforeToday;
    int? bestE1rmToday;

    for (final s in sorted) {
      if (lastDate != null && s.date != lastDate) {
        // A new session started: fold yesterday's best into the running
        // baseline before classifying anything in today's session.
        if (bestE1rmToday != null) {
          bestE1rmBeforeToday = bestE1rmBeforeToday == null
              ? bestE1rmToday
              : (bestE1rmToday > bestE1rmBeforeToday
                    ? bestE1rmToday
                    : bestE1rmBeforeToday);
        }
        bestE1rmToday = null;
      }
      lastDate = s.date;

      final zone = intensityZoneFor(
        weightGrams: s.weightGrams,
        e1rmGrams: bestE1rmBeforeToday,
      );
      if (zone != null) result[zone] = result[zone]! + 1;

      final setE1rm = epley1Rm(weightGrams: s.weightGrams, reps: s.reps);
      if (setE1rm != null) {
        bestE1rmToday = bestE1rmToday == null || setE1rm > bestE1rmToday
            ? setE1rm
            : bestE1rmToday;
      }
    }
  }
  return result;
}
