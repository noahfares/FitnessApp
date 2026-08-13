import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/analytics/acwr.dart';
import 'package:fitness_app/domain/analytics/stall_detection.dart';
import 'package:fitness_app/domain/progression/deload_suggestion.dart';

/// `F-PRG-011`.
void main() {
  const stalled = StallVerdict(
    stalled: true,
    slopeGramsPerSession: 10,
    windowSize: 5,
  );
  const notStalled = StallVerdict(
    stalled: false,
    slopeGramsPerSession: 5000,
    windowSize: 5,
  );
  const rampedUp = AcwrResult(
    acuteGrams: 15000,
    chronicGrams: 10000,
    ratio: 1.5,
  );
  const normalLoad = AcwrResult(
    acuteGrams: 10000,
    chronicGrams: 10000,
    ratio: 1.0,
  );

  test('suggests only when both signals fire', () {
    final result = suggestDeload(stall: stalled, acwr: rampedUp);

    expect(result.suggested, isTrue);
    expect(result.reasons, hasLength(2));
  });

  test('stall alone does not suggest a deload', () {
    final result = suggestDeload(stall: stalled, acwr: normalLoad);

    expect(result.suggested, isFalse);
    expect(result.reasons, ['Progress has stalled over the trailing window.']);
  });

  test('ramped-up load alone does not suggest a deload', () {
    final result = suggestDeload(stall: notStalled, acwr: rampedUp);

    expect(result.suggested, isFalse);
    expect(result.reasons, hasLength(1));
  });

  test('neither signal present gives no suggestion and no reasons', () {
    final result = suggestDeload(stall: null, acwr: null);

    expect(result.suggested, isFalse);
    expect(result.reasons, isEmpty);
  });

  test('a null ACWR ratio (chronic == 0) is treated as no ramp-up', () {
    const zeroChronic = AcwrResult(
      acuteGrams: 10000,
      chronicGrams: 0,
      ratio: null,
    );
    final result = suggestDeload(stall: stalled, acwr: zeroChronic);

    expect(result.suggested, isFalse);
    expect(result.reasons, hasLength(1));
  });
}
