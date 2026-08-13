import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/features/settings/application/tracked_measurements_provider.dart';
import 'package:fitness_app/features/settings/application/unit_preferences_provider.dart';

/// `F-BOD-002`.
void main() {
  Future<ProviderContainer> containerWith(Map<String, Object> stored) async {
    SharedPreferences.setMockInitialValues(stored);
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('defaults to empty — showing all thirteen is clutter', () async {
    final container = await containerWith({});
    expect(container.read(trackedMeasurementTypesProvider), isEmpty);
  });

  test('a stored selection is restored', () async {
    final container = await containerWith({
      'body.trackedMeasurementTypes': ['waist', 'bodyFatPercent'],
    });
    expect(container.read(trackedMeasurementTypesProvider), {
      MeasurementType.waist,
      MeasurementType.bodyFatPercent,
    });
  });

  test('an unrecognised stored name is dropped rather than throwing', () async {
    final container = await containerWith({
      'body.trackedMeasurementTypes': ['waist', 'notAType'],
    });
    expect(container.read(trackedMeasurementTypesProvider), {
      MeasurementType.waist,
    });
  });

  group('toggle', () {
    test('adds a type not yet tracked', () async {
      final container = await containerWith({});
      await container
          .read(trackedMeasurementTypesProvider.notifier)
          .toggle(MeasurementType.chest);

      expect(container.read(trackedMeasurementTypesProvider), {
        MeasurementType.chest,
      });
      final raw = await SharedPreferences.getInstance();
      expect(raw.getStringList('body.trackedMeasurementTypes'), ['chest']);
    });

    test('removes a type already tracked', () async {
      final container = await containerWith({
        'body.trackedMeasurementTypes': ['chest', 'waist'],
      });
      await container
          .read(trackedMeasurementTypesProvider.notifier)
          .toggle(MeasurementType.chest);

      expect(container.read(trackedMeasurementTypesProvider), {
        MeasurementType.waist,
      });
    });
  });
}
