import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../io/backup_service.dart';
import '../io/csv_export_service.dart';
import '../io/json_dump_service.dart';
import '../io/json_export_service.dart';
import '../io/restore_service.dart';
import '../repositories/body_measurement_repository.dart';
import '../repositories/exercise_repository.dart';
import '../repositories/personal_record_repository.dart';
import '../repositories/plate_repository.dart';
import '../repositories/routine_repository.dart';
import '../repositories/set_repository.dart';
import '../repositories/workout_repository.dart';
import '../seed/demo_data_seeder.dart';
import 'app_database.dart';
import 'table_snapshot_io.dart';

/// The single database instance.
///
/// Overridden in tests with an in-memory executor; features never construct
/// their own.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// The only route features have to the exercise catalogue. Screens depend on
/// this, never on `AppDatabase` directly — that seam is what keeps them
/// testable and lets storage change without rewriting them
/// (docs/20-ARCHITECTURE.md).
final exerciseRepositoryProvider = Provider<ExerciseRepository>(
  (ref) => ExerciseRepository(ref.watch(databaseProvider)),
);

/// Sessions and everything hanging off them (`F-LOG-001`, `F-LOG-002`,
/// `F-LOG-007`).
final workoutRepositoryProvider = Provider<WorkoutRepository>(
  (ref) => WorkoutRepository(ref.watch(databaseProvider)),
);

/// The `sets` table — the app's hot path (`F-LOG-003`–`F-LOG-006`,
/// `F-LOG-023`).
final setRepositoryProvider = Provider<SetRepository>(
  (ref) => SetRepository(ref.watch(databaseProvider)),
);

/// Bodyweight and future body measurements (`F-BOD-001`).
final bodyMeasurementRepositoryProvider = Provider<BodyMeasurementRepository>(
  (ref) => BodyMeasurementRepository(ref.watch(databaseProvider)),
);

/// The rescue-artefact JSON dump (`F-DAT-011`).
final jsonDumpServiceProvider = Provider<JsonDumpService>(
  (ref) => JsonDumpService(ref.watch(databaseProvider)),
);

/// Routines, their days, and per-exercise targets (`F-ROU-001`–`F-ROU-003`).
final routineRepositoryProvider = Provider<RoutineRepository>(
  (ref) => RoutineRepository(ref.watch(databaseProvider)),
);

/// The `personal_records` cache (`F-LOG-013`).
final personalRecordRepositoryProvider = Provider<PersonalRecordRepository>(
  (ref) => PersonalRecordRepository(ref.watch(databaseProvider)),
);

/// Bars and the plate inventory (`F-PLT-002`).
final plateRepositoryProvider = Provider<PlateRepository>(
  (ref) => PlateRepository(ref.watch(databaseProvider)),
);

/// Debug-only sample history for exercising the analytics screens without
/// hand-logging workouts (Settings › Data, `kDebugMode` gated).
final demoDataSeederProvider = Provider<DemoDataSeeder>(
  (ref) => DemoDataSeeder(ref.watch(databaseProvider)),
);

/// Generic whole-database delete/reinsert shared by restore and wipe
/// (`F-DAT-004`, `F-DAT-010`).
final tableSnapshotIoProvider = Provider<TableSnapshotIo>(
  (ref) => TableSnapshotIo(ref.watch(databaseProvider)),
);

/// The designed, versioned, round-trip-guaranteed export (`F-DAT-001`).
final jsonExportServiceProvider = Provider<JsonExportService>(
  (ref) => JsonExportService(ref.watch(databaseProvider)),
);

/// The single-file backup a user keeps (`F-DAT-003`).
final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(ref.watch(jsonExportServiceProvider)),
);

/// Restore from a backup file (`F-DAT-004`).
final restoreServiceProvider = Provider<RestoreService>(
  (ref) => RestoreService(
    ref.watch(databaseProvider),
    ref.watch(backupServiceProvider),
    ref.watch(tableSnapshotIoProvider),
  ),
);

/// Human-readable CSVs for spreadsheets — sets, measurements, routines
/// (`F-DAT-002`).
final csvExportServiceProvider = Provider<CsvExportService>(
  (ref) => CsvExportService(
    ref.watch(setRepositoryProvider),
    ref.watch(bodyMeasurementRepositoryProvider),
    ref.watch(routineRepositoryProvider),
  ),
);
