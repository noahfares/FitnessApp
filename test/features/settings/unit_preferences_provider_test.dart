import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitness_app/core/units/distance.dart';
import 'package:fitness_app/core/units/length.dart';
import 'package:fitness_app/core/units/mass.dart';
import 'package:fitness_app/core/units/unit_preferences.dart';
import 'package:fitness_app/features/settings/application/unit_preferences_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// [country] pins the first-run default so tests do not depend on whichever
  /// locale the test runner happens to have.
  Future<ProviderContainer> containerWith(
    Map<String, Object> stored, {
    String? country = 'DE',
  }) async {
    SharedPreferences.setMockInitialValues(stored);
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        localeProvider.overrideWithValue('en_US'),
        deviceCountryProvider.overrideWithValue(country),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('persistence', () {
    test('stored values are restored', () async {
      final container = await containerWith({
        'units.load': 'kg',
        'units.body': 'lb',
        'units.length': 'inches',
        'units.distance': 'miles',
      });

      final prefs = container.read(unitPreferencesProvider);
      expect(prefs.load, MassUnit.kg);
      expect(prefs.body, MassUnit.lb);
      expect(prefs.length, LengthUnit.inches);
      expect(prefs.distance, DistanceUnit.miles);
    });

    test('setting a unit persists it', () async {
      final container = await containerWith({});
      await container
          .read(unitPreferencesProvider.notifier)
          .setLoad(MassUnit.lb);

      expect(container.read(unitPreferencesProvider).load, MassUnit.lb);
      final raw = await SharedPreferences.getInstance();
      expect(raw.getString('units.load'), 'lb');
    });

    test('the four settings are independent', () async {
      final container = await containerWith({});
      final notifier = container.read(unitPreferencesProvider.notifier);

      // Lifting in kilograms while weighing in pounds must be expressible.
      await notifier.setLoad(MassUnit.kg);
      await notifier.setBody(MassUnit.lb);

      final prefs = container.read(unitPreferencesProvider);
      expect(prefs.load, MassUnit.kg);
      expect(prefs.body, MassUnit.lb);
    });

    test(
      'an unrecognised stored value falls back instead of throwing',
      () async {
        // A downgrade or corrupt write must never stop the app starting.
        final container = await containerWith({'units.load': 'stone'});
        expect(() => container.read(unitPreferencesProvider), returnsNormally);
      },
    );
  });

  group('display-only', () {
    test('changing a unit re-renders values without altering them', () async {
      final container = await containerWith({'units.load': 'kg'});
      const stored = Mass.grams(102500); // canonical, never rewritten

      expect(
        container.read(quantityFormatterProvider).setWeight(stored),
        '102.5',
      );

      await container
          .read(unitPreferencesProvider.notifier)
          .setLoad(MassUnit.lb);

      // Same stored grams, different rendering. This is the whole point of
      // canonical storage (ADR-0003).
      expect(
        container.read(quantityFormatterProvider).setWeight(stored),
        '226',
      );
      expect(stored.grams, 102500);
    });

    test('switching back and forth is lossless', () async {
      final container = await containerWith({'units.load': 'kg'});
      final notifier = container.read(unitPreferencesProvider.notifier);
      const stored = Mass.grams(102500);

      final before = container
          .read(quantityFormatterProvider)
          .setWeight(stored);
      await notifier.setLoad(MassUnit.lb);
      await notifier.setLoad(MassUnit.kg);
      final after = container.read(quantityFormatterProvider).setWeight(stored);

      expect(after, before);
      expect(stored.grams, 102500);
    });
  });

  group('locale defaults', () {
    test('first run infers from the device country', () async {
      final us = await containerWith({}, country: 'US');
      expect(us.read(unitPreferencesProvider).load, MassUnit.lb);

      final de = await containerWith({}, country: 'DE');
      expect(de.read(unitPreferencesProvider).load, MassUnit.kg);
    });

    test('a stored value beats the locale default', () async {
      // Travelling, or changing the phone's region, must never silently alter
      // someone's settings.
      final container = await containerWith({
        'units.load': 'kg',
      }, country: 'US');
      expect(container.read(unitPreferencesProvider).load, MassUnit.kg);
    });

    test('US defaults to imperial, elsewhere metric', () {
      expect(UnitPreferences.forCountry('US'), UnitPreferences.imperial);
      expect(UnitPreferences.forCountry('us'), UnitPreferences.imperial);
      expect(UnitPreferences.forCountry('DE'), UnitPreferences.metric);
      expect(UnitPreferences.forCountry(null), UnitPreferences.metric);
      // The UK loads barbells in kilograms even though bodyweight is often
      // spoken in stone.
      expect(UnitPreferences.forCountry('GB'), UnitPreferences.metric);
    });
  });
}
