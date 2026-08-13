/// Stall detection (`F-ANA-009`), `docs/40-ANALYTICS-SPEC.md` §7.
///
/// Pure Dart. Charts require going looking; stalling is exactly the thing
/// you don't notice from inside it.
library;

import 'linear_regression.dart';

/// One session's estimated 1RM, oldest-first ordering is the caller's job.
class SessionE1rm {
  const SessionE1rm({required this.date, required this.e1rmGrams});

  final DateTime date;
  final int e1rmGrams;
}

class StallVerdict {
  const StallVerdict({
    required this.stalled,
    required this.slopeGramsPerSession,
    required this.windowSize,
  });

  final bool stalled;

  /// Least-squares slope of e1RM against session index, over the window
  /// actually used.
  final double slopeGramsPerSession;

  final int windowSize;
}

/// `null` when there are fewer than [minSessions] sessions at all — silence,
/// not a guess (§7 rule 1). Otherwise a verdict, computed over the trailing
/// [windowSize] sessions (or every session, if fewer than that many exist).
///
/// Stalled requires **both** a flat-or-negative slope and a window spanning
/// at least [minSpan] (§7 rule 3) — a lift trained twice in one week must
/// not be flagged just because two points alone can't show progress yet.
/// [sessions] must already be sorted oldest first.
StallVerdict? detectStall(
  List<SessionE1rm> sessions, {
  int windowSize = 8,
  int minSessions = 5,
  int thresholdGramsPerSession = 100, // 0.1 kg/session (§7 rule 3)
  Duration minSpan = const Duration(days: 21),
}) {
  if (sessions.length < minSessions) return null;

  final window = sessions.length > windowSize
      ? sessions.sublist(sessions.length - windowSize)
      : sessions;

  final xs = [for (var i = 0; i < window.length; i++) i.toDouble()];
  final ys = [for (final s in window) s.e1rmGrams.toDouble()];
  final line = linearRegression(xs, ys);
  // Every x is the same session index by construction, so this is
  // unreachable in practice — window.length >= minSessions >= 2 always
  // gives distinct indices. Guarded anyway rather than assuming.
  final slope = line?.slope ?? 0;

  final span = window.last.date.difference(window.first.date);
  final stalled = slope <= thresholdGramsPerSession && span >= minSpan;

  return StallVerdict(
    stalled: stalled,
    slopeGramsPerSession: slope,
    windowSize: window.length,
  );
}
