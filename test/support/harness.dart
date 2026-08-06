/// The standard widget-test setup, in one place.
///
/// Every screen test needs the same four overrides, and two of them are traps
/// that cost a debugging round trip each time they are rediscovered:
///
/// - **The locale defaults to `en_US`**, which makes `UnitPreferences` imperial
///   on first run (`F-SET-001`). A test asserting `100 kg` then fails against
///   `220.5 lb` for reasons that have nothing to do with what it is testing.
/// - **A live clock never settles.** `clockTickProvider` emits once a second,
///   so `pumpAndSettle` spins forever unless it is pinned (`F-LOG-007`).
///
/// Tests that are *about* those things override them back explicitly, which
/// then reads as the deliberate choice it is.
library;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// `Override` is not in the main barrel in Riverpod 3.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitness_app/app.dart';
import 'package:fitness_app/core/theme/app_theme.dart';
import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/database_provider.dart';
import 'package:fitness_app/features/logging/application/active_workout_providers.dart';
import 'package:fitness_app/features/settings/application/unit_preferences_provider.dart';

/// A fresh in-memory database, closed when the test ends.
///
/// Each test gets its own: sharing one would make ordering matter, and a suite
/// where test order matters is a suite that fails on a machine that is not
/// yours.
AppDatabase testDatabase() {
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  return db;
}

/// A container wired to [db], with the traps above disarmed.
///
/// [now] pins the clock. [country] drives the first-run unit defaults — null is
/// metric, `'US'` imperial. [prefs] seeds `SharedPreferences`, whose stored
/// values win over the country default.
Future<ProviderContainer> testContainer({
  required AppDatabase db,
  DateTime? now,
  String? country,
  Map<String, Object> prefs = const {},
  List<Override> overrides = const [],
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final preferences = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      databaseProvider.overrideWithValue(db),
      localeProvider.overrideWithValue('en_US'),
      deviceCountryProvider.overrideWithValue(country),
      clockTickProvider.overrideWith(
        (ref) => Stream.value(now ?? DateTime.now()),
      ),
      // Caller overrides come last so they win.
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Pumps [screen] alone, with the app's theme — enough for anything that does
/// not navigate. Faster to reason about than the whole app, and a failure
/// points at the screen rather than at the router.
///
/// [textScale] drives `MediaQuery`, for the 200%-scale rule that set rows have
/// to hold to (`F-A11Y-002`).
Future<ProviderContainer> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  AppDatabase? db,
  DateTime? now,
  String? country,
  double textScale = 1,
  Map<String, Object> prefs = const {},
  List<Override> overrides = const [],
}) async {
  final container = await testContainer(
    db: db ?? testDatabase(),
    now: now,
    country: country,
    prefs: prefs,
    overrides: overrides,
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light(),
        home: textScale == 1
            ? screen
            : MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
                child: screen,
              ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

/// Pumps the real app, router and all — for anything that navigates.
///
/// [startAt] overrides where it opens, which is how kill recovery is tested
/// without a kill (`F-LOG-007`).
Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  required AppDatabase db,
  String? startAt,
  DateTime? now,
  String? country,
  Map<String, Object> prefs = const {},
  List<Override> overrides = const [],
}) async {
  final container = await testContainer(
    db: db,
    now: now,
    country: country,
    prefs: prefs,
    overrides: [
      if (startAt != null) startupLocationProvider.overrideWithValue(startAt),
      ...overrides,
    ],
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const FitnessApp()),
  );
  await tester.pumpAndSettle();
  return container;
}
