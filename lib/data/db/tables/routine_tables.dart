import 'package:drift/drift.dart';

import 'catalog_tables.dart';
import 'shared.dart';

/// Groups routines — "Current block", "Archive" (`F-ROU-007`). Flat, one level.
class RoutineFolders extends Table with SyncColumns {
  TextColumn get name => text()();

  IntColumn get position => integer()();
}

/// A named container of days. Not itself startable (`F-ROU-001`).
class Routines extends Table with SyncColumns {
  TextColumn get name => text()();

  TextColumn get folderId =>
      text().named('folder_id').nullable().references(RoutineFolders, #id)();

  TextColumn get notes => text().nullable()();

  /// Explicit ordering. Never inferred from `createdAt` — that breaks the
  /// moment anything is reordered.
  IntColumn get position => integer()();

  IntColumn get archivedAt => integer().named('archived_at').nullable()();
}

/// One session's worth of planned exercises — "Push", "Pull" (`F-ROU-002`).
///
/// **This is what you start a workout from**, not the routine.
class RoutineDays extends Table with SyncColumns {
  TextColumn get routineId =>
      text().named('routine_id').references(Routines, #id)();

  TextColumn get name => text()();

  IntColumn get position => integer()();

  /// ISO weekday numbers (`F-ROU-012`).
  TextColumn get scheduledWeekdays => text()
      .named('scheduled_weekdays')
      .map(const IntListConverter())
      .withDefault(const Constant(''))();

  TextColumn get notes => text().nullable()();
}

/// A planned exercise within a day, with its targets (`F-ROU-003`).
class RoutineExercises extends Table with SyncColumns {
  TextColumn get routineDayId =>
      text().named('routine_day_id').references(RoutineDays, #id)();

  TextColumn get exerciseId =>
      text().named('exercise_id').references(Exercises, #id)();

  IntColumn get position => integer()();

  /// Same value = same superset (`F-ROU-005`). Null = standalone.
  TextColumn get groupId => text().named('group_id').nullable()();

  IntColumn get targetSets => integer().named('target_sets').nullable()();

  /// Rep **ranges**, not single numbers — real programming says 8-12, and
  /// collapsing that to one value is what makes most template features useless.
  IntColumn get targetRepsMin =>
      integer().named('target_reps_min').nullable()();

  IntColumn get targetRepsMax =>
      integer().named('target_reps_max').nullable()();

  IntColumn get targetWeightGrams =>
      integer().named('target_weight_grams').nullable()();

  RealColumn get targetRpe => real().named('target_rpe').nullable()();

  IntColumn get restSeconds => integer().named('rest_seconds').nullable()();

  /// JSON-serialised progression rule (`F-PRG-001`).
  TextColumn get progressionRule =>
      text().named('progression_rule').nullable()();

  TextColumn get notes => text().nullable()();
}
