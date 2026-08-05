import 'dart:ui' show PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/formatting/quantity_formatter.dart';
import '../../../core/formatting/quantity_parser.dart';
import '../../../core/units/distance.dart';
import '../../../core/units/length.dart';
import '../../../core/units/mass.dart';
import '../../../core/units/unit_preferences.dart';

/// Overridden in `main()` once [SharedPreferences] has loaded.
///
/// Resolved eagerly at startup rather than exposed as an async provider,
/// because unit preferences are needed synchronously by nearly every widget
/// that renders a number. An `AsyncValue` at every one of those call sites
/// would be noise for something that is ready in milliseconds.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw StateError(
    'sharedPreferencesProvider must be overridden in main() — see lib/main.dart',
  ),
);

/// The device locale name, e.g. `en_US`. Overridable in tests.
final localeProvider = Provider<String>((ref) {
  final locale = PlatformDispatcher.instance.locale;
  return locale.countryCode == null
      ? locale.languageCode
      : '${locale.languageCode}_${locale.countryCode}';
});

/// The device's region subtag, e.g. `US`. Null when the locale carries none.
///
/// A provider rather than a direct `PlatformDispatcher` read so that first-run
/// defaults are testable — otherwise the notifier's behaviour depends on
/// whichever locale the test runner happens to have.
final deviceCountryProvider = Provider<String?>(
  (ref) => PlatformDispatcher.instance.locale.countryCode,
);

/// The user's display-unit choices (F-SET-001).
///
/// Changing any of these is display-only: it writes one small key to
/// [SharedPreferences] and rebuilds anything watching. **No database write
/// occurs, and no stored value is rewritten** — that is the payoff of canonical
/// storage (ADR-0003), and it makes the change instantly reversible.
final unitPreferencesProvider =
    NotifierProvider<UnitPreferencesNotifier, UnitPreferences>(
      UnitPreferencesNotifier.new,
    );

class UnitPreferencesNotifier extends Notifier<UnitPreferences> {
  static const _loadKey = 'units.load';
  static const _bodyKey = 'units.body';
  static const _lengthKey = 'units.length';
  static const _distanceKey = 'units.distance';

  @override
  UnitPreferences build() {
    final prefs = ref.watch(sharedPreferencesProvider);

    // First run: infer from the device locale. Afterwards the stored values
    // win, so that later travelling or changing the phone's region never
    // silently alters someone's settings.
    final defaults = UnitPreferences.forCountry(
      ref.watch(deviceCountryProvider),
    );

    return UnitPreferences(
      load: _readEnum(prefs, _loadKey, MassUnit.values) ?? defaults.load,
      body: _readEnum(prefs, _bodyKey, MassUnit.values) ?? defaults.body,
      length:
          _readEnum(prefs, _lengthKey, LengthUnit.values) ?? defaults.length,
      distance:
          _readEnum(prefs, _distanceKey, DistanceUnit.values) ??
          defaults.distance,
    );
  }

  Future<void> setLoad(MassUnit unit) async {
    state = state.copyWith(load: unit);
    await _write(_loadKey, unit.name);
  }

  Future<void> setBody(MassUnit unit) async {
    state = state.copyWith(body: unit);
    await _write(_bodyKey, unit.name);
  }

  Future<void> setLength(LengthUnit unit) async {
    state = state.copyWith(length: unit);
    await _write(_lengthKey, unit.name);
  }

  Future<void> setDistance(DistanceUnit unit) async {
    state = state.copyWith(distance: unit);
    await _write(_distanceKey, unit.name);
  }

  /// State updates first so the UI is immediate; persistence follows. A failed
  /// write costs one preference, not a frame of latency on every number in the
  /// app.
  Future<void> _write(String key, String value) =>
      ref.read(sharedPreferencesProvider).setString(key, value);

  static T? _readEnum<T extends Enum>(
    SharedPreferences prefs,
    String key,
    List<T> values,
  ) {
    final stored = prefs.getString(key);
    if (stored == null) return null;
    for (final value in values) {
      if (value.name == stored) return value;
    }
    // An unrecognised stored value means a downgrade or a corrupt write. Fall
    // back to the default rather than throwing — a preference is never worth
    // failing to start over.
    return null;
  }
}

/// Formatter bound to the current preferences and locale.
///
/// Every displayed number goes through this, so changing a unit setting
/// rebuilds all of them at once — the acceptance criterion for F-SET-001.
final quantityFormatterProvider = Provider<QuantityFormatter>((ref) {
  return QuantityFormatter(
    prefs: ref.watch(unitPreferencesProvider),
    locale: ref.watch(localeProvider),
  );
});

/// Parser bound to the current locale (F-I18N-002).
final quantityParserProvider = Provider<QuantityParser>((ref) {
  return QuantityParser(locale: ref.watch(localeProvider));
});
