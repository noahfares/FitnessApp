import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/routines/rep_range.dart';

/// `F-ROU-003`.
void main() {
  group('formatRepRange', () {
    test('a real range renders as "min–max"', () {
      expect(formatRepRange(8, 12), '8–12');
    });

    test('min == max renders as a single value', () {
      expect(formatRepRange(8, 8), '8');
    });

    test('only one side set renders that side', () {
      expect(formatRepRange(8, null), '8');
      expect(formatRepRange(null, 12), '12');
    });

    test('neither side set renders empty — targets are optional', () {
      expect(formatRepRange(null, null), '');
    });
  });
}
