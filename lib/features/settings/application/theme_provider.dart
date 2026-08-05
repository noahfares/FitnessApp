import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'unit_preferences_provider.dart' show sharedPreferencesProvider;

/// Light, dark, or follow the system (F-SET-002).
///
/// Applies instantly with no restart, and persists. Stored as the enum's name
/// so the value stays readable in the preferences file and survives reordering
/// of [ThemeMode].
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'appearance.themeMode';

  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final stored = prefs.getString(_key);
    for (final mode in ThemeMode.values) {
      if (mode.name == stored) return mode;
    }
    // Following the system is the least surprising default, and it means the
    // app is already correct for anyone using a scheduled dark mode.
    return ThemeMode.system;
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref.read(sharedPreferencesProvider).setString(_key, mode.name);
  }
}

/// Labels for the appearance screen (batch 0.4).
extension ThemeModeLabel on ThemeMode {
  String get label => switch (this) {
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
    ThemeMode.system => 'System',
  };
}
