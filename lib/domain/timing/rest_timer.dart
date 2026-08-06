/// The rest timer, as a value (`F-TIM-001`).
///
/// Pure Dart, and deliberately **not** a ticking object. The timer is a target
/// timestamp plus the duration it was started with; everything else — how much
/// is left, how far through it is, whether it has fired — is a function of
/// "now" (`F-TIM-001` §4).
///
/// That is the whole trick. A decrementing counter loses a second for every
/// frame the app did not get, so it drifts exactly when it matters: phone in a
/// pocket, screen off, doze active. Deriving from a timestamp cannot drift,
/// because nothing about the state changes while the app is asleep.
library;

/// What the timer is doing. There is no `finished` state: a running timer whose
/// target has passed *is* finished, and asking is [RestTimer.hasFiredAt].
enum RestTimerStatus { idle, running, paused }

/// An immutable rest-timer state.
class RestTimer {
  const RestTimer._({
    required this.status,
    required this.totalMs,
    this.endsAtMs,
    this.pausedRemainingMs,
    this.startedBySetId,
  });

  /// Nothing is resting.
  static const RestTimer idle = RestTimer._(
    status: RestTimerStatus.idle,
    totalMs: 0,
  );

  /// A timer of [seconds], targeting [nowMs] + [seconds].
  ///
  /// [setId] records which set completion started it, so that un-ticking that
  /// same set can cancel it and un-ticking a different one cannot
  /// (`F-TIM-002` §5).
  factory RestTimer.start({
    required int seconds,
    required int nowMs,
    String? setId,
  }) {
    final totalMs = (seconds < 0 ? 0 : seconds) * 1000;
    return RestTimer._(
      status: RestTimerStatus.running,
      totalMs: totalMs,
      endsAtMs: nowMs + totalMs,
      startedBySetId: setId,
    );
  }

  final RestTimerStatus status;

  /// The full duration this timer is counting down, in milliseconds. Grows and
  /// shrinks with [adjusted] so that [progressAt] stays honest.
  final int totalMs;

  /// Wall-clock target, UTC ms. Null while paused and while idle.
  final int? endsAtMs;

  /// What was left at the moment of the pause. Null unless paused.
  final int? pausedRemainingMs;

  /// The set whose completion auto-started this timer (`F-TIM-002`), or null
  /// for one started by hand.
  final String? startedBySetId;

  bool get isRunning => status == RestTimerStatus.running;
  bool get isPaused => status == RestTimerStatus.paused;
  bool get isIdle => status == RestTimerStatus.idle;

  /// Whether the bar should be on screen at [nowMs] — running-and-unfired, or
  /// paused. A fired timer is not shown, which is also what keeps a relaunch
  /// from rendering a stale countdown (`F-TIM-001` acceptance).
  bool isVisibleAt(int nowMs) => isPaused || (isRunning && !hasFiredAt(nowMs));

  Duration get total => Duration(milliseconds: totalMs);

  /// How much is left at [nowMs], never negative.
  Duration remainingAt(int nowMs) =>
      Duration(milliseconds: _remainingMsAt(nowMs));

  int _remainingMsAt(int nowMs) {
    switch (status) {
      case RestTimerStatus.idle:
        return 0;
      case RestTimerStatus.paused:
        return pausedRemainingMs ?? 0;
      case RestTimerStatus.running:
        final left = (endsAtMs ?? nowMs) - nowMs;
        return left < 0 ? 0 : left;
    }
  }

  /// True once the target has passed. Always false while paused — a paused
  /// timer cannot reach zero on its own.
  bool hasFiredAt(int nowMs) =>
      isRunning && (endsAtMs == null || nowMs >= endsAtMs!);

  /// Fraction elapsed, 0 → 1, for the progress bar. A zero-length timer reads
  /// as complete rather than dividing by zero.
  double progressAt(int nowMs) {
    if (isIdle || totalMs <= 0) return 1;
    final done = totalMs - _remainingMsAt(nowMs);
    if (done <= 0) return 0;
    if (done >= totalMs) return 1;
    return done / totalMs;
  }

  /// Freezes the countdown, keeping what is left.
  RestTimer pausedAt(int nowMs) {
    if (!isRunning) return this;
    return RestTimer._(
      status: RestTimerStatus.paused,
      totalMs: totalMs,
      pausedRemainingMs: _remainingMsAt(nowMs),
      startedBySetId: startedBySetId,
    );
  }

  /// Resumes from what was left, targeting that far past [nowMs].
  RestTimer resumedAt(int nowMs) {
    if (!isPaused) return this;
    return RestTimer._(
      status: RestTimerStatus.running,
      totalMs: totalMs,
      endsAtMs: nowMs + (pausedRemainingMs ?? 0),
      startedBySetId: startedBySetId,
    );
  }

  /// Back to the top, still running (`F-TIM-001` §2 "reset").
  RestTimer restartedAt(int nowMs) {
    if (isIdle) return this;
    return RestTimer._(
      status: RestTimerStatus.running,
      totalMs: totalMs,
      endsAtMs: nowMs + totalMs,
      startedBySetId: startedBySetId,
    );
  }

  /// ±[deltaSeconds] while running or paused (`F-TIM-001` §2).
  ///
  /// [totalMs] moves with the remaining time rather than staying fixed, so that
  /// adding 15 s does not make the progress bar jump backwards — the elapsed
  /// portion is untouched by an adjustment, and only the target moves.
  /// Subtracting past zero clamps: it ends the rest, it does not owe time.
  RestTimer adjusted(int deltaSeconds, {required int nowMs}) {
    if (isIdle) return this;

    final remaining = _remainingMsAt(nowMs);
    var next = remaining + deltaSeconds * 1000;
    if (next < 0) next = 0;
    final newTotal = totalMs + (next - remaining);

    return isPaused
        ? RestTimer._(
            status: RestTimerStatus.paused,
            totalMs: newTotal,
            pausedRemainingMs: next,
            startedBySetId: startedBySetId,
          )
        : RestTimer._(
            status: RestTimerStatus.running,
            totalMs: newTotal,
            endsAtMs: nowMs + next,
            startedBySetId: startedBySetId,
          );
  }

  @override
  bool operator ==(Object other) =>
      other is RestTimer &&
      other.status == status &&
      other.totalMs == totalMs &&
      other.endsAtMs == endsAtMs &&
      other.pausedRemainingMs == pausedRemainingMs &&
      other.startedBySetId == startedBySetId;

  @override
  int get hashCode =>
      Object.hash(status, totalMs, endsAtMs, pausedRemainingMs, startedBySetId);

  @override
  String toString() =>
      'RestTimer(${status.name}, total: ${totalMs}ms, endsAt: $endsAtMs)';
}

/// `m:ss` for a countdown — no hour field, unlike the session clock, because a
/// rest interval that ran past an hour is a forgotten timer, not a rest.
///
/// Minutes are unpadded so the figure stays as wide as the display type allows
/// at arm's length (`F-TIM-001` §3); an hour or more clamps to `59:59` rather
/// than growing a third field and reflowing the bar.
String formatCountdown(Duration remaining) {
  final clamped = remaining.isNegative ? Duration.zero : remaining;
  final capped = clamped.inSeconds > 3599 ? 3599 : clamped.inSeconds;
  final minutes = capped ~/ 60;
  final seconds = (capped % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
