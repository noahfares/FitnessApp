import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/logging/rpe.dart';
import 'unit_preferences_provider.dart';

/// RPE preferences (`F-LOG-014` §2–§3).
///
/// Scalar settings, so [SharedPreferences] rather than the database, same
/// reasoning as [restTimerSettingsProvider] — resolved synchronously off the
/// already-loaded instance, since every set row in the logger reads
/// [RpeSettings.enabled] to decide whether to render at all.
final rpeSettingsProvider = NotifierProvider<RpeSettingsNotifier, RpeSettings>(
  RpeSettingsNotifier.new,
);

class RpeSettingsNotifier extends Notifier<RpeSettings> {
  static const _enabledKey = 'rpe.enabled';
  static const _displayModeKey = 'rpe.displayMode';

  @override
  RpeSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    const defaults = RpeSettings();
    return RpeSettings(
      enabled: prefs.getBool(_enabledKey) ?? defaults.enabled,
      displayMode: _readMode(prefs) ?? defaults.displayMode,
    );
  }

  Future<void> setEnabled({required bool enabled}) async {
    state = state.copyWith(enabled: enabled);
    await ref.read(sharedPreferencesProvider).setBool(_enabledKey, enabled);
  }

  Future<void> setDisplayMode(RpeDisplayMode mode) async {
    state = state.copyWith(displayMode: mode);
    await ref
        .read(sharedPreferencesProvider)
        .setString(_displayModeKey, mode.name);
  }

  /// An unrecognised stored value means a downgrade or a corrupt write; the
  /// default is a better answer than throwing.
  static RpeDisplayMode? _readMode(SharedPreferences prefs) {
    final stored = prefs.getString(_displayModeKey);
    if (stored == null) return null;
    for (final mode in RpeDisplayMode.values) {
      if (mode.name == stored) return mode;
    }
    return null;
  }
}
