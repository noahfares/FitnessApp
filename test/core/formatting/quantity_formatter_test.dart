import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/formatting/quantity_formatter.dart';
import 'package:fitness_app/core/units/distance.dart';
import 'package:fitness_app/core/units/length.dart';
import 'package:fitness_app/core/units/mass.dart';
import 'package:fitness_app/core/units/unit_preferences.dart';

/// Covers every row of the display table in docs/22-UNITS.md, in both unit
/// systems and in two locales — de_DE because it swaps the decimal and group
/// separators, which is where naive formatting breaks.
void main() {
  const metricUS = QuantityFormatter(
    prefs: UnitPreferences.metric,
    locale: 'en_US',
  );
  const imperialUS = QuantityFormatter(
    prefs: UnitPreferences.imperial,
    locale: 'en_US',
  );
  const metricDE = QuantityFormatter(
    prefs: UnitPreferences.metric,
    locale: 'de_DE',
  );

  group('set weight — 1 decimal, trailing .0 stripped, ungrouped', () {
    test('kilograms', () {
      expect(metricUS.setWeight(Mass.kg(100)), '100');
      expect(metricUS.setWeight(Mass.kg(102.5)), '102.5');
      expect(metricUS.setWeight(Mass.kg(60)), '60');
      expect(metricUS.setWeight(Mass.kg(2.5)), '2.5');
    });

    test('pounds', () {
      expect(imperialUS.setWeight(Mass.lb(225)), '225');
      expect(imperialUS.setWeight(Mass.lb(227.5)), '227.5');
    });

    test('is ungrouped, to save width in the set row', () {
      expect(metricUS.setWeight(Mass.kg(1000)), '1000');
    });

    test('unit suffix is opt-in — the column header normally carries it', () {
      expect(metricUS.setWeight(Mass.kg(100)), isNot(contains('kg')));
      expect(metricUS.setWeight(Mass.kg(100), showUnit: true), '100 kg');
    });

    test('German swaps the decimal separator', () {
      expect(metricDE.setWeight(Mass.kg(102.5)), '102,5');
      expect(metricDE.setWeight(Mass.kg(100)), '100');
    });
  });

  group('volume total — 0 decimals, grouped', () {
    test('English groups with commas', () {
      expect(metricUS.volume(Mass.kg(12480)), '12,480 kg');
      expect(metricUS.volume(Mass.kg(1760)), '1,760 kg');
    });

    test('German groups with full stops', () {
      expect(metricDE.volume(Mass.kg(12480)), '12.480 kg');
    });

    test('decimals are dropped, not shown as .0', () {
      expect(metricUS.volume(Mass.kg(1760.4)), '1,760 kg');
    });
  });

  group('estimated 1RM — 1 decimal', () {
    test('formats the worked fixture from the analytics spec', () {
      // 100 kg x 8 by Epley = 126.667 kg.
      expect(metricUS.e1rm(const Mass.grams(126667)), '126.7 kg');
    });
  });

  group('bodyweight — 1 decimal, independent unit', () {
    test('body unit is separate from load unit', () {
      // Lifting in kilograms while weighing in pounds is entirely normal.
      const mixed = QuantityFormatter(
        prefs: UnitPreferences(load: MassUnit.kg, body: MassUnit.lb),
        locale: 'en_US',
      );
      expect(mixed.setWeight(Mass.kg(100), showUnit: true), '100 kg');
      expect(mixed.bodyweight(Mass.kg(80)), '176.4 lb');
    });
  });

  group('circumference — 1 decimal cm, 2 decimals inches', () {
    test('centimetres', () {
      expect(metricUS.circumference(Length.cm(35.5)), '35.5 cm');
    });

    test('inches get the extra digit', () {
      expect(imperialUS.circumference(Length.inches(14.25)), '14.25 in');
    });
  });

  group('distance — 2 decimals', () {
    test('kilometres and miles', () {
      expect(metricUS.distance(Distance.km(5)), '5 km');
      expect(metricUS.distance(Distance.km(5.25)), '5.25 km');
      expect(imperialUS.distance(Distance.miles(3.1)), '3.1 mi');
    });
  });

  group('massValueOnly — for editable fields', () {
    test('never groups, so it round-trips through the parser', () {
      expect(metricUS.massValueOnly(Mass.kg(1000), MassUnit.kg), '1000');
      expect(metricDE.massValueOnly(Mass.kg(1000), MassUnit.kg), '1000');
    });
  });

  group('percent — 1 decimal, basis points (F-BOD-002)', () {
    test('formats basis points as a percentage', () {
      expect(metricUS.percent(1850), '18.5%');
      expect(metricUS.percent(1800), '18%');
    });

    test('showUnit false omits the sign', () {
      expect(metricUS.percent(1850, showUnit: false), '18.5');
    });
  });
}
