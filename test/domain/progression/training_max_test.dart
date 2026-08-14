import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/progression/training_max.dart';

/// Batch 4.2's second pass — `F-PRG-010`. Reuses the `trainingMaxProgression`
/// fixture (`docs/40-ANALYTICS-SPEC.md` §12).
void main() {
  test('derives ~90% of the best e1RM, floored', () {
    expect(deriveTrainingMaxGrams(120000), 108000);
  });

  test('floors rather than rounds', () {
    // 100005 * 0.9 = 90004.5g exactly — round-half-up would give 90005,
    // but a training max is meant to err light, so this floors to 90004.
    expect(deriveTrainingMaxGrams(100005), 90004);
  });
}
