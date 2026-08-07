import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/platform/export_sharer.dart';
import 'package:fitness_app/features/settings/presentation/data_screen.dart';

import '../../support/harness.dart';

/// Batch 1.8 — `F-DAT-011`.
void main() {
  testWidgets('exporting writes a dump and hands it to the share sheet', (
    tester,
  ) async {
    final fakeSharer = FakeExportSharer();
    await pumpScreen(
      tester,
      const DataScreen(),
      overrides: [exportSharerProvider.overrideWithValue(fakeSharer)],
    );

    // The export writes a real file via dart:io, which runs on the genuine
    // event loop rather than flutter_test's simulated one. The tap itself
    // has to happen inside `runAsync` too — every `await` inside `_export`
    // is bound to whichever zone it was invoked from, so triggering it from
    // the ordinary fake-async zone and only entering `runAsync` afterwards
    // leaves it permanently stuck.
    await tester.runAsync(() async {
      await tester.tap(find.text('Export data (.json)'));
      var attempts = 0;
      while (fakeSharer.sharedFile == null && attempts < 200) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        attempts++;
      }
    });
    await tester.pump();

    expect(fakeSharer.sharedFile, isNotNull);
    expect(fakeSharer.sharedFile!.existsSync(), isTrue);
    expect(fakeSharer.subject, 'FitnessApp export');

    final contents = fakeSharer.sharedFile!.readAsStringSync();
    expect(contents, contains('"schemaVersion"'));
    expect(contents, contains('"tables"'));

    fakeSharer.sharedFile!.deleteSync();
  });
}
