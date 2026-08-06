import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/db/app_database.dart';
import 'data/db/database_provider.dart';
import 'data/seed/exercise_seeder.dart';
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

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        databaseProvider.overrideWithValue(database),
      ],
      child: const FitnessApp(),
    ),
  );
}
