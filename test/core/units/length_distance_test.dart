import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/units/distance.dart';
import 'package:fitness_app/core/units/length.dart';

void main() {
  group('Length', () {
    test('exactness', () {
      expect(Length.cm(100).millimetres, 1000);
      expect(Length.cm(35.5).millimetres, 355);
      // 14 x 25.4 = 355.6, rounds to 356.
      expect(Length.inches(14).millimetres, 356);
      expect(Length.millimetresPerInch, 25.4);
    });

    test('round-trips within display precision', () {
      for (var quarter = 0; quarter <= 400; quarter++) {
        final inches = quarter / 4; // circumferences are read to the 1/4 inch
        expect(Length.inches(inches).inInches, closeTo(inches, 0.02));
      }
    });

    test('value semantics', () {
      expect(Length.cm(100), const Length.millimetres(1000));
      expect(Length.cm(90) < Length.cm(100), isTrue);
      expect(Length.cm(10) + Length.cm(5), Length.cm(15));
    });
  });

  group('Distance', () {
    test('exactness', () {
      expect(Distance.km(5).metres, 5000);
      expect(Distance.miles(1).metres, 1609);
      expect(Distance.metresPerMile, 1609.344);
    });

    test('round-trips within display precision', () {
      for (var hundredths = 0; hundredths <= 5000; hundredths++) {
        final miles = hundredths / 100;
        expect(Distance.miles(miles).inMiles, closeTo(miles, 0.001));
      }
    });

    test('value semantics', () {
      expect(Distance.km(5), const Distance.metres(5000));
      expect(Distance.km(5) > Distance.km(1), isTrue);
    });
  });
}
