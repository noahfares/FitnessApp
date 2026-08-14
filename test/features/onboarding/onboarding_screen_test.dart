import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/routing/app_routes.dart';
import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/features/onboarding/application/onboarding_provider.dart';
import 'package:fitness_app/features/settings/application/unit_preferences_provider.dart';

import '../../support/harness.dart';

/// First-run onboarding (`F-SET-011`): units/theme, an optional starter
/// routine, and a `Skip` reachable from every page.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  testWidgets('skipping from the welcome page completes onboarding and '
      'lands on the dashboard', (tester) async {
    final container = await pumpApp(
      tester,
      db: db,
      startAt: AppRoutes.onboarding,
    );

    expect(find.text('Welcome to FitnessApp'), findsOneWidget);
    expect(container.read(onboardingCompletedProvider), isFalse);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Ready to train?'), findsOneWidget);
    expect(container.read(onboardingCompletedProvider), isTrue);
  });

  testWidgets('choosing a weight unit on the second page updates the shared '
      'preference, unprompted by anything onboarding-specific', (tester) async {
    final container = await pumpApp(
      tester,
      db: db,
      startAt: AppRoutes.onboarding,
    );

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Make it yours'), findsOneWidget);
    await tester.tap(find.text('lb'));
    await tester.pumpAndSettle();

    expect(container.read(unitPreferencesProvider).load.symbol, 'lb');
  });

  testWidgets(
    'importing a starter program on the last page finishes onboarding '
    'and opens the new routine',
    (tester) async {
      final container = await pumpApp(
        tester,
        db: db,
        startAt: AppRoutes.onboarding,
      );

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Want a starting point?'), findsOneWidget);
      await tester
          .tap(find.widgetWithText(FilledButton, 'Use this').first)
          .then((_) => tester.pumpAndSettle());

      expect(container.read(onboardingCompletedProvider), isTrue);
      final routines = await db.select(db.routines).get();
      expect(routines, hasLength(1));
      expect(find.text(routines.single.name), findsOneWidget);
    },
  );

  testWidgets('the final page reads Get started, not Continue', (tester) async {
    await pumpApp(tester, db: db, startAt: AppRoutes.onboarding);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);
  });
}
