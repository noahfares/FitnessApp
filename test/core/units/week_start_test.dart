import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/units/week_start.dart';

/// Batch 3.3 — `F-SET-005`.
void main() {
  group('weekStartFor', () {
    test('Monday start — a Wednesday belongs to the Monday before it', () {
      // 2026-08-05 is a Wednesday.
      expect(
        WeekStart.monday.weekStartFor(DateTime(2026, 8, 5)),
        DateTime(2026, 8, 3),
      );
    });

    test('Monday start — a Monday is its own week start', () {
      expect(
        WeekStart.monday.weekStartFor(DateTime(2026, 8, 3)),
        DateTime(2026, 8, 3),
      );
    });

    test(
      'Sunday start — the same Wednesday belongs to the Sunday before it',
      () {
        expect(
          WeekStart.sunday.weekStartFor(DateTime(2026, 8, 5)),
          DateTime(2026, 8, 2),
        );
      },
    );

    test('Sunday start — a Sunday is its own week start', () {
      expect(
        WeekStart.sunday.weekStartFor(DateTime(2026, 8, 2)),
        DateTime(2026, 8, 2),
      );
    });

    test('discards time of day', () {
      expect(
        WeekStart.monday.weekStartFor(DateTime(2026, 8, 5, 23, 59)),
        DateTime(2026, 8, 3),
      );
    });
  });

  group('WeekStart.forCountry', () {
    test('US defaults to Sunday', () {
      expect(WeekStart.forCountry('US'), WeekStart.sunday);
    });

    test('Saudi Arabia defaults to Saturday', () {
      expect(WeekStart.forCountry('SA'), WeekStart.saturday);
    });

    test('unrecognised or null country defaults to Monday', () {
      expect(WeekStart.forCountry('DE'), WeekStart.monday);
      expect(WeekStart.forCountry(null), WeekStart.monday);
    });
  });
}
