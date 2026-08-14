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

  // Batch 4.5's second pass — `F-CAT-013` §2, `F-ANA-014`.
  group('bodyMapViewOf', () {
    test('every muscle with a category also has a view, and vice versa', () {
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
        expect(
          bodyMapViewOf(muscle) != null,
          categoryOf(muscle) != null,
          reason: muscle,
        );
      }
    });

    test('§16 front/back lists match exactly', () {
      const front = [
        'chest',
        'frontDelts',
        'sideDelts',
        'biceps',
        'forearms',
        'abs',
        'obliques',
        'adductors',
        'quads',
      ];
      const back = [
        'traps',
        'rearDelts',
        'lats',
        'upperBack',
        'lowerBack',
        'triceps',
        'glutes',
        'hamstrings',
        'calves',
        'abductors',
      ];
      for (final muscle in front) {
        expect(bodyMapViewOf(muscle), BodyMapView.front, reason: muscle);
      }
      for (final muscle in back) {
        expect(bodyMapViewOf(muscle), BodyMapView.back, reason: muscle);
      }
    });

    test('neck and fullBody map to no view', () {
      expect(bodyMapViewOf('neck'), isNull);
      expect(bodyMapViewOf('fullBody'), isNull);
    });

    test('an unrecognised name returns null rather than throwing', () {
      expect(bodyMapViewOf('notAMuscle'), isNull);
    });
  });
}
