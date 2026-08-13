/// Body map heat intensity (`F-ANA-014`, `docs/40-ANALYTICS-SPEC.md` §16).
library;

import 'analytics_boundary.dart';
import 'analytics_set_record.dart';

/// Volume-load per muscle, attributed by primary muscle only — same rule
/// `F-ANA-004`'s weekly volume chart uses, and the same reason: §16 has no
/// fractional-secondary rule the way sets-per-muscle-per-week does.
/// `fullBody` contributes to no specific muscle, same as `F-ANA-005` §3
/// rule 4.
Map<String, int> volumeByMuscle(List<AnalyticsSetRecord> records) {
  final totals = <String, int>{};
  for (final record in records) {
    if (!isCountedSet(
      setType: record.setType,
      isCompleted: record.isCompleted,
    )) {
      continue;
    }
    if (record.primaryMuscle == 'fullBody') continue;
    final weight = record.weightGrams;
    final reps = record.reps;
    if (weight == null || reps == null) continue;
    final volume = weight * reps;
    totals[record.primaryMuscle] = (totals[record.primaryMuscle] ?? 0) + volume;
  }
  return totals;
}

/// `volume(muscle) / max(volume(m) for m in all trained muscles)` — the
/// hottest-trained muscle in [records] is always `1.0`, everything else
/// scaled relative to it. A muscle with no volume has no key (excluded, not
/// zero — `null` intensity reads as "not trained", never "cold").
Map<String, double> muscleHeatIntensity(List<AnalyticsSetRecord> records) {
  final volumes = volumeByMuscle(records);
  if (volumes.isEmpty) return const {};
  final maxVolume = volumes.values.reduce((a, b) => a > b ? a : b);
  if (maxVolume <= 0) return const {};
  return {
    for (final entry in volumes.entries) entry.key: entry.value / maxVolume,
  };
}
