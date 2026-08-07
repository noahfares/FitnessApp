import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitness_app/features/settings/application/theme_provider.dart';
import 'package:fitness_app/features/settings/application/unit_preferences_provider.dart';

import '../../support/harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> containerWith(Map<String, Object> stored) async {
    SharedPreferences.setMockInitialValues(stored);
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('theme mode', () {
    test('defaults to following the system', () async {
      final container = await containerWith({});
      expect(container.read(themeModeProvider), ThemeMode.system);
    });

    test('restores a stored choice', () async {
      final container = await containerWith({'appearance.themeMode': 'dark'});
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    test('setting persists', () async {
      final container = await containerWith({});
      await container.read(themeModeProvider.notifier).set(ThemeMode.light);

      expect(container.read(themeModeProvider), ThemeMode.light);
      final raw = await SharedPreferences.getInstance();
      expect(raw.getString('appearance.themeMode'), 'light');
    });

    test(
      'an unrecognised stored value falls back rather than throwing',
      () async {
        final container = await containerWith({
          'appearance.themeMode': 'sepia',
        });
        expect(container.read(themeModeProvider), ThemeMode.system);
      },
    );
  });

  group('dynamic colour (F-THM-003)', () {
    test('defaults off', () async {
      final container = await containerWith({});
      expect(container.read(dynamicColorEnabledProvider), isFalse);
    });

    test('restores a stored choice', () async {
      final container = await containerWith({'appearance.dynamicColor': true});
      expect(container.read(dynamicColorEnabledProvider), isTrue);
    });

    test('setting persists', () async {
      final container = await containerWith({});
      await container.read(dynamicColorEnabledProvider.notifier).set(true);

      expect(container.read(dynamicColorEnabledProvider), isTrue);
      final raw = await SharedPreferences.getInstance();
      expect(raw.getBool('appearance.dynamicColor'), isTrue);
    });
  });

  group('applied to the app', () {
    testWidgets('changing the mode re-themes without a restart', (
      tester,
    ) async {
      final container = await pumpApp(
        tester,
        db: testDatabase(),
        prefs: {'appearance.themeMode': 'light'},
      );

      MaterialApp app() => tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app().themeMode, ThemeMode.light);

      await container.read(themeModeProvider.notifier).set(ThemeMode.dark);
      await tester.pumpAndSettle();

      expect(app().themeMode, ThemeMode.dark);
      expect(app().theme, isNotNull);
      expect(app().darkTheme, isNotNull);
    });
  });
}
