/// Session duration trend and rest compliance (`F-ANA-012`,
/// `docs/40-ANALYTICS-SPEC.md` §15).
library;

class SessionDurationPoint {
  const SessionDurationPoint({
    required this.date,
    required this.durationSeconds,
  });

  final DateTime date;
  final int durationSeconds;
}

/// Oldest-to-newest, one point per **finished** session — the in-progress
/// session (`endedAt` null) is excluded, the same boundary discipline every
/// other metric applies to counted sets, extended here to whole sessions.
List<SessionDurationPoint> sessionDurationTrend(
  List<({DateTime date, int startedAtMs, int? endedAtMs})> sessions,
) {
  final points = [
    for (final session in sessions)
      if (session.endedAtMs case final endedAtMs?)
        SessionDurationPoint(
          date: session.date,
          durationSeconds: (endedAtMs - session.startedAtMs) ~/ 1000,
        ),
  ];
  points.sort((a, b) => a.date.compareTo(b.date));
  return points;
}

class RestComplianceRecord {
  const RestComplianceRecord({
    required this.actualSeconds,
    required this.prescribedSeconds,
  });

  final int actualSeconds;
  final int prescribedSeconds;
}

/// `actualSeconds / prescribedSeconds`, averaged across [records] —
/// `1.0` is exact compliance, below under-resting, above over-resting.
/// `null` for an empty sample rather than a misleading `0.0` or `1.0`.
double? averageRestComplianceRatio(List<RestComplianceRecord> records) {
  if (records.isEmpty) return null;
  final ratios = [
    for (final r in records)
      if (r.prescribedSeconds > 0) r.actualSeconds / r.prescribedSeconds,
  ];
  if (ratios.isEmpty) return null;
  return ratios.reduce((a, b) => a + b) / ratios.length;
}
