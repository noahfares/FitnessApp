import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitness_app/app.dart';
import 'package:fitness_app/core/routing/app_router.dart';
import 'package:fitness_app/core/routing/app_routes.dart';
import 'package:fitness_app/features/settings/application/unit_preferences_provider.dart';
import 'package:fitness_app/features/shell/presentation/app_shell.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> pumpApp(
    WidgetTester tester, {
    Map<String, Object> stored = const {},
  }) async {
    SharedPreferences.setMockInitialValues(stored);
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const FitnessApp(),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  group('shell', () {
    testWidgets('shows five destinations', (tester) async {
      await pumpApp(tester);

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(AppShell.destinations.length, 5);
      for (final destination in AppShell.destinations) {
        expect(
          find.text(destination.label),
          findsWidgets,
          reason: '${destination.label} tab missing',
        );
      }
    });

    testWidgets('starts on Home', (tester) async {
      await pumpApp(tester);
      expect(find.text('Phase 0 complete'), findsOneWidget);
    });

    testWidgets('tapping a destination switches branch', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byIcon(Icons.insights_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Arrives in Phase 3'), findsOneWidget);
      expect(find.text('Phase 0 complete'), findsNothing);
    });

    testWidgets('tab state persists across switches', (tester) async {
      // The acceptance criterion for F-NAV-001: switching tabs must not lose
      // scroll position or a half-completed form. StatefulShellRoute.indexedStack
      // keeps every branch mounted, so the departed tab is still in the tree —
      // offstage, not rebuilt from scratch.
      await pumpApp(tester);
      expect(find.text('Phase 0 complete'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.insights_outlined));
      await tester.pumpAndSettle();

      // Not painted...
      expect(find.text('Phase 0 complete'), findsNothing);
      // ...but still mounted, which is what preserves its state.
      expect(
        find.text('Phase 0 complete', skipOffstage: false),
        findsOneWidget,
      );

      await tester.tap(find.byIcon(Icons.home_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Phase 0 complete'), findsOneWidget);
    });

    testWidgets('settings pushes over the shell and pops back', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Units'), findsOneWidget);

      // Pushed, not replaced — so the shell and its branch are still beneath.
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Phase 0 complete'), findsOneWidget);
    });
  });

  group('routing', () {
    testWidgets('settings routes resolve', (tester) async {
      final container = await pumpApp(tester);
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
      final container = await pumpApp(tester);
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
      final container = await pumpApp(tester, stored: {'units.load': 'kg'});
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
        stored: {'appearance.themeMode': 'light'},
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
