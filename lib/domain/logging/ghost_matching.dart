/// Pairing this session's set rows with last session's (`F-LOG-004`).
///
/// Pure Dart, and deliberately separate from the query that fetches last
/// session: which previous set belongs against which current row is a rule
/// worth testing on its own, and it is the part that is easy to get quietly
/// wrong.
library;

/// For each entry of [currentTypes], the index into [previousTypes] whose
/// values should be shown as the ghost, or null when there is none.
///
/// Two rules, both from `F-LOG-004`:
///
/// - **Matched by index** (§1) — the *n*th set against the *n*th set. Matching
///   by "best set" was considered and rejected as the default: it makes the
///   ghost move around between sessions, and the number people are chasing is
///   what they did in that slot last time.
/// - **Warm-ups match warm-ups, counted sets match counted sets** (§6), never
///   across. The index is therefore an ordinal *within its class*: a warm-up
///   inserted at the top of today's session must not shunt every working ghost
///   down a row.
///
/// A previous session with fewer sets leaves the later rows with no ghost (§5)
/// rather than repeating the last one, which would read as a target nobody set.
List<int?> matchGhostIndices({
  required List<String> currentTypes,
  required List<String> previousTypes,
}) {
  final warmups = <int>[];
  final counted = <int>[];
  for (var i = 0; i < previousTypes.length; i++) {
    (previousTypes[i] == 'warmup' ? warmups : counted).add(i);
  }

  var nextWarmup = 0;
  var nextCounted = 0;
  return [
    for (final type in currentTypes)
      if (type == 'warmup')
        nextWarmup < warmups.length ? warmups[nextWarmup++] : null
      else
        nextCounted < counted.length ? counted[nextCounted++] : null,
  ];
}
