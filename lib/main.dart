import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/units/mass.dart';
import 'core/units/unit_preferences.dart';
import 'data/db/app_database.dart';
import 'data/db/database_provider.dart';
import 'data/io/backup_service.dart';
import 'data/io/json_export_service.dart';
import 'data/repositories/plate_repository.dart';
import 'data/repositories/workout_repository.dart';
import 'data/seed/exercise_seeder.dart';
import 'features/logging/application/active_workout_providers.dart';
import 'features/settings/application/unit_preferences_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Resolved before the first frame so unit preferences are synchronously
  // available to every widget that renders a number, rather than each one
  // handling a loading state for something that is ready in milliseconds.
  final sharedPreferences = await SharedPreferences.getInstance();

  final database = AppDatabase();

  // Seeding runs before the first frame so the catalogue is never briefly
  // empty. It is a no-op once the shipped seed version has been applied, so
  // this costs one indexed lookup on every launch after the first
  // (`F-CAT-001`).
  await ExerciseSeeder(
    database,
  ).seedIfNeeded(now: () => DateTime.now().millisecondsSinceEpoch);

  // First-run only, gated the same way as the exercise catalogue seed — see
  // `PlateRepository.seedDefaultsIfNeeded` (`F-PLT-002` §3). The load-unit
  // default mirrors `UnitPreferencesNotifier.build`'s own first-run inference,
  // since that provider isn't constructed yet at this point in startup.
  final storedLoadUnit = sharedPreferences.getString('units.load');
  final loadUnit =
      MassUnit.values.where((u) => u.name == storedLoadUnit).firstOrNull ??
      UnitPreferences.forCountry(
        PlatformDispatcher.instance.locale.countryCode,
      ).load;
  await PlateRepository(database).seedDefaultsIfNeeded(loadUnit);

  // Crash recovery is a query, not a serialised-state restore: any workout
  // with a null `ended_at` is still in progress, so the app simply opens there
  // (`F-LOG-007`). Resolved before the first frame, so recovery is not a
  // visible flash of the dashboard.
  final active = await WorkoutRepository(database).findActive();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        databaseProvider.overrideWithValue(database),
        startupLocationProvider.overrideWithValue(startupLocationFor(active)),
      ],
      child: const FitnessApp(),
    ),
  );

  // Fire-and-forget: never delays the first frame, and a failure here (full
  // disk, etc.) is not something launch should ever fail on (`F-DAT-008`).
  unawaited(
    BackupService(
      JsonExportService(database),
    ).maybeCreateAutomaticBackup().catchError((_) => null),
  );
}
