import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/features/settings/presentation/about_screen.dart';

import '../../support/harness.dart';

/// F-SET-009 — About: version/build, licences, repository link.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows the version and build read from the package', (
    tester,
  ) async {
    await pumpScreen(tester, const AboutScreen());

    // FakeAppInfoService (test/support/harness.dart) fixes this pair, proving
    // the screen reads it rather than a compile-time constant (F-REL-005).
    expect(find.text('0.0.0 (build 0)'), findsOneWidget);
  });

  testWidgets('offers the repository link and open-source licences', (
    tester,
  ) async {
    await pumpScreen(tester, const AboutScreen());

    expect(find.text('Source code'), findsOneWidget);
    expect(
      find.text('https://github.com/noahfares/fitnessapp'),
      findsOneWidget,
    );

    await tester.tap(find.text('Open-source licences'));
    await tester.pumpAndSettle();

    expect(find.byType(LicensePage), findsOneWidget);
  });

  testWidgets('states the privacy position', (tester) async {
    await pumpScreen(tester, const AboutScreen());

    expect(
      find.textContaining('No account. No server. No telemetry.'),
      findsOneWidget,
    );
  });
}
