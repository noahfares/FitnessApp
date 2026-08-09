import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/progression/linear_progression.dart';

void main() {
  test('legs default to a 5 kg increment, everything else to 2.5 kg', () {
    expect(defaultIncrementGrams('quads'), 5000);
    expect(defaultIncrementGrams('hamstrings'), 5000);
    expect(defaultIncrementGrams('chest'), 2500);
    expect(defaultIncrementGrams('lats'), 2500);
    expect(defaultIncrementGrams('abs'), 2500);
    // Unrecognised/no-category muscles fall to the smaller default too.
    expect(defaultIncrementGrams('neck'), 2500);
  });
}
