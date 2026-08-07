import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/timing/rest_timer.dart';

/// The rest timer as a value (`F-TIM-001`).
///
/// Plain Dart, no clock: every question takes "now" as an argument, which is
/// what makes "the phone was asleep for four minutes" a single integer in a
/// test rather than a device and a stopwatch.
void main() {
  const t0 = 1000000000000;

  group('countdown (F-TIM-001 §1)', () {
    test('starts at the full duration', () {
      final timer = RestTimer.start(seconds: 90, nowMs: t0);

      expect(timer.isRunning, isTrue);
      expect(timer.remainingAt(t0), const Duration(seconds: 90));
      expect(timer.progressAt(t0), 0);
    });

    test('derives from the target, so a missed tick costs nothing', () {
      final timer = RestTimer.start(seconds: 90, nowMs: t0);

      // Four minutes backgrounded, one question asked on resume. A decrementing
      // counter would be sitting at 90 (`F-TIM-001` §4, acceptance).
      expect(timer.remainingAt(t0 + 240000), Duration.zero);
      expect(timer.hasFiredAt(t0 + 240000), isTrue);
    });

    test('is accurate to the second across several minutes asleep', () {
      final timer = RestTimer.start(seconds: 300, nowMs: t0);

      expect(timer.remainingAt(t0 + 299000), const Duration(seconds: 1));
      expect(timer.remainingAt(t0 + 299999).inMilliseconds, 1);
    });

    test('never reports negative time left', () {
      final timer = RestTimer.start(seconds: 60, nowMs: t0);

      expect(timer.remainingAt(t0 + 600000), Duration.zero);
      expect(timer.progressAt(t0 + 600000), 1);
    });

    test('idle is idle, and shows nothing', () {
      expect(RestTimer.idle.isIdle, isTrue);
      expect(RestTimer.idle.remainingAt(t0), Duration.zero);
      expect(RestTimer.idle.isVisibleAt(t0), isFalse);
      expect(RestTimer.idle.hasFiredAt(t0), isFalse);
    });

    test('a fired timer is not shown — a relaunch must not look stale', () {
      final timer = RestTimer.start(seconds: 60, nowMs: t0);

      expect(timer.isVisibleAt(t0 + 59000), isTrue);
      expect(timer.isVisibleAt(t0 + 61000), isFalse);
    });
  });

  group('pause and resume (F-TIM-001 §2)', () {
    test('a pause freezes what is left, however long the pause runs', () {
      final paused = RestTimer.start(
        seconds: 90,
        nowMs: t0,
      ).pausedAt(t0 + 30000);

      expect(paused.isPaused, isTrue);
      expect(paused.remainingAt(t0 + 30000), const Duration(seconds: 60));
      expect(paused.remainingAt(t0 + 600000), const Duration(seconds: 60));
      // A paused timer cannot reach zero on its own.
      expect(paused.hasFiredAt(t0 + 600000), isFalse);
      expect(paused.isVisibleAt(t0 + 600000), isTrue);
    });

    test('resuming targets that far past now, not the original target', () {
      final resumed = RestTimer.start(
        seconds: 90,
        nowMs: t0,
      ).pausedAt(t0 + 30000).resumedAt(t0 + 600000);

      expect(resumed.isRunning, isTrue);
      expect(resumed.remainingAt(t0 + 600000), const Duration(seconds: 60));
      expect(resumed.hasFiredAt(t0 + 660000), isTrue);
    });

    test('restart goes back to the full duration', () {
      final restarted = RestTimer.start(
        seconds: 90,
        nowMs: t0,
      ).restartedAt(t0 + 80000);

      expect(restarted.remainingAt(t0 + 80000), const Duration(seconds: 90));
    });
  });

  group('±15 s (F-TIM-001 §2)', () {
    test('adding moves the target and the total together', () {
      final timer = RestTimer.start(
        seconds: 90,
        nowMs: t0,
      ).adjusted(15, nowMs: t0 + 30000);

      expect(timer.remainingAt(t0 + 30000), const Duration(seconds: 75));
      // The elapsed 30 s is untouched, so the progress bar does not jump back.
      expect(timer.total, const Duration(seconds: 105));
      expect(timer.progressAt(t0 + 30000), closeTo(30 / 105, 0.0001));
    });

    test('subtracting past zero clamps rather than owing time', () {
      final timer = RestTimer.start(
        seconds: 20,
        nowMs: t0,
      ).adjusted(-45, nowMs: t0 + 5000);

      expect(timer.remainingAt(t0 + 5000), Duration.zero);
      expect(timer.hasFiredAt(t0 + 5000), isTrue);
    });

    test('adjusting a paused timer keeps it paused', () {
      final timer = RestTimer.start(
        seconds: 90,
        nowMs: t0,
      ).pausedAt(t0 + 30000).adjusted(15, nowMs: t0 + 30000);

      expect(timer.isPaused, isTrue);
      expect(timer.remainingAt(t0 + 999999), const Duration(seconds: 75));
    });

    test('an idle timer ignores every control', () {
      expect(RestTimer.idle.adjusted(15, nowMs: t0), RestTimer.idle);
      expect(RestTimer.idle.pausedAt(t0), RestTimer.idle);
      expect(RestTimer.idle.restartedAt(t0), RestTimer.idle);
    });
  });

  group('which set started it (F-TIM-002 §5)', () {
    test('carries the set id through every transition', () {
      final timer = RestTimer.start(
        seconds: 90,
        nowMs: t0,
        setId: 'set-1',
      ).pausedAt(t0 + 1000).resumedAt(t0 + 2000).adjusted(15, nowMs: t0 + 3000);

      expect(timer.startedBySetId, 'set-1');
    });
  });

  group('formatCountdown', () {
    test('is m:ss, unpadded minutes', () {
      expect(formatCountdown(const Duration(seconds: 90)), '1:30');
      expect(formatCountdown(const Duration(seconds: 5)), '0:05');
      expect(formatCountdown(const Duration(minutes: 10)), '10:00');
    });

    test('clamps rather than growing an hour field', () {
      expect(formatCountdown(const Duration(hours: 2)), '59:59');
      expect(formatCountdown(const Duration(seconds: -5)), '0:00');
    });
  });
}
