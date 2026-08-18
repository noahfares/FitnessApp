import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'unit_preferences_provider.dart' show sharedPreferencesProvider;
import '../../../l10n/app_localizations.dart';

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

/// Android 12+ wallpaper-derived colour (`F-THM-003`) — **off by default**, so
/// the app has a consistent identity out of the box regardless of wallpaper.
/// A no-op on any platform `dynamic_color` doesn't support: the builder just
/// never has a scheme to offer, and `AppTheme` falls back to its fixed seed.
final dynamicColorEnabledProvider =
    NotifierProvider<DynamicColorEnabledNotifier, bool>(
      DynamicColorEnabledNotifier.new,
    );

class DynamicColorEnabledNotifier extends Notifier<bool> {
  static const _key = 'appearance.dynamicColor';

  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_key) ?? false;

  Future<void> set(bool enabled) async {
    state = enabled;
    await ref.read(sharedPreferencesProvider).setBool(_key, enabled);
  }
}

/// Labels for the appearance screen (batch 0.4).
extension ThemeModeLabel on ThemeMode {
  String label(AppLocalizations l10n) => switch (this) {
    ThemeMode.light => l10n.themeModeLight,
    ThemeMode.dark => l10n.themeModeDark,
    ThemeMode.system => l10n.themeModeSystem,
  };
}
