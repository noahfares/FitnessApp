import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/health/health_connect_import.dart';

void main() {
  group('shouldImportHealthConnectReading', () {
    test('imports a day with no manual entry', () {
      expect(
        shouldImportHealthConnectReading(
          candidateLocalDate: DateTime(2026, 3, 5),
          manuallyMeasuredLocalDates: {DateTime(2026, 3, 4)},
        ),
        isTrue,
      );
    });

    test('skips a day that already has a manual entry', () {
      expect(
        shouldImportHealthConnectReading(
          candidateLocalDate: DateTime(2026, 3, 5),
          manuallyMeasuredLocalDates: {DateTime(2026, 3, 5)},
        ),
        isFalse,
      );
    });

    test('imports when there are no manual entries at all', () {
      expect(
        shouldImportHealthConnectReading(
          candidateLocalDate: DateTime(2026, 3, 5),
          manuallyMeasuredLocalDates: {},
        ),
        isTrue,
      );
    });

    test('ignores time-of-day on both sides — only the date matters', () {
      expect(
        shouldImportHealthConnectReading(
          candidateLocalDate: DateTime(2026, 3, 5, 23, 45),
          manuallyMeasuredLocalDates: {DateTime(2026, 3, 5, 6, 30)},
        ),
        isFalse,
      );
    });
  });
}
