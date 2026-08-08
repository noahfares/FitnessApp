import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitness_app/core/units/week_start.dart';
import 'package:fitness_app/features/settings/application/unit_preferences_provider.dart';
import 'package:fitness_app/features/settings/application/week_start_provider.dart';

/// Batch 3.3 — `F-SET-005`.
void main() {
  Future<ProviderContainer> containerWith(
    Map<String, Object> stored, {
    String? country = 'DE',
  }) async {
    SharedPreferences.setMockInitialValues(stored);
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        deviceCountryProvider.overrideWithValue(country),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('persistence', () {
    test('a stored value is restored', () async {
      final container = await containerWith({
        'analytics.weekStartWeekday': DateTime.sunday,
      });
      expect(container.read(weekStartProvider), WeekStart.sunday);
    });

    test('setting a value persists it', () async {
      final container = await containerWith({});
      await container.read(weekStartProvider.notifier).set(WeekStart.saturday);

      expect(container.read(weekStartProvider), WeekStart.saturday);
      final raw = await SharedPreferences.getInstance();
      expect(raw.getInt('analytics.weekStartWeekday'), DateTime.saturday);
    });

    test(
      'an out-of-range stored value falls back instead of throwing',
      () async {
        final container = await containerWith({
          'analytics.weekStartWeekday': 99,
        });
        expect(() => container.read(weekStartProvider), returnsNormally);
      },
    );
  });

  group('locale defaults', () {
    test('first run infers from the device country', () async {
      final us = await containerWith({}, country: 'US');
      expect(us.read(weekStartProvider), WeekStart.sunday);

      final de = await containerWith({}, country: 'DE');
      expect(de.read(weekStartProvider), WeekStart.monday);
    });

    test('a stored value beats the locale default', () async {
      final container = await containerWith({
        'analytics.weekStartWeekday': DateTime.monday,
      }, country: 'US');
      expect(container.read(weekStartProvider), WeekStart.monday);
    });
  });
}
