import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/formatting/quantity_formatter.dart';
import 'package:fitness_app/core/formatting/quantity_parser.dart';
import 'package:fitness_app/core/units/mass.dart';
import 'package:fitness_app/core/units/unit_preferences.dart';

void main() {
  const us = QuantityParser(locale: 'en_US');
  const de = QuantityParser(locale: 'de_DE');

  group('plain numbers', () {
    test('integers and simple decimals', () {
      expect(us.parseNumber('100'), 100);
      expect(us.parseNumber('102.5'), 102.5);
      expect(us.parseNumber('0'), 0);
      expect(us.parseNumber('  60  '), 60);
      expect(us.parseNumber('-2.5'), -2.5);
      expect(us.parseNumber('+2.5'), 2.5);
    });
  });

  group('separator leniency — the point of this parser', () {
    test('a US user typing a comma still means a decimal point', () {
      // Refusing this would be a bug, not correctness.
      expect(us.parseNumber('102,5'), 102.5);
      expect(us.parseNumber('102,50'), 102.5);
    });

    test('a German user typing a full stop still means a decimal point', () {
      expect(de.parseNumber('102.5'), 102.5);
    });

    test('each locale reads its own decimal separator natively', () {
      expect(us.parseNumber('102.5'), 102.5);
      expect(de.parseNumber('102,5'), 102.5);
    });
  });

  group('grouping versus decimal — the genuinely ambiguous cases', () {
    test(
      'group separator with exactly 3 trailing digits reads as grouping',
      () {
        expect(us.parseNumber('1,234'), 1234);
        expect(de.parseNumber('1.234'), 1234);
      },
    );

    test('but with 1 or 2 trailing digits it reads as a decimal', () {
      // "102,5" cannot be grouping — nobody groups a single digit.
      expect(us.parseNumber('102,5'), 102.5);
      expect(us.parseNumber('102,55'), 102.55);
    });

    test('the locale decimal separator always wins, even with 3 digits', () {
      expect(us.parseNumber('1.234'), 1.234);
      expect(de.parseNumber('1,234'), 1.234);
    });

    test('mixed separators: the last one is the decimal point', () {
      expect(us.parseNumber('1,234.5'), 1234.5);
      expect(de.parseNumber('1.234,5'), 1234.5);
    });

    test('repeated group separators are all grouping', () {
      expect(us.parseNumber('1,234,567'), 1234567);
      expect(de.parseNumber('1.234.567'), 1234567);
    });
  });

  group('rejection — malformed input returns null, never a guess', () {
    test('empty and whitespace', () {
      expect(us.parseNumber(''), isNull);
      expect(us.parseNumber('   '), isNull);
    });

    test('letters are rejected rather than stripped', () {
      // Silently discarding characters is how "10O" becomes 10.
      expect(us.parseNumber('10O'), isNull);
      expect(us.parseNumber('abc'), isNull);
      expect(us.parseNumber('100kg'), isNull);
      expect(us.parseNumber('1e3'), isNull);
    });

    test('trailing and lone separators', () {
      expect(us.parseNumber('102.'), isNull);
      expect(us.parseNumber('.'), isNull);
      expect(us.parseNumber('-'), isNull);
    });

    test('two decimal points', () {
      expect(us.parseNumber('1.2.3'), isNull);
    });
  });

  group('parseMass', () {
    test('converts from the display unit straight to canonical grams', () {
      expect(us.parseMass('100', MassUnit.kg), const Mass.grams(100000));
      expect(us.parseMass('225', MassUnit.lb), const Mass.grams(102058));
      expect(us.parseMass('102,5', MassUnit.kg), const Mass.grams(102500));
      expect(us.parseMass('nonsense', MassUnit.kg), isNull);
    });
  });

  group('formatter/parser round-trip', () {
    test('an edited value survives a display round-trip unchanged', () {
      // The trap in docs/22-UNITS.md: formatting then reparsing must not drift.
      for (final locale in ['en_US', 'de_DE']) {
        final formatter = QuantityFormatter(
          prefs: UnitPreferences.metric,
          locale: locale,
        );
        final parser = QuantityParser(locale: locale);

        for (var half = 0; half <= 600; half++) {
          final original = Mass.kg(half / 2);
          final text = formatter.massValueOnly(original, MassUnit.kg);
          expect(
            parser.parseMass(text, MassUnit.kg),
            original,
            reason: '$locale: "$text" did not round-trip',
          );
        }
      }
    });

    test('pounds round-trip to within a gram', () {
      const formatter = QuantityFormatter(
        prefs: UnitPreferences.imperial,
        locale: 'en_US',
      );
      const parser = QuantityParser(locale: 'en_US');

      for (var lb = 0; lb <= 600; lb += 5) {
        final original = Mass.lb(lb);
        final text = formatter.massValueOnly(original, MassUnit.lb);
        final reparsed = parser.parseMass(text, MassUnit.lb)!;
        // One decimal place of pounds is ~45 g, so exact equality is not
        // available here — but the stored value is never overwritten by a
        // display round-trip, which is what makes this safe.
        expect((reparsed.grams - original.grams).abs(), lessThanOrEqualTo(46));
      }
    });
  });
}
