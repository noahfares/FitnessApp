/// Sessions per week someone is aiming for (`F-ANA-006` §5 rule 2).
///
/// A setting rather than a fixed 3, because a streak measured against a number
/// nobody chose is a number nobody believes. Persisted the same way as
/// `WeekStart` and the RPE settings — one scalar, `SharedPreferences`, no
/// database row.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'unit_preferences_provider.dart' show sharedPreferencesProvider;

const String weeklyTargetKey = 'consistency.weeklyTarget';

/// Three sessions a week: the most common recommendation for a full-body or
/// upper/lower split, and low enough that the default is achievable rather
/// than aspirational — a target nobody hits is a shame machine (§5 rule 4).
const int defaultWeeklyTarget = 3;

final weeklyTargetProvider = NotifierProvider<WeeklyTargetNotifier, int>(
  WeeklyTargetNotifier.new,
);

class WeeklyTargetNotifier extends Notifier<int> {
  @override
  int build() =>
      ref.watch(sharedPreferencesProvider).getInt(weeklyTargetKey) ??
      defaultWeeklyTarget;

  Future<void> set(int sessions) async {
    final clamped = sessions.clamp(1, 14);
    state = clamped;
    await ref.read(sharedPreferencesProvider).setInt(weeklyTargetKey, clamped);
  }
}
