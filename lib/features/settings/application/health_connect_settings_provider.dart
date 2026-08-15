import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'unit_preferences_provider.dart';

/// Whether Health Connect sync is turned on (`F-HLT-001` §2, `F-HLT-002`).
///
/// Off by default — explicitly opt-in, per both features' own spec. A
/// scalar preference, [SharedPreferences] rather than the database, the
/// same reasoning [rpeSettingsProvider] already uses. This flag alone gates
/// both directions: no workout is written and no bodyweight is read while
/// it is off, regardless of whatever permissions Health Connect itself
/// still holds from an earlier session.
final healthConnectEnabledProvider =
    NotifierProvider<HealthConnectEnabledNotifier, bool>(
      HealthConnectEnabledNotifier.new,
    );

class HealthConnectEnabledNotifier extends Notifier<bool> {
  static const _key = 'healthConnect.enabled';

  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_key) ?? false;

  Future<void> setEnabled({required bool enabled}) async {
    state = enabled;
    await ref.read(sharedPreferencesProvider).setBool(_key, enabled);
  }
}
