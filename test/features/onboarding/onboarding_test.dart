import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/routing/app_routes.dart';
import 'package:fitness_app/core/units/mass.dart';
import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/features/logging/application/active_workout_providers.dart';
import 'package:fitness_app/features/onboarding/application/onboarding_provider.dart';
import 'package:fitness_app/features/settings/application/theme_provider.dart';
import 'package:fitness_app/features/settings/application/unit_preferences_provider.dart';

import '../../support/harness.dart';

/// `F-SET-011` — first run: units, theme, an optional starter routine, and a
/// Skip on every one of them.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = testDatabase());

  group('where the app opens', () {
    test('a first run goes to onboarding, ahead of everything else', () {
      expect(
        startupLocationFor(null, onboardingSeen: false),
        AppRoutes.onboarding,
      );
      expect(startupLocationFor(null), AppRoutes.home);
    });
  });

  testWidgets('every step is skippable, and skipping is a complete answer', (
    tester,
  ) async {
    final container = await pumpApp(
      tester,
      db: db,
      startAt: AppRoutes.onboarding,
    );

    expect(find.text('Everything, free'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    // Landed on the dashboard, and the flag is set — a second launch does not
    // ask again (§2).
    expect(find.text('Ready to train?'), findsOneWidget);
    expect(container.read(onboardingSeenProvider), isTrue);
  });

  testWidgets('units and theme chosen here are the ones that stick', (
    tester,
  ) async {
    final container = await pumpApp(
      tester,
      db: db,
      startAt: AppRoutes.onboarding,
      // Metric by default here, so choosing lb below is a real change rather
      // than a re-selection of what was already set.
      country: 'GB',
    );

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(container.read(themeModeProvider), ThemeMode.dark);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('lb'));
    await tester.pumpAndSettle();

    final prefs = container.read(unitPreferencesProvider);
    expect(prefs.load, MassUnit.lb);
    // Bodyweight follows rather than asking a fourth question.
    expect(prefs.body, MassUnit.lb);
  });

  testWidgets('nothing is asked for that the app does not need', (
    tester,
  ) async {
    // §3 is the feature's actual point: no account, no email, no permission
    // prompt. Asserting the absence is the only way that stays true.
    await pumpApp(tester, db: db, startAt: AppRoutes.onboarding);

    for (final forbidden in [
      'Sign up',
      'Sign in',
      'Email',
      'Create account',
      'Allow notifications',
    ]) {
      expect(
        find.textContaining(forbidden),
        findsNothing,
        reason: '$forbidden has no place in a local-first app (F-SET-011 §3)',
      );
    }
  });
}
