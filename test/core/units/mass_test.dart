import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/units/mass.dart';

/// Required by docs/22-UNITS.md §Testing requirements. These are not optional:
/// mixed-unit corruption is invisible until it is catastrophic.
void main() {
  group('exactness', () {
    test('kilograms convert without loss', () {
      expect(Mass.kg(100).grams, 100000);
      expect(Mass.kg(102.5).grams, 102500);
      expect(Mass.kg(2.5).grams, 2500);
      expect(Mass.kg(0.25).grams, 250);
    });

    test(
      'pounds use the exact international definition, rounded to the gram',
      () {
        // 45 x 453.59237 = 20411.65665, which rounds to 20412. Truncating would
        // bias every imperial conversion downward.
        expect(Mass.lb(45).grams, 20412);
        expect(Mass.lb(225).grams, 102058);
        expect(Mass.lb(1).grams, 454);
        expect(Mass.gramsPerPound, 453.59237);
      },
    );

    test('zero and negatives behave', () {
      expect(Mass.zero.grams, 0);
      expect(Mass.zero.isZero, isTrue);
      expect((-Mass.kg(20)).grams, -20000);
    });
  });

  group('round-trip', () {
    test('pounds survive the trip within display precision, 0-1000 lb', () {
      for (var lb = 0; lb <= 1000; lb++) {
        final round = Mass.lb(lb).inLb;
        // Worst case is half a gram of rounding, ~0.0011 lb — far inside the
        // one decimal place anything is ever displayed at.
        expect(round, closeTo(lb, 0.002), reason: '$lb lb did not round-trip');
      }
    });

    test('half-pound steps survive too', () {
      for (var half = 0; half <= 2000; half++) {
        final lb = half / 2;
        expect(Mass.lb(lb).inLb, closeTo(lb, 0.002));
      }
    });

    test('kilograms round-trip exactly at one decimal place', () {
      for (var tenths = 0; tenths <= 5000; tenths++) {
        final kg = tenths / 10;
        expect(Mass.kg(kg).inKg, closeTo(kg, 1e-9));
      }
    });
  });

  group('no drift', () {
    test('adding 2.5 kg 200 times gives exactly 500 kg more', () {
      var mass = Mass.kg(60);
      for (var i = 0; i < 200; i++) {
        mass += Mass.kg(2.5);
      }
      // Exact integer equality. This is the entire reason storage is integer
      // grams rather than a double (ADR-0003).
      expect(mass.grams, 60000 + 500000);
      expect(mass, Mass.kg(560));
    });

    test('adding 5 lb 200 times drifts by not one gram', () {
      var mass = Mass.zero;
      final step = Mass.lb(5);
      for (var i = 0; i < 200; i++) {
        mass += step;
      }
      expect(mass.grams, step.grams * 200);
    });

    test('a long alternating sequence returns exactly to its start', () {
      var mass = Mass.kg(100);
      for (var i = 0; i < 500; i++) {
        mass = mass + Mass.kg(2.5) - Mass.kg(2.5);
      }
      expect(mass, Mass.kg(100));
    });
  });

  group('value semantics', () {
    test('equality is by value', () {
      expect(Mass.kg(100), const Mass.grams(100000));
      expect(Mass.kg(100).hashCode, const Mass.grams(100000).hashCode);
      expect(Mass.kg(100), isNot(Mass.kg(100.001)));
    });

    test('comparison and sorting', () {
      final masses = [Mass.kg(102.5), Mass.kg(60), Mass.kg(100)]..sort();
      expect(masses, [Mass.kg(60), Mass.kg(100), Mass.kg(102.5)]);
      expect(Mass.kg(60) < Mass.kg(100), isTrue);
      expect(Mass.kg(100) >= Mass.kg(100), isTrue);
    });

    test('scaling rounds to the nearest gram', () {
      expect((Mass.kg(100) * 0.9).grams, 90000);
      expect((const Mass.grams(101) * 0.5).grams, 51); // 50.5 rounds up
    });

    test('toUnit and inUnit agree', () {
      expect(Mass.inUnit(100, MassUnit.kg), Mass.kg(100));
      expect(Mass.inUnit(225, MassUnit.lb), Mass.lb(225));
      expect(Mass.kg(100).toUnit(MassUnit.kg), closeTo(100, 1e-9));
      expect(Mass.lb(225).toUnit(MassUnit.lb), closeTo(225, 0.002));
    });
  });
}
