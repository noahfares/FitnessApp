import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// `Override` is not in the main barrel in Riverpod 3.
import 'package:flutter_riverpod/misc.dart' show Override;

import 'package:fitness_app/core/routing/app_routes.dart';
import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/platform/health_service.dart';
import 'package:fitness_app/data/repositories/body_measurement_repository.dart';
import 'package:fitness_app/data/repositories/set_repository.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';
import 'package:fitness_app/features/health/application/health_providers.dart';
import 'package:fitness_app/features/health/application/health_sync.dart';
import 'package:drift/drift.dart' show Value;

import '../../support/harness.dart';

/// A [HealthService] that records instead of talking to a platform.
///
/// [granted] and [available] are the two states every method has to survive:
/// the spec is explicit that a refusal is a working state, not a failure
/// (`F-HLT-001` §2–§3).
class FakeHealthService implements HealthService {
  FakeHealthService({this.granted = true, this.entries = const []});

  bool granted;
  List<({DateTime measuredAt, int grams})> entries;

  final List<({DateTime start, DateTime end, String? title})> written = [];
  final List<({DateTime start, DateTime end})> deleted = [];
  int permissionRequests = 0;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<bool> requestPermissions({required bool read}) async {
    permissionRequests++;
    return granted;
  }

  @override
  Future<bool> hasPermissions({required bool read}) async => granted;

  @override
  Future<bool> writeWorkout({
    required DateTime start,
    required DateTime end,
    String? title,
  }) async {
    if (!granted) return false;
    written.add((start: start, end: end, title: title));
    return true;
  }

  @override
  Future<bool> deleteWorkout({
    required DateTime start,
    required DateTime end,
  }) async {
    deleted.add((start: start, end: end));
    return true;
  }

  @override
  Future<List<({DateTime measuredAt, int grams})>> readBodyweight({
    required DateTime from,
    required DateTime to,
  }) async => granted ? entries : const [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late FakeHealthService health;

  setUp(() {
    db = testDatabase();
    health = FakeHealthService();
  });

  List<Override> overrides() => [
    healthServiceProvider.overrideWithValue(health),
  ];

  group('writing workouts (F-HLT-001)', () {
    test('nothing is written before consent', () async {
      final written = await writeWorkoutToHealth(
        health,
        enabled: false,
        start: DateTime(2026, 3, 1, 10),
        end: DateTime(2026, 3, 1, 11),
      );

      expect(written, isFalse);
      expect(health.written, isEmpty);
    });

    test('a revoked permission degrades to doing nothing', () async {
      health.granted = false;

      final written = await writeWorkoutToHealth(
        health,
        enabled: true,
        start: DateTime(2026, 3, 1, 10),
        end: DateTime(2026, 3, 1, 11),
      );

      // No throw, no retry, no user-visible failure: the local record is
      // authoritative and always was (§3).
      expect(written, isFalse);
      expect(health.written, isEmpty);
    });

    test('an enabled, permitted write carries the session window', () async {
      final start = DateTime(2026, 3, 1, 10);
      final end = DateTime(2026, 3, 1, 11, 15);

      final written = await writeWorkoutToHealth(
        health,
        enabled: true,
        start: start,
        end: end,
        title: 'Push A',
      );

      expect(written, isTrue);
      expect(health.written.single.start, start);
      expect(health.written.single.end, end);
      expect(health.written.single.title, 'Push A');
    });

    testWidgets('finishing a session writes it, without blocking the summary', (
      tester,
    ) async {
      await db
          .into(db.exercises)
          .insert(
            ExercisesCompanion.insert(
              id: 'bench',
              name: 'Bench Press',
              primaryMuscle: Muscle.chest,
              equipment: Equipment.barbell,
              trackingType: TrackingType.weightReps,
              createdAt: 1,
              updatedAt: 1,
            ),
          );
      final workouts = WorkoutRepository(db);
      final workout = await workouts.start(name: 'Push A');
      await workouts.addExercises(workout.id, ['bench']);
      final sets = SetRepository(db);
      final we = (await workouts.watchExercises(workout.id).first)
          .single
          .workoutExerciseId;
      final set = (await sets.getSets(we)).single;
      await sets.complete(
        set.id,
        weightGrams: const Value(100000),
        reps: const Value(5),
      );

      await pumpApp(
        tester,
        db: db,
        startAt: AppRoutes.activeWorkout,
        prefs: {healthWriteEnabledKey: true},
        overrides: overrides(),
      );

      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();

      expect(find.text('Workout complete'), findsOneWidget);
      expect(health.written, hasLength(1));
      expect(health.written.single.title, 'Push A');
    });
  });

  group('reading bodyweight (F-HLT-002)', () {
    test('an entry you logged yourself is never overwritten', () async {
      final repo = BodyMeasurementRepository(db);
      final day = DateTime(2026, 3, 1, 7);
      await repo.logBodyweight(grams: 80000, measuredAt: day);

      health.entries = [
        (measuredAt: DateTime(2026, 3, 1, 21), grams: 81500),
        (measuredAt: DateTime(2026, 3, 2, 7), grams: 80700),
      ];

      final result = await importBodyweightFromHealth(
        health,
        repo,
        from: DateTime(2026, 2, 1),
        to: DateTime(2026, 4, 1),
      );

      expect(result.imported, 1);
      expect(result.skipped, 1);

      final history = await repo.watchBodyweightHistory().first;
      final first = history.firstWhere(
        (m) => DateTime.fromMillisecondsSinceEpoch(m.measuredAt).day == 1,
      );
      expect(first.valueCanonical, 80000, reason: 'the local entry stands');
    });

    test('no permission imports nothing rather than failing', () async {
      health
        ..granted = false
        ..entries = [(measuredAt: DateTime(2026, 3, 2), grams: 80000)];

      final result = await importBodyweightFromHealth(
        health,
        BodyMeasurementRepository(db),
        from: DateTime(2026, 2, 1),
        to: DateTime(2026, 4, 1),
      );

      expect(result.imported, 0);
    });
  });

  group('the settings screen', () {
    testWidgets('both switches start off and ask in context', (tester) async {
      final container = await pumpApp(
        tester,
        db: db,
        startAt: AppRoutes.settingsHealth,
        overrides: overrides(),
      );

      expect(container.read(healthWriteEnabledProvider), isFalse);
      expect(container.read(healthReadEnabledProvider), isFalse);
      // Nothing was asked for on the way in — permission is requested when the
      // switch is flipped, never at launch (§2).
      expect(health.permissionRequests, 0);

      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      expect(health.permissionRequests, 1);
      expect(container.read(healthWriteEnabledProvider), isTrue);
    });

    testWidgets('a refused permission leaves the switch off, and says so', (
      tester,
    ) async {
      health.granted = false;
      final container = await pumpApp(
        tester,
        db: db,
        startAt: AppRoutes.settingsHealth,
        overrides: overrides(),
      );

      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      expect(container.read(healthWriteEnabledProvider), isFalse);
      expect(find.textContaining('Permission was not granted'), findsOneWidget);
    });
  });
}
