import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app boots and renders in both schemes', (tester) async {
    // The dashboard (`F-NAV-004`) reads the database on the very first frame
    // now, so this smoke test needs the full harness rather than a bare
    // `ProviderScope`: an in-memory db closed in the wrong order relative to
    // its live query streams leaves a pending drift teardown timer that
    // trips flutter_test's "no pending timers" check. `pumpApp` disposes the
    // container (and with it every stream) before the database closes.
    await pumpApp(tester, db: testDatabase());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
