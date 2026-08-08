import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The "now" every chart's date range (`F-ANA-015`) resolves against.
///
/// Overridable in tests the same way `restClockProvider` is — without this
/// seam, a chart's default range would depend on the real wall clock, making
/// any test that logs a fixed date and expects it to fall inside "the last 3
/// months" flaky the moment the suite runs more than a few months later.
final analyticsClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);
