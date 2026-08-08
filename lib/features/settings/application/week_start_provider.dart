import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/units/week_start.dart';
import 'unit_preferences_provider.dart';

/// The first-day-of-week preference (`F-SET-005`).
///
/// Scalar setting, so [SharedPreferences] rather than the database, same
/// reasoning as [unitPreferencesProvider]. First-run default is inferred
/// from the device locale via [WeekStart.forCountry]; afterwards the stored
/// value wins, so a later locale change never silently shifts someone's
/// weekly charts.
final weekStartProvider = NotifierProvider<WeekStartNotifier, WeekStart>(
  WeekStartNotifier.new,
);

class WeekStartNotifier extends Notifier<WeekStart> {
  static const _key = 'analytics.weekStartWeekday';

  @override
  WeekStart build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final stored = prefs.getInt(_key);
    if (stored != null &&
        stored >= DateTime.monday &&
        stored <= DateTime.sunday) {
      return WeekStart(stored);
    }
    return WeekStart.forCountry(ref.watch(deviceCountryProvider));
  }

  Future<void> set(WeekStart weekStart) async {
    state = weekStart;
    await ref.read(sharedPreferencesProvider).setInt(_key, weekStart.weekday);
  }
}
