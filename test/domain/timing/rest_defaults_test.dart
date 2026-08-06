import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/timing/rest_defaults.dart';

/// Resolving how long a rest is (`F-TIM-005`).
void main() {
  group('built-in defaults', () {
    test('compound barbell work rests considerably longer than isolation', () {
      final squat = builtInRestSeconds(
        equipment: 'barbell',
        primaryMuscle: 'quads',
      );
      final curl = builtInRestSeconds(
        equipment: 'cable',
        primaryMuscle: 'biceps',
      );

      expect(squat, 180);
      expect(curl, 60);
      expect(squat, greaterThan(curl * 2));
    });

    test('equipment outranks muscle — a machine press is not a squat', () {
      expect(
        builtInRestSeconds(equipment: 'machine', primaryMuscle: 'chest'),
        lessThan(builtInRestSeconds(equipment: 'barbell', primaryMuscle: 'chest')),
      );
    });

    test('an unknown equipment gets a sane middle answer, not a crash', () {
      expect(
        builtInRestSeconds(equipment: 'sledgehammer', primaryMuscle: 'traps'),
        90,
      );
    });
  });

  group('resolution order (F-TIM-005)', () {
    test('the routine wins over everything', () {
      expect(
        resolveRestSeconds(
          equipment: 'barbell',
          primaryMuscle: 'quads',
          routineSeconds: 45,
          exerciseSeconds: 120,
          globalSeconds: 90,
        ),
        45,
      );
    });

    test('the exercise wins over the global setting', () {
      expect(
        resolveRestSeconds(
          equipment: 'barbell',
          primaryMuscle: 'quads',
          exerciseSeconds: 120,
          globalSeconds: 90,
        ),
        120,
      );
    });

    test('the global setting wins over the built-in', () {
      expect(
        resolveRestSeconds(
          equipment: 'barbell',
          primaryMuscle: 'quads',
          globalSeconds: 90,
        ),
        90,
      );
    });

    test('"automatic" — no global setting — falls through to the built-in', () {
      // The reason the global default is nullable at all: a global that was
      // always set would make the per-type split dead code.
      expect(
        resolveRestSeconds(equipment: 'barbell', primaryMuscle: 'quads'),
        180,
      );
      expect(
        resolveRestSeconds(equipment: 'cable', primaryMuscle: 'biceps'),
        60,
      );
    });
  });

  group('formatRestDuration', () {
    test('reads as short as the value allows', () {
      expect(formatRestDuration(45), '45 s');
      expect(formatRestDuration(90), '1:30 min');
      expect(formatRestDuration(180), '3 min');
    });
  });
}
