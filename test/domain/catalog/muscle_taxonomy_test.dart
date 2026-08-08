import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/catalog/muscle_taxonomy.dart';

/// Batch 3.3 — `F-CAT-013` §3.
void main() {
  group('categoryOf', () {
    test('the push:pull ratio fixture muscles match §9', () {
      // docs/40-ANALYTICS-SPEC.md §9: push = chest+frontDelts+triceps,
      // pull = lats+upperBack+biceps.
      for (final muscle in ['chest', 'frontDelts', 'triceps']) {
        expect(categoryOf(muscle), MuscleCategory.push, reason: muscle);
      }
      for (final muscle in ['lats', 'upperBack', 'biceps']) {
        expect(categoryOf(muscle), MuscleCategory.pull, reason: muscle);
      }
    });

    test(
      'every muscle in the fixed taxonomy is classified or explicitly not',
      () {
        const all = [
          'chest',
          'frontDelts',
          'sideDelts',
          'rearDelts',
          'lats',
          'traps',
          'upperBack',
          'lowerBack',
          'biceps',
          'triceps',
          'forearms',
          'quads',
          'hamstrings',
          'glutes',
          'calves',
          'adductors',
          'abductors',
          'abs',
          'obliques',
          'neck',
          'fullBody',
        ];
        for (final muscle in all) {
          // Every muscle resolves without throwing; only neck/fullBody are null.
          final category = categoryOf(muscle);
          if (muscle == 'neck' || muscle == 'fullBody') {
            expect(category, isNull, reason: muscle);
          } else {
            expect(category, isNotNull, reason: muscle);
          }
        }
      },
    );

    test('an unrecognised name returns null rather than throwing', () {
      expect(categoryOf('notAMuscle'), isNull);
    });
  });
}
