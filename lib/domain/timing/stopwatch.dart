/// A count-up stopwatch for timed exercises (`F-TIM-009`).
///
/// Pure Dart, the same "value derived from a timestamp" shape `RestTimer`
/// already uses: elapsed time is `now - startedAtMs`, so nothing drifts if
/// the app loses a frame or two while backgrounded mid-hold.
library;

class LogStopwatch {
  const LogStopwatch._({required this.startedAtMs});

  factory LogStopwatch.start(int nowMs) => LogStopwatch._(startedAtMs: nowMs);

  final int startedAtMs;

  /// Never negative — a clock that moved backward reads as "just started"
  /// rather than a negative duration.
  int elapsedSecondsAt(int nowMs) {
    final ms = nowMs - startedAtMs;
    return ms < 0 ? 0 : ms ~/ 1000;
  }
}
