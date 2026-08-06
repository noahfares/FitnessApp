import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/units/mass.dart';
import 'package:fitness_app/domain/logging/duration_entry.dart';
import 'package:fitness_app/domain/logging/ghost_matching.dart';
import 'package:fitness_app/domain/logging/set_fields.dart';
import 'package:fitness_app/domain/logging/set_numbering.dart';
import 'package:fitness_app/domain/logging/weight_steps.dart';

/// Batch 1.4 — the rules behind the set row, tested away from the widget that
/// renders them (`F-LOG-003`–`F-LOG-006`).
void main() {
  group('setFieldsFor (F-LOG-003 §1)', () {
    test('every tracking type renders the inputs it measures', () {
      expect(setFieldsFor('weightReps'), [SetField.weight, SetField.reps]);
      expect(setFieldsFor('bodyweightReps'), [SetField.reps]);
      expect(setFieldsFor('reps'), [SetField.reps]);
      expect(setFieldsFor('time'), [SetField.duration]);
      expect(setFieldsFor('distanceTime'), [
        SetField.distance,
        SetField.duration,
      ]);
      expect(setFieldsFor('weightTime'), [SetField.weight, SetField.duration]);
    });

    test('an unknown type still renders something loggable', () {
      // A row written by a newer version. An unloggable set row is worse than
      // one with the wrong columns.
      expect(setFieldsFor('somethingNewerThanUs'), [
        SetField.weight,
        SetField.reps,
      ]);
    });
  });

  group('labelSets (F-LOG-005 §3)', () {
    test('warm-ups are numbered separately from counted sets', () {
      final labels = labelSets([
        'warmup',
        'warmup',
        'working',
        'working',
        'working',
      ]);
      expect([for (final l in labels) l.text], ['W1', 'W2', '1', '2', '3']);
    });

    test('a warm-up between working sets does not renumber them', () {
      // The numbers must agree with the analytics, which never see the warm-up.
      final labels = labelSets(['working', 'warmup', 'working']);
      expect([for (final l in labels) l.text], ['1', 'W1', '2']);
    });

    test('counted types carry a letter as well as a number', () {
      final labels = labelSets(['working', 'drop', 'amrap']);
      expect([for (final l in labels) l.toString()], ['1', '2D', '3A']);
      expect(labels.first.badge, isNull);
    });

    test('warm-up is identifiable from the label alone', () {
      expect(labelSets(['warmup']).single.isWarmup, isTrue);
      expect(labelSets(['working']).single.isWarmup, isFalse);
    });
  });

  group('matchGhostIndices (F-LOG-004)', () {
    test('matches by index within the session', () {
      expect(
        matchGhostIndices(
          currentTypes: ['working', 'working'],
          previousTypes: ['working', 'working'],
        ),
        [0, 1],
      );
    });

    test('never mixes warm-ups with counted sets (§6)', () {
      // Today opens with a warm-up that last time did not have. The working
      // ghosts must not all shift down a row.
      expect(
        matchGhostIndices(
          currentTypes: ['warmup', 'working', 'working'],
          previousTypes: ['working', 'working'],
        ),
        [null, 0, 1],
      );
    });

    test('warm-ups match warm-ups', () {
      expect(
        matchGhostIndices(
          currentTypes: ['warmup', 'working'],
          previousTypes: ['warmup', 'warmup', 'working'],
        ),
        [0, 2],
      );
    });

    test('a shorter previous session leaves later rows without a ghost (§5)', () {
      expect(
        matchGhostIndices(
          currentTypes: ['working', 'working', 'working'],
          previousTypes: ['working'],
        ),
        [0, null, null],
      );
    });

    test('no previous session at all is empty ghosts, not an error', () {
      expect(
        matchGhostIndices(
          currentTypes: ['working', 'working'],
          previousTypes: const [],
        ),
        [null, null],
      );
    });
  });

  group('weight steps (F-LOG-006 §2-§3)', () {
    test('the step is defined in the display unit', () {
      expect(
        defaultStep(equipment: 'barbell', unit: MassUnit.kg),
        Mass.kg(2.5),
      );
      expect(
        defaultStep(equipment: 'dumbbell', unit: MassUnit.kg),
        Mass.kg(2),
      );
      // Pounds step by 5 regardless: that is how the plates come.
      expect(defaultStep(equipment: 'barbell', unit: MassUnit.lb), Mass.lb(5));
      expect(defaultStep(equipment: 'dumbbell', unit: MassUnit.lb), Mass.lb(5));
    });

    test('unknown equipment still steps', () {
      expect(
        defaultStep(equipment: 'somethingNew', unit: MassUnit.kg),
        Mass.kg(2.5),
      );
    });

    test('two hundred increments land exactly, with no drift', () {
      // The acceptance criterion in `F-LOG-006`, and the reason stepping runs
      // on integer grams rather than on the displayed double.
      final step = defaultStep(equipment: 'barbell', unit: MassUnit.kg);
      var grams = 0;
      for (var i = 0; i < 200; i++) {
        grams = steppedGrams(grams, step, 1);
      }
      expect(grams, Mass.kg(500).grams);
    });

    test('stepping down stops at zero rather than going negative', () {
      final step = defaultStep(equipment: 'barbell', unit: MassUnit.kg);
      expect(steppedGrams(1000, step, -1), 0);
      // Zero is a valid load — an unloaded bar, an assisted rep — so it is a
      // floor and not a rejection.
      expect(steppedGrams(0, step, 1), 2500);
    });
  });

  group('duration entry (F-LOG-006)', () {
    test('digits read as a stopwatch does', () {
      expect(secondsFromDigits('45'), 45);
      expect(secondsFromDigits('130'), 90);
      expect(secondsFromDigits('1000'), 600);
      // Minutes are not capped at 59 — a 90-minute ride is `9000`, and there is
      // no hours key to reach for.
      expect(secondsFromDigits('6000'), 3600);
      expect(secondsFromDigits('9000'), 5400);
    });

    test('empty and non-numeric input is no value, not zero', () {
      expect(secondsFromDigits(''), isNull);
      expect(secondsFromDigits('1o0'), isNull);
    });

    test('round-trips through the digits that produced it', () {
      for (final seconds in [0, 9, 59, 60, 90, 600, 3600, 3725]) {
        expect(secondsFromDigits(digitsFromSeconds(seconds)), seconds);
      }
    });

    test('formats as a clock', () {
      expect(formatDurationSeconds(0), '00:00');
      expect(formatDurationSeconds(90), '01:30');
      expect(formatDurationSeconds(3725), '1:02:05');
    });
  });
}
