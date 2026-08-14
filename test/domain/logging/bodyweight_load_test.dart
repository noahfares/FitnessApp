import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/logging/bodyweight_load.dart';

/// `F-LOG-019`.
void main() {
  test('full bodyweight plus added weight, when no coefficient is set', () {
    expect(
      effectiveLoadGrams(
        bodyweightGrams: 80000,
        coefficient: null,
        addedGrams: 20000,
      ),
      100000,
    );
  });

  test('a partial coefficient scales bodyweight before adding the plate', () {
    // A push-up at ~0.64 bodyweight, unweighted.
    expect(
      effectiveLoadGrams(
        bodyweightGrams: 80000,
        coefficient: 0.64,
        addedGrams: 0,
      ),
      51200,
    );
  });

  test('no bodyweight on record falls back to the added weight alone', () {
    expect(
      effectiveLoadGrams(
        bodyweightGrams: null,
        coefficient: 0.64,
        addedGrams: 20000,
      ),
      20000,
    );
  });

  test('zero added weight is still a real load — full bodyweight', () {
    expect(
      effectiveLoadGrams(
        bodyweightGrams: 80000,
        coefficient: null,
        addedGrams: 0,
      ),
      80000,
    );
  });
}
