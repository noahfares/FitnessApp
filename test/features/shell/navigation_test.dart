import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/routing/app_router.dart';
import 'package:fitness_app/core/routing/app_routes.dart';
import 'package:fitness_app/features/shell/presentation/app_shell.dart';

import '../../support/harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('shell', () {
    testWidgets('shows five destinations', (tester) async {
      await pumpApp(tester, db: testDatabase());

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(AppShell.destinations.length, 5);
      for (final destination in AppShell.destinations) {
        if (destination.label == 'Start') {
          // The centre Start slot is a floating icon-only action (no visible
          // label, per the Apple-style redesign) — verified by semantics.
          expect(
            find.bySemanticsLabel('Start'),
            findsOneWidget,
            reason: 'Start slot missing an accessible label',
          );
          continue;
        }
        expect(
          find.text(destination.label),
          findsWidgets,
          reason: '${destination.label} tab missing',
        );
      }
    });

    testWidgets('starts on Home', (tester) async {
      await pumpApp(tester, db: testDatabase());
      expect(find.text('Home'), findsWidgets);
      expect(find.text('Ready to train?'), findsOneWidget);
    });

    testWidgets('tapping a destination switches branch', (tester) async {
      await pumpApp(tester, db: testDatabase());

      await tester.tap(find.byIcon(Icons.insights_outlined));
      await tester.pumpAndSettle();

      expect(find.text('No sessions yet'), findsOneWidget);
      expect(find.text('Ready to train?'), findsNothing);
    });

    testWidgets('tab state persists across switches', (tester) async {
      // The acceptance criterion for F-NAV-001: switching tabs must not lose
      // scroll position or a half-completed form. StatefulShellRoute.indexedStack
      // keeps every branch mounted, so the departed tab is still in the tree —
      // offstage, not rebuilt from scratch.
      await pumpApp(tester, db: testDatabase());
      expect(find.text('Ready to train?'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.insights_outlined));
      await tester.pumpAndSettle();

      // Not painted...
      expect(find.text('Ready to train?'), findsNothing);
      // ...but still mounted, which is what preserves its state.
      expect(find.text('Ready to train?', skipOffstage: false), findsOneWidget);

      await tester.tap(find.byIcon(Icons.home_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Ready to train?'), findsOneWidget);
    });

    testWidgets('settings pushes over the shell and pops back', (tester) async {
      await pumpApp(tester, db: testDatabase());

      // Settings is a flush row at the bottom of Home now, not an AppBar
      // action — scroll it into view before tapping.
      await tester.scrollUntilVisible(
        find.text('Settings'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Units'), findsOneWidget);

      // Pushed, not replaced — so the shell and its branch are still beneath.
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Ready to train?'), findsOneWidget);
    });
  });

  group('routing', () {
    testWidgets('settings routes resolve', (tester) async {
      final container = await pumpApp(tester, db: testDatabase());
      final router = container.read(routerProvider);

      for (final route in [
        AppRoutes.settingsUnits,
        AppRoutes.settingsAppearance,
        AppRoutes.settingsAbout,
      ]) {
        router.go(route);
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '$route threw on navigation',
        );
      }
    });

    testWidgets('an unknown deep link lands on a real screen, not a crash', (
      tester,
    ) async {
      // Deep links come from widgets, app shortcuts and notifications, so a
      // stale or mistyped URI is a realistic input, not a hypothetical.
      final container = await pumpApp(tester, db: testDatabase());
      container.read(routerProvider).go('/nonsense/route');
      await tester.pumpAndSettle();

      expect(find.text('Not found'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('settings screens', () {
    testWidgets('units screen changes a unit and the preview follows', (
      tester,
    ) async {
      final container = await pumpApp(
        tester,
        db: testDatabase(),
        prefs: {'units.load': 'kg'},
      );
      container.read(routerProvider).go(AppRoutes.settingsUnits);
      await tester.pumpAndSettle();

      expect(find.text('102.5 kg'), findsOneWidget);

      // Tap the "lb" segment of the first (Weights) control.
      await tester.tap(find.text('lb').first);
      await tester.pumpAndSettle();

      // Same stored grams, different rendering — F-SET-001's whole point.
      expect(find.text('226 lb'), findsOneWidget);
      expect(find.text('102.5 kg'), findsNothing);
    });

    testWidgets('appearance screen changes the theme mode', (tester) async {
      final container = await pumpApp(
        tester,
        db: testDatabase(),
        prefs: {'appearance.themeMode': 'light'},
      );
      container.read(routerProvider).go(AppRoutes.settingsAppearance);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
    });
  });
}
