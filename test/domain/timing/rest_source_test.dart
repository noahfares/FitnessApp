import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/timing/rest_defaults.dart';

/// `F-ROU-006` — "each level is explicitly overridable and shows which level it
/// inherited from". The resolution order was already `F-TIM-005`'s; this is the
/// half that makes an inherited value legible.
void main() {
  test('the most specific level set is the one reported', () {
    expect(
      resolveRestSource(
        routineSeconds: 120,
        exerciseSeconds: 90,
        globalSeconds: 60,
      ),
      RestSource.routine,
    );
    expect(
      resolveRestSource(exerciseSeconds: 90, globalSeconds: 60),
      RestSource.exercise,
    );
    expect(resolveRestSource(globalSeconds: 60), RestSource.global);
    expect(resolveRestSource(), RestSource.builtIn);
  });

  test('the source always agrees with the value resolveRestSeconds picks', () {
    // The two functions answering differently is the one bug this pairing can
    // have, and it would be invisible: the number would be right and the
    // explanation wrong.
    const cases = [
      (routine: 120, exercise: 90, global: 60, expected: 120),
      (routine: null, exercise: 90, global: 60, expected: 90),
      (routine: null, exercise: null, global: 60, expected: 60),
      (routine: null, exercise: null, global: null, expected: 180),
    ];

    for (final c in cases) {
      final seconds = resolveRestSeconds(
        equipment: 'barbell',
        primaryMuscle: 'chest',
        routineSeconds: c.routine,
        exerciseSeconds: c.exercise,
        globalSeconds: c.global,
      );
      final source = resolveRestSource(
        routineSeconds: c.routine,
        exerciseSeconds: c.exercise,
        globalSeconds: c.global,
      );

      expect(seconds, c.expected);
      final fromSource = switch (source) {
        RestSource.routine => c.routine,
        RestSource.exercise => c.exercise,
        RestSource.global => c.global,
        RestSource.builtIn => builtInRestSeconds(
          equipment: 'barbell',
          primaryMuscle: 'chest',
        ),
      };
      expect(fromSource, seconds);
    }
  });
}
