import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/timing/rest_settings.dart';
import 'unit_preferences_provider.dart';

/// Rest-timer preferences (`F-SET-003`).
///
/// Scalar settings, so [SharedPreferences] rather than the database (per
/// `pubspec.yaml`: anything relational lives in SQLite). Resolved synchronously
/// off the already-loaded instance for the same reason unit preferences are —
/// every set completion reads [RestTimerSettings.autoStart], and an
/// `AsyncValue` on the hot path of the logger buys nothing.
final restTimerSettingsProvider =
    NotifierProvider<RestTimerSettingsNotifier, RestTimerSettings>(
      RestTimerSettingsNotifier.new,
    );

class RestTimerSettingsNotifier extends Notifier<RestTimerSettings> {
  static const _autoStartKey = 'rest.autoStart';
  static const _defaultSecondsKey = 'rest.defaultSeconds';
  static const _alertStyleKey = 'rest.alertStyle';
  static const _preWarningKey = 'rest.preWarning';

  @override
  RestTimerSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    const defaults = RestTimerSettings();

    // Absent means "automatic" — the built-in per-exercise defaults
    // (`F-TIM-005`). A stored 0 means the same thing and is treated as absent,
    // because a zero-second rest is nobody's intent.
    final storedSeconds = prefs.getInt(_defaultSecondsKey);

    return RestTimerSettings(
      autoStart: prefs.getBool(_autoStartKey) ?? defaults.autoStart,
      defaultSeconds: storedSeconds == null || storedSeconds <= 0
          ? null
          : storedSeconds,
      alertStyle: _readStyle(prefs) ?? defaults.alertStyle,
      preWarning: prefs.getBool(_preWarningKey) ?? defaults.preWarning,
    );
  }

  Future<void> setAutoStart({required bool enabled}) async {
    state = state.copyWith(autoStart: enabled);
    await ref.read(sharedPreferencesProvider).setBool(_autoStartKey, enabled);
  }

  /// Null selects "automatic".
  Future<void> setDefaultSeconds(int? seconds) async {
    state = state.copyWith(
      defaultSeconds: seconds,
      clearDefaultSeconds: seconds == null,
    );
    await ref
        .read(sharedPreferencesProvider)
        .setInt(_defaultSecondsKey, seconds ?? 0);
  }

  Future<void> setAlertStyle(RestAlertStyle style) async {
    state = state.copyWith(alertStyle: style);
    await ref
        .read(sharedPreferencesProvider)
        .setString(_alertStyleKey, style.name);
  }

  Future<void> setPreWarning({required bool enabled}) async {
    state = state.copyWith(preWarning: enabled);
    await ref.read(sharedPreferencesProvider).setBool(_preWarningKey, enabled);
  }

  /// An unrecognised stored value means a downgrade or a corrupt write; the
  /// default is a better answer than throwing, since no preference is worth
  /// failing to start over.
  static RestAlertStyle? _readStyle(SharedPreferences prefs) {
    final stored = prefs.getString(_alertStyleKey);
    if (stored == null) return null;
    for (final style in RestAlertStyle.values) {
      if (style.name == stored) return style;
    }
    return null;
  }
}
