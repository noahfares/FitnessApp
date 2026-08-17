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
/// - **The rest timer schedules a real `Timer`.** Completing a set auto-starts
///   a rest (`F-TIM-002`), and a pending timer at the end of a test fails it
///   with "A Timer is still pending" — a message that says nothing about the
///   set row the test was actually exercising. [FakeRestTimerService] records
///   instead of scheduling.
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

import 'dart:io';

import 'package:fitness_app/app.dart';
import 'package:fitness_app/core/theme/app_theme.dart';
import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/database_provider.dart';
import 'package:fitness_app/data/platform/app_info_service.dart';
import 'package:fitness_app/data/platform/export_sharer.dart';
import 'package:fitness_app/data/platform/rest_timer_service.dart';
import 'package:fitness_app/domain/timing/rest_settings.dart';
import 'package:fitness_app/features/analytics/application/analytics_clock_provider.dart';
import 'package:fitness_app/features/logging/application/active_workout_providers.dart';
import 'package:fitness_app/features/settings/application/unit_preferences_provider.dart';
import 'package:fitness_app/features/timing/application/rest_timer_providers.dart';

/// A [RestTimerService] that schedules nothing and remembers everything.
///
/// [scheduledFor] is the last target it was handed, which is how a test asserts
/// that a rest of the right length was started without waiting for it.
class FakeRestTimerService implements RestTimerService {
  DateTime? scheduledFor;
  RestAlertStyle? style;
  int cancels = 0;

  @override
  Future<void> schedule({
    required DateTime firesAt,
    required RestAlertStyle style,
    Duration preWarning = Duration.zero,
    void Function()? onFired,
    void Function()? onWarning,
  }) async {
    scheduledFor = firesAt;
    this.style = style;
  }

  @override
  Future<void> cancel() async {
    scheduledFor = null;
    cancels++;
  }

  @override
  Future<bool> requestPermission() async => true;
}

/// An [ExportSharer] that records instead of invoking the real share-sheet
/// platform channel, which a widget test cannot exercise (`F-DAT-011`).
class FakeExportSharer implements ExportSharer {
  File? sharedFile;
  List<File>? sharedFiles;
  String? subject;

  @override
  Future<void> share(File file, {required String subject}) async {
    sharedFile = file;
    this.subject = subject;
  }

  @override
  Future<void> shareAll(List<File> files, {required String subject}) async {
    sharedFiles = files;
    this.subject = subject;
  }
}

/// An [AppInfoService] that returns a fixed value instead of hitting the
/// `package_info_plus` platform channel, which `flutter_test` cannot service
/// (`F-REL-005`, `F-SET-009`).
class FakeAppInfoService implements AppInfoService {
  const FakeAppInfoService();

  @override
  Future<AppVersionInfo> current() async =>
      const AppVersionInfo(version: '0.0.0', buildNumber: '0');
}

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
      // Pinned to the same instant as the display tick, so a rest started
      // during a test counts down from where the test thinks it is.
      restClockProvider.overrideWithValue(() => now ?? DateTime.now()),
      analyticsClockProvider.overrideWithValue(() => now ?? DateTime.now()),
      restTimerServiceProvider.overrideWithValue(FakeRestTimerService()),
      appInfoServiceProvider.overrideWithValue(const FakeAppInfoService()),
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
/// to hold to (`F-A11Y-002`); [disableAnimations] drives the same
/// `MediaQuery`'s reduce-motion flag (`F-A11Y-005`).
Future<ProviderContainer> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  AppDatabase? db,
  DateTime? now,
  String? country,
  double textScale = 1,
  bool dark = false,
  bool disableAnimations = false,
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
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        home: _withMediaQuery(
          screen,
          textScale: textScale,
          disableAnimations: disableAnimations,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

/// Presses and holds [finder] long enough to trigger a `HoldToConfirmButton`
/// (`F-LOG-022` §2) — a plain `tester.tap` releases immediately, which is
/// exactly the single-tap mis-fire the widget exists to refuse.
Future<void> holdToConfirm(WidgetTester tester, Finder finder) async {
  final gesture = await tester.startGesture(tester.getCenter(finder));
  // Several small pumps, not one big jump: a single multi-second `pump` does
  // not reliably drive `HoldToConfirmButton`'s `AnimationController` to
  // completion, even though its value is purely elapsed-time-based.
  for (var i = 0; i < 15; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
  await gesture.up();
  await tester.pumpAndSettle();
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
  double textScale = 1,
  bool disableAnimations = false,
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
    UncontrolledProviderScope(
      container: container,
      child: _withMediaQuery(
        const FitnessApp(),
        textScale: textScale,
        disableAnimations: disableAnimations,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

/// Wraps [child] only when something is actually being overridden.
///
/// An unconditional `MediaQuery` here would pin every other property to
/// `MediaQueryData()`'s defaults — a zero-size window among them — so the
/// wrapper has to stay opt-in rather than becoming the default environment
/// every screen test runs in.
Widget _withMediaQuery(
  Widget child, {
  required double textScale,
  required bool disableAnimations,
}) {
  if (textScale == 1 && !disableAnimations) return child;
  return Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScale),
        disableAnimations: disableAnimations,
      ),
      child: child,
    ),
  );
}
