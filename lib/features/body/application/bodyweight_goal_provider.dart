/// A bodyweight goal (`F-BOD-003` §4).
///
/// One number, in canonical grams, stored beside the other scalar preferences
/// rather than in the database: it is a display annotation on a chart, not a
/// logged measurement, and giving it a table would invite it into analytics
/// where it does not belong.
///
/// Deliberately narrower than `F-BOD-005` (goals in general, still unscheduled
/// and still an idea): this is the one goal §4 actually names, and the chart
/// that needed it exists today.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/application/unit_preferences_provider.dart'
    show sharedPreferencesProvider;

const String bodyweightGoalKey = 'body.bodyweightGoalGrams';

final bodyweightGoalProvider = NotifierProvider<BodyweightGoalNotifier, int?>(
  BodyweightGoalNotifier.new,
);

class BodyweightGoalNotifier extends Notifier<int?> {
  @override
  int? build() =>
      ref.watch(sharedPreferencesProvider).getInt(bodyweightGoalKey);

  /// Null clears it — a goal you no longer have should leave no line behind.
  Future<void> set(int? grams) async {
    state = grams;
    final prefs = ref.read(sharedPreferencesProvider);
    if (grams == null) {
      await prefs.remove(bodyweightGoalKey);
      return;
    }
    await prefs.setInt(bodyweightGoalKey, grams);
  }
}
