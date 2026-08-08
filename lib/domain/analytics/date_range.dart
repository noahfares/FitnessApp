/// Shared date range for every chart (`F-ANA-015`).
///
/// Plain Dart, not `package:flutter/material.dart`'s `DateTimeRange`
/// (docs/20-ARCHITECTURE.md's one hard rule).
library;

/// The six presets `F-ANA-015` names, in the order they're offered.
enum RangePreset { fourWeeks, threeMonths, sixMonths, oneYear, allTime, custom }

/// An inclusive `[start, end]` window.
class DateRange {
  const DateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  bool contains(DateTime date) => !date.isBefore(start) && !date.isAfter(end);
}

/// Resolves [preset] against [now]. [custom] is used only for
/// [RangePreset.custom]; falling back to "all time" if none was ever picked,
/// since an unset custom range should show something rather than nothing.
DateRange resolveRange(RangePreset preset, DateTime now, {DateRange? custom}) {
  switch (preset) {
    case RangePreset.fourWeeks:
      return DateRange(start: now.subtract(const Duration(days: 28)), end: now);
    case RangePreset.threeMonths:
      return DateRange(start: now.subtract(const Duration(days: 90)), end: now);
    case RangePreset.sixMonths:
      return DateRange(
        start: now.subtract(const Duration(days: 182)),
        end: now,
      );
    case RangePreset.oneYear:
      return DateRange(
        start: now.subtract(const Duration(days: 365)),
        end: now,
      );
    case RangePreset.allTime:
      return DateRange(start: DateTime.fromMillisecondsSinceEpoch(0), end: now);
    case RangePreset.custom:
      return custom ??
          DateRange(start: DateTime.fromMillisecondsSinceEpoch(0), end: now);
  }
}
