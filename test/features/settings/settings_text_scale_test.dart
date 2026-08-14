import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/features/settings/presentation/about_screen.dart';
import 'package:fitness_app/features/settings/presentation/app_lock_screen.dart';
import 'package:fitness_app/features/settings/presentation/appearance_screen.dart';
import 'package:fitness_app/features/settings/presentation/data_screen.dart';
import 'package:fitness_app/features/settings/presentation/import_screen.dart';
import 'package:fitness_app/features/settings/presentation/plate_settings_screen.dart';
import 'package:fitness_app/features/settings/presentation/rest_timer_screen.dart';
import 'package:fitness_app/features/settings/presentation/settings_screen.dart';
import 'package:fitness_app/features/settings/presentation/units_screen.dart';

import '../../support/harness.dart';

/// F-A11Y-002 — the settings tree, screen by screen. Each is simple enough
/// on its own that a shared render-and-assert-no-overflow check is the
/// proportionate level of proof, rather than a dedicated fixture per screen.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final entry in <String, WidgetBuilder>{
    'Settings root': (_) => const SettingsScreen(),
    'Units': (_) => const UnitsScreen(),
    'Appearance': (_) => const AppearanceScreen(),
    'Rest timer': (_) => const RestTimerScreen(),
    'Data': (_) => const DataScreen(),
    'Import': (_) => const ImportScreen(),
    'Bars & plates': (_) => const PlateSettingsScreen(),
    'App lock': (_) => const AppLockScreen(),
    'About': (_) => const AboutScreen(),
  }.entries) {
    testWidgets('${entry.key} renders at 200% with no overflow', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        Builder(builder: entry.value),
        db: testDatabase(),
        textScale: 2.0,
      );

      expect(tester.takeException(), isNull);
    });
  }
}
