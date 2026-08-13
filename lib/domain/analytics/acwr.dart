/// Acute-to-chronic workload ratio (`F-ANA-010`),
/// `docs/40-ANALYTICS-SPEC.md` §8.
///
/// Pure Dart. Presented as information, never a warning — the injury-risk
/// literature behind ACWR is contested (§8 rule 4); this module only
/// computes the number, the presentation layer owns the framing.
library;

class AcwrResult {
  const AcwrResult({
    required this.acuteGrams,
    required this.chronicGrams,
    required this.ratio,
  });

  /// Σ volume load over the trailing 7 days.
  final int acuteGrams;

  /// (Σ volume load over the trailing 28 days) / 4.
  final double chronicGrams;

  /// Null when [chronicGrams] is zero — never a division by zero (§8 rule 2).
  final double? ratio;
}

/// `null` when [dailyVolumes] doesn't span at least 28 days as of [asOf]
/// (defaults to the latest date present) — below that, not shown (§8 rule 1).
AcwrResult? computeAcwr(
  List<({DateTime date, int volumeGrams})> dailyVolumes, {
  DateTime? asOf,
}) {
  if (dailyVolumes.isEmpty) return null;

  final sorted = [...dailyVolumes]..sort((a, b) => a.date.compareTo(b.date));
  final today = asOf ?? sorted.last.date;
  if (today.difference(sorted.first.date).inDays < 28) return null;

  final acuteStart = today.subtract(const Duration(days: 7));
  final chronicStart = today.subtract(const Duration(days: 28));

  var acute = 0;
  var chronicSum = 0;
  for (final d in sorted) {
    if (d.date.isAfter(today)) continue;
    if (!d.date.isBefore(chronicStart)) chronicSum += d.volumeGrams;
    if (!d.date.isBefore(acuteStart)) acute += d.volumeGrams;
  }

  final chronic = chronicSum / 4;
  return AcwrResult(
    acuteGrams: acute,
    chronicGrams: chronic,
    ratio: chronic == 0 ? null : acute / chronic,
  );
}
