/// Health-platform integration state (`F-HLT-001`, `F-HLT-002`).
///
/// Two independent switches, both **off by default** and both persisted:
/// writing workouts out, and reading bodyweight in. They are separate because
/// they are separate decisions — plenty of people want their sessions to show
/// up in Health Connect without letting an app read anything back.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/application/unit_preferences_provider.dart'
    show sharedPreferencesProvider;

const String healthWriteEnabledKey = 'health.writeWorkouts';
const String healthReadEnabledKey = 'health.readBodyweight';

final healthWriteEnabledProvider =
    NotifierProvider<HealthWriteEnabledNotifier, bool>(
      HealthWriteEnabledNotifier.new,
    );

class HealthWriteEnabledNotifier extends Notifier<bool> {
  @override
  bool build() =>
      ref.watch(sharedPreferencesProvider).getBool(healthWriteEnabledKey) ??
      false;

  Future<void> set(bool enabled) async {
    state = enabled;
    await ref
        .read(sharedPreferencesProvider)
        .setBool(healthWriteEnabledKey, enabled);
  }
}

final healthReadEnabledProvider =
    NotifierProvider<HealthReadEnabledNotifier, bool>(
      HealthReadEnabledNotifier.new,
    );

class HealthReadEnabledNotifier extends Notifier<bool> {
  @override
  bool build() =>
      ref.watch(sharedPreferencesProvider).getBool(healthReadEnabledKey) ??
      false;

  Future<void> set(bool enabled) async {
    state = enabled;
    await ref
        .read(sharedPreferencesProvider)
        .setBool(healthReadEnabledKey, enabled);
  }
}
