import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/timing/stopwatch.dart';

/// `F-TIM-009`.
void main() {
  test('elapsed time is derived from the start timestamp, not accumulated', () {
    final watch = LogStopwatch.start(1000);

    expect(watch.elapsedSecondsAt(1000), 0);
    expect(watch.elapsedSecondsAt(1000 + 45000), 45);
    // A gap the app was backgrounded for is not lost — it's just the
    // difference between two timestamps.
    expect(watch.elapsedSecondsAt(1000 + 3600000), 3600);
  });

  test('a clock that moved backward never reads negative', () {
    final watch = LogStopwatch.start(10000);
    expect(watch.elapsedSecondsAt(5000), 0);
  });
}
