import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/units/mass.dart';
import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/set_repository.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';
import 'package:fitness_app/features/logging/presentation/active_workout_screen.dart';
import 'package:fitness_app/features/logging/presentation/set_row.dart';

import '../../support/harness.dart';

/// Batch 1.4 — the set row (`F-LOG-003`), ghosts (`F-LOG-004`), set types
/// (`F-LOG-005`), the keypad (`F-LOG-006`) and per-set notes (`F-LOG-023`).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late WorkoutRepository workouts;
  late SetRepository sets;
  var clock = DateTime(2026, 8, 6, 18, 30);

  setUp(() {
    db = testDatabase();
    clock = DateTime(2026, 8, 6, 18, 30);
    workouts = WorkoutRepository(db, clock: () => clock);
    sets = SetRepository(db, clock: () => clock);
  });

  Future<void> makeExercise(
    String id, {
    String? name,
    TrackingType tracking = TrackingType.weightReps,
    Equipment equipment = Equipment.barbell,
    WeightEntryMode weightEntryMode = WeightEntryMode.total,
  }) async {
    await db
        .into(db.exercises)
        .insert(
          ExercisesCompanion.insert(
            id: id,
            name: name ?? id,
            primaryMuscle: Muscle.chest,
            equipment: equipment,
            trackingType: tracking,
            weightEntryMode: Value(weightEntryMode),
            createdAt: 1,
            updatedAt: 1,
          ),
        );
  }

  /// Starts a session containing [exerciseId] and returns its
  /// `workout_exercises` id.
  Future<String> startWith(String exerciseId) async {
    final workout = await workouts.start();
    await workouts.addExercises(workout.id, [exerciseId]);
    return (await workouts.watchExercises(workout.id).first)
        .single
        .workoutExerciseId;
  }

  /// A finished session, so the next one has something to ghost.
  Future<void> logPreviousSession(
    String exerciseId,
    List<({int weight, int reps, SetType type})> performed, {
    DateTime? when,
  }) async {
    final saved = clock;
    clock = when ?? DateTime(2026, 7, 30);
    final workout = await workouts.start();
    await workouts.addExercises(workout.id, [exerciseId]);
    final we = (await workouts.watchExercises(workout.id).first)
        .single
        .workoutExerciseId;
    final first = (await sets.getSets(we)).single;
    for (var i = 0; i < performed.length; i++) {
      final id = i == 0 ? first.id : await sets.addSet(we);
      await sets.setType(id, performed[i].type);
      await sets.complete(
        id,
        weightGrams: Value(performed[i].weight),
        reps: Value(performed[i].reps),
      );
    }
    await workouts.finish(workout.id);
    clock = saved;
  }

  Future<void> pumpSession(
    WidgetTester tester, {
    double textScale = 1,
    Map<String, Object> prefs = const {},
  }) => pumpScreen(
    tester,
    const ActiveWorkoutScreen(),
    db: db,
    now: clock,
    textScale: textScale,
    prefs: prefs,
  );

  group('the row (F-LOG-003)', () {
    testWidgets('renders the exercise\'s own columns, not a fixed pair', (
      tester,
    ) async {
      await makeExercise('bench', name: 'Bench Press');
      await makeExercise(
        'plank',
        name: 'Plank',
        tracking: TrackingType.time,
        equipment: Equipment.bodyweight,
      );
      final workout = await workouts.start();
      await workouts.addExercises(workout.id, ['bench', 'plank']);

      await pumpSession(tester);

      // Weight × reps for the barbell lift, a clock for the hold
      // (`F-CAT-002`).
      expect(find.text('kg'), findsOneWidget);
      expect(find.text('Reps'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);
    });

    testWidgets('a run logs distance and time', (tester) async {
      await makeExercise(
        'row-erg',
        name: 'Rowing Machine',
        tracking: TrackingType.distanceTime,
        equipment: Equipment.machine,
      );
      await startWith('row-erg');

      await pumpSession(tester);

      expect(find.text('km'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);
      expect(find.text('Reps'), findsNothing);
    });

    testWidgets('adding a set appends one, pre-filled', (tester) async {
      await makeExercise('bench', name: 'Bench Press');
      final we = await startWith('bench');
      await sets.complete(
        (await sets.getSets(we)).single.id,
        weightGrams: const Value(100000),
        reps: const Value(8),
      );

      await pumpSession(tester);
      await tester.tap(find.text('Add set'));
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);
      // Both rows now read 100 — the new one inherited it (`F-LOG-003` §5).
      expect(find.text('100'), findsNWidgets(2));
    });

    testWidgets('swiping a set away offers undo, and undo brings it back', (
      tester,
    ) async {
      await makeExercise('bench', name: 'Bench Press');
      final we = await startWith('bench');
      await sets.addSet(we);
      await pumpSession(tester);

      await tester.drag(find.text('2'), const Offset(-600, 0));
      await tester.pumpAndSettle();

      expect(await sets.getSets(we), hasLength(1));
      expect(find.text('Set 2 deleted'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(await sets.getSets(we), hasLength(2));
    });

    testWidgets('announces itself as a set, not as loose numbers', (
      tester,
    ) async {
      await makeExercise('bench', name: 'Bench Press');
      final we = await startWith('bench');
      await sets.complete(
        (await sets.getSets(we)).single.id,
        weightGrams: const Value(100000),
        reps: const Value(8),
      );
      await pumpSession(tester);

      // Without this the row is a grid of unlabelled numbers (`F-A11Y-001`).
      // The controls keep their own nodes — the checkbox stays operable — so
      // this is a describing node above them, not a merge.
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Set 1, kg 100, Reps 8, completed',
        ),
        findsOneWidget,
      );
    });

    testWidgets('stays operable at 200% text scale', (tester) async {
      await makeExercise('bench', name: 'Bench Press');
      await startWith('bench');

      await pumpSession(tester, textScale: 2);

      // No overflow, and every control still on screen (`F-A11Y-002`).
      expect(tester.takeException(), isNull);
      expect(find.byType(Checkbox), findsOneWidget);
      expect(
        find.descendant(of: find.byType(SetRow), matching: find.text('1')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(SetRow),
          matching: find.byKey(const ValueKey('value-cell-weight')),
        ),
        findsOneWidget,
      );
    });
  });

  group('ghost values (F-LOG-004)', () {
    testWidgets('shows last time in the display unit, with the unit', (
      tester,
    ) async {
      await makeExercise('bench', name: 'Bench Press');
      await logPreviousSession('bench', [
        (weight: 100000, reps: 8, type: SetType.working),
      ]);
      await startWith('bench');

      await pumpSession(tester);

      expect(find.text('100 kg × 8'), findsOneWidget);
    });

    testWidgets('a first-ever session shows an empty ghost, not a zero', (
      tester,
    ) async {
      await makeExercise('bench', name: 'Bench Press');
      await startWith('bench');

      await pumpSession(tester);

      expect(find.text('—'), findsOneWidget);
      expect(find.text('0 kg × 0'), findsNothing);
    });

    testWidgets('completing an empty set adopts the ghost in one tap', (
      tester,
    ) async {
      await makeExercise('bench', name: 'Bench Press');
      await logPreviousSession('bench', [
        (weight: 100000, reps: 8, type: SetType.working),
      ]);
      final we = await startWith('bench');

      await pumpSession(tester);
      // One tap — the acceptance criterion in `F-LOG-003`.
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      final stored = (await sets.getSets(we)).single;
      expect(stored.isCompleted, isTrue);
      expect(stored.weightGrams, 100000);
      expect(stored.reps, 8);
    });

    testWidgets('a typed value is never overwritten by the ghost', (
      tester,
    ) async {
      await makeExercise('bench', name: 'Bench Press');
      await logPreviousSession('bench', [
        (weight: 100000, reps: 8, type: SetType.working),
      ]);
      final we = await startWith('bench');
      await sets.updateValues(
        (await sets.getSets(we)).single.id,
        weightGrams: const Value(105000),
      );

      await pumpSession(tester);
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      final stored = (await sets.getSets(we)).single;
      expect(stored.weightGrams, 105000);
      // The empty field still adopts.
      expect(stored.reps, 8);
    });

    testWidgets('a warm-up does not take the working set\'s ghost', (
      tester,
    ) async {
      await makeExercise('bench', name: 'Bench Press');
      await logPreviousSession('bench', [
        (weight: 100000, reps: 8, type: SetType.working),
      ]);
      final we = await startWith('bench');
      await sets.setType((await sets.getSets(we)).single.id, SetType.warmup);

      await pumpSession(tester);

      // Last time's working set is not a target for today's warm-up
      // (`F-LOG-004` §6).
      expect(find.text('100 kg × 8'), findsNothing);
      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('follows the display unit setting', (tester) async {
      await makeExercise('bench', name: 'Bench Press');
      await logPreviousSession('bench', [
        (weight: 100000, reps: 8, type: SetType.working),
      ]);
      await startWith('bench');

      await pumpSession(tester, prefs: {'units.load': 'lb'});

      // 100 kg is 220.462 lb; displaying it is right, storing it back is not
      // (docs/22-UNITS.md §rounding).
      expect(find.text('220.5 lb × 8'), findsOneWidget);
      expect(find.text('lb'), findsOneWidget);
    });
  });

  group('set types (F-LOG-005)', () {
    testWidgets('a long-press makes a set a warm-up, and renumbers', (
      tester,
    ) async {
      await makeExercise('bench', name: 'Bench Press');
      final we = await startWith('bench');
      await sets.addSet(we);
      await pumpSession(tester);

      await tester.longPress(
        find.descendant(
          of: find.byType(SetRow).first,
          matching: find.text('1'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Warm-up'));
      await tester.pumpAndSettle();

      // Warm-ups are numbered apart, so the working set below becomes 1
      // (`F-LOG-005` §3).
      expect(find.text('W1'), findsOneWidget);
      expect(
        find.descendant(of: find.byType(SetRow).last, matching: find.text('1')),
        findsOneWidget,
      );
      expect(find.text('2'), findsNothing);
      expect((await sets.getSets(we)).first.setType, SetType.warmup);
    });
  });

  group('the keypad (F-LOG-006)', () {
    testWidgets('tapping a value opens the keypad, not the system keyboard', (
      tester,
    ) async {
      await makeExercise('bench', name: 'Bench Press');
      await startWith('bench');
      await pumpSession(tester);

      await tester.tap(find.byKey(const ValueKey('value-cell-weight')));
      await tester.pumpAndSettle();

      expect(find.text('Clear'), findsOneWidget);
      // No text field anywhere: the system keyboard covers the set list and
      // has targets too small for imprecise thumbs (`F-LOG-006`).
      expect(find.byType(EditableText), findsNothing);
    });

    testWidgets('digits write through immediately', (tester) async {
      await makeExercise('bench', name: 'Bench Press');
      final we = await startWith('bench');
      await pumpSession(tester);

      await tester.tap(find.byKey(const ValueKey('value-cell-weight')));
      await tester.pumpAndSettle();
      for (final digit in ['1', '0', '0']) {
        await tester.tap(find.widgetWithText(FilledButton, digit).last);
        await tester.pump();
      }

      // No "save" step — an app kill mid-entry must not lose the number
      // (`F-LOG-003` §7).
      expect((await sets.getSets(we)).single.weightGrams, 100000);
    });

    testWidgets('the stepper moves by the equipment\'s increment', (
      tester,
    ) async {
      await makeExercise('bench', name: 'Bench Press');
      final we = await startWith('bench');
      await sets.updateValues(
        (await sets.getSets(we)).single.id,
        weightGrams: const Value(100000),
      );
      await pumpSession(tester);

      await tester.tap(find.byKey(const ValueKey('value-cell-weight')));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Increase'));
      await tester.pumpAndSettle();

      expect((await sets.getSets(we)).single.weightGrams, Mass.kg(102.5).grams);
    });

    testWidgets('switching field keeps the keypad open', (tester) async {
      await makeExercise('bench', name: 'Bench Press');
      final we = await startWith('bench');
      await pumpSession(tester);

      await tester.tap(find.byKey(const ValueKey('value-cell-weight')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reps').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, '8').last);
      await tester.pump();

      expect(find.text('Clear'), findsOneWidget);
      expect((await sets.getSets(we)).single.reps, 8);
    });
  });

  group('per-set notes (F-LOG-023)', () {
    testWidgets('a note is entered from the row and marked on it', (
      tester,
    ) async {
      await makeExercise('bench', name: 'Bench Press');
      final we = await startWith('bench');
      await pumpSession(tester);

      expect(find.byIcon(Icons.sticky_note_2_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.sticky_note_2_outlined));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Left shoulder twinged');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect((await sets.getSets(we)).single.notes, 'Left shoulder twinged');
      // Findable later without opening it (`F-LOG-023` §3).
      expect(find.byIcon(Icons.sticky_note_2), findsOneWidget);
    });
  });

  group('per-side weight entry (F-LOG-017)', () {
    Future<void> makeDumbbellCurl() => makeExercise(
      'curl',
      name: 'Dumbbell Curl',
      equipment: Equipment.dumbbell,
      weightEntryMode: WeightEntryMode.perSide,
    );

    testWidgets('the header marks the entry mode', (tester) async {
      await makeDumbbellCurl();
      await startWith('curl');
      await pumpSession(tester);

      expect(find.text('kg/side'), findsOneWidget);
    });

    testWidgets('typed digits store doubled total, and read back halved', (
      tester,
    ) async {
      await makeDumbbellCurl();
      final we = await startWith('curl');
      await pumpSession(tester);

      await tester.tap(find.byKey(const ValueKey('value-cell-weight')));
      await tester.pumpAndSettle();
      for (final digit in ['2', '0']) {
        await tester.tap(find.widgetWithText(FilledButton, digit).last);
        await tester.pump();
      }

      // Typed "20" per side stores 40 kg total (`F-LOG-017` §1, §3).
      expect((await sets.getSets(we)).single.weightGrams, Mass.kg(40).grams);

      await tester.tap(find.byTooltip('Done'));
      await tester.pumpAndSettle();

      // ...and the row reads it straight back as "20", not "40"
      // (`F-LOG-017` §3).
      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('the stepper moves the per-side value, doubling the total', (
      tester,
    ) async {
      await makeDumbbellCurl();
      final we = await startWith('curl');
      await sets.updateValues(
        (await sets.getSets(we)).single.id,
        weightGrams: const Value(40000), // 20 kg/side, 40 kg total
      );
      await pumpSession(tester);

      await tester.tap(find.byKey(const ValueKey('value-cell-weight')));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Increase'));
      await tester.pumpAndSettle();

      // Dumbbell's default step (2 kg) applies in the per-side domain the
      // buffer is now in, so the total moves by twice that (`F-LOG-006` §2,
      // `F-LOG-017` §3).
      expect((await sets.getSets(we)).single.weightGrams, Mass.kg(44).grams);
    });

    testWidgets('the ghost halves the same way', (tester) async {
      await makeDumbbellCurl();
      await logPreviousSession('curl', [
        (weight: 40000, reps: 10, type: SetType.working),
      ]);
      await startWith('curl');
      await pumpSession(tester);

      expect(find.textContaining('20 kg/side'), findsOneWidget);
    });
  });

  group('RPE (F-LOG-014)', () {
    testWidgets('hidden entirely when the setting is off', (tester) async {
      await makeExercise('bench', name: 'Bench Press');
      await startWith('bench');
      await pumpSession(tester);

      expect(find.byKey(const ValueKey('rpe-cell')), findsNothing);
    });

    testWidgets('logging a value writes through and shows on the row', (
      tester,
    ) async {
      await makeExercise('bench', name: 'Bench Press');
      final we = await startWith('bench');
      await pumpSession(tester, prefs: {'rpe.enabled': true});

      await tester.tap(find.byKey(const ValueKey('rpe-cell')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('8.5'));
      await tester.pumpAndSettle();

      expect((await sets.getSets(we)).single.rpe, 8.5);
      expect(find.text('8.5'), findsOneWidget);
    });

    testWidgets('the RIR setting shows the converted value, not RPE', (
      tester,
    ) async {
      await makeExercise('bench', name: 'Bench Press');
      final we = await startWith('bench');
      await sets.setRpe((await sets.getSets(we)).single.id, 8.0);
      await pumpSession(
        tester,
        prefs: {'rpe.enabled': true, 'rpe.displayMode': 'rir'},
      );

      // 10 − 8 = 2 RIR (`F-LOG-014` §2), never re-stored as anything but RPE.
      expect(find.text('2'), findsOneWidget);
      expect((await sets.getSets(we)).single.rpe, 8.0);
    });
  });
}
